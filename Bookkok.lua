local novel = {}

novel.name = "Bookkor (북코)"
novel.id = "bookkor"
novel.site = "https://bookkor.com"
novel.version = 1

-- 1. Scrapes the home catalog card blocks
function novel:popularNovels(page)
    local url = self.site .. "/?page=" .. page
    local html = http.get(url)
    local parse = cheerio.load(html)
    local list = {}

    parse:find("div.novel-card, article, div.list-item"):each(function(i, el)
        local a = el:find("a"):first()
        local path = a:attr("href"):gsub(self.site, "")
        local name = el:find("h3, .title, .novel-title"):text():trim()
        local cover = el:find("img"):attr("src")

        if name ~= "" and path ~= "" then
            table.insert(list, { name = name, path = path, cover = cover })
        end
    end)
    return list
end

-- 2. Extracts novel metadata structure info
function novel:parseNovel(novelPath)
    local html = http.get(self.site .. novelPath)
    local parse = cheerio.load(html)
    
    local data = {
        path = novelPath,
        name = parse:find("h1, .novel-title"):first():text():trim(),
        cover = parse:find(".novel-cover img, .cover img"):attr("src"),
        summary = parse:find(".novel-description, .summary"):text():trim(),
        chapters = {}
    }

    parse:find(".chapter-list a, .list-item a"):each(function(i, el)
        local path = el:attr("href"):gsub(self.site, "")
        if path ~= "" then
            table.insert(data.chapters, {
                name = el:text():trim(),
                path = path,
                chapterNumber = i + 1
            })
        end
    end)
    return data
end

-- 3. Targets and displays story page view text html
function novel:parseChapter(chapterPath)
    local html = http.get(self.site .. chapterPath)
    local parse = cheerio.load(html)
    
    local el = parse:find(".chapter-content, #novel-content, .viewer-text")
    el:find("script, style, ins, .banner"):remove()
    
    return el:html() or ""
end

return novel

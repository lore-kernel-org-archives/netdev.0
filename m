From: Joe Stringer <joe@ovn.org>
Subject: [PATCHv3 perf/core 4/6] tools perf util: Make rm_rf(path) argument const
Date: Thu, 26 Jan 2017 13:19:59 -0800
Message-ID: <20170126212001.14103-5-joe@ovn.org>
References: <20170126212001.14103-1-joe@ovn.org>
Cc: wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: acme@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170126212001.14103-1-joe@ovn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rm_rf() doesn't modify its path argument, and a future caller will pass
a string constant into it to delete.

Signed-off-by: Joe Stringer <joe@ovn.org>
---
v3: Initial post.
---
 tools/perf/util/util.c | 2 +-
 tools/perf/util/util.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/perf/util/util.c b/tools/perf/util/util.c
index bf29aed16bd6..d8b45cea54d0 100644
--- a/tools/perf/util/util.c
+++ b/tools/perf/util/util.c
@@ -85,7 +85,7 @@ int mkdir_p(char *path, mode_t mode)
 	return (stat(path, &st) && mkdir(path, mode)) ? -1 : 0;
 }
 
-int rm_rf(char *path)
+int rm_rf(const char *path)
 {
 	DIR *dir;
 	int ret = 0;
diff --git a/tools/perf/util/util.h b/tools/perf/util/util.h
index 6e8be174ec0b..c74708da8571 100644
--- a/tools/perf/util/util.h
+++ b/tools/perf/util/util.h
@@ -209,7 +209,7 @@ static inline int sane_case(int x, int high)
 }
 
 int mkdir_p(char *path, mode_t mode);
-int rm_rf(char *path);
+int rm_rf(const char *path);
 struct strlist *lsdir(const char *name, bool (*filter)(const char *, struct dirent *));
 bool lsdir_no_dot_filter(const char *name, struct dirent *d);
 int copyfile(const char *from, const char *to);
-- 
2.11.0

From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 10/14] tools perf util: Make rm_rf(path) argument const
Date: Wed,  1 Feb 2017 09:25:03 -0300
Message-ID: <20170201122507.29303-11-acme@kernel.org>
References: <20170201122507.29303-1-acme@kernel.org>
Cc: linux-kernel@vger.kernel.org, Joe Stringer <joe@ovn.org>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@redhat.com>
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170201122507.29303-1-acme@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Stringer <joe@ovn.org>

rm_rf() doesn't modify its path argument, and a future caller will pass
a string constant into it to delete.

Signed-off-by: Joe Stringer <joe@ovn.org>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Wang Nan <wangnan0@huawei.com>
Cc: netdev@vger.kernel.org
Link: http://lkml.kernel.org/r/20170126212001.14103-5-joe@ovn.org
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
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
2.9.3

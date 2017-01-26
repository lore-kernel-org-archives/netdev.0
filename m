From: Joe Stringer <joe@ovn.org>
Subject: [PATCHv3 perf/core 5/6] tools lib api fs: Add bpf_fs filesystem detector
Date: Thu, 26 Jan 2017 13:20:00 -0800
Message-ID: <20170126212001.14103-6-joe@ovn.org>
References: <20170126212001.14103-1-joe@ovn.org>
Cc: wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: acme@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170126212001.14103-1-joe@ovn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow mounting of the BPF filesystem at /sys/fs/bpf.

Signed-off-by: Joe Stringer <joe@ovn.org>
---
v3: Initial post.
---
 tools/lib/api/fs/fs.c | 16 ++++++++++++++++
 tools/lib/api/fs/fs.h |  1 +
 2 files changed, 17 insertions(+)

diff --git a/tools/lib/api/fs/fs.c b/tools/lib/api/fs/fs.c
index f99f49e4a31e..4b6bfc43cccf 100644
--- a/tools/lib/api/fs/fs.c
+++ b/tools/lib/api/fs/fs.c
@@ -38,6 +38,10 @@
 #define HUGETLBFS_MAGIC        0x958458f6
 #endif
 
+#ifndef BPF_FS_MAGIC
+#define BPF_FS_MAGIC           0xcafe4a11
+#endif
+
 static const char * const sysfs__fs_known_mountpoints[] = {
 	"/sys",
 	0,
@@ -75,6 +79,11 @@ static const char * const hugetlbfs__known_mountpoints[] = {
 	0,
 };
 
+static const char * const bpf_fs__known_mountpoints[] = {
+	"/sys/fs/bpf",
+	0,
+};
+
 struct fs {
 	const char		*name;
 	const char * const	*mounts;
@@ -89,6 +98,7 @@ enum {
 	FS__DEBUGFS = 2,
 	FS__TRACEFS = 3,
 	FS__HUGETLBFS = 4,
+	FS__BPF_FS = 5,
 };
 
 #ifndef TRACEFS_MAGIC
@@ -121,6 +131,11 @@ static struct fs fs__entries[] = {
 		.mounts = hugetlbfs__known_mountpoints,
 		.magic	= HUGETLBFS_MAGIC,
 	},
+	[FS__BPF_FS] = {
+		.name	= "bpf",
+		.mounts = bpf_fs__known_mountpoints,
+		.magic	= BPF_FS_MAGIC,
+	},
 };
 
 static bool fs__read_mounts(struct fs *fs)
@@ -280,6 +295,7 @@ FS(procfs,  FS__PROCFS);
 FS(debugfs, FS__DEBUGFS);
 FS(tracefs, FS__TRACEFS);
 FS(hugetlbfs, FS__HUGETLBFS);
+FS(bpf_fs, FS__BPF_FS);
 
 int filename__read_int(const char *filename, int *value)
 {
diff --git a/tools/lib/api/fs/fs.h b/tools/lib/api/fs/fs.h
index a63269f5d20c..6b332dc74498 100644
--- a/tools/lib/api/fs/fs.h
+++ b/tools/lib/api/fs/fs.h
@@ -22,6 +22,7 @@ FS(procfs)
 FS(debugfs)
 FS(tracefs)
 FS(hugetlbfs)
+FS(bpf_fs)
 
 #undef FS
 
-- 
2.11.0

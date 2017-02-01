From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 11/14] tools lib api fs: Add bpf_fs filesystem detector
Date: Wed,  1 Feb 2017 09:25:04 -0300
Message-ID: <20170201122507.29303-12-acme@kernel.org>
References: <20170201122507.29303-1-acme@kernel.org>
Cc: linux-kernel@vger.kernel.org, Joe Stringer <joe@ovn.org>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@redhat.com>
To: Ingo Molnar <mingo@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:48614 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752282AbdBAMZi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 07:25:38 -0500
In-Reply-To: <20170201122507.29303-1-acme@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@ovn.org>

Allow mounting of the BPF filesystem at /sys/fs/bpf.

Signed-off-by: Joe Stringer <joe@ovn.org>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Wang Nan <wangnan0@huawei.com>
Cc: netdev@vger.kernel.org
Link: http://lkml.kernel.org/r/20170126212001.14103-6-joe@ovn.org
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
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
2.9.3

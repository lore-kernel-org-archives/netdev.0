From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 024/115] sysctl: remove .child from fs/ntfs-debug
Date: Mon,  9 May 2011 00:38:36 +0200
Message-ID: <1304894407-32201-25-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 fs/ntfs/sysctl.c |   15 +++++----------
 1 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/fs/ntfs/sysctl.c b/fs/ntfs/sysctl.c
index 79a8918..da1293d 100644
--- a/fs/ntfs/sysctl.c
+++ b/fs/ntfs/sysctl.c
@@ -34,7 +34,7 @@
 #include "debug.h"
 
 /* Definition of the ntfs sysctl. */
-static ctl_table ntfs_sysctls[] = {
+static ctl_table ntfs_table[] = {
 	{
 		.procname	= "ntfs-debug",
 		.data		= &debug_msgs,		/* Data pointer and size. */
@@ -45,14 +45,9 @@ static ctl_table ntfs_sysctls[] = {
 	{}
 };
 
-/* Define the parent directory /proc/sys/fs. */
-static ctl_table sysctls_root[] = {
-	{
-		.procname	= "fs",
-		.mode		= 0555,
-		.child		= ntfs_sysctls
-	},
-	{}
+static const __initdata struct ctl_path ntfs_path[] = {
+	{ .procname = "fs" },
+	{ }
 };
 
 /* Storage for the sysctls header. */
@@ -68,7 +63,7 @@ int ntfs_sysctl(int add)
 {
 	if (add) {
 		BUG_ON(sysctls_root_table);
-		sysctls_root_table = register_sysctl_table(sysctls_root);
+		sysctls_root_table = register_sysctl_paths(ntfs_path, ntfs_table);
 		if (!sysctls_root_table)
 			return -ENOMEM;
 	} else {
-- 
1.7.5.134.g1c08b

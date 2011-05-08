From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 023/115] sysctl: remove .child from fs/nfs/ nfs_cb_table
Date: Mon,  9 May 2011 00:38:35 +0200
Message-ID: <1304894407-32201-24-git-send-email-lucian.grijincu@gmail.com>
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
 fs/nfs/sysctl.c |   22 +++++-----------------
 1 files changed, 5 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/sysctl.c b/fs/nfs/sysctl.c
index 978aaeb..046fe19 100644
--- a/fs/nfs/sysctl.c
+++ b/fs/nfs/sysctl.c
@@ -21,7 +21,7 @@ static const int nfs_set_port_max = 65535;
 #endif
 static struct ctl_table_header *nfs_callback_sysctl_table;
 
-static ctl_table nfs_cb_sysctls[] = {
+static ctl_table nfs_cb_table[] = {
 #ifdef CONFIG_NFS_V4
 	{
 		.procname = "nfs_callback_tcpport",
@@ -59,27 +59,15 @@ static ctl_table nfs_cb_sysctls[] = {
 	{ }
 };
 
-static ctl_table nfs_cb_sysctl_dir[] = {
-	{
-		.procname = "nfs",
-		.mode = 0555,
-		.child = nfs_cb_sysctls,
-	},
-	{ }
-};
-
-static ctl_table nfs_cb_sysctl_root[] = {
-	{
-		.procname = "fs",
-		.mode = 0555,
-		.child = nfs_cb_sysctl_dir,
-	},
+static const __initdata struct ctl_path nfs_cb_path[] = {
+	{ .procname = "fs" },
+	{ .procname = "nfs" },
 	{ }
 };
 
 int nfs_register_sysctl(void)
 {
-	nfs_callback_sysctl_table = register_sysctl_table(nfs_cb_sysctl_root);
+	nfs_callback_sysctl_table = register_sysctl_paths(nfs_cb_path, nfs_cb_table);
 	if (nfs_callback_sysctl_table == NULL)
 		return -ENOMEM;
 	return 0;
-- 
1.7.5.134.g1c08b

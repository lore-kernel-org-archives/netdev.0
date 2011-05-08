From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 041/115] sysctl: remove .child from s390dbf/
Date: Mon,  9 May 2011 00:38:53 +0200
Message-ID: <1304894407-32201-42-git-send-email-lucian.grijincu@gmail.com>
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
 arch/s390/kernel/debug.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/arch/s390/kernel/debug.c b/arch/s390/kernel/debug.c
index 5ad6bc0..384f67b 100644
--- a/arch/s390/kernel/debug.c
+++ b/arch/s390/kernel/debug.c
@@ -902,7 +902,7 @@ static struct ctl_table s390dbf_table[] = {
 		.mode           = S_IRUGO | S_IWUSR,
 		.proc_handler   = proc_dointvec,
 	},
-	 {
+	{
 		.procname       = "debug_active",
 		.data		= &debug_active,
 		.maxlen		= sizeof(int),
@@ -912,13 +912,8 @@ static struct ctl_table s390dbf_table[] = {
 	{ }
 };
 
-static struct ctl_table s390dbf_dir_table[] = {
-	{
-		.procname       = "s390dbf",
-		.maxlen         = 0,
-		.mode           = S_IRUGO | S_IXUGO,
-		.child          = s390dbf_table,
-	},
+static const __initdata struct ctl_path s390dbf_path[] = {
+	{ .procname = "s390dbf" },
 	{ }
 };
 
@@ -1071,7 +1066,7 @@ __init debug_init(void)
 {
 	int rc = 0;
 
-	s390dbf_sysctl_header = register_sysctl_table(s390dbf_dir_table);
+	s390dbf_sysctl_header = register_sysctl_paths(s390dbf_path, s390dbf_table);
 	mutex_lock(&debug_mutex);
 	debug_debugfs_root_entry = debugfs_create_dir(DEBUG_DIR_ROOT,NULL);
 	initialized = 1;
-- 
1.7.5.134.g1c08b

From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 014/115] sysctl: remove .child from dev/raid/
Date: Mon,  9 May 2011 00:38:26 +0200
Message-ID: <1304894407-32201-15-git-send-email-lucian.grijincu@gmail.com>
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
 drivers/md/md.c |   22 ++++------------------
 1 files changed, 4 insertions(+), 18 deletions(-)

diff --git a/drivers/md/md.c b/drivers/md/md.c
index 7d6f7f1..3b54374 100644
--- a/drivers/md/md.c
+++ b/drivers/md/md.c
@@ -125,26 +125,12 @@ static ctl_table raid_table[] = {
 	{ }
 };
 
-static ctl_table raid_dir_table[] = {
-	{
-		.procname	= "raid",
-		.maxlen		= 0,
-		.mode		= S_IRUGO|S_IXUGO,
-		.child		= raid_table,
-	},
+static const __initdata struct ctl_path raid_path[] = {
+	{ .procname = "dev" },
+	{ .procname = "raid" },
 	{ }
 };
 
-static ctl_table raid_root_table[] = {
-	{
-		.procname	= "dev",
-		.maxlen		= 0,
-		.mode		= 0555,
-		.child		= raid_dir_table,
-	},
-	{  }
-};
-
 static const struct block_device_operations md_fops;
 
 static int start_readonly;
@@ -7380,7 +7366,7 @@ static int __init md_init(void)
 			    md_probe, NULL, NULL);
 
 	register_reboot_notifier(&md_notifier);
-	raid_table_header = register_sysctl_table(raid_root_table);
+	raid_table_header = register_sysctl_paths(raid_path, raid_table);
 
 	md_geninit();
 	return 0;
-- 
1.7.5.134.g1c08b

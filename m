From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 018/115] sysctl: remove .child from dev/scsi
Date: Mon,  9 May 2011 00:38:30 +0200
Message-ID: <1304894407-32201-19-git-send-email-lucian.grijincu@gmail.com>
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
 drivers/scsi/scsi_sysctl.c |   28 +++++++++++-----------------
 1 files changed, 11 insertions(+), 17 deletions(-)

diff --git a/drivers/scsi/scsi_sysctl.c b/drivers/scsi/scsi_sysctl.c
index 2b6b93f..a28707f 100644
--- a/drivers/scsi/scsi_sysctl.c
+++ b/drivers/scsi/scsi_sysctl.c
@@ -13,25 +13,19 @@
 
 
 static ctl_table scsi_table[] = {
-	{ .procname	= "logging_level",
-	  .data		= &scsi_logging_level,
-	  .maxlen	= sizeof(scsi_logging_level),
-	  .mode		= 0644,
-	  .proc_handler	= proc_dointvec },
+	{
+		.procname	= "logging_level",
+		.data		= &scsi_logging_level,
+		.maxlen		= sizeof(scsi_logging_level),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 	{ }
 };
 
-static ctl_table scsi_dir_table[] = {
-	{ .procname	= "scsi",
-	  .mode		= 0555,
-	  .child	= scsi_table },
-	{ }
-};
-
-static ctl_table scsi_root_table[] = {
-	{ .procname	= "dev",
-	  .mode		= 0555,
-	  .child	= scsi_dir_table },
+static const __initdata struct ctl_path scsi_path[] = {
+	{ .procname = "dev" },
+	{ .procname = "scsi" },
 	{ }
 };
 
@@ -39,7 +33,7 @@ static struct ctl_table_header *scsi_table_header;
 
 int __init scsi_init_sysctl(void)
 {
-	scsi_table_header = register_sysctl_table(scsi_root_table);
+	scsi_table_header = register_sysctl_paths(scsi_path, scsi_table);
 	if (!scsi_table_header)
 		return -ENOMEM;
 	return 0;
-- 
1.7.5.134.g1c08b

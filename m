From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 012/115] sysctl: remove .child from dev/rtc/
Date: Mon,  9 May 2011 00:38:24 +0200
Message-ID: <1304894407-32201-13-git-send-email-lucian.grijincu@gmail.com>
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
 drivers/char/rtc.c |   24 ++++++------------------
 1 files changed, 6 insertions(+), 18 deletions(-)

diff --git a/drivers/char/rtc.c b/drivers/char/rtc.c
index dfa8b30..cc752f5 100644
--- a/drivers/char/rtc.c
+++ b/drivers/char/rtc.c
@@ -291,21 +291,9 @@ static ctl_table rtc_table[] = {
 	{ }
 };
 
-static ctl_table rtc_root[] = {
-	{
-		.procname	= "rtc",
-		.mode		= 0555,
-		.child		= rtc_table,
-	},
-	{ }
-};
-
-static ctl_table dev_root[] = {
-	{
-		.procname	= "dev",
-		.mode		= 0555,
-		.child		= rtc_root,
-	},
+static const __initdata struct ctl_path rtc_path[] = {
+	{ .procname = "dev" },
+	{ .procname = "rtc" },
 	{ }
 };
 
@@ -313,13 +301,13 @@ static struct ctl_table_header *sysctl_header;
 
 static int __init init_sysctl(void)
 {
-    sysctl_header = register_sysctl_table(dev_root);
-    return 0;
+	sysctl_header = register_sysctl_paths(rtc_path, rtc_table);
+	return 0;
 }
 
 static void __exit cleanup_sysctl(void)
 {
-    unregister_sysctl_table(sysctl_header);
+	unregister_sysctl_table(sysctl_header);
 }
 
 /*
-- 
1.7.5.134.g1c08b

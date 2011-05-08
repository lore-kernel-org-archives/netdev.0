From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 011/115] sysctl: remove .child from dev/ipmi/
Date: Mon,  9 May 2011 00:38:23 +0200
Message-ID: <1304894407-32201-12-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51704 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932098Ab1EHWkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:40:42 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 drivers/char/ipmi/ipmi_poweroff.c |   16 ++++------------
 1 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/drivers/char/ipmi/ipmi_poweroff.c b/drivers/char/ipmi/ipmi_poweroff.c
index 2efa176..ac71d69 100644
--- a/drivers/char/ipmi/ipmi_poweroff.c
+++ b/drivers/char/ipmi/ipmi_poweroff.c
@@ -668,17 +668,9 @@ static ctl_table ipmi_table[] = {
 	{ }
 };
 
-static ctl_table ipmi_dir_table[] = {
-	{ .procname	= "ipmi",
-	  .mode		= 0555,
-	  .child	= ipmi_table },
-	{ }
-};
-
-static ctl_table ipmi_root_table[] = {
-	{ .procname	= "dev",
-	  .mode		= 0555,
-	  .child	= ipmi_dir_table },
+static const struct ctl_path ipmi_path[] = {
+	{ .procname = "dev" },
+	{ .procname = "ipmi" },
 	{ }
 };
 
@@ -699,7 +691,7 @@ static int __init ipmi_poweroff_init(void)
 		printk(KERN_INFO PFX "Power cycle is enabled.\n");
 
 #ifdef CONFIG_PROC_FS
-	ipmi_table_header = register_sysctl_table(ipmi_root_table);
+	ipmi_table_header = register_sysctl_paths(ipmi_path, ipmi_table);
 	if (!ipmi_table_header) {
 		printk(KERN_ERR PFX "Unable to register powercycle sysctl\n");
 		rv = -ENOMEM;
-- 
1.7.5.134.g1c08b


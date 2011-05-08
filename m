From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 017/115] sysctl: remove .child from kernel/sclp (s390)
Date: Mon,  9 May 2011 00:38:29 +0200
Message-ID: <1304894407-32201-18-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45747 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932184Ab1EHWks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:40:48 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 drivers/s390/char/sclp_async.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/s390/char/sclp_async.c b/drivers/s390/char/sclp_async.c
index 7ad30e7..43f8b1e 100644
--- a/drivers/s390/char/sclp_async.c
+++ b/drivers/s390/char/sclp_async.c
@@ -106,14 +106,9 @@ static struct ctl_table callhome_table[] = {
 	{}
 };
 
-static struct ctl_table kern_dir_table[] = {
-	{
-		.procname	= "kernel",
-		.maxlen		= 0,
-		.mode		= 0555,
-		.child		= callhome_table,
-	},
-	{}
+static const __initdata struct ctl_path kern_path[] = {
+	{ .procname = "kernel" },
+	{ }
 };
 
 /*
@@ -175,7 +170,7 @@ static int __init sclp_async_init(void)
 	if (!(sclp_async_register.sclp_receive_mask & EVTYP_ASYNC_MASK))
 		goto out_sclp;
 	rc = -ENOMEM;
-	callhome_sysctl_header = register_sysctl_table(kern_dir_table);
+	callhome_sysctl_header = register_sysctl_paths(kern_path, callhome_table);
 	if (!callhome_sysctl_header)
 		goto out_sclp;
 	request = kzalloc(sizeof(struct sclp_req), GFP_KERNEL);
-- 
1.7.5.134.g1c08b


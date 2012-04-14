From: Peter Huewe <peterhuewe@gmx.de>
Subject: [PATCH] isdn/hysdn:  Convert to kstrtoul_from_user
Date: Sun, 15 Apr 2012 01:42:59 +0200
Message-ID: <1334446979-1177-1-git-send-email-peterhuewe@gmx.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org, Peter Huewe <peterhuewe@gmx.de>
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:41348 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754925Ab2DNXnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2012 19:43:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces the code for getting an number from a
userspace buffer by a simple call to kstroul_from_user.
This makes it easier to read and less error prone.

Signed-off-by: Peter Huewe <peterhuewe@gmx.de>
---
 drivers/isdn/hysdn/hysdn_proclog.c |   10 +---------
 1 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/drivers/isdn/hysdn/hysdn_proclog.c b/drivers/isdn/hysdn/hysdn_proclog.c
index ba91333..88e4f0e 100644
--- a/drivers/isdn/hysdn/hysdn_proclog.c
+++ b/drivers/isdn/hysdn/hysdn_proclog.c
@@ -156,17 +156,9 @@ static ssize_t
 hysdn_log_write(struct file *file, const char __user *buf, size_t count, loff_t *off)
 {
 	int rc;
-	unsigned char valbuf[128];
 	hysdn_card *card = file->private_data;
 
-	if (count > (sizeof(valbuf) - 1))
-		count = sizeof(valbuf) - 1;	/* limit length */
-	if (copy_from_user(valbuf, buf, count))
-		return (-EFAULT);	/* copy failed */
-
-	valbuf[count] = 0;	/* terminating 0 */
-
-	rc = kstrtoul(valbuf, 0, &card->debug_flags);
+	rc = kstrtoul_from_user(buf, count, 0, &card->debug_flags);
 	if (rc < 0)
 		return rc;
 	hysdn_addlog(card, "debug set to 0x%lx", card->debug_flags);
-- 
1.7.3.4

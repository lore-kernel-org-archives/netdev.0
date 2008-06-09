From: akpm@linux-foundation.org
Subject: [patch 4/4] isdn: use simple_read_from_buffer()
Date: Mon, 09 Jun 2008 16:32:01 -0700
Message-ID: <200806092332.m59NW1e6014568@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	akinobu.mita@gmail.com, kkeil@suse.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:53029 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755907AbYFIXcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 19:32:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akinobu Mita <akinobu.mita@gmail.com>

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Acked-by: Karsten Keil <kkeil@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/hysdn/hysdn_procconf.c |   27 ++++++--------------------
 1 file changed, 7 insertions(+), 20 deletions(-)

diff -puN drivers/isdn/hysdn/hysdn_procconf.c~isdn-use-simple_read_from_buffer drivers/isdn/hysdn/hysdn_procconf.c
--- a/drivers/isdn/hysdn/hysdn_procconf.c~isdn-use-simple_read_from_buffer
+++ a/drivers/isdn/hysdn/hysdn_procconf.c
@@ -207,30 +207,17 @@ hysdn_conf_write(struct file *file, cons
 /* read conf file -> output card info data */
 /*******************************************/
 static ssize_t
-hysdn_conf_read(struct file *file, char __user *buf, size_t count, loff_t * off)
+hysdn_conf_read(struct file *file, char __user *buf, size_t count, loff_t *off)
 {
 	char *cp;
-	int i;
 
-	if (file->f_mode & FMODE_READ) {
-		if (!(cp = file->private_data))
-			return (-EFAULT);	/* should never happen */
-		i = strlen(cp);	/* get total string length */
-		if (*off < i) {
-			/* still bytes to transfer */
-			cp += *off;	/* point to desired data offset */
-			i -= *off;	/* remaining length */
-			if (i > count)
-				i = count;	/* limit length to transfer */
-			if (copy_to_user(buf, cp, i))
-				return (-EFAULT);	/* copy error */
-			*off += i;	/* adjust offset */
-		} else
-			return (0);
-	} else
-		return (-EPERM);	/* no permission to read */
+	if (!(file->f_mode & FMODE_READ))
+		return -EPERM;	/* no permission to read */
 
-	return (i);
+	if (!(cp = file->private_data))
+		return -EFAULT;	/* should never happen */
+
+	return simple_read_from_buffer(buf, count, off, cp, strlen(cp));
 }				/* hysdn_conf_read */
 
 /******************/
_

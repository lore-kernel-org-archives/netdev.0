From: Dan Carpenter <error27@gmail.com>
Subject: [patch] isdn: return -EFAULT if copy_from_user() fails
Date: Fri, 10 Dec 2010 15:40:09 +0300
Message-ID: <20101210124009.GC10623@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44314 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755762Ab0LJMrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 07:47:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should be returning -EFAULT here.

Mostly this patch is to silence a smatch warning.  The upper levels
of this driver turn all non-zero return values from isar_load_firmware()
into 1.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/isdn/hisax/isar.c b/drivers/isdn/hisax/isar.c
index 2e72227..9cd4829 100644
--- a/drivers/isdn/hisax/isar.c
+++ b/drivers/isdn/hisax/isar.c
@@ -212,9 +212,9 @@ isar_load_firmware(struct IsdnCardState *cs, u_char __user *buf)
 	cs->debug &= ~(L1_DEB_HSCX | L1_DEB_HSCX_FIFO);
 #endif
 	
-	if ((ret = copy_from_user(&size, p, sizeof(int)))) {
+	if (copy_from_user(&size, p, sizeof(int))) {
 		printk(KERN_ERR"isar_load_firmware copy_from_user ret %d\n", ret);
-		return ret;
+		return -EFAULT;
 	}
 	p += sizeof(int);
 	printk(KERN_DEBUG"isar_load_firmware size: %d\n", size);

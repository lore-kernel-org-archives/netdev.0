From: Amol Lad <amol@verismonetworks.com>
Subject: [PATCH 3/4] drivers/net/sis900.c: Replacing yield() with a better
	alternative
Date: Wed, 11 Oct 2006 18:37:39 +0530
Message-ID: <1160572059.19143.341.camel@amol.verismonetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kernel Janitors <kernel-janitors@lists.osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail01.verismonetworks.com ([164.164.99.228]:7661 "EHLO
	mail01.verismonetworks.com") by vger.kernel.org with ESMTP
	id S1751259AbWJKNES (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Oct 2006 09:04:18 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

*Please check if the timout value is ok or it should be increased*

Signed-off-by: Amol Lad <amol@verismonetworks.com>
---
diff -uprN -X linux-2.6.19-rc1-orig/Documentation/dontdiff linux-2.6.19-rc1-orig/drivers/net/sis900.c linux-2.6.19-rc1/drivers/net/sis900.c
--- linux-2.6.19-rc1-orig/drivers/net/sis900.c	2006-10-05 14:00:48.000000000 +0530
+++ linux-2.6.19-rc1/drivers/net/sis900.c	2006-10-11 17:57:02.000000000 +0530
@@ -664,7 +664,7 @@ static int __init sis900_mii_probe(struc
 
 	if(status & MII_STAT_LINK){
 		while (poll_bit) {
-			yield();
+			schedule_timeout_interruptible(1);
 
 			poll_bit ^= (mdio_read(net_dev, sis_priv->cur_phy, MII_STATUS) & poll_bit);
 			if (time_after_eq(jiffies, timeout)) {



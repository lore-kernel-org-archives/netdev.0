From: Michael Buesch <mb@bu3sch.de>
Subject: b44-ssb: Remove redundant device reset
Date: Sun, 27 May 2007 17:14:48 +0200
Message-ID: <200705271714.48272.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Gary Zambrano <zambrano@broadcom.com>, netdev@vger.kernel.org
To: John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:56765
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754001AbXE0PRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2007 11:17:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reset wasn't there in the old b44 driver
and I don't think it's needed for the 47xx either.
If it later turns out that this is really needed for
some weird 47xx, we can re-add it with a special case
branch for that particular device.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: bu3sch-wireless-dev/drivers/net/b44.c
===================================================================
--- bu3sch-wireless-dev.orig/drivers/net/b44.c	2007-05-27 16:59:22.000000000 +0200
+++ bu3sch-wireless-dev/drivers/net/b44.c	2007-05-27 17:03:32.000000000 +0200
@@ -2201,11 +2201,6 @@
 		printk("%2.2x%c", dev->dev_addr[i],
 		       i == 5 ? '\n' : ':');
 
-	/* Initialize phy */
-	spin_lock_irq(&bp->lock);
-	b44_chip_reset(bp);
-	spin_unlock_irq(&bp->lock);
-
 	return 0;
 
 err_out_free_dev:

-- 
Greetings Michael.

From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx-d80211: Lower mac_suspend timeout
Date: Wed, 28 Jun 2006 20:43:55 +0200
Message-ID: <200606282043.56088.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:2974
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750827AbWF1SrI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 14:47:08 -0400
To: linville@tuxdriver.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lower mac_suspend timeout.
This timeout won't ever trigger, if the hardware and driver is
not horribly faulty. It's just a safety net to not lock up the
kernel on bugs.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-06-28 20:37:15.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-06-28 20:40:47.000000000 +0200
@@ -2195,11 +2195,11 @@
 		                bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD)
 				& ~BCM43xx_SBF_MAC_ENABLED);
 		bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON); /* dummy read */
-		for (i = 100000; i; i--) {
+		for (i = 10000; i; i--) {
 			tmp = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
 			if (tmp & BCM43xx_IRQ_READY)
 				goto out;
-			udelay(10);
+			udelay(1);
 		}
 		printkl(KERN_ERR PFX "MAC suspend failed\n");
 	}


-- 
Greetings Michael.

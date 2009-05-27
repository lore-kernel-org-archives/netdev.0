From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH net-next] r6040: check and update media status
Date: Wed, 27 May 2009 11:38:10 +0200
Message-ID: <200905271138.11348.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:27717 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756963AbZE0JiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 05:38:16 -0400
Received: by fg-out-1718.google.com with SMTP id 16so1635540fgg.17
        for <netdev@vger.kernel.org>; Wed, 27 May 2009 02:38:16 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch is intended to be applied to your net-next-2.6 tree.
I do not bump the release number this time since this
change is not a bugfix but is there for completeness. Thanks !
--
From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH -next] r6040: check and update media status

This patch removes the not-that-useful message in the
r6040_timer which prints the PHY status. Instead
replace it with a call to mii_check_media which will
update the link status and print it on startup.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index d4ab162..57c31b8 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -401,6 +401,9 @@ static void r6040_init_mac_regs(struct net_device *dev)
 	 * we may got called by r6040_tx_timeout which has left
 	 * some unsent tx buffers */
 	iowrite16(0x01, ioaddr + MTPR);
+
+	/* Check media */
+	mii_check_media(&lp->mii_if, 1, 1);
 }
 
 static void r6040_tx_timeout(struct net_device *dev)
@@ -528,6 +531,8 @@ static int r6040_phy_mode_chk(struct net_device *dev)
 			phy_dat = 0x0000;
 	}
 
+	mii_check_media(&lp->mii_if, 0, 1);
+
 	return phy_dat;
 };
 
@@ -810,7 +815,6 @@ static void r6040_timer(unsigned long data)
 		lp->phy_mode = phy_mode;
 		lp->mcr0 = (lp->mcr0 & 0x7fff) | phy_mode;
 		iowrite16(lp->mcr0, ioaddr);
-		printk(KERN_INFO "Link Change %x \n", ioread16(ioaddr));
 	}
 
 	/* Timer active again */

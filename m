From: Arnaud Patard (Rtp) <arnaud.patard@rtp-net.org>
Subject: [patch 1/1] phy/marvell: fix 88e1121 support
Date: Mon, 18 Oct 2010 23:44:02 +0200
Message-ID: <20101018214414.375368957@rtp-net.org>
References: <20101018214401.053486146@rtp-net.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cyril Chemparathy <cyril@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lechat.rtp-net.org ([88.191.19.38]:43166 "EHLO
	lechat.rtp-net.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754800Ab0JRVpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 17:45:17 -0400
Content-Disposition: inline; filename=phy_marvell_fix_modes.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit c477d0447db08068a497e7beb892b2b2a7bff64b added support for RGMII
rx/tx delays except that it ends up clearing rx/tx delays bit for modes
differents that RGMII*ID. Due to this, ethernet is not working anymore
on my guruplug server +. This patch is fixing that.

Signed-off-by: Arnaud Patard <arnaud.patard@rtp-net.org>
Index: linux-2.6/drivers/net/phy/marvell.c
===================================================================
--- linux-2.6.orig/drivers/net/phy/marvell.c	2010-10-18 22:46:09.000000000 +0200
+++ linux-2.6/drivers/net/phy/marvell.c	2010-10-18 23:19:14.000000000 +0200
@@ -199,13 +199,13 @@
 	mscr = phy_read(phydev, MII_88E1121_PHY_MSCR_REG) &
 		MII_88E1121_PHY_MSCR_DELAY_MASK;
 
-	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
-		mscr |= (MII_88E1121_PHY_MSCR_RX_DELAY |
-			 MII_88E1121_PHY_MSCR_TX_DELAY);
-	else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID)
+	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID)
 		mscr |= MII_88E1121_PHY_MSCR_RX_DELAY;
 	else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)
 		mscr |= MII_88E1121_PHY_MSCR_TX_DELAY;
+	else
+		mscr |= (MII_88E1121_PHY_MSCR_RX_DELAY |
+			 MII_88E1121_PHY_MSCR_TX_DELAY);
 
 	err = phy_write(phydev, MII_88E1121_PHY_MSCR_REG, mscr);
 	if (err < 0)



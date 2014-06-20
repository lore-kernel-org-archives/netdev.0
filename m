From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 02/30] net: fec: iMX6 FEC does not support half-duplex
 gigabit
Date: Fri, 20 Jun 2014 13:11:53 +0100
Message-ID: <E1Wxxfd-0005Wx-Cl@rmk-PC.arm.linux.org.uk>
References: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:36319 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S966820AbaFTMLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 08:11:55 -0400
In-Reply-To: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The iMX6 gigabit FEC does not support half-duplex gigabit operation.
Phys attacked to the FEC may support this, and we currently do nothing
to disable this feature.  This may result in an invalid configuration.
Mask out phy support for gigabit half-duplex operation.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 77037fd377b8..a91fe68030e6 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1667,6 +1667,7 @@ static int fec_enet_mii_probe(struct net_device *ndev)
 	/* mask with MAC supported features */
 	if (id_entry->driver_data & FEC_QUIRK_HAS_GBIT) {
 		phy_dev->supported &= PHY_GBIT_FEATURES;
+		phy_dev->supported &= ~SUPPORTED_1000baseT_Half;
 #if !defined(CONFIG_M5272)
 		phy_dev->supported |= SUPPORTED_Pause;
 #endif
-- 
1.8.3.1

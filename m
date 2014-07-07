From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH A 01/12] net: fec: iMX6 FEC does not support half-duplex
 gigabit
Date: Tue, 08 Jul 2014 00:22:34 +0100
Message-ID: <E1X4IF0-0004wh-0e@rmk-PC.arm.linux.org.uk>
References: <20140707232148.GG21766@n2100.arm.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:57968 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752672AbaGGXWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 19:22:36 -0400
In-Reply-To: <20140707232148.GG21766@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The iMX6 gigabit FEC does not support half-duplex gigabit operation.
Phys attacked to the FEC may support this, and we currently do nothing
to disable this feature.  This may result in an invalid configuration.
Mask out phy support for gigabit half-duplex operation.

Acked-by: Fugang Duan <B38611@freescale.com>
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

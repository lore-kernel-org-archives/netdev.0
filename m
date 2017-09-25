From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net v2 3/3] net: mvpp2: do not select the internal source clock
Date: Mon, 25 Sep 2017 14:59:48 +0200
Message-ID: <20170925125948.13507-4-antoine.tenart@free-electrons.com>
References: <20170925125948.13507-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:43237 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934840AbdIYNAD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 09:00:03 -0400
In-Reply-To: <20170925125948.13507-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch stops the internal MAC Tx clock from being enabled as the
internal clock isn't used. The definition used for the bit controlling
this behaviour is renamed as well as it was wrongly named (bit 4 of
GMAC_CTRL_2_REG).

Fixes: 3919357fb0bb ("net: mvpp2: initialize the GMAC when using a port")
Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index b2f99df81e9c..161055564720 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -333,7 +333,7 @@
 #define     MVPP2_GMAC_INBAND_AN_MASK		BIT(0)
 #define     MVPP2_GMAC_FLOW_CTRL_MASK		GENMASK(2, 1)
 #define     MVPP2_GMAC_PCS_ENABLE_MASK		BIT(3)
-#define     MVPP2_GMAC_PORT_RGMII_MASK		BIT(4)
+#define     MVPP2_GMAC_INTERNAL_CLK_MASK	BIT(4)
 #define     MVPP2_GMAC_DISABLE_PADDING		BIT(5)
 #define     MVPP2_GMAC_PORT_RESET_MASK		BIT(6)
 #define MVPP2_GMAC_AUTONEG_CONFIG		0xc
@@ -4599,7 +4599,6 @@ static void mvpp2_port_mii_gmac_configure(struct mvpp2_port *port)
 	        val |= MVPP2_GMAC_INBAND_AN_MASK | MVPP2_GMAC_PCS_ENABLE_MASK;
 	} else if (phy_interface_mode_is_rgmii(port->phy_interface)) {
 		val &= ~MVPP2_GMAC_PCS_ENABLE_MASK;
-		val |= MVPP2_GMAC_PORT_RGMII_MASK;
 	}
 	writel(val, port->base + MVPP2_GMAC_CTRL_2_REG);
 
-- 
2.13.5

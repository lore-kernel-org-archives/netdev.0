From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next v2 1/4] net: mvpp2: take advantage of the is_rgmii helper
Date: Fri,  1 Sep 2017 11:04:52 +0200
Message-ID: <20170901090455.32316-2-antoine.tenart@free-electrons.com>
References: <20170901090455.32316-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:45326 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751514AbdIAJFC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 05:05:02 -0400
In-Reply-To: <20170901090455.32316-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert all RGMII checks to use the phy_interface_mode_is_rgmii()
helper. This is a cosmetic patch.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 9e64b1ba3d43..f93d3a332c60 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -4463,10 +4463,7 @@ static void mvpp2_port_mii_gmac_configure_mode(struct mvpp2_port *port)
 		val |= MVPP2_GMAC_DISABLE_PADDING;
 		val &= ~MVPP2_GMAC_FLOW_CTRL_MASK;
 		writel(val, port->base + MVPP2_GMAC_CTRL_2_REG);
-	} else if (port->phy_interface == PHY_INTERFACE_MODE_RGMII ||
-		   port->phy_interface == PHY_INTERFACE_MODE_RGMII_ID ||
-		   port->phy_interface == PHY_INTERFACE_MODE_RGMII_RXID ||
-		   port->phy_interface == PHY_INTERFACE_MODE_RGMII_TXID) {
+	} else if (phy_interface_mode_is_rgmii(port->phy_interface)) {
 		val = readl(port->base + MVPP22_GMAC_CTRL_4_REG);
 		val |= MVPP22_CTRL4_EXT_PIN_GMII_SEL |
 		       MVPP22_CTRL4_SYNC_BYPASS_DIS |
@@ -4512,10 +4509,7 @@ static void mvpp2_port_mii_gmac_configure(struct mvpp2_port *port)
 	val = readl(port->base + MVPP2_GMAC_CTRL_2_REG);
 	if (port->phy_interface == PHY_INTERFACE_MODE_SGMII) {
 	        val |= MVPP2_GMAC_INBAND_AN_MASK | MVPP2_GMAC_PCS_ENABLE_MASK;
-	} else if (port->phy_interface == PHY_INTERFACE_MODE_RGMII ||
-		   port->phy_interface == PHY_INTERFACE_MODE_RGMII_ID ||
-		   port->phy_interface == PHY_INTERFACE_MODE_RGMII_RXID ||
-		   port->phy_interface == PHY_INTERFACE_MODE_RGMII_TXID) {
+	} else if (phy_interface_mode_is_rgmii(port->phy_interface)) {
 		val &= ~MVPP2_GMAC_PCS_ENABLE_MASK;
 		val |= MVPP2_GMAC_PORT_RGMII_MASK;
 	}
@@ -4575,10 +4569,7 @@ static void mvpp2_port_mii_set(struct mvpp2_port *port)
 	if (port->priv->hw_version == MVPP22)
 		mvpp22_port_mii_set(port);
 
-	if (port->phy_interface == PHY_INTERFACE_MODE_RGMII ||
-	    port->phy_interface == PHY_INTERFACE_MODE_RGMII_ID ||
-	    port->phy_interface == PHY_INTERFACE_MODE_RGMII_RXID ||
-	    port->phy_interface == PHY_INTERFACE_MODE_RGMII_TXID ||
+	if (phy_interface_mode_is_rgmii(port->phy_interface) ||
 	    port->phy_interface == PHY_INTERFACE_MODE_SGMII)
 		mvpp2_port_mii_gmac_configure(port);
 	else if (port->phy_interface == PHY_INTERFACE_MODE_10GKR)
-- 
2.13.5

From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH] drivers: net: cpsw-phy-sel: add support to configure rgmii internal delay
Date: Tue, 4 Oct 2016 19:07:29 +0530
Message-ID: <20161004133729.12564-1-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Grygorii Strashko <grygorii.strashko@ti.com>,
        <linux-omap@vger.kernel.org>, Sekhar Nori <nsekhar@ti.com>,
        "David S . Miller" <davem@davemloft.net>,
        Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:36431 "EHLO
        devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750908AbcJDNhw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 09:37:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to enable CPSW RGMII internal delay (id mode) bits
when rgmii internal delay is configured in phy.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw-phy-sel.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw-phy-sel.c b/drivers/net/ethernet/ti/cpsw-phy-sel.c
index c3e85ac..054a8dd 100644
--- a/drivers/net/ethernet/ti/cpsw-phy-sel.c
+++ b/drivers/net/ethernet/ti/cpsw-phy-sel.c
@@ -30,6 +30,8 @@
 
 #define AM33XX_GMII_SEL_RMII2_IO_CLK_EN	BIT(7)
 #define AM33XX_GMII_SEL_RMII1_IO_CLK_EN	BIT(6)
+#define AM33XX_GMII_SEL_RGMII2_IDMODE	BIT(5)
+#define AM33XX_GMII_SEL_RGMII1_IDMODE	BIT(4)
 
 #define GMII_SEL_MODE_MASK		0x3
 
@@ -48,6 +50,7 @@ static void cpsw_gmii_sel_am3352(struct cpsw_phy_sel_priv *priv,
 	u32 reg;
 	u32 mask;
 	u32 mode = 0;
+	bool rgmii_id = false;
 
 	reg = readl(priv->gmii_sel);
 
@@ -57,10 +60,14 @@ static void cpsw_gmii_sel_am3352(struct cpsw_phy_sel_priv *priv,
 		break;
 
 	case PHY_INTERFACE_MODE_RGMII:
+		mode = AM33XX_GMII_SEL_MODE_RGMII;
+		break;
+
 	case PHY_INTERFACE_MODE_RGMII_ID:
 	case PHY_INTERFACE_MODE_RGMII_RXID:
 	case PHY_INTERFACE_MODE_RGMII_TXID:
 		mode = AM33XX_GMII_SEL_MODE_RGMII;
+		rgmii_id = true;
 		break;
 
 	default:
@@ -83,6 +90,13 @@ static void cpsw_gmii_sel_am3352(struct cpsw_phy_sel_priv *priv,
 			mode |= AM33XX_GMII_SEL_RMII2_IO_CLK_EN;
 	}
 
+	if (rgmii_id) {
+		if (slave == 0)
+			mode |= AM33XX_GMII_SEL_RGMII1_IDMODE;
+		else
+			mode |= AM33XX_GMII_SEL_RGMII2_IDMODE;
+	}
+
 	reg &= ~mask;
 	reg |= mode;
 
-- 
2.10.0.372.g6fe1b14

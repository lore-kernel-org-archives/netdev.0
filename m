From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 3/8] drivers: net: phy: at803x: add interface mode support
Date: Tue, 4 Jun 2013 11:40:06 +0530
Message-ID: <1370326212-17580-4-git-send-email-mugunthanvnm@ti.com>
References: <1370326212-17580-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <benoit.cousson@linaro.org>,
	<paul@pwsan.com>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:42906 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758801Ab3FDGJq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jun 2013 02:09:46 -0400
In-Reply-To: <1370326212-17580-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for RGMII TX delay configuration on Atheros 803X,
this can be enabled in debug registers. With this patch,
PHY_INTERFACE_MODE_RGMII_TXID modes are now supported.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/phy/at803x.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index 63444b7..dda07ed 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -27,6 +27,10 @@
 #define AT803X_MMD_ACCESS_CONTROL		0x0D
 #define AT803X_MMD_ACCESS_CONTROL_DATA		0x0E
 #define AT803X_FUNC_DATA			0x4003
+#define AT803X_DEBUG_ADDR			0x1D
+#define AT803X_DEBUG_DATA			0x1E
+#define AT803X_DEBUG_SYSTEM_MODE_CTRL		0x05
+#define AT803X_DEBUG_RGMII_TX_CLK_DLY		BIT(8)
 
 MODULE_DESCRIPTION("Atheros 803x PHY driver");
 MODULE_AUTHOR("Matus Ujhelyi");
@@ -99,6 +103,7 @@ static void at803x_get_wol(struct phy_device *phydev,
 static int at803x_config_init(struct phy_device *phydev)
 {
 	int val;
+	int ret;
 	u32 features;
 
 	features = SUPPORTED_TP | SUPPORTED_MII | SUPPORTED_AUI |
@@ -133,6 +138,17 @@ static int at803x_config_init(struct phy_device *phydev)
 	phydev->supported = features;
 	phydev->advertising = features;
 
+	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID) {
+		ret = phy_write(phydev, AT803X_DEBUG_ADDR,
+				AT803X_DEBUG_SYSTEM_MODE_CTRL);
+		if (ret)
+			return ret;
+		ret = phy_write(phydev, AT803X_DEBUG_DATA,
+				AT803X_DEBUG_RGMII_TX_CLK_DLY);
+		if (ret)
+			return ret;
+	}
+
 	return 0;
 }
 
-- 
1.7.9.5

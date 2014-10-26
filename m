From: Vince Bridgers <vbridger@opensource.altera.com>
Subject: [PATCH net] net: phy: Add SGMII Configuration for Marvell 88E1145 Initialization
Date: Sun, 26 Oct 2014 14:22:24 -0500
Message-ID: <1414351344-24042-1-git-send-email-vbridger@opensource.altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vbridger@altera.com>, <vbridger@opensource.altera.com>
To: <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0078.outbound.protection.outlook.com ([157.56.111.78]:3946
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751844AbaJZXmy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Oct 2014 19:42:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marvell phy 88E1145 configuration & initialization was missing a case
for initializing SGMII mode. This patch adds that case.

Signed-off-by: Vince Bridgers <vbridger@opensource.altera.com>
---
 drivers/net/phy/marvell.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index bd37e45..225c033 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -50,10 +50,15 @@
 #define MII_M1011_PHY_SCR		0x10
 #define MII_M1011_PHY_SCR_AUTO_CROSS	0x0060
 
+#define MII_M1145_PHY_EXT_SR		0x1b
 #define MII_M1145_PHY_EXT_CR		0x14
 #define MII_M1145_RGMII_RX_DELAY	0x0080
 #define MII_M1145_RGMII_TX_DELAY	0x0002
 
+#define MII_M1145_HWCFG_MODE_SGMII_NO_CLK	0x4
+#define MII_M1145_HWCFG_MODE_MASK		0xf
+#define MII_M1145_HWCFG_FIBER_COPPER_AUTO	0x8000
+
 #define MII_M1111_PHY_LED_CONTROL	0x18
 #define MII_M1111_PHY_LED_DIRECT	0x4100
 #define MII_M1111_PHY_LED_COMBINE	0x411c
@@ -676,6 +681,20 @@ static int m88e1145_config_init(struct phy_device *phydev)
 		}
 	}
 
+	if (phydev->interface == PHY_INTERFACE_MODE_SGMII) {
+		int temp = phy_read(phydev, MII_M1145_PHY_EXT_SR);
+		if (temp < 0)
+			return temp;
+
+		temp &= ~MII_M1145_HWCFG_MODE_MASK;
+		temp |= MII_M1145_HWCFG_MODE_SGMII_NO_CLK;
+		temp |= MII_M1145_HWCFG_FIBER_COPPER_AUTO;
+
+		err = phy_write(phydev, MII_M1145_PHY_EXT_SR, temp);
+		if (err < 0)
+			return err;
+	}
+
 	err = marvell_of_reg_init(phydev);
 	if (err < 0)
 		return err;
-- 
1.9.1

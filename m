From: <vndao@altera.com>
Subject: [net-next] net: phy: Adding SGMII support for Marvell 88ee1145 driver
Date: Thu, 23 Oct 2014 19:41:53 -0700
Message-ID: <1414118513-12765-1-git-send-email-vndao@altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<ngachi86@gmail.com>, Viet Nga Dao <vndao@altera.com>
To: <f.faineli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Viet Nga Dao <vndao@altera.com>

Additional code to m88e1145_config_init function to allow the driver to
support SGMII mode.

Signed-off-by: Viet Nga Dao <vndao@altera.com>
---
 drivers/net/phy/marvell.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index bd37e45..b14cb10 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -50,9 +50,13 @@
 #define MII_M1011_PHY_SCR		0x10
 #define MII_M1011_PHY_SCR_AUTO_CROSS	0x0060
 
+#define MII_M1145_PHY_EXT_SR		0x1b
 #define MII_M1145_PHY_EXT_CR		0x14
 #define MII_M1145_RGMII_RX_DELAY	0x0080
 #define MII_M1145_RGMII_TX_DELAY	0x0002
+#define MII_M1145_HWCFG_MODE_SGMII_NO_CLK	0x4
+#define MII_M1145_HWCFG_MODE_MASK		0xf
+#define MII_M1145_HWCFG_FIBER_COPPER_AUTO	0x8000
 
 #define MII_M1111_PHY_LED_CONTROL	0x18
 #define MII_M1111_PHY_LED_DIRECT	0x4100
@@ -620,6 +624,7 @@ static int m88e1149_config_init(struct phy_device *phydev)
 static int m88e1145_config_init(struct phy_device *phydev)
 {
 	int err;
+	int temp;
 
 	/* Take care of errata E0 & E1 */
 	err = phy_write(phydev, 0x1d, 0x001b);
@@ -676,6 +681,20 @@ static int m88e1145_config_init(struct phy_device *phydev)
 		}
 	}
 
+	if (phydev->interface == PHY_INTERFACE_MODE_SGMII) {
+		temp = phy_read(phydev, MII_M1145_PHY_EXT_SR);
+		if (temp < 0)
+			return temp;
+
+		temp &= ~(MII_M1145_HWCFG_MODE_MASK);
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
1.7.7.4

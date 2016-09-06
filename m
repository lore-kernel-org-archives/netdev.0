From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] microchipphy.h and uses: Remove trailing underscores from defines and uses
Date: Tue,  6 Sep 2016 16:04:34 -0700
Message-ID: <b816c318eb4b2bfe7d69c33015f136337fcc2ffa.1473202982.git.joe@perches.com>
References: <cover.1473202982.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-usb@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
        Woojung Huh <woojung.huh@microchip.com>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1473202982.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Macro defines with trailing underscore are hard to read.

These uses with trailing underscores are all unique to this .h file,
so remove them from the defines and uses.

Done with:

$ sed -r -i -e 's/\b([A-Z0-9_][A-Za-z0-9_]+)_\b/\U\1\E/g' \
  include/linux/microchipphy.h \
  drivers/net/usb/lan78xx.c \
  drivers/net/phy/microchip.c

and some editing to realign columns in the .h file.

No change in defconfig objects.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/phy/microchip.c  |  4 +--
 drivers/net/usb/lan78xx.c    | 28 ++++++++---------
 include/linux/microchipphy.h | 72 ++++++++++++++++++++++----------------------
 3 files changed, 52 insertions(+), 52 deletions(-)

diff --git a/drivers/net/phy/microchip.c b/drivers/net/phy/microchip.c
index 15f8206..d8ea811 100644
--- a/drivers/net/phy/microchip.c
+++ b/drivers/net/phy/microchip.c
@@ -39,8 +39,8 @@ static int lan88xx_phy_config_intr(struct phy_device *phydev)
 		rc = phy_write(phydev, LAN88XX_INT_MASK, 0x7FFF);
 		rc = phy_read(phydev, LAN88XX_INT_STS);
 		rc = phy_write(phydev, LAN88XX_INT_MASK,
-			       LAN88XX_INT_MASK_MDINTPIN_EN_ |
-			       LAN88XX_INT_MASK_LINK_CHANGE_);
+			       LAN88XX_INT_MASK_MDINTPIN_EN |
+			       LAN88XX_INT_MASK_LINK_CHANGE);
 	} else {
 		rc = phy_write(phydev, LAN88XX_INT_MASK, 0);
 	}
diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index b6d6d0f..5e870cc 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -1457,27 +1457,27 @@ static void lan78xx_set_mdix_status(struct net_device *net, __u8 mdix_ctrl)
 		phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
 			  LAN88XX_EXT_PAGE_SPACE_1);
 		buf = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);
-		buf &= ~LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
+		buf &= ~LAN88XX_EXT_MODE_CTRL_MDIX_MASK;
 		phy_write(phydev, LAN88XX_EXT_MODE_CTRL,
-			  buf | LAN88XX_EXT_MODE_CTRL_MDI_);
+			  buf | LAN88XX_EXT_MODE_CTRL_MDI);
 		phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
 			  LAN88XX_EXT_PAGE_SPACE_0);
 	} else if (mdix_ctrl == ETH_TP_MDI_X) {
 		phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
 			  LAN88XX_EXT_PAGE_SPACE_1);
 		buf = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);
-		buf &= ~LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
+		buf &= ~LAN88XX_EXT_MODE_CTRL_MDIX_MASK;
 		phy_write(phydev, LAN88XX_EXT_MODE_CTRL,
-			  buf | LAN88XX_EXT_MODE_CTRL_MDI_X_);
+			  buf | LAN88XX_EXT_MODE_CTRL_MDI_X);
 		phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
 			  LAN88XX_EXT_PAGE_SPACE_0);
 	} else if (mdix_ctrl == ETH_TP_MDI_AUTO) {
 		phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
 			  LAN88XX_EXT_PAGE_SPACE_1);
 		buf = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);
-		buf &= ~LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
+		buf &= ~LAN88XX_EXT_MODE_CTRL_MDIX_MASK;
 		phy_write(phydev, LAN88XX_EXT_MODE_CTRL,
-			  buf | LAN88XX_EXT_MODE_CTRL_AUTO_MDIX_);
+			  buf | LAN88XX_EXT_MODE_CTRL_AUTO_MDIX);
 		phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
 			  LAN88XX_EXT_PAGE_SPACE_0);
 	}
@@ -1499,14 +1499,14 @@ static int lan78xx_get_settings(struct net_device *net, struct ethtool_cmd *cmd)
 
 	buf = lan78xx_get_mdix_status(net);
 
-	buf &= LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
-	if (buf == LAN88XX_EXT_MODE_CTRL_AUTO_MDIX_) {
+	buf &= LAN88XX_EXT_MODE_CTRL_MDIX_MASK;
+	if (buf == LAN88XX_EXT_MODE_CTRL_AUTO_MDIX) {
 		cmd->eth_tp_mdix = ETH_TP_MDI_AUTO;
 		cmd->eth_tp_mdix_ctrl = ETH_TP_MDI_AUTO;
-	} else if (buf == LAN88XX_EXT_MODE_CTRL_MDI_) {
+	} else if (buf == LAN88XX_EXT_MODE_CTRL_MDI) {
 		cmd->eth_tp_mdix = ETH_TP_MDI;
 		cmd->eth_tp_mdix_ctrl = ETH_TP_MDI;
-	} else if (buf == LAN88XX_EXT_MODE_CTRL_MDI_X_) {
+	} else if (buf == LAN88XX_EXT_MODE_CTRL_MDI_X) {
 		cmd->eth_tp_mdix = ETH_TP_MDI_X;
 		cmd->eth_tp_mdix_ctrl = ETH_TP_MDI_X;
 	}
@@ -1815,7 +1815,7 @@ static void lan78xx_link_status_change(struct net_device *net)
 	if (!phydev->autoneg && (phydev->speed == 100)) {
 		/* disable phy interrupt */
 		temp = phy_read(phydev, LAN88XX_INT_MASK);
-		temp &= ~LAN88XX_INT_MASK_MDINTPIN_EN_;
+		temp &= ~LAN88XX_INT_MASK_MDINTPIN_EN;
 		ret = phy_write(phydev, LAN88XX_INT_MASK, temp);
 
 		temp = phy_read(phydev, MII_BMCR);
@@ -1829,7 +1829,7 @@ static void lan78xx_link_status_change(struct net_device *net)
 
 		/* enable phy interrupt back */
 		temp = phy_read(phydev, LAN88XX_INT_MASK);
-		temp |= LAN88XX_INT_MASK_MDINTPIN_EN_;
+		temp |= LAN88XX_INT_MASK_MDINTPIN_EN;
 		ret = phy_write(phydev, LAN88XX_INT_MASK, temp);
 	}
 }
@@ -1851,8 +1851,8 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
 	 */
 	ret = phy_read(phydev, LAN88XX_INT_STS);
 	ret = phy_write(phydev, LAN88XX_INT_MASK,
-			LAN88XX_INT_MASK_MDINTPIN_EN_ |
-			LAN88XX_INT_MASK_LINK_CHANGE_);
+			LAN88XX_INT_MASK_MDINTPIN_EN |
+			LAN88XX_INT_MASK_LINK_CHANGE);
 
 	phydev->irq = PHY_IGNORE_INTERRUPT;
 
diff --git a/include/linux/microchipphy.h b/include/linux/microchipphy.h
index eb492d4..20395ea 100644
--- a/include/linux/microchipphy.h
+++ b/include/linux/microchipphy.h
@@ -19,40 +19,40 @@
 #define _MICROCHIPPHY_H
 
 #define LAN88XX_INT_MASK			(0x19)
-#define LAN88XX_INT_MASK_MDINTPIN_EN_		(0x8000)
-#define LAN88XX_INT_MASK_SPEED_CHANGE_		(0x4000)
-#define LAN88XX_INT_MASK_LINK_CHANGE_		(0x2000)
-#define LAN88XX_INT_MASK_FDX_CHANGE_		(0x1000)
-#define LAN88XX_INT_MASK_AUTONEG_ERR_		(0x0800)
-#define LAN88XX_INT_MASK_AUTONEG_DONE_		(0x0400)
-#define LAN88XX_INT_MASK_POE_DETECT_		(0x0200)
-#define LAN88XX_INT_MASK_SYMBOL_ERR_		(0x0100)
-#define LAN88XX_INT_MASK_FAST_LINK_FAIL_	(0x0080)
-#define LAN88XX_INT_MASK_WOL_EVENT_		(0x0040)
-#define LAN88XX_INT_MASK_EXTENDED_INT_		(0x0020)
-#define LAN88XX_INT_MASK_RESERVED_		(0x0010)
-#define LAN88XX_INT_MASK_FALSE_CARRIER_		(0x0008)
-#define LAN88XX_INT_MASK_LINK_SPEED_DS_		(0x0004)
-#define LAN88XX_INT_MASK_MASTER_SLAVE_DONE_	(0x0002)
-#define LAN88XX_INT_MASK_RX__ER_		(0x0001)
+#define LAN88XX_INT_MASK_MDINTPIN_EN		(0x8000)
+#define LAN88XX_INT_MASK_SPEED_CHANGE		(0x4000)
+#define LAN88XX_INT_MASK_LINK_CHANGE		(0x2000)
+#define LAN88XX_INT_MASK_FDX_CHANGE		(0x1000)
+#define LAN88XX_INT_MASK_AUTONEG_ERR		(0x0800)
+#define LAN88XX_INT_MASK_AUTONEG_DONE		(0x0400)
+#define LAN88XX_INT_MASK_POE_DETECT		(0x0200)
+#define LAN88XX_INT_MASK_SYMBOL_ERR		(0x0100)
+#define LAN88XX_INT_MASK_FAST_LINK_FAIL		(0x0080)
+#define LAN88XX_INT_MASK_WOL_EVENT		(0x0040)
+#define LAN88XX_INT_MASK_EXTENDED_INT		(0x0020)
+#define LAN88XX_INT_MASK_RESERVED		(0x0010)
+#define LAN88XX_INT_MASK_FALSE_CARRIER		(0x0008)
+#define LAN88XX_INT_MASK_LINK_SPEED_DS		(0x0004)
+#define LAN88XX_INT_MASK_MASTER_SLAVE_DONE	(0x0002)
+#define LAN88XX_INT_MASK_RX__ER			(0x0001)
 
 #define LAN88XX_INT_STS				(0x1A)
-#define LAN88XX_INT_STS_INT_ACTIVE_		(0x8000)
-#define LAN88XX_INT_STS_SPEED_CHANGE_		(0x4000)
-#define LAN88XX_INT_STS_LINK_CHANGE_		(0x2000)
-#define LAN88XX_INT_STS_FDX_CHANGE_		(0x1000)
-#define LAN88XX_INT_STS_AUTONEG_ERR_		(0x0800)
-#define LAN88XX_INT_STS_AUTONEG_DONE_		(0x0400)
-#define LAN88XX_INT_STS_POE_DETECT_		(0x0200)
-#define LAN88XX_INT_STS_SYMBOL_ERR_		(0x0100)
-#define LAN88XX_INT_STS_FAST_LINK_FAIL_		(0x0080)
-#define LAN88XX_INT_STS_WOL_EVENT_		(0x0040)
-#define LAN88XX_INT_STS_EXTENDED_INT_		(0x0020)
-#define LAN88XX_INT_STS_RESERVED_		(0x0010)
-#define LAN88XX_INT_STS_FALSE_CARRIER_		(0x0008)
-#define LAN88XX_INT_STS_LINK_SPEED_DS_		(0x0004)
-#define LAN88XX_INT_STS_MASTER_SLAVE_DONE_	(0x0002)
-#define LAN88XX_INT_STS_RX_ER_			(0x0001)
+#define LAN88XX_INT_STS_INT_ACTIVE		(0x8000)
+#define LAN88XX_INT_STS_SPEED_CHANGE		(0x4000)
+#define LAN88XX_INT_STS_LINK_CHANGE		(0x2000)
+#define LAN88XX_INT_STS_FDX_CHANGE		(0x1000)
+#define LAN88XX_INT_STS_AUTONEG_ERR		(0x0800)
+#define LAN88XX_INT_STS_AUTONEG_DONE		(0x0400)
+#define LAN88XX_INT_STS_POE_DETECT		(0x0200)
+#define LAN88XX_INT_STS_SYMBOL_ERR		(0x0100)
+#define LAN88XX_INT_STS_FAST_LINK_FAIL		(0x0080)
+#define LAN88XX_INT_STS_WOL_EVENT		(0x0040)
+#define LAN88XX_INT_STS_EXTENDED_INT		(0x0020)
+#define LAN88XX_INT_STS_RESERVED		(0x0010)
+#define LAN88XX_INT_STS_FALSE_CARRIER		(0x0008)
+#define LAN88XX_INT_STS_LINK_SPEED_DS		(0x0004)
+#define LAN88XX_INT_STS_MASTER_SLAVE_DONE	(0x0002)
+#define LAN88XX_INT_STS_RX_ER			(0x0001)
 
 #define LAN88XX_EXT_PAGE_ACCESS			(0x1F)
 #define LAN88XX_EXT_PAGE_SPACE_0		(0x0000)
@@ -61,10 +61,10 @@
 
 /* Extended Register Page 1 space */
 #define LAN88XX_EXT_MODE_CTRL			(0x13)
-#define LAN88XX_EXT_MODE_CTRL_MDIX_MASK_	(0x000C)
-#define LAN88XX_EXT_MODE_CTRL_AUTO_MDIX_	(0x0000)
-#define LAN88XX_EXT_MODE_CTRL_MDI_		(0x0008)
-#define LAN88XX_EXT_MODE_CTRL_MDI_X_		(0x000C)
+#define LAN88XX_EXT_MODE_CTRL_MDIX_MASK		(0x000C)
+#define LAN88XX_EXT_MODE_CTRL_AUTO_MDIX		(0x0000)
+#define LAN88XX_EXT_MODE_CTRL_MDI		(0x0008)
+#define LAN88XX_EXT_MODE_CTRL_MDI_X		(0x000C)
 
 /* MMD 3 Registers */
 #define	LAN88XX_MMD3_CHIP_ID			(32877)
-- 
2.10.0.rc2.1.g053435c

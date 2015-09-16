From: <Woojung.Huh@microchip.com>
Subject: [PATCH net 4/6] lan78xx: Remove phy defines in lan78xx.h and use
 defines in include/linux/microchipphy.h
Date: Wed, 16 Sep 2015 23:41:07 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D55C6A2@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp02.microchip.com ([198.175.253.38]:46227 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752721AbbIPXlI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 19:41:08 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove phy defines in lan78xx.h and use defines in include/linux/microchipphy.h.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/lan78xx.c |  80 +++++++++----------
 drivers/net/usb/lan78xx.h | 192 ----------------------------------------------
 2 files changed, 40 insertions(+), 232 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 04e6f82..517264d 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -30,6 +30,7 @@
 #include <linux/ipv6.h>
 #include <linux/mdio.h>
 #include <net/ip6_checksum.h>
+#include <linux/microchipphy.h>
 #include "lan78xx.h"
 
 #define DRIVER_AUTHOR	"WOOJUNG HUH <woojung.huh@microchip.com>"
@@ -837,8 +838,7 @@ static int lan78xx_link_reset(struct lan78xx_net *dev)
 	u32 buf;
 
 	/* clear PHY interrupt status */
-	/* VTSE PHY */
-	ret = phy_read(phydev, PHY_VTSE_INT_STS);
+	ret = phy_read(phydev, LAN88XX_INT_STS);
 	if (unlikely(ret < 0))
 		return -EIO;
 
@@ -866,7 +866,7 @@ static int lan78xx_link_reset(struct lan78xx_net *dev)
 
 		phy_ethtool_gset(phydev, &ecmd);
 
-		ret = phy_read(phydev, PHY_VTSE_INT_STS);
+		ret = phy_read(phydev, LAN88XX_INT_STS);
 
 		if (dev->udev->speed == USB_SPEED_SUPER) {
 			if (ethtool_cmd_speed(&ecmd) == 1000) {
@@ -1188,18 +1188,18 @@ static int lan78xx_get_settings(struct net_device *net, struct ethtool_cmd *cmd)
 
 	ret = phy_ethtool_gset(phydev, cmd);
 
-	phy_write(phydev, PHY_EXT_GPIO_PAGE, PHY_EXT_GPIO_PAGE_SPACE_1);
-	buf = phy_read(phydev, PHY_EXT_MODE_CTRL);
-	phy_write(phydev, PHY_EXT_GPIO_PAGE, PHY_EXT_GPIO_PAGE_SPACE_0);
+	phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS, LAN88XX_EXT_PAGE_SPACE_1);
+	buf = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);
+	phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS, LAN88XX_EXT_PAGE_SPACE_0);
 
-	buf &= PHY_EXT_MODE_CTRL_MDIX_MASK_;
-	if (buf == PHY_EXT_MODE_CTRL_AUTO_MDIX_) {
+	buf &= LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
+	if (buf == LAN88XX_EXT_MODE_CTRL_AUTO_MDIX_) {
 		cmd->eth_tp_mdix = ETH_TP_MDI_AUTO;
 		cmd->eth_tp_mdix_ctrl = ETH_TP_MDI_AUTO;
-	} else if (buf == PHY_EXT_MODE_CTRL_MDI_) {
+	} else if (buf == LAN88XX_EXT_MODE_CTRL_MDI_) {
 		cmd->eth_tp_mdix = ETH_TP_MDI;
 		cmd->eth_tp_mdix_ctrl = ETH_TP_MDI;
-	} else if (buf == PHY_EXT_MODE_CTRL_MDI_X_) {
+	} else if (buf == LAN88XX_EXT_MODE_CTRL_MDI_X_) {
 		cmd->eth_tp_mdix = ETH_TP_MDI_X;
 		cmd->eth_tp_mdix_ctrl = ETH_TP_MDI_X;
 	}
@@ -1222,32 +1222,32 @@ static int lan78xx_set_settings(struct net_device *net, struct ethtool_cmd *cmd)
 
 	if (dev->mdix_ctrl != cmd->eth_tp_mdix_ctrl) {
 		if (cmd->eth_tp_mdix_ctrl == ETH_TP_MDI) {
-			phy_write(phydev, PHY_EXT_GPIO_PAGE,
-				  PHY_EXT_GPIO_PAGE_SPACE_1);
-			temp = phy_read(phydev, PHY_EXT_MODE_CTRL);
-			temp &= ~PHY_EXT_MODE_CTRL_MDIX_MASK_;
-			phy_write(phydev, PHY_EXT_MODE_CTRL,
-				  temp | PHY_EXT_MODE_CTRL_MDI_);
-			phy_write(phydev, PHY_EXT_GPIO_PAGE,
-				  PHY_EXT_GPIO_PAGE_SPACE_0);
+			phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
+				  LAN88XX_EXT_PAGE_SPACE_1);
+			temp = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);
+			temp &= ~LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
+			phy_write(phydev, LAN88XX_EXT_MODE_CTRL,
+				  temp | LAN88XX_EXT_MODE_CTRL_MDI_);
+			phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
+				  LAN88XX_EXT_PAGE_SPACE_0);
 		} else if (cmd->eth_tp_mdix_ctrl == ETH_TP_MDI_X) {
-			phy_write(phydev, PHY_EXT_GPIO_PAGE,
-				  PHY_EXT_GPIO_PAGE_SPACE_1);
-			temp = phy_read(phydev, PHY_EXT_MODE_CTRL);
-			temp &= ~PHY_EXT_MODE_CTRL_MDIX_MASK_;
-			phy_write(phydev, PHY_EXT_MODE_CTRL,
-				  temp | PHY_EXT_MODE_CTRL_MDI_X_);
-			phy_write(phydev, PHY_EXT_GPIO_PAGE,
-				  PHY_EXT_GPIO_PAGE_SPACE_0);
+			phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
+				  LAN88XX_EXT_PAGE_SPACE_1);
+			temp = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);
+			temp &= ~LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
+			phy_write(phydev, LAN88XX_EXT_MODE_CTRL,
+				  temp | LAN88XX_EXT_MODE_CTRL_MDI_X_);
+			phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
+				  LAN88XX_EXT_PAGE_SPACE_0);
 		} else if (cmd->eth_tp_mdix_ctrl == ETH_TP_MDI_AUTO) {
-			phy_write(phydev, PHY_EXT_GPIO_PAGE,
-				  PHY_EXT_GPIO_PAGE_SPACE_1);
-			temp = phy_read(phydev, PHY_EXT_MODE_CTRL);
-			temp &= ~PHY_EXT_MODE_CTRL_MDIX_MASK_;
-			phy_write(phydev, PHY_EXT_MODE_CTRL,
-				  temp | PHY_EXT_MODE_CTRL_AUTO_MDIX_);
-			phy_write(phydev, PHY_EXT_GPIO_PAGE,
-				  PHY_EXT_GPIO_PAGE_SPACE_0);
+			phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
+				  LAN88XX_EXT_PAGE_SPACE_1);
+			temp = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);
+			temp &= ~LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
+			phy_write(phydev, LAN88XX_EXT_MODE_CTRL,
+				  temp | LAN88XX_EXT_MODE_CTRL_AUTO_MDIX_);
+			phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
+				  LAN88XX_EXT_PAGE_SPACE_0);
 		}
 	}
 
@@ -1504,12 +1504,12 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
 	}
 
 	/* set to AUTOMDIX */
-	phy_write(phydev, PHY_EXT_GPIO_PAGE, PHY_EXT_GPIO_PAGE_SPACE_1);
-	ret = phy_read(phydev, PHY_EXT_MODE_CTRL);
-	ret &= ~PHY_EXT_MODE_CTRL_MDIX_MASK_;
-	phy_write(phydev, PHY_EXT_MODE_CTRL,
-		  ret | PHY_EXT_MODE_CTRL_AUTO_MDIX_);
-	phy_write(phydev, PHY_EXT_GPIO_PAGE, PHY_EXT_GPIO_PAGE_SPACE_0);
+	phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS, LAN88XX_EXT_PAGE_SPACE_1);
+	ret = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);
+	ret &= ~LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
+	phy_write(phydev, LAN88XX_EXT_MODE_CTRL,
+		  ret | LAN88XX_EXT_MODE_CTRL_AUTO_MDIX_);
+	phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS, LAN88XX_EXT_PAGE_SPACE_0);
 	dev->mdix_ctrl = ETH_TP_MDI_AUTO;
 
 	/* MAC doesn't support 1000T Half */
diff --git a/drivers/net/usb/lan78xx.h b/drivers/net/usb/lan78xx.h
index ae7562e..e0a5a8f 100644
--- a/drivers/net/usb/lan78xx.h
+++ b/drivers/net/usb/lan78xx.h
@@ -874,196 +874,4 @@
 #define OTP_TPVSR_VAL			(OTP_BASE_ADDR + 4 * 0x3A)
 #define OTP_TPVHR_VAL			(OTP_BASE_ADDR + 4 * 0x3B)
 #define OTP_TPVSA_VAL			(OTP_BASE_ADDR + 4 * 0x3C)
-
-#define PHY_ID1				(0x02)
-#define PHY_ID2				(0x03)
-
-#define PHY_DEV_ID_OUI_VTSE		(0x04001C)
-#define PHY_DEV_ID_MODEL_VTSE_8502	(0x23)
-
-#define PHY_AUTONEG_ADV			(0x04)
-#define NWAY_AR_NEXT_PAGE_		(0x8000)
-#define NWAY_AR_REMOTE_FAULT_		(0x2000)
-#define NWAY_AR_ASM_DIR_		(0x0800)
-#define NWAY_AR_PAUSE_			(0x0400)
-#define NWAY_AR_100T4_CAPS_		(0x0200)
-#define NWAY_AR_100TX_FD_CAPS_		(0x0100)
-#define NWAY_AR_SELECTOR_FIELD_		(0x001F)
-#define NWAY_AR_100TX_HD_CAPS_		(0x0080)
-#define NWAY_AR_10T_FD_CAPS_		(0x0040)
-#define NWAY_AR_10T_HD_CAPS_		(0x0020)
-#define NWAY_AR_ALL_CAPS_		(NWAY_AR_10T_HD_CAPS_ | \
-					 NWAY_AR_10T_FD_CAPS_ | \
-					 NWAY_AR_100TX_HD_CAPS_ | \
-					 NWAY_AR_100TX_FD_CAPS_)
-#define NWAY_AR_PAUSE_MASK		(NWAY_AR_PAUSE_ | NWAY_AR_ASM_DIR_)
-
-#define PHY_LP_ABILITY			(0x05)
-#define NWAY_LPAR_NEXT_PAGE_		(0x8000)
-#define NWAY_LPAR_ACKNOWLEDGE_		(0x4000)
-#define NWAY_LPAR_REMOTE_FAULT_		(0x2000)
-#define NWAY_LPAR_ASM_DIR_		(0x0800)
-#define NWAY_LPAR_PAUSE_		(0x0400)
-#define NWAY_LPAR_100T4_CAPS_		(0x0200)
-#define NWAY_LPAR_100TX_FD_CAPS_	(0x0100)
-#define NWAY_LPAR_100TX_HD_CAPS_	(0x0080)
-#define NWAY_LPAR_10T_FD_CAPS_		(0x0040)
-#define NWAY_LPAR_10T_HD_CAPS_		(0x0020)
-#define NWAY_LPAR_SELECTOR_FIELD_	(0x001F)
-
-#define PHY_AUTONEG_EXP			(0x06)
-#define NWAY_ER_PAR_DETECT_FAULT_	(0x0010)
-#define NWAY_ER_LP_NEXT_PAGE_CAPS_	(0x0008)
-#define NWAY_ER_NEXT_PAGE_CAPS_		(0x0004)
-#define NWAY_ER_PAGE_RXD_		(0x0002)
-#define NWAY_ER_LP_NWAY_CAPS_		(0x0001)
-
-#define PHY_NEXT_PAGE_TX		(0x07)
-#define NPTX_NEXT_PAGE_			(0x8000)
-#define NPTX_MSG_PAGE_			(0x2000)
-#define NPTX_ACKNOWLDGE2_		(0x1000)
-#define NPTX_TOGGLE_			(0x0800)
-#define NPTX_MSG_CODE_FIELD_		(0x0001)
-
-#define PHY_LP_NEXT_PAGE		(0x08)
-#define LP_RNPR_NEXT_PAGE_		(0x8000)
-#define LP_RNPR_ACKNOWLDGE_		(0x4000)
-#define LP_RNPR_MSG_PAGE_		(0x2000)
-#define LP_RNPR_ACKNOWLDGE2_		(0x1000)
-#define LP_RNPR_TOGGLE_			(0x0800)
-#define LP_RNPR_MSG_CODE_FIELD_		(0x0001)
-
-#define PHY_1000T_CTRL			(0x09)
-#define CR_1000T_TEST_MODE_4_		(0x8000)
-#define CR_1000T_TEST_MODE_3_		(0x6000)
-#define CR_1000T_TEST_MODE_2_		(0x4000)
-#define CR_1000T_TEST_MODE_1_		(0x2000)
-#define CR_1000T_MS_ENABLE_		(0x1000)
-#define CR_1000T_MS_VALUE_		(0x0800)
-#define CR_1000T_REPEATER_DTE_		(0x0400)
-#define CR_1000T_FD_CAPS_		(0x0200)
-#define CR_1000T_HD_CAPS_		(0x0100)
-#define CR_1000T_ASYM_PAUSE_		(0x0080)
-#define CR_1000T_TEST_MODE_NORMAL_	(0x0000)
-
-#define PHY_1000T_STATUS		(0x0A)
-#define SR_1000T_MS_CONFIG_FAULT_	(0x8000)
-#define SR_1000T_MS_CONFIG_RES_		(0x4000)
-#define SR_1000T_LOCAL_RX_STATUS_	(0x2000)
-#define SR_1000T_REMOTE_RX_STATUS_	(0x1000)
-#define SR_1000T_LP_FD_CAPS_		(0x0800)
-#define SR_1000T_LP_HD_CAPS_		(0x0400)
-#define SR_1000T_ASYM_PAUSE_DIR_	(0x0100)
-#define SR_1000T_IDLE_ERROR_CNT_	(0x00FF)
-#define SR_1000T_REMOTE_RX_STATUS_SHIFT		12
-#define SR_1000T_LOCAL_RX_STATUS_SHIFT		13
-#define SR_1000T_PHY_EXCESSIVE_IDLE_ERR_COUNT	5
-#define FFE_IDLE_ERR_COUNT_TIMEOUT_20		20
-#define FFE_IDLE_ERR_COUNT_TIMEOUT_100		100
-
-#define PHY_EXT_STATUS			(0x0F)
-#define IEEE_ESR_1000X_FD_CAPS_		(0x8000)
-#define IEEE_ESR_1000X_HD_CAPS_		(0x4000)
-#define IEEE_ESR_1000T_FD_CAPS_		(0x2000)
-#define IEEE_ESR_1000T_HD_CAPS_		(0x1000)
-#define PHY_TX_POLARITY_MASK_		(0x0100)
-#define PHY_TX_NORMAL_POLARITY_		(0x0000)
-#define AUTO_POLARITY_DISABLE_		(0x0010)
-
-#define PHY_MMD_CTL			(0x0D)
-#define PHY_MMD_CTRL_OP_MASK_		(0xC000)
-#define PHY_MMD_CTRL_OP_REG_		(0x0000)
-#define PHY_MMD_CTRL_OP_DNI_		(0x4000)
-#define PHY_MMD_CTRL_OP_DPIRW_		(0x8000)
-#define PHY_MMD_CTRL_OP_DPIWO_		(0xC000)
-#define PHY_MMD_CTRL_DEV_ADDR_MASK_	(0x001F)
-
-#define PHY_MMD_REG_DATA		(0x0E)
-
-/* VTSE Vendor Specific registers */
-#define PHY_VTSE_BYPASS				(0x12)
-#define PHY_VTSE_BYPASS_DISABLE_PAIR_SWAP_	(0x0020)
-
-#define PHY_VTSE_INT_MASK			(0x19)
-#define PHY_VTSE_INT_MASK_MDINTPIN_EN_		(0x8000)
-#define PHY_VTSE_INT_MASK_SPEED_CHANGE_		(0x4000)
-#define PHY_VTSE_INT_MASK_LINK_CHANGE_		(0x2000)
-#define PHY_VTSE_INT_MASK_FDX_CHANGE_		(0x1000)
-#define PHY_VTSE_INT_MASK_AUTONEG_ERR_		(0x0800)
-#define PHY_VTSE_INT_MASK_AUTONEG_DONE_		(0x0400)
-#define PHY_VTSE_INT_MASK_POE_DETECT_		(0x0200)
-#define PHY_VTSE_INT_MASK_SYMBOL_ERR_		(0x0100)
-#define PHY_VTSE_INT_MASK_FAST_LINK_FAIL_	(0x0080)
-#define PHY_VTSE_INT_MASK_WOL_EVENT_		(0x0040)
-#define PHY_VTSE_INT_MASK_EXTENDED_INT_		(0x0020)
-#define PHY_VTSE_INT_MASK_RESERVED_		(0x0010)
-#define PHY_VTSE_INT_MASK_FALSE_CARRIER_	(0x0008)
-#define PHY_VTSE_INT_MASK_LINK_SPEED_DS_	(0x0004)
-#define PHY_VTSE_INT_MASK_MASTER_SLAVE_DONE_	(0x0002)
-#define PHY_VTSE_INT_MASK_RX__ER_		(0x0001)
-
-#define PHY_VTSE_INT_STS			(0x1A)
-#define PHY_VTSE_INT_STS_INT_ACTIVE_		(0x8000)
-#define PHY_VTSE_INT_STS_SPEED_CHANGE_		(0x4000)
-#define PHY_VTSE_INT_STS_LINK_CHANGE_		(0x2000)
-#define PHY_VTSE_INT_STS_FDX_CHANGE_		(0x1000)
-#define PHY_VTSE_INT_STS_AUTONEG_ERR_		(0x0800)
-#define PHY_VTSE_INT_STS_AUTONEG_DONE_		(0x0400)
-#define PHY_VTSE_INT_STS_POE_DETECT_		(0x0200)
-#define PHY_VTSE_INT_STS_SYMBOL_ERR_		(0x0100)
-#define PHY_VTSE_INT_STS_FAST_LINK_FAIL_	(0x0080)
-#define PHY_VTSE_INT_STS_WOL_EVENT_		(0x0040)
-#define PHY_VTSE_INT_STS_EXTENDED_INT_		(0x0020)
-#define PHY_VTSE_INT_STS_RESERVED_		(0x0010)
-#define PHY_VTSE_INT_STS_FALSE_CARRIER_		(0x0008)
-#define PHY_VTSE_INT_STS_LINK_SPEED_DS_		(0x0004)
-#define PHY_VTSE_INT_STS_MASTER_SLAVE_DONE_	(0x0002)
-#define PHY_VTSE_INT_STS_RX_ER_			(0x0001)
-
-/* VTSE PHY registers */
-#define PHY_EXT_GPIO_PAGE		(0x1F)
-#define PHY_EXT_GPIO_PAGE_SPACE_0	(0x0000)
-#define PHY_EXT_GPIO_PAGE_SPACE_1	(0x0001)
-#define PHY_EXT_GPIO_PAGE_SPACE_2	(0x0002)
-
-/* Extended Register Page 1 space */
-#define PHY_EXT_MODE_CTRL		(0x13)
-#define PHY_EXT_MODE_CTRL_MDIX_MASK_	(0x000C)
-#define PHY_EXT_MODE_CTRL_AUTO_MDIX_	(0x0000)
-#define PHY_EXT_MODE_CTRL_MDI_		(0x0008)
-#define PHY_EXT_MODE_CTRL_MDI_X_	(0x000C)
-
-#define PHY_ANA_10BASE_T_HD		0x01
-#define PHY_ANA_10BASE_T_FD		0x02
-#define PHY_ANA_100BASE_TX_HD		0x04
-#define PHY_ANA_100BASE_TX_FD		0x08
-#define PHY_ANA_1000BASE_T_FD		0x10
-#define PHY_ANA_ALL_SUPPORTED_MEDIA	(PHY_ANA_10BASE_T_HD |	 \
-					 PHY_ANA_10BASE_T_FD |	 \
-					 PHY_ANA_100BASE_TX_HD | \
-					 PHY_ANA_100BASE_TX_FD | \
-					 PHY_ANA_1000BASE_T_FD)
-/* PHY MMD registers */
-#define PHY_MMD_DEV_3				3
-
-#define PHY_EEE_PCS_STATUS			(0x1)
-#define PHY_EEE_PCS_STATUS_TX_LPI_RCVD_		((WORD)0x0800)
-#define PHY_EEE_PCS_STATUS_RX_LPI_RCVD_		((WORD)0x0400)
-#define PHY_EEE_PCS_STATUS_TX_LPI_IND_		((WORD)0x0200)
-#define PHY_EEE_PCS_STATUS_RX_LPI_IND_		((WORD)0x0100)
-#define PHY_EEE_PCS_STATUS_PCS_RCV_LNK_STS_	((WORD)0x0004)
-
-#define PHY_EEE_CAPABILITIES			(0x14)
-#define PHY_EEE_CAPABILITIES_1000BT_EEE_	((WORD)0x0004)
-#define PHY_EEE_CAPABILITIES_100BT_EEE_		((WORD)0x0002)
-
-#define PHY_MMD_DEV_7				7
-
-#define PHY_EEE_ADVERTISEMENT			(0x3C)
-#define PHY_EEE_ADVERTISEMENT_1000BT_EEE_	((WORD)0x0004)
-#define PHY_EEE_ADVERTISEMENT_100BT_EEE_	((WORD)0x0002)
-
-#define PHY_EEE_LP_ADVERTISEMENT		(0x3D)
-#define PHY_EEE_1000BT_EEE_CAPABLE_		((WORD)0x0004)
-#define PHY_EEE_100BT_EEE_CAPABLE_		((WORD)0x0002)
 #endif /* _LAN78XX_H */
-- 
2.1.4

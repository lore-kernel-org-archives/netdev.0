From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 06/12] tg3: Rename
 TG3_FLG3_RGMII_STD_IBND_DISABLE
Date: Wed, 17 Feb 2010 17:16:59 -0800
Message-ID: <1266455825-16150-7-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3242 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755529Ab0BRBR0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 20:17:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The STD part of this preprocessor definition is a bit of a misnomer.
This flag is a coarse control of the RGMII inband status facilities.
This patch renames the definition to be more accurate.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   12 ++++++------
 drivers/net/tg3.h |    4 ++--
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index c9974a7..09e3af0 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -984,7 +984,7 @@ static void tg3_mdio_config_5785(struct tg3 *tp)
 		return;
 	}
 
-	if (!(tp->tg3_flags3 & TG3_FLG3_RGMII_STD_IBND_DISABLE))
+	if (!(tp->tg3_flags3 & TG3_FLG3_RGMII_INBAND_DISABLE))
 		val |= MAC_PHYCFG2_EMODE_MASK_MASK |
 		       MAC_PHYCFG2_FMODE_MASK_MASK |
 		       MAC_PHYCFG2_GMODE_MASK_MASK |
@@ -997,7 +997,7 @@ static void tg3_mdio_config_5785(struct tg3 *tp)
 	val = tr32(MAC_PHYCFG1);
 	val &= ~(MAC_PHYCFG1_RXCLK_TO_MASK | MAC_PHYCFG1_TXCLK_TO_MASK |
 		 MAC_PHYCFG1_RGMII_EXT_RX_DEC | MAC_PHYCFG1_RGMII_SND_STAT_EN);
-	if (!(tp->tg3_flags3 & TG3_FLG3_RGMII_STD_IBND_DISABLE)) {
+	if (!(tp->tg3_flags3 & TG3_FLG3_RGMII_INBAND_DISABLE)) {
 		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_RX_EN)
 			val |= MAC_PHYCFG1_RGMII_EXT_RX_DEC;
 		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_TX_EN)
@@ -1015,7 +1015,7 @@ static void tg3_mdio_config_5785(struct tg3 *tp)
 		 MAC_RGMII_MODE_TX_ENABLE |
 		 MAC_RGMII_MODE_TX_LOWPWR |
 		 MAC_RGMII_MODE_TX_RESET);
-	if (!(tp->tg3_flags3 & TG3_FLG3_RGMII_STD_IBND_DISABLE)) {
+	if (!(tp->tg3_flags3 & TG3_FLG3_RGMII_INBAND_DISABLE)) {
 		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_RX_EN)
 			val |= MAC_RGMII_MODE_RX_INT_B |
 			       MAC_RGMII_MODE_RX_QUALITY |
@@ -1125,7 +1125,7 @@ static int tg3_mdio_init(struct tg3 *tp)
 				     PHY_BRCM_RX_REFCLK_UNUSED |
 				     PHY_BRCM_DIS_TXCRXC_NOENRGY |
 				     PHY_BRCM_AUTO_PWRDWN_ENABLE;
-		if (tp->tg3_flags3 & TG3_FLG3_RGMII_STD_IBND_DISABLE)
+		if (tp->tg3_flags3 & TG3_FLG3_RGMII_INBAND_DISABLE)
 			phydev->dev_flags |= PHY_BRCM_STD_IBND_DISABLE;
 		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_RX_EN)
 			phydev->dev_flags |= PHY_BRCM_EXT_IBND_RX_ENABLE;
@@ -12365,8 +12365,8 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 				tp->tg3_flags |= TG3_FLAG_ASPM_WORKAROUND;
 		}
 
-		if (cfg4 & NIC_SRAM_RGMII_STD_IBND_DISABLE)
-			tp->tg3_flags3 |= TG3_FLG3_RGMII_STD_IBND_DISABLE;
+		if (cfg4 & NIC_SRAM_RGMII_INBAND_DISABLE)
+			tp->tg3_flags3 |= TG3_FLG3_RGMII_INBAND_DISABLE;
 		if (cfg4 & NIC_SRAM_RGMII_EXT_IBND_RX_EN)
 			tp->tg3_flags3 |= TG3_FLG3_RGMII_EXT_IBND_RX_EN;
 		if (cfg4 & NIC_SRAM_RGMII_EXT_IBND_TX_EN)
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index ffc12b1..d2712c5 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1979,7 +1979,7 @@
 
 #define NIC_SRAM_DATA_CFG_4		0x00000d60
 #define  NIC_SRAM_GMII_MODE		 0x00000002
-#define  NIC_SRAM_RGMII_STD_IBND_DISABLE 0x00000004
+#define  NIC_SRAM_RGMII_INBAND_DISABLE	 0x00000004
 #define  NIC_SRAM_RGMII_EXT_IBND_RX_EN	 0x00000008
 #define  NIC_SRAM_RGMII_EXT_IBND_TX_EN	 0x00000010
 
@@ -2825,7 +2825,7 @@ struct tg3 {
 #define TG3_FLG3_USE_PHYLIB		0x00000010
 #define TG3_FLG3_MDIOBUS_INITED		0x00000020
 #define TG3_FLG3_PHY_CONNECTED		0x00000080
-#define TG3_FLG3_RGMII_STD_IBND_DISABLE	0x00000100
+#define TG3_FLG3_RGMII_INBAND_DISABLE	0x00000100
 #define TG3_FLG3_RGMII_EXT_IBND_RX_EN	0x00000200
 #define TG3_FLG3_RGMII_EXT_IBND_TX_EN	0x00000400
 #define TG3_FLG3_CLKREQ_BUG		0x00000800
-- 
1.6.4.4



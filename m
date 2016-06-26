From: Joe Perches <joe@perches.com>
Subject: [PATCH] rtlwifi: Add missing newlines to RT_TRACE calls
Date: Sun, 26 Jun 2016 12:34:30 -0700
Message-ID: <5677791872bfb47963780c198c825d882456720f.1466969647.git.joe@perches.com>
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0088.hostedemail.com ([216.40.44.88]:46710 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751330AbcFZTeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2016 15:34:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RT_TRACE does not add a newline to the end of a message and always
emits at KERN_DEBUG so these are susceptible to message interleaving
from other processes without the newline.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/realtek/rtlwifi/core.c                |  2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8188ee/hw.c        |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8188ee/phy.c       |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8188ee/rf.c        |  2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8188ee/trx.c       |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8192c/phy_common.c |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c        |  2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192ce/trx.c       |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8192cu/rf.c        |  2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192de/rf.c        |  2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192de/trx.c       |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/dm.c        |  2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c        |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c       |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/rf.c        |  2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/trx.c       |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8192se/hw.c        |  2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192se/trx.c       |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/dm.c        |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hal_btc.c   |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c        |  2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/phy.c       |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/rf.c        |  2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/trx.c       |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c        |  2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c       |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/rf.c        |  2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/trx.c       |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/dm.c        |  6 +++---
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c        |  6 +++---
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/phy.c       | 14 +++++++-------
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/rf.c        |  2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/trx.c       |  4 ++--
 33 files changed, 60 insertions(+), 60 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/core.c b/drivers/net/wireless/realtek/rtlwifi/core.c
index 3a0faa8..41f77f8 100644
--- a/drivers/net/wireless/realtek/rtlwifi/core.c
+++ b/drivers/net/wireless/realtek/rtlwifi/core.c
@@ -526,7 +526,7 @@ static void _rtl_add_wowlan_patterns(struct ieee80211_hw *hw,
 		/* 3. calculate crc */
 		rtl_pattern.crc = _calculate_wol_pattern_crc(content, len);
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
-			 "CRC_Remainder = 0x%x", rtl_pattern.crc);
+			 "CRC_Remainder = 0x%x\n", rtl_pattern.crc);
 
 		/* 4. write crc & mask_for_hw to hw */
 		rtlpriv->cfg->ops->add_wowlan_pattern(hw, &rtl_pattern, i);
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/hw.c
index e26a233..cfdf6d8 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/hw.c
@@ -1846,12 +1846,12 @@ static void _rtl88ee_read_adapter_info(struct ieee80211_hw *hw)
 
 	case EEPROM_93C46:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "RTL819X Not boot from eeprom, check it !!");
+			 "RTL819X Not boot from eeprom, check it !!\n");
 		return;
 
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "boot from neither eeprom nor efuse, check it !!");
+			 "boot from neither eeprom nor efuse, check it !!\n");
 		return;
 	}
 	memcpy(hwinfo, &rtlefuse->efuse_map[EFUSE_INIT_MAP][0], HWSET_MAX_SIZE);
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/phy.c
index 416a9ba..1d034a1 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/phy.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/phy.c
@@ -373,7 +373,7 @@ static bool _rtl88e_phy_bb8188e_config_parafile(struct ieee80211_hw *hw)
 
 	rtstatus = phy_config_bb_with_headerfile(hw, BASEBAND_CONFIG_PHY_REG);
 	if (!rtstatus) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Write BB Reg Fail!!");
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Write BB Reg Fail!!\n");
 		return false;
 	}
 
@@ -383,7 +383,7 @@ static bool _rtl88e_phy_bb8188e_config_parafile(struct ieee80211_hw *hw)
 		  phy_config_bb_with_pghdr(hw, BASEBAND_CONFIG_PHY_REG);
 	}
 	if (!rtstatus) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "BB_PG Reg Fail!!");
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "BB_PG Reg Fail!!\n");
 		return false;
 	}
 	rtstatus =
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/rf.c b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/rf.c
index 40893ce..26ac4c2 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/rf.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/rf.c
@@ -498,7 +498,7 @@ static bool _rtl88e_phy_rf6052_config_parafile(struct ieee80211_hw *hw)
 
 		if (rtstatus != true) {
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-				 "Radio[%d] Fail!!", rfpath);
+				 "Radio[%d] Fail!!\n", rfpath);
 			return false;
 		}
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/trx.c b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/trx.c
index 1170106..be0d77d 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/trx.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/trx.c
@@ -540,7 +540,7 @@ void rtl88ee_tx_fill_desc(struct ieee80211_hw *hw,
 				 PCI_DMA_TODEVICE);
 	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
 		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
-			 "DMA mapping error");
+			 "DMA mapping error\n");
 		return;
 	}
 	CLEAR_PCI_TX_DESC_CONTENT(pdesc, sizeof(struct tx_desc_88e));
@@ -703,7 +703,7 @@ void rtl88ee_tx_fill_cmddesc(struct ieee80211_hw *hw,
 
 	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
 		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
-			 "DMA mapping error");
+			 "DMA mapping error\n");
 		return;
 	}
 	CLEAR_PCI_TX_DESC_CONTENT(pdesc, TX_DESC_SIZE);
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192c/phy_common.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192c/phy_common.c
index 77e61b1..995c5a6 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192c/phy_common.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192c/phy_common.c
@@ -213,7 +213,7 @@ bool _rtl92c_phy_bb8192c_config_parafile(struct ieee80211_hw *hw)
 	rtstatus = rtlpriv->cfg->ops->config_bb_with_headerfile(hw,
 						 BASEBAND_CONFIG_PHY_REG);
 	if (!rtstatus) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Write BB Reg Fail!!");
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Write BB Reg Fail!!\n");
 		return false;
 	}
 	if (rtlphy->rf_type == RF_1T2R) {
@@ -226,7 +226,7 @@ bool _rtl92c_phy_bb8192c_config_parafile(struct ieee80211_hw *hw)
 						   BASEBAND_CONFIG_PHY_REG);
 	}
 	if (!rtstatus) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "BB_PG Reg Fail!!");
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "BB_PG Reg Fail!!\n");
 		return false;
 	}
 	rtstatus = rtlpriv->cfg->ops->config_bb_with_headerfile(hw,
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c
index 58b7ac6..809a021 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c
@@ -1692,7 +1692,7 @@ static void _rtl92ce_read_adapter_info(struct ieee80211_hw *hw)
 
 	case EEPROM_93C46:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "RTL819X Not boot from eeprom, check it !!");
+			 "RTL819X Not boot from eeprom, check it !!\n");
 		return;
 
 	default:
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/trx.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/trx.c
index 84ddd4d..cc7b11f 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/trx.c
@@ -449,7 +449,7 @@ void rtl92ce_tx_fill_desc(struct ieee80211_hw *hw,
 
 	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
 		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
-			 "DMA mapping error");
+			 "DMA mapping error\n");
 		return;
 	}
 	rcu_read_lock();
@@ -615,7 +615,7 @@ void rtl92ce_tx_fill_cmddesc(struct ieee80211_hw *hw,
 
 	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
 		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
-			 "DMA mapping error");
+			 "DMA mapping error\n");
 		return;
 	}
 	CLEAR_PCI_TX_DESC_CONTENT(pdesc, TX_DESC_SIZE);
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/rf.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/rf.c
index 5624ade..ec2ea56 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/rf.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/rf.c
@@ -465,7 +465,7 @@ static bool _rtl92c_phy_rf6052_config_parafile(struct ieee80211_hw *hw)
 		}
 		if (!rtstatus) {
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-				 "Radio[%d] Fail!!", rfpath);
+				 "Radio[%d] Fail!!\n", rfpath);
 			goto phy_rf_cfg_fail;
 		}
 	}
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/rf.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/rf.c
index 6a6ac54..2f479d3 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/rf.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/rf.c
@@ -601,7 +601,7 @@ bool rtl92d_phy_rf6052_config(struct ieee80211_hw *hw)
 		}
 		if (!rtstatus) {
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-				 "Radio[%d] Fail!!", rfpath);
+				 "Radio[%d] Fail!!\n", rfpath);
 			goto phy_rf_cfg_fail;
 		}
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/trx.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/trx.c
index 1feaa62..68acdcf 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/trx.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/trx.c
@@ -586,7 +586,7 @@ void rtl92de_tx_fill_desc(struct ieee80211_hw *hw,
 				 PCI_DMA_TODEVICE);
 	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
 		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
-			 "DMA mapping error");
+			 "DMA mapping error\n");
 		return;
 	}
 	CLEAR_PCI_TX_DESC_CONTENT(pdesc, sizeof(struct tx_desc_92d));
@@ -744,7 +744,7 @@ void rtl92de_tx_fill_cmddesc(struct ieee80211_hw *hw,
 
 	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
 		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
-			 "DMA mapping error");
+			 "DMA mapping error\n");
 		return;
 	}
 	CLEAR_PCI_TX_DESC_CONTENT(pdesc, TX_DESC_SIZE);
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/dm.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/dm.c
index 459f3d0..222e74a 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/dm.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/dm.c
@@ -983,7 +983,7 @@ static bool _rtl92ee_dm_ra_state_check(struct ieee80211_hw *hw,
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
-			 "wrong rssi level setting %d !", *ratr_state);
+			 "wrong rssi level setting %d !\n", *ratr_state);
 		break;
 	}
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c
index 28c260d..9d1ecba 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c
@@ -2109,12 +2109,12 @@ static void _rtl92ee_read_adapter_info(struct ieee80211_hw *hw)
 
 	case EEPROM_93C46:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "RTL819X Not boot from eeprom, check it !!");
+			 "RTL819X Not boot from eeprom, check it !!\n");
 		return;
 
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "boot from neither eeprom nor efuse, check it !!");
+			 "boot from neither eeprom nor efuse, check it !!\n");
 		return;
 	}
 	memcpy(hwinfo, &rtlefuse->efuse_map[EFUSE_INIT_MAP][0], HWSET_MAX_SIZE);
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c
index c2bf8d1..38a5552 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c
@@ -650,7 +650,7 @@ static bool _rtl92ee_phy_bb8192ee_config_parafile(struct ieee80211_hw *hw)
 
 	rtstatus = phy_config_bb_with_hdr_file(hw, BASEBAND_CONFIG_PHY_REG);
 	if (!rtstatus) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Write BB Reg Fail!!");
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Write BB Reg Fail!!\n");
 		return false;
 	}
 
@@ -662,7 +662,7 @@ static bool _rtl92ee_phy_bb8192ee_config_parafile(struct ieee80211_hw *hw)
 	}
 	_rtl92ee_phy_txpower_by_rate_configuration(hw);
 	if (!rtstatus) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "BB_PG Reg Fail!!");
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "BB_PG Reg Fail!!\n");
 		return false;
 	}
 	rtstatus = phy_config_bb_with_hdr_file(hw, BASEBAND_CONFIG_AGC_TAB);
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/rf.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/rf.c
index c9bc33c..73716c0 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/rf.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/rf.c
@@ -142,7 +142,7 @@ static bool _rtl92ee_phy_rf6052_config_parafile(struct ieee80211_hw *hw)
 
 		if (!rtstatus) {
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-				 "Radio[%d] Fail!!", rfpath);
+				 "Radio[%d] Fail!!\n", rfpath);
 			return false;
 		}
 	}
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/trx.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/trx.c
index 35e6bf7..6a4c5cb 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/trx.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/trx.c
@@ -703,7 +703,7 @@ void rtl92ee_tx_fill_desc(struct ieee80211_hw *hw,
 				 PCI_DMA_TODEVICE);
 	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
 		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
-			 "DMA mapping error");
+			 "DMA mapping error\n");
 		return;
 	}
 
@@ -867,7 +867,7 @@ void rtl92ee_tx_fill_cmddesc(struct ieee80211_hw *hw,
 
 	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
 		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
-			 "DMA mapping error");
+			 "DMA mapping error\n");
 		return;
 	}
 	CLEAR_PCI_TX_DESC_CONTENT(pdesc, txdesc_len);
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192se/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192se/hw.c
index 442f2b6..ddfa0ae 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192se/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192se/hw.c
@@ -2003,7 +2003,7 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 	rtlefuse->b1ss_support = rtlefuse->b1x1_recvcombine;
 	rtlefuse->eeprom_oemid = *&hwinfo[EEPROM_CUSTOMID];
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "EEPROM Customer ID: 0x%2x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "EEPROM Customer ID: 0x%2x\n",
 		 rtlefuse->eeprom_oemid);
 
 	/* set channel paln to world wide 13 */
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192se/trx.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192se/trx.c
index 125b29b..d53bbf6 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192se/trx.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192se/trx.c
@@ -360,7 +360,7 @@ void rtl92se_tx_fill_desc(struct ieee80211_hw *hw,
 
 	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
 		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
-			 "DMA mapping error");
+			 "DMA mapping error\n");
 		return;
 	}
 	if (mac->opmode == NL80211_IFTYPE_STATION) {
@@ -529,7 +529,7 @@ void rtl92se_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
 
 	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
 		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
-			 "DMA mapping error");
+			 "DMA mapping error\n");
 		return;
 	}
 	/* Clear all status	*/
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/dm.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/dm.c
index 4c1c96c..0e4ca62 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/dm.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/dm.c
@@ -874,8 +874,8 @@ void rtl8723e_dm_bt_coexist(struct ieee80211_hw *hw)
 
 	tmp_byte = rtl_read_byte(rtlpriv, 0x40);
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_LOUD,
-		 "[DM][BT], 0x40 is 0x%x", tmp_byte);
+		 "[DM][BT], 0x40 is 0x%x\n", tmp_byte);
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-		 "[DM][BT], bt_dm_coexist start");
+		 "[DM][BT], bt_dm_coexist start\n");
 	rtl8723e_dm_bt_coexist_8723(hw);
 }
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hal_btc.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hal_btc.c
index 44de695..ec9bcf3 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hal_btc.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hal_btc.c
@@ -185,7 +185,7 @@ static void rtl8723e_dm_bt_set_hw_pta_mode(struct ieee80211_hw *hw, bool b_mode)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	if (BT_PTA_MODE_ON == b_mode) {
-		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE, "PTA mode on, ");
+		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE, "PTA mode on\n");
 		/*  Enable GPIO 0/1/2/3/8 pins for bt */
 		rtl_write_byte(rtlpriv, 0x40, 0x20);
 		rtlpriv->btcoexist.hw_coexist_all_off = false;
@@ -1401,7 +1401,7 @@ static void rtl8723e_dm_bt_inq_page_monitor(struct ieee80211_hw *hw)
 			(long)hal_coex_8723.bt_inq_page_start_time) / HZ)
 			>= 10) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-				"[BTCoex], BT Inquiry/page >= 10sec!!!");
+				"[BTCoex], BT Inquiry/page >= 10sec!!!\n");
 			hal_coex_8723.bt_inq_page_start_time = 0;
 			rtlpriv->btcoexist.cstate &=
 				~BT_COEX_STATE_BT_INQ_PAGE;
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c
index 57a1ba8..0025e21 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c
@@ -1645,7 +1645,7 @@ static void _rtl8723e_read_adapter_info(struct ieee80211_hw *hw,
 
 	case EEPROM_93C46:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "RTL819X Not boot from eeprom, check it !!");
+			 "RTL819X Not boot from eeprom, check it !!\n");
 		return;
 
 	default:
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/phy.c
index d367097..af07e00 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/phy.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/phy.c
@@ -213,7 +213,7 @@ static bool _rtl8723e_phy_bb8192c_config_parafile(struct ieee80211_hw *hw)
 	rtstatus = _rtl8723e_phy_config_bb_with_headerfile(hw,
 						BASEBAND_CONFIG_PHY_REG);
 	if (rtstatus != true) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Write BB Reg Fail!!");
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Write BB Reg Fail!!\n");
 		return false;
 	}
 
@@ -227,7 +227,7 @@ static bool _rtl8723e_phy_bb8192c_config_parafile(struct ieee80211_hw *hw)
 					BASEBAND_CONFIG_PHY_REG);
 	}
 	if (rtstatus != true) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "BB_PG Reg Fail!!");
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "BB_PG Reg Fail!!\n");
 		return false;
 	}
 	rtstatus =
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/rf.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/rf.c
index 9ebc828..4227717 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/rf.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/rf.c
@@ -504,7 +504,7 @@ static bool _rtl8723e_phy_rf6052_config_parafile(struct ieee80211_hw *hw)
 
 		if (rtstatus != true) {
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-				 "Radio[%d] Fail!!", rfpath);
+				 "Radio[%d] Fail!!\n", rfpath);
 			return false;
 		}
 	}
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/trx.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/trx.c
index 7b4a9b6..e93125e 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/trx.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/trx.c
@@ -389,7 +389,7 @@ void rtl8723e_tx_fill_desc(struct ieee80211_hw *hw,
 
 	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
 		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
-			 "DMA mapping error");
+			 "DMA mapping error\n");
 		return;
 	}
 	if (mac->opmode == NL80211_IFTYPE_STATION) {
@@ -557,7 +557,7 @@ void rtl8723e_tx_fill_cmddesc(struct ieee80211_hw *hw,
 
 	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
 		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
-			 "DMA mapping error");
+			 "DMA mapping error\n");
 		return;
 	}
 	CLEAR_PCI_TX_DESC_CONTENT(pdesc, TX_DESC_SIZE);
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
index 08288ac..63b0df6 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
@@ -2064,7 +2064,7 @@ static void _rtl8723be_read_adapter_info(struct ieee80211_hw *hw,
 
 	case EEPROM_93C46:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "RTL819X Not boot from eeprom, check it !!");
+			 "RTL819X Not boot from eeprom, check it !!\n");
 		return;
 
 	default:
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c
index c5ca9df..3659148 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c
@@ -467,7 +467,7 @@ static bool _rtl8723be_phy_bb8723b_config_parafile(struct ieee80211_hw *hw)
 	rtstatus = _rtl8723be_phy_config_bb_with_headerfile(hw,
 						BASEBAND_CONFIG_PHY_REG);
 	if (!rtstatus) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Write BB Reg Fail!!");
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Write BB Reg Fail!!\n");
 		return false;
 	}
 	_rtl8723be_phy_init_tx_power_by_rate(hw);
@@ -478,7 +478,7 @@ static bool _rtl8723be_phy_bb8723b_config_parafile(struct ieee80211_hw *hw)
 	}
 	phy_txpower_by_rate_config(hw);
 	if (!rtstatus) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "BB_PG Reg Fail!!");
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "BB_PG Reg Fail!!\n");
 		return false;
 	}
 	rtstatus = _rtl8723be_phy_config_bb_with_headerfile(hw,
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/rf.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/rf.c
index 97f5a03..78f4f18 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/rf.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/rf.c
@@ -502,7 +502,7 @@ static bool _rtl8723be_phy_rf6052_config_parafile(struct ieee80211_hw *hw)
 
 		if (!rtstatus) {
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-				 "Radio[%d] Fail!!", rfpath);
+				 "Radio[%d] Fail!!\n", rfpath);
 			return false;
 		}
 	}
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/trx.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/trx.c
index 6034597..99bb997 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/trx.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/trx.c
@@ -464,7 +464,7 @@ void rtl8723be_tx_fill_desc(struct ieee80211_hw *hw,
 	mapping = pci_map_single(rtlpci->pdev, skb->data, skb->len,
 				 PCI_DMA_TODEVICE);
 	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
-		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE, "DMA mapping error");
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE, "DMA mapping error\n");
 		return;
 	}
 	CLEAR_PCI_TX_DESC_CONTENT(pdesc, sizeof(struct tx_desc_8723be));
@@ -616,7 +616,7 @@ void rtl8723be_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
 
 	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
 		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
-			 "DMA mapping error");
+			 "DMA mapping error\n");
 		return;
 	}
 	CLEAR_PCI_TX_DESC_CONTENT(pdesc, TX_DESC_SIZE);
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/dm.c b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/dm.c
index 17a6817..15df0df1 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/dm.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/dm.c
@@ -843,7 +843,7 @@ static void rtl8821ae_dm_dig(struct ieee80211_hw *hw)
 				dm_digtable->rssi_val_min + offset;
 
 		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
-			 "dm_digtable->rssi_val_min=0x%x,dm_digtable->rx_gain_max = 0x%x",
+			 "dm_digtable->rssi_val_min=0x%x,dm_digtable->rx_gain_max = 0x%x\n",
 			 dm_digtable->rssi_val_min,
 			 dm_digtable->rx_gain_max);
 		if (rtlpriv->dm.one_entry_only) {
@@ -2682,9 +2682,9 @@ static void rtl8821ae_dm_check_edca_turbo(struct ieee80211_hw *hw)
 	bool b_edca_turbo_on = false;
 
 	RT_TRACE(rtlpriv, COMP_TURBO, DBG_LOUD,
-		 "rtl8821ae_dm_check_edca_turbo=====>");
+		 "rtl8821ae_dm_check_edca_turbo=====>\n");
 	RT_TRACE(rtlpriv, COMP_TURBO, DBG_LOUD,
-		 "Orginial BE PARAM: 0x%x\n",
+		 "Original BE PARAM: 0x%x\n",
 		 rtl_read_dword(rtlpriv, DM_REG_EDCA_BE_11N));
 
 	if (rtlpriv->dm.dbginfo.num_non_be_pkt > 0x100)
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
index b9436df..ac8836b 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
@@ -3117,7 +3117,7 @@ static void _rtl8821ae_read_adapter_info(struct ieee80211_hw *hw, bool b_pseudo_
 
 	case EEPROM_93C46:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "RTL819X Not boot from eeprom, check it !!");
+			 "RTL819X Not boot from eeprom, check it !!\n");
 		return;
 
 	default:
@@ -3140,7 +3140,7 @@ static void _rtl8821ae_read_adapter_info(struct ieee80211_hw *hw, bool b_pseudo_
 
 	if (rtlefuse->autoload_failflag) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "RTL8812AE autoload_failflag, check it !!");
+			 "RTL8812AE autoload_failflag, check it !!\n");
 		return;
 	}
 
@@ -3836,7 +3836,7 @@ void rtl8821ae_update_hal_rate_tbl(struct ieee80211_hw *hw,
 		rtl8821ae_update_hal_rate_mask(hw, sta, rssi_level);
 	else
 		/*RT_TRACE(rtlpriv, COMP_RATR,DBG_LOUD,
-			   "rtl8821ae_update_hal_rate_tbl() Error! 8821ae FW RA Only");*/
+			   "rtl8821ae_update_hal_rate_tbl() Error! 8821ae FW RA Only\n");*/
 		rtl8821ae_update_hal_rate_table(hw, sta);
 }
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/phy.c
index 0c3b9ce..f3b680c 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/phy.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/phy.c
@@ -581,7 +581,7 @@ void rtl8821ae_phy_switch_wirelessband(struct ieee80211_hw *hw, u8 band)
 		count = 0;
 		reg_41a = rtl_read_word(rtlpriv, REG_TXPKT_EMPTY);
 		RT_TRACE(rtlpriv, COMP_SCAN, DBG_LOUD,
-			 "Reg41A value %d", reg_41a);
+			 "Reg41A value %d\n", reg_41a);
 		reg_41a &= 0x30;
 		while ((reg_41a != 0x30) && (count < 50)) {
 			udelay(50);
@@ -591,7 +591,7 @@ void rtl8821ae_phy_switch_wirelessband(struct ieee80211_hw *hw, u8 band)
 			reg_41a &= 0x30;
 			count++;
 			RT_TRACE(rtlpriv, COMP_SCAN, DBG_LOUD,
-				 "Reg41A value %d", reg_41a);
+				 "Reg41A value %d\n", reg_41a);
 		}
 		if (count != 0)
 			RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
@@ -1013,7 +1013,7 @@ static void _rtl8812ae_phy_cross_reference_ht_and_vht_txpower_limit(struct ieee8
 									rtlphy->txpwr_limit_5g[regulation][bw][3][channel][RF90_PATH_A];
 							}
 
-							RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "use other value %d", temp_pwrlmt);
+							RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "use other value %d\n", temp_pwrlmt);
 						}
 					}
 				}
@@ -1482,12 +1482,12 @@ static char _rtl8812ae_phy_get_chnl_idx_of_txpwr_lmt(struct ieee80211_hw *hw,
 				channel_index = i;
 		}
 	} else
-		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, "Invalid Band %d in %s",
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, "Invalid Band %d in %s\n",
 			 band,  __func__);
 
 	if (channel_index == -1)
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 "Invalid Channel %d of Band %d in %s", channel,
+			 "Invalid Channel %d of Band %d in %s\n", channel,
 			 band, __func__);
 
 	return channel_index;
@@ -1665,7 +1665,7 @@ static bool _rtl8821ae_phy_bb8821a_config_parafile(struct ieee80211_hw *hw)
 	rtstatus = _rtl8821ae_phy_config_bb_with_headerfile(hw,
 						       BASEBAND_CONFIG_PHY_REG);
 	if (rtstatus != true) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Write BB Reg Fail!!");
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Write BB Reg Fail!!\n");
 		return false;
 	}
 	_rtl8821ae_phy_init_tx_power_by_rate(hw);
@@ -1674,7 +1674,7 @@ static bool _rtl8821ae_phy_bb8821a_config_parafile(struct ieee80211_hw *hw)
 						    BASEBAND_CONFIG_PHY_REG);
 	}
 	if (rtstatus != true) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "BB_PG Reg Fail!!");
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "BB_PG Reg Fail!!\n");
 		return false;
 	}
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/rf.c b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/rf.c
index 2922538..c6ab957 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/rf.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/rf.c
@@ -454,7 +454,7 @@ static bool _rtl8821ae_phy_rf6052_config_parafile(struct ieee80211_hw *hw)
 
 		if (!rtstatus) {
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-				 "Radio[%d] Fail!!", rfpath);
+				 "Radio[%d] Fail!!\n", rfpath);
 			return false;
 		}
 	}
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/trx.c b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/trx.c
index 41efaa1..0ea69cd 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/trx.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/trx.c
@@ -716,7 +716,7 @@ void rtl8821ae_tx_fill_desc(struct ieee80211_hw *hw,
 				 PCI_DMA_TODEVICE);
 	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
 		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
-			 "DMA mapping error");
+			 "DMA mapping error\n");
 		return;
 	}
 	CLEAR_PCI_TX_DESC_CONTENT(pdesc, sizeof(struct tx_desc_8821ae));
@@ -857,7 +857,7 @@ void rtl8821ae_tx_fill_cmddesc(struct ieee80211_hw *hw,
 
 	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
 		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
-			 "DMA mapping error");
+			 "DMA mapping error\n");
 		return;
 	}
 	CLEAR_PCI_TX_DESC_CONTENT(pdesc, TX_DESC_SIZE);
-- 
2.8.0.rc4.16.g56331f8

From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 5/7] rtlwifi: rtl8192ce: Convert driver to use new rtl_phy_scan_operation_backup() routine
Date: Thu, 26 Sep 2013 13:25:31 -0500
Message-ID: <1380219933-16784-6-git-send-email-Larry.Finger@lwfinger.net>
References: <1380219933-16784-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:57626 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754063Ab3IZS0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 14:26:08 -0400
In-Reply-To: <1380219933-16784-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that rtl_phy_scan_operation_backup() exists, convert rtl8192de to use it.
Routine rtl92d_phy_scan_operation_backup() is no longer used and is removed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c | 28 ----------------------------
 drivers/net/wireless/rtlwifi/rtl8192de/phy.h |  1 -
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c  |  3 ++-
 3 files changed, 2 insertions(+), 30 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/phy.c b/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
index 840bac5..13196cc 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
@@ -1022,34 +1022,6 @@ void rtl92d_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel)
 	rtl92d_phy_rf6052_set_ofdm_txpower(hw, &ofdmpowerlevel[0], channel);
 }
 
-void rtl92d_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	enum io_type iotype;
-
-	if (!is_hal_stop(rtlhal)) {
-		switch (operation) {
-		case SCAN_OPT_BACKUP:
-			rtlhal->current_bandtypebackup =
-						 rtlhal->current_bandtype;
-			iotype = IO_CMD_PAUSE_DM_BY_SCAN;
-			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_IO_CMD,
-						      (u8 *)&iotype);
-			break;
-		case SCAN_OPT_RESTORE:
-			iotype = IO_CMD_RESUME_DM_BY_SCAN;
-			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_IO_CMD,
-						      (u8 *)&iotype);
-			break;
-		default:
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "Unknown Scan Backup operation\n");
-			break;
-		}
-	}
-}
-
 void rtl92d_phy_set_bw_mode(struct ieee80211_hw *hw,
 			    enum nl80211_channel_type ch_type)
 {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/phy.h b/drivers/net/wireless/rtlwifi/rtl8192de/phy.h
index 8f07606..33df0d1c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/phy.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/phy.h
@@ -139,7 +139,6 @@ bool rtl92c_phy_config_rf_with_feaderfile(struct ieee80211_hw *hw,
 					  enum radio_path rfpath);
 void rtl92d_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw);
 void rtl92d_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel);
-void rtl92d_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation);
 void rtl92d_phy_set_bw_mode(struct ieee80211_hw *hw,
 			    enum nl80211_channel_type ch_type);
 u8 rtl92d_phy_sw_chnl(struct ieee80211_hw *hw);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c b/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
index c18c04b..edab5a5 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
@@ -30,6 +30,7 @@
 #include "../wifi.h"
 #include "../core.h"
 #include "../pci.h"
+#include "../base.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
@@ -236,7 +237,7 @@ static struct rtl_hal_ops rtl8192de_hal_ops = {
 	.set_bw_mode = rtl92d_phy_set_bw_mode,
 	.switch_channel = rtl92d_phy_sw_chnl,
 	.dm_watchdog = rtl92d_dm_watchdog,
-	.scan_operation_backup = rtl92d_phy_scan_operation_backup,
+	.scan_operation_backup = rtl_phy_scan_operation_backup,
 	.set_rf_power_state = rtl92d_phy_set_rf_power_state,
 	.led_control = rtl92de_led_control,
 	.set_desc = rtl92de_set_desc,
-- 
1.8.1.4

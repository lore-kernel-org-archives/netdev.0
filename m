From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 6/7] rtlwifi: rtl8723ae: Convert driver to use new rtl_phy_scan_operation_backup() routine
Date: Thu, 26 Sep 2013 13:25:32 -0500
Message-ID: <1380219933-16784-7-git-send-email-Larry.Finger@lwfinger.net>
References: <1380219933-16784-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:49868 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754069Ab3IZS0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 14:26:10 -0400
In-Reply-To: <1380219933-16784-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that rtl_phy_scan_operation_backup() exists, convert rtl8723ae to use it.
Routine rtl8723ae_phy_scan_operation_backup() is no longer used and is removed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.c | 29 ----------------------------
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.h |  1 -
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.c  |  3 ++-
 3 files changed, 2 insertions(+), 31 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/phy.c b/drivers/net/wireless/rtlwifi/rtl8723ae/phy.c
index eafbb18..5d318a8 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/phy.c
@@ -934,35 +934,6 @@ static long _phy_txpwr_idx_to_dbm(struct ieee80211_hw *hw,
 	return pwrout_dbm;
 }
 
-void rtl8723ae_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	enum io_type iotype;
-
-	if (!is_hal_stop(rtlhal)) {
-		switch (operation) {
-		case SCAN_OPT_BACKUP:
-			iotype = IO_CMD_PAUSE_DM_BY_SCAN;
-			rtlpriv->cfg->ops->set_hw_reg(hw,
-						      HW_VAR_IO_CMD,
-						      (u8 *)&iotype);
-
-			break;
-		case SCAN_OPT_RESTORE:
-			iotype = IO_CMD_RESUME_DM_BY_SCAN;
-			rtlpriv->cfg->ops->set_hw_reg(hw,
-						      HW_VAR_IO_CMD,
-						      (u8 *)&iotype);
-			break;
-		default:
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "Unknown Scan Backup operation.\n");
-			break;
-		}
-	}
-}
-
 void rtl8723ae_phy_set_bw_mode_callback(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/phy.h b/drivers/net/wireless/rtlwifi/rtl8723ae/phy.h
index bbb950d..c3adc72 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/phy.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/phy.h
@@ -203,7 +203,6 @@ void rtl8723ae_phy_get_txpower_level(struct ieee80211_hw *hw, long *powerlevel);
 void rtl8723ae_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel);
 bool rtl8723ae_phy_update_txpower_dbm(struct ieee80211_hw *hw,
 				      long power_indbm);
-void rtl8723ae_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation);
 void rtl8723ae_phy_set_bw_mode_callback(struct ieee80211_hw *hw);
 void rtl8723ae_phy_set_bw_mode(struct ieee80211_hw *hw,
 			       enum nl80211_channel_type ch_type);
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/sw.c b/drivers/net/wireless/rtlwifi/rtl8723ae/sw.c
index d9ee2ef..62b204f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/sw.c
@@ -33,6 +33,7 @@
 
 #include "../core.h"
 #include "../pci.h"
+#include "../base.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
@@ -220,7 +221,7 @@ static struct rtl_hal_ops rtl8723ae_hal_ops = {
 	.set_bw_mode = rtl8723ae_phy_set_bw_mode,
 	.switch_channel = rtl8723ae_phy_sw_chnl,
 	.dm_watchdog = rtl8723ae_dm_watchdog,
-	.scan_operation_backup = rtl8723ae_phy_scan_operation_backup,
+	.scan_operation_backup = rtl_phy_scan_operation_backup,
 	.set_rf_power_state = rtl8723ae_phy_set_rf_power_state,
 	.led_control = rtl8723ae_led_control,
 	.set_desc = rtl8723ae_set_desc,
-- 
1.8.1.4

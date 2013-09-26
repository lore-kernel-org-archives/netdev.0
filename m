From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 7/7] rtlwifi: rtl8188ee: Convert driver to use new rtl_phy_scan_operation_backup() routine
Date: Thu, 26 Sep 2013 13:25:33 -0500
Message-ID: <1380219933-16784-8-git-send-email-Larry.Finger@lwfinger.net>
References: <1380219933-16784-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:55192 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753387Ab3IZS0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 14:26:11 -0400
In-Reply-To: <1380219933-16784-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that rtl_phy_scan_operation_backup() exists, convert rtl8188ee to use it.
Routine rtl88e_phy_scan_operation_backup() is no longer used and is removed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.c | 28 ----------------------------
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.h |  1 -
 drivers/net/wireless/rtlwifi/rtl8188ee/sw.c  |  3 ++-
 3 files changed, 2 insertions(+), 30 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/phy.c b/drivers/net/wireless/rtlwifi/rtl8188ee/phy.c
index e655c04..d67f9c7 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/phy.c
@@ -1136,34 +1136,6 @@ void rtl88e_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel)
 					   &bw40_pwr[0], channel);
 }
 
-void rtl88e_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation)
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
 void rtl88e_phy_set_bw_mode_callback(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/phy.h b/drivers/net/wireless/rtlwifi/rtl8188ee/phy.h
index 71ddf4f..8e1f1be 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/phy.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/phy.h
@@ -213,7 +213,6 @@ bool rtl88e_phy_rf_config(struct ieee80211_hw *hw);
 void rtl88e_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw);
 void rtl88e_phy_get_txpower_level(struct ieee80211_hw *hw, long *powerlevel);
 void rtl88e_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel);
-void rtl88e_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation);
 void rtl88e_phy_set_bw_mode_callback(struct ieee80211_hw *hw);
 void rtl88e_phy_set_bw_mode(struct ieee80211_hw *hw,
 			    enum nl80211_channel_type ch_type);
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
index c254693..347af1e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
@@ -30,6 +30,7 @@
 #include "../wifi.h"
 #include "../core.h"
 #include "../pci.h"
+#include "../base.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
@@ -244,7 +245,7 @@ static struct rtl_hal_ops rtl8188ee_hal_ops = {
 	.set_bw_mode = rtl88e_phy_set_bw_mode,
 	.switch_channel = rtl88e_phy_sw_chnl,
 	.dm_watchdog = rtl88e_dm_watchdog,
-	.scan_operation_backup = rtl88e_phy_scan_operation_backup,
+	.scan_operation_backup = rtl_phy_scan_operation_backup,
 	.set_rf_power_state = rtl88e_phy_set_rf_power_state,
 	.led_control = rtl88ee_led_control,
 	.set_desc = rtl88ee_set_desc,
-- 
1.8.1.4

From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 4/7] rtlwifi: rtl8192c: Remove rtl8192c_phy_scan_operation_backup()
Date: Thu, 26 Sep 2013 13:25:30 -0500
Message-ID: <1380219933-16784-5-git-send-email-Larry.Finger@lwfinger.net>
References: <1380219933-16784-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:39822 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754062Ab3IZS0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 14:26:07 -0400
In-Reply-To: <1380219933-16784-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers rtl8192ce and rtl8192cu no longer rely on this routine. It is removed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c | 30 ----------------------
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.h |  2 --
 2 files changed, 32 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
index 246e535..0c0e782 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
@@ -592,36 +592,6 @@ long _rtl92c_phy_txpwr_idx_to_dbm(struct ieee80211_hw *hw,
 }
 EXPORT_SYMBOL(_rtl92c_phy_txpwr_idx_to_dbm);
 
-void rtl92c_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation)
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
-				 "Unknown Scan Backup operation\n");
-			break;
-		}
-	}
-}
-EXPORT_SYMBOL(rtl92c_phy_scan_operation_backup);
-
 void rtl92c_phy_set_bw_mode(struct ieee80211_hw *hw,
 			    enum nl80211_channel_type ch_type)
 {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.h b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.h
index 24957e2..e79dabe 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.h
@@ -203,8 +203,6 @@ void rtl92c_phy_get_txpower_level(struct ieee80211_hw *hw,
 void rtl92c_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel);
 bool rtl92c_phy_update_txpower_dbm(struct ieee80211_hw *hw,
 					  long power_indbm);
-void rtl92c_phy_scan_operation_backup(struct ieee80211_hw *hw,
-					     u8 operation);
 void rtl92c_phy_set_bw_mode(struct ieee80211_hw *hw,
 				   enum nl80211_channel_type ch_type);
 void rtl92c_phy_sw_chnl_callback(struct ieee80211_hw *hw);
-- 
1.8.1.4

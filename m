From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 4/8 V3] rtlwifi: rtl8192_common: Fix smatch errors and warnings in rtl8192c/dm_common.c
Date: Wed, 18 Sep 2013 14:58:55 -0500
Message-ID: <1379534339-14895-5-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f47.google.com ([209.85.212.47]:47649 "EHLO
	mail-vb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015Ab3IRT7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 15:59:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch lists the following:
  CHECK   drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:551 rtl92c_dm_pwdb_monitor() info: ignoring unreachable code.
drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:551 rtl92c_dm_pwdb_monitor() info: ignoring unreachable code.
drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:870 rtl92c_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'txpwr_level' 2 <= 2
drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:870 rtl92c_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'txpwr_level' 2 <= 2
drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:882 rtl92c_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'txpwr_level' 2 <= 2
drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:883 rtl92c_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'txpwr_level' 2 <= 2
drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:891 rtl92c_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'txpwr_level' 2 <= 2
drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:892 rtl92c_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'txpwr_level' 2 <= 2

The unreachable code message is fixed by deleting the code that follows a return.

The errors are fixed by increasing the size of txpwr_level.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c |   25 +------------------------
 1 file changed, 1 insertion(+), 24 deletions(-)

Index: wireless-testing-save/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
===================================================================
--- wireless-testing-save.orig/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
+++ wireless-testing-save/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
@@ -541,29 +541,6 @@ EXPORT_SYMBOL(rtl92c_dm_write_dig);
 
 static void rtl92c_dm_pwdb_monitor(struct ieee80211_hw *hw)
 {
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	long tmpentry_max_pwdb = 0, tmpentry_min_pwdb = 0xff;
-
-	u8 h2c_parameter[3] = { 0 };
-
-	return;
-
-	if (tmpentry_max_pwdb != 0) {
-		rtlpriv->dm.entry_max_undec_sm_pwdb = tmpentry_max_pwdb;
-	} else {
-		rtlpriv->dm.entry_max_undec_sm_pwdb = 0;
-	}
-
-	if (tmpentry_min_pwdb != 0xff) {
-		rtlpriv->dm.entry_min_undec_sm_pwdb = tmpentry_min_pwdb;
-	} else {
-		rtlpriv->dm.entry_min_undec_sm_pwdb = 0;
-	}
-
-	h2c_parameter[2] = (u8) (rtlpriv->dm.undec_sm_pwdb & 0xFF);
-	h2c_parameter[0] = 0;
-
-	rtl92c_fill_h2c_cmd(hw, H2C_RSSI_REPORT, 3, h2c_parameter);
 }
 
 void rtl92c_dm_init_edca_turbo(struct ieee80211_hw *hw)
@@ -673,7 +650,7 @@ static void rtl92c_dm_txpower_tracking_c
 	s8 cck_index = 0;
 	int i;
 	bool is2t = IS_92C_SERIAL(rtlhal->version);
-	s8 txpwr_level[2] = {0, 0};
+	s8 txpwr_level[3] = {0, 0, 0};
 	u8 ofdm_min_index = 6, rf;
 
 	rtlpriv->dm.txpower_trackinginit = true;

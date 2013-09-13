From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 4/7] rtlwifi: rtl8192_common: Fix smatch errors and warnings in rtl8192c/dm_common.c
Date: Fri, 13 Sep 2013 12:45:01 -0500
Message-ID: <1379094304-22041-5-git-send-email-Larry.Finger@lwfinger.net>
References: <1379094304-22041-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:62731 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753692Ab3IMRpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 13:45:21 -0400
In-Reply-To: <1379094304-22041-1-git-send-email-Larry.Finger@lwfinger.net>
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

The unreachable code message is fixed by commenting out the code that follows a return.

The errors are fixed by increasing the size of txpwr_level.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
index d2d57a2..0721756 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
@@ -541,6 +541,7 @@ EXPORT_SYMBOL(rtl92c_dm_write_dig);
 
 static void rtl92c_dm_pwdb_monitor(struct ieee80211_hw *hw)
 {
+/*
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	long tmpentry_max_pwdb = 0, tmpentry_min_pwdb = 0xff;
 
@@ -564,6 +565,7 @@ static void rtl92c_dm_pwdb_monitor(struct ieee80211_hw *hw)
 	h2c_parameter[0] = 0;
 
 	rtl92c_fill_h2c_cmd(hw, H2C_RSSI_REPORT, 3, h2c_parameter);
+ */
 }
 
 void rtl92c_dm_init_edca_turbo(struct ieee80211_hw *hw)
@@ -673,7 +675,7 @@ static void rtl92c_dm_txpower_tracking_callback_thermalmeter(struct ieee80211_hw
 	s8 cck_index = 0;
 	int i;
 	bool is2t = IS_92C_SERIAL(rtlhal->version);
-	s8 txpwr_level[2] = {0, 0};
+	s8 txpwr_level[3] = {0, 0, 0};
 	u8 ofdm_min_index = 6, rf;
 
 	rtlpriv->dm.txpower_trackinginit = true;
-- 
1.8.1.4

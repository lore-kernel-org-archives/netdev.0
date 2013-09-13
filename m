From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/7] rtlwifi: rtl8192du: Fix smatch errors in /rtl8192de/dm.c
Date: Fri, 13 Sep 2013 12:44:58 -0500
Message-ID: <1379094304-22041-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1379094304-22041-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:57908 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513Ab3IMRpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 13:45:18 -0400
In-Reply-To: <1379094304-22041-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch lists the following:
  CHECK   drivers/net/wireless/rtlwifi/rtl8192de/dm.c
drivers/net/wireless/rtlwifi/rtl8192de/dm.c:1054 rtl92d_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'ofdm_index' 2 <= 2
drivers/net/wireless/rtlwifi/rtl8192de/dm.c:1056 rtl92d_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'ofdm_index' 2 <= 2
drivers/net/wireless/rtlwifi/rtl8192de/dm.c:1126 rtl92d_dm_txpower_tracking_callback_thermalmeter() debug: remove_pools: nr_children over 4000 (4596). (rtlpriv->dbg.global_debuglevel merged)
drivers/net/wireless/rtlwifi/rtl8192de/dm.c:1126 rtl92d_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'cckswing_table_ch1ch13' 33 <= 255
drivers/net/wireless/rtlwifi/rtl8192de/dm.c:1129 rtl92d_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'cckswing_table_ch1ch13' 33 <= 255
drivers/net/wireless/rtlwifi/rtl8192de/dm.c:1132 rtl92d_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'cckswing_table_ch1ch13' 33 <= 255
drivers/net/wireless/rtlwifi/rtl8192de/dm.c:1135 rtl92d_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'cckswing_table_ch1ch13' 33 <= 255
drivers/net/wireless/rtlwifi/rtl8192de/dm.c:1138 rtl92d_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'cckswing_table_ch1ch13' 33 <= 255
drivers/net/wireless/rtlwifi/rtl8192de/dm.c:1141 rtl92d_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'cckswing_table_ch1ch13' 33 <= 255
drivers/net/wireless/rtlwifi/rtl8192de/dm.c:1144 rtl92d_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'cckswing_table_ch1ch13' 33 <= 255
drivers/net/wireless/rtlwifi/rtl8192de/dm.c:1147 rtl92d_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'cckswing_table_ch1ch13' 33 <= 255
drivers/net/wireless/rtlwifi/rtl8192de/dm.c:1151 rtl92d_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'cckswing_table_ch14' 33 <= 255
drivers/net/wireless/rtlwifi/rtl8192de/dm.c:1154 rtl92d_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'cckswing_table_ch14' 33 <= 255
drivers/net/wireless/rtlwifi/rtl8192de/dm.c:1157 rtl92d_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'cckswing_table_ch14' 33 <= 255
drivers/net/wireless/rtlwifi/rtl8192de/dm.c:1160 rtl92d_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'cckswing_table_ch14' 33 <= 255
drivers/net/wireless/rtlwifi/rtl8192de/dm.c:1163 rtl92d_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'cckswing_table_ch14' 33 <= 255
drivers/net/wireless/rtlwifi/rtl8192de/dm.c:1166 rtl92d_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'cckswing_table_ch14' 33 <= 255
drivers/net/wireless/rtlwifi/rtl8192de/dm.c:1169 rtl92d_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'cckswing_table_ch14' 33 <= 255
drivers/net/wireless/rtlwifi/rtl8192de/dm.c:1172 rtl92d_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow 'cckswing_table_ch14' 33 <= 255

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/dm.c b/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
index 47875ba..eaeee77 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
@@ -840,9 +840,9 @@ static void rtl92d_dm_txpower_tracking_callback_thermalmeter(
 	bool internal_pa = false;
 	long ele_a = 0, ele_d, temp_cck, val_x, value32;
 	long val_y, ele_c = 0;
-	u8 ofdm_index[2];
+	u8 ofdm_index[3];
 	s8 cck_index = 0;
-	u8 ofdm_index_old[2] = {0, 0};
+	u8 ofdm_index_old[3] = {0, 0, 0};
 	s8 cck_index_old = 0;
 	u8 index;
 	int i;
@@ -1118,6 +1118,10 @@ static void rtl92d_dm_txpower_tracking_callback_thermalmeter(
 				 val_x, val_y, ele_a, ele_c, ele_d,
 				 val_x, val_y);
 
+			if (cck_index >= CCK_TABLE_SIZE)
+				cck_index = CCK_TABLE_SIZE - 1;
+			if (cck_index < 0)
+				cck_index = 0;
 			if (rtlhal->current_bandtype == BAND_ON_2_4G) {
 				/* Adjust CCK according to IQK result */
 				if (!rtlpriv->dm.cck_inch14) {
-- 
1.8.1.4

From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 1/8 V4] rtlwifi: rtl8192du: Fix smatch errors in /rtl8192de/dm.c
Date: Wed, 25 Sep 2013 12:57:42 -0500
Message-ID: <1380131869-19185-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1380131869-19185-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1380131869-19185-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

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

This patch fixes several off-by-one errors. It also removes a comment
referencing variable 'noise' in the rts_stats struct.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c  | 8 ++++++--
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c | 1 -
 2 files changed, 6 insertions(+), 3 deletions(-)

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
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
index b8ec718..945ddec 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
@@ -526,7 +526,6 @@ bool rtl92de_rx_query_desc(struct ieee80211_hw *hw,	struct rtl_stats *stats,
 	}
 	/*rx_status->qual = stats->signal; */
 	rx_status->signal = stats->rssi + 10;
-	/*rx_status->noise = -stats->noise; */
 	return true;
 }
 
-- 
1.8.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

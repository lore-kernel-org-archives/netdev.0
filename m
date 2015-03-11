From: Priit Laes <plaes@plaes.org>
Subject: [PATCH 1/6] rtlwifi: Use common rtl_query_rxpwrpercentage function
Date: Wed, 11 Mar 2015 22:03:24 +0200
Message-ID: <1426104209-6913-2-git-send-email-plaes@plaes.org>
References: <1426104209-6913-1-git-send-email-plaes@plaes.org>
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Priit Laes <plaes@plaes.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from plaes.org ([188.166.43.21]:51902 "EHLO plaes.org"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752297AbbCKUDr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 16:03:47 -0400
In-Reply-To: <1426104209-6913-1-git-send-email-plaes@plaes.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Priit Laes <plaes@plaes.org>
---
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c | 14 ++------------
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c | 16 +++-------------
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c | 16 +++-------------
 drivers/net/wireless/rtlwifi/stats.c         |  4 ++--
 4 files changed, 10 insertions(+), 40 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
index 84ddd4d..4eedf39 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -49,16 +49,6 @@ static u8 _rtl92ce_map_hwqueue_to_fwqueue(struct sk_buff *skb, u8 hw_queue)
 	return skb->priority;
 }
 
-static u8 _rtl92c_query_rxpwrpercentage(char antpower)
-{
-	if ((antpower <= -100) || (antpower >= 20))
-		return 0;
-	else if (antpower >= 0)
-		return 100;
-	else
-		return 100 + antpower;
-}
-
 static u8 _rtl92c_evm_db_to_percentage(char value)
 {
 	char ret_val;
@@ -236,7 +226,7 @@ static void _rtl92ce_query_rxphystatus(struct ieee80211_hw *hw,
 			rx_pwr[i] =
 			    ((p_drvinfo->gain_trsw[i] & 0x3f) * 2) - 110;
 			/* Translate DBM to percentage. */
-			rssi = _rtl92c_query_rxpwrpercentage(rx_pwr[i]);
+			rssi = rtl_query_rxpwrpercentage(rx_pwr[i]);
 			total_rssi += rssi;
 			/* Get Rx snr value in DB */
 			rtlpriv->stats.rx_snr_db[i] =
@@ -251,7 +241,7 @@ static void _rtl92ce_query_rxphystatus(struct ieee80211_hw *hw,
 		 * hardware (for rate adaptive)
 		 */
 		rx_pwr_all = ((p_drvinfo->pwdb_all >> 1) & 0x7f) - 110;
-		pwdb_all = _rtl92c_query_rxpwrpercentage(rx_pwr_all);
+		pwdb_all = rtl_query_rxpwrpercentage(rx_pwr_all);
 		pstats->rx_pwdb_all = pwdb_all;
 		pstats->rxpower = rx_pwr_all;
 		pstats->recvsignalpower = rx_pwr_all;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
index 133e395..f55b35c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
@@ -714,16 +714,6 @@ void rtl92c_set_data_filter(struct ieee80211_hw *hw, u16 filter)
 }
 /*==============================================================*/
 
-static u8 _rtl92c_query_rxpwrpercentage(char antpower)
-{
-	if ((antpower <= -100) || (antpower >= 20))
-		return 0;
-	else if (antpower >= 0)
-		return 100;
-	else
-		return 100 + antpower;
-}
-
 static u8 _rtl92c_evm_db_to_percentage(char value)
 {
 	char ret_val;
@@ -838,7 +828,7 @@ static void _rtl92c_query_rxphystatus(struct ieee80211_hw *hw,
 				break;
 			}
 		}
-		pwdb_all = _rtl92c_query_rxpwrpercentage(rx_pwr_all);
+		pwdb_all = rtl_query_rxpwrpercentage(rx_pwr_all);
 		pstats->rx_pwdb_all = pwdb_all;
 		pstats->recvsignalpower = rx_pwr_all;
 		if (packet_match_bssid) {
@@ -866,7 +856,7 @@ static void _rtl92c_query_rxphystatus(struct ieee80211_hw *hw,
 				rf_rx_num++;
 			rx_pwr[i] =
 			    ((p_drvinfo->gain_trsw[i] & 0x3f) * 2) - 110;
-			rssi = _rtl92c_query_rxpwrpercentage(rx_pwr[i]);
+			rssi = rtl_query_rxpwrpercentage(rx_pwr[i]);
 			total_rssi += rssi;
 			rtlpriv->stats.rx_snr_db[i] =
 			    (long)(p_drvinfo->rxsnr[i] / 2);
@@ -875,7 +865,7 @@ static void _rtl92c_query_rxphystatus(struct ieee80211_hw *hw,
 				pstats->rx_mimo_signalstrength[i] = (u8) rssi;
 		}
 		rx_pwr_all = ((p_drvinfo->pwdb_all >> 1) & 0x7f) - 110;
-		pwdb_all = _rtl92c_query_rxpwrpercentage(rx_pwr_all);
+		pwdb_all = rtl_query_rxpwrpercentage(rx_pwr_all);
 		pstats->rx_pwdb_all = pwdb_all;
 		pstats->rxpower = rx_pwr_all;
 		pstats->recvsignalpower = rx_pwr_all;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
index 1feaa62..54736dd 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
@@ -48,16 +48,6 @@ static u8 _rtl92de_map_hwqueue_to_fwqueue(struct sk_buff *skb, u8 hw_queue)
 	return skb->priority;
 }
 
-static u8 _rtl92d_query_rxpwrpercentage(char antpower)
-{
-	if ((antpower <= -100) || (antpower >= 20))
-		return 0;
-	else if (antpower >= 0)
-		return 100;
-	else
-		return 100 + antpower;
-}
-
 static u8 _rtl92d_evm_db_to_percentage(char value)
 {
 	char ret_val = value;
@@ -181,7 +171,7 @@ static void _rtl92de_query_rxphystatus(struct ieee80211_hw *hw,
 				break;
 			}
 		}
-		pwdb_all = _rtl92d_query_rxpwrpercentage(rx_pwr_all);
+		pwdb_all = rtl_query_rxpwrpercentage(rx_pwr_all);
 		/* CCK gain is smaller than OFDM/MCS gain,  */
 		/* so we add gain diff by experiences, the val is 6 */
 		pwdb_all += 6;
@@ -223,7 +213,7 @@ static void _rtl92de_query_rxphystatus(struct ieee80211_hw *hw,
 				rf_rx_num++;
 			rx_pwr[i] = ((p_drvinfo->gain_trsw[i] & 0x3f) * 2)
 				    - 110;
-			rssi = _rtl92d_query_rxpwrpercentage(rx_pwr[i]);
+			rssi = rtl_query_rxpwrpercentage(rx_pwr[i]);
 			total_rssi += rssi;
 			rtlpriv->stats.rx_snr_db[i] =
 					 (long)(p_drvinfo->rxsnr[i] / 2);
@@ -231,7 +221,7 @@ static void _rtl92de_query_rxphystatus(struct ieee80211_hw *hw,
 				pstats->rx_mimo_signalstrength[i] = (u8) rssi;
 		}
 		rx_pwr_all = ((p_drvinfo->pwdb_all >> 1) & 0x7f) - 106;
-		pwdb_all = _rtl92d_query_rxpwrpercentage(rx_pwr_all);
+		pwdb_all = rtl_query_rxpwrpercentage(rx_pwr_all);
 		pstats->rx_pwdb_all = pwdb_all;
 		pstats->rxpower = rx_pwr_all;
 		pstats->recvsignalpower = rx_pwr_all;
diff --git a/drivers/net/wireless/rtlwifi/stats.c b/drivers/net/wireless/rtlwifi/stats.c
index 2d0736a..874e7d1 100644
--- a/drivers/net/wireless/rtlwifi/stats.c
+++ b/drivers/net/wireless/rtlwifi/stats.c
@@ -26,14 +26,14 @@
 #include "stats.h"
 #include <linux/export.h>
 
+/* TODO: Figure out a better name */
 u8 rtl_query_rxpwrpercentage(char antpower)
 {
 	if ((antpower <= -100) || (antpower >= 20))
 		return 0;
 	else if (antpower >= 0)
 		return 100;
-	else
-		return 100 + antpower;
+	return 100 + antpower;
 }
 EXPORT_SYMBOL(rtl_query_rxpwrpercentage);
 
-- 
2.3.1

From: Priit Laes <plaes@plaes.org>
Subject: [PATCH v2 4/4] rtlwifi: Use common rtl_query_rxpwrpercentage function
Date: Sun, 22 Mar 2015 15:35:20 +0200
Message-ID: <1427031320-10913-5-git-send-email-plaes@plaes.org>
References: <1427031320-10913-1-git-send-email-plaes@plaes.org>
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Joe Perches <joe@perches.com>, Priit Laes <plaes@plaes.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from plaes.org ([188.166.43.21]:54675 "EHLO plaes.org"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751762AbbCVNgI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Mar 2015 09:36:08 -0400
In-Reply-To: <1427031320-10913-1-git-send-email-plaes@plaes.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Priit Laes <plaes@plaes.org>
---
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c | 14 ++------------
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c | 16 +++-------------
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c | 16 +++-------------
 drivers/net/wireless/rtlwifi/stats.c         |  7 ++++---
 4 files changed, 12 insertions(+), 41 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
index e2474bd..6884af4 100644
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
 static void _rtl92ce_query_rxphystatus(struct ieee80211_hw *hw,
 				       struct rtl_stats *pstats,
 				       struct rx_desc_92c *pdesc,
@@ -187,7 +177,7 @@ static void _rtl92ce_query_rxphystatus(struct ieee80211_hw *hw,
 			rx_pwr[i] =
 			    ((p_drvinfo->gain_trsw[i] & 0x3f) * 2) - 110;
 			/* Translate DBM to percentage. */
-			rssi = _rtl92c_query_rxpwrpercentage(rx_pwr[i]);
+			rssi = rtl_query_rxpwrpercentage(rx_pwr[i]);
 			total_rssi += rssi;
 			/* Get Rx snr value in DB */
 			rtlpriv->stats.rx_snr_db[i] =
@@ -202,7 +192,7 @@ static void _rtl92ce_query_rxphystatus(struct ieee80211_hw *hw,
 		 * hardware (for rate adaptive)
 		 */
 		rx_pwr_all = ((p_drvinfo->pwdb_all >> 1) & 0x7f) - 110;
-		pwdb_all = _rtl92c_query_rxpwrpercentage(rx_pwr_all);
+		pwdb_all = rtl_query_rxpwrpercentage(rx_pwr_all);
 		pstats->rx_pwdb_all = pwdb_all;
 		pstats->rxpower = rx_pwr_all;
 		pstats->recvsignalpower = rx_pwr_all;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
index 18edd8e..728e4ff 100644
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
 static void _rtl92c_query_rxphystatus(struct ieee80211_hw *hw,
 				      struct rtl_stats *pstats,
 				      struct rx_desc_92c *p_desc,
@@ -794,7 +784,7 @@ static void _rtl92c_query_rxphystatus(struct ieee80211_hw *hw,
 				break;
 			}
 		}
-		pwdb_all = _rtl92c_query_rxpwrpercentage(rx_pwr_all);
+		pwdb_all = rtl_query_rxpwrpercentage(rx_pwr_all);
 		pstats->rx_pwdb_all = pwdb_all;
 		pstats->recvsignalpower = rx_pwr_all;
 		if (packet_match_bssid) {
@@ -822,7 +812,7 @@ static void _rtl92c_query_rxphystatus(struct ieee80211_hw *hw,
 				rf_rx_num++;
 			rx_pwr[i] =
 			    ((p_drvinfo->gain_trsw[i] & 0x3f) * 2) - 110;
-			rssi = _rtl92c_query_rxpwrpercentage(rx_pwr[i]);
+			rssi = rtl_query_rxpwrpercentage(rx_pwr[i]);
 			total_rssi += rssi;
 			rtlpriv->stats.rx_snr_db[i] =
 			    (long)(p_drvinfo->rxsnr[i] / 2);
@@ -831,7 +821,7 @@ static void _rtl92c_query_rxphystatus(struct ieee80211_hw *hw,
 				pstats->rx_mimo_signalstrength[i] = (u8) rssi;
 		}
 		rx_pwr_all = ((p_drvinfo->pwdb_all >> 1) & 0x7f) - 110;
-		pwdb_all = _rtl92c_query_rxpwrpercentage(rx_pwr_all);
+		pwdb_all = rtl_query_rxpwrpercentage(rx_pwr_all);
 		pstats->rx_pwdb_all = pwdb_all;
 		pstats->rxpower = rx_pwr_all;
 		pstats->recvsignalpower = rx_pwr_all;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
index 64ad847..44fcf79 100644
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
 static long _rtl92de_translate_todbm(struct ieee80211_hw *hw,
 				     u8 signal_strength_index)
 {
@@ -139,7 +129,7 @@ static void _rtl92de_query_rxphystatus(struct ieee80211_hw *hw,
 				break;
 			}
 		}
-		pwdb_all = _rtl92d_query_rxpwrpercentage(rx_pwr_all);
+		pwdb_all = rtl_query_rxpwrpercentage(rx_pwr_all);
 		/* CCK gain is smaller than OFDM/MCS gain,  */
 		/* so we add gain diff by experiences, the val is 6 */
 		pwdb_all += 6;
@@ -181,7 +171,7 @@ static void _rtl92de_query_rxphystatus(struct ieee80211_hw *hw,
 				rf_rx_num++;
 			rx_pwr[i] = ((p_drvinfo->gain_trsw[i] & 0x3f) * 2)
 				    - 110;
-			rssi = _rtl92d_query_rxpwrpercentage(rx_pwr[i]);
+			rssi = rtl_query_rxpwrpercentage(rx_pwr[i]);
 			total_rssi += rssi;
 			rtlpriv->stats.rx_snr_db[i] =
 					 (long)(p_drvinfo->rxsnr[i] / 2);
@@ -189,7 +179,7 @@ static void _rtl92de_query_rxphystatus(struct ieee80211_hw *hw,
 				pstats->rx_mimo_signalstrength[i] = (u8) rssi;
 		}
 		rx_pwr_all = ((p_drvinfo->pwdb_all >> 1) & 0x7f) - 106;
-		pwdb_all = _rtl92d_query_rxpwrpercentage(rx_pwr_all);
+		pwdb_all = rtl_query_rxpwrpercentage(rx_pwr_all);
 		pstats->rx_pwdb_all = pwdb_all;
 		pstats->rxpower = rx_pwr_all;
 		pstats->recvsignalpower = rx_pwr_all;
diff --git a/drivers/net/wireless/rtlwifi/stats.c b/drivers/net/wireless/rtlwifi/stats.c
index 4cce472..1fa19d5 100644
--- a/drivers/net/wireless/rtlwifi/stats.c
+++ b/drivers/net/wireless/rtlwifi/stats.c
@@ -26,14 +26,15 @@
 #include "stats.h"
 #include <linux/export.h>
 
+/* TODO: Figure out a better name */
 u8 rtl_query_rxpwrpercentage(char antpower)
 {
 	if ((antpower <= -100) || (antpower >= 20))
 		return 0;
-	else if (antpower >= 0)
-		return 100;
-	else
+	else if (antpower < 0)
 		return 100 + antpower;
+	else
+		return 100;
 }
 EXPORT_SYMBOL(rtl_query_rxpwrpercentage);
 
-- 
2.3.3

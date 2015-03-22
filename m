From: Priit Laes <plaes@plaes.org>
Subject: [PATCH v2 2/4] rtlwifi: Use common rtl_signal_scale_mapping
Date: Sun, 22 Mar 2015 15:35:18 +0200
Message-ID: <1427031320-10913-3-git-send-email-plaes@plaes.org>
References: <1427031320-10913-1-git-send-email-plaes@plaes.org>
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Joe Perches <joe@perches.com>, Priit Laes <plaes@plaes.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from plaes.org ([188.166.43.21]:54665 "EHLO plaes.org"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751742AbbCVNgH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Mar 2015 09:36:07 -0400
In-Reply-To: <1427031320-10913-1-git-send-email-plaes@plaes.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Priit Laes <plaes@plaes.org>
---
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c |  8 +++----
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c | 34 ++-------------------------
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c | 33 ++------------------------
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c | 35 ++++------------------------
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.c |  8 +++----
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c |  8 +++----
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c |  8 +++----
 drivers/net/wireless/rtlwifi/rtl8723be/trx.c |  8 +++----
 drivers/net/wireless/rtlwifi/rtl8821ae/trx.c |  8 +++----
 drivers/net/wireless/rtlwifi/stats.c         |  2 +-
 drivers/net/wireless/rtlwifi/stats.h         |  2 +-
 11 files changed, 34 insertions(+), 120 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
index 791efbe..d1ca048 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
@@ -247,11 +247,11 @@ static void _rtl88ee_query_rxphystatus(struct ieee80211_hw *hw,
 	 * make it good looking, from 0~100.
 	 */
 	if (is_cck)
-		pstatus->signalstrength = (u8)(rtl_signal_scale_mapping(hw,
-			pwdb_all));
+		pstatus->signalstrength =
+			(u8)(rtl_signal_scale_mapping(pwdb_all));
 	else if (rf_rx_num != 0)
-		pstatus->signalstrength = (u8)(rtl_signal_scale_mapping(hw,
-			total_rssi /= rf_rx_num));
+		pstatus->signalstrength =
+			(u8)(rtl_signal_scale_mapping(total_rssi /= rf_rx_num));
 	/*HW antenna diversity*/
 	rtldm->fat_table.antsel_rx_keep_0 = phystrpt->ant_sel;
 	rtldm->fat_table.antsel_rx_keep_1 = phystrpt->ant_sel_b;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
index f6cf05e..e2474bd 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -59,35 +59,6 @@ static u8 _rtl92c_query_rxpwrpercentage(char antpower)
 		return 100 + antpower;
 }
 
-static long _rtl92ce_signal_scale_mapping(struct ieee80211_hw *hw,
-		long currsig)
-{
-	long retsig;
-
-	if (currsig >= 61 && currsig <= 100)
-		retsig = 90 + ((currsig - 60) / 4);
-	else if (currsig >= 41 && currsig <= 60)
-		retsig = 78 + ((currsig - 40) / 2);
-	else if (currsig >= 31 && currsig <= 40)
-		retsig = 66 + (currsig - 30);
-	else if (currsig >= 21 && currsig <= 30)
-		retsig = 54 + (currsig - 20);
-	else if (currsig >= 5 && currsig <= 20)
-		retsig = 42 + (((currsig - 5) * 2) / 3);
-	else if (currsig == 4)
-		retsig = 36;
-	else if (currsig == 3)
-		retsig = 27;
-	else if (currsig == 2)
-		retsig = 18;
-	else if (currsig == 1)
-		retsig = 9;
-	else
-		retsig = currsig;
-
-	return retsig;
-}
-
 static void _rtl92ce_query_rxphystatus(struct ieee80211_hw *hw,
 				       struct rtl_stats *pstats,
 				       struct rx_desc_92c *pdesc,
@@ -263,11 +234,10 @@ static void _rtl92ce_query_rxphystatus(struct ieee80211_hw *hw,
 	 */
 	if (is_cck_rate)
 		pstats->signalstrength =
-		    (u8) (_rtl92ce_signal_scale_mapping(hw, pwdb_all));
+		    (u8) (rtl_signal_scale_mapping(pwdb_all));
 	else if (rf_rx_num != 0)
 		pstats->signalstrength =
-		    (u8) (_rtl92ce_signal_scale_mapping
-			  (hw, total_rssi /= rf_rx_num));
+		    (u8) (rtl_signal_scale_mapping(total_rssi /= rf_rx_num));
 }
 
 static void _rtl92ce_translate_rx_signal_stuff(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
index 40e5a84..18edd8e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
@@ -724,34 +724,6 @@ static u8 _rtl92c_query_rxpwrpercentage(char antpower)
 		return 100 + antpower;
 }
 
-static long _rtl92c_signal_scale_mapping(struct ieee80211_hw *hw,
-		long currsig)
-{
-	long retsig;
-
-	if (currsig >= 61 && currsig <= 100)
-		retsig = 90 + ((currsig - 60) / 4);
-	else if (currsig >= 41 && currsig <= 60)
-		retsig = 78 + ((currsig - 40) / 2);
-	else if (currsig >= 31 && currsig <= 40)
-		retsig = 66 + (currsig - 30);
-	else if (currsig >= 21 && currsig <= 30)
-		retsig = 54 + (currsig - 20);
-	else if (currsig >= 5 && currsig <= 20)
-		retsig = 42 + (((currsig - 5) * 2) / 3);
-	else if (currsig == 4)
-		retsig = 36;
-	else if (currsig == 3)
-		retsig = 27;
-	else if (currsig == 2)
-		retsig = 18;
-	else if (currsig == 1)
-		retsig = 9;
-	else
-		retsig = currsig;
-	return retsig;
-}
-
 static void _rtl92c_query_rxphystatus(struct ieee80211_hw *hw,
 				      struct rtl_stats *pstats,
 				      struct rx_desc_92c *p_desc,
@@ -882,11 +854,10 @@ static void _rtl92c_query_rxphystatus(struct ieee80211_hw *hw,
 	}
 	if (is_cck_rate)
 		pstats->signalstrength =
-		    (u8) (_rtl92c_signal_scale_mapping(hw, pwdb_all));
+		    (u8) (rtl_signal_scale_mapping(pwdb_all));
 	else if (rf_rx_num != 0)
 		pstats->signalstrength =
-		    (u8) (_rtl92c_signal_scale_mapping
-			  (hw, total_rssi /= rf_rx_num));
+		    (u8) (rtl_signal_scale_mapping(total_rssi /= rf_rx_num));
 }
 
 void rtl92c_translate_rx_signal_stuff(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
index 7a621f9..64ad847 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
@@ -68,33 +68,6 @@ static long _rtl92de_translate_todbm(struct ieee80211_hw *hw,
 	return signal_power;
 }
 
-static long _rtl92de_signal_scale_mapping(struct ieee80211_hw *hw, long currsig)
-{
-	long retsig;
-
-	if (currsig >= 61 && currsig <= 100)
-		retsig = 90 + ((currsig - 60) / 4);
-	else if (currsig >= 41 && currsig <= 60)
-		retsig = 78 + ((currsig - 40) / 2);
-	else if (currsig >= 31 && currsig <= 40)
-		retsig = 66 + (currsig - 30);
-	else if (currsig >= 21 && currsig <= 30)
-		retsig = 54 + (currsig - 20);
-	else if (currsig >= 5 && currsig <= 20)
-		retsig = 42 + (((currsig - 5) * 2) / 3);
-	else if (currsig == 4)
-		retsig = 36;
-	else if (currsig == 3)
-		retsig = 27;
-	else if (currsig == 2)
-		retsig = 18;
-	else if (currsig == 1)
-		retsig = 9;
-	else
-		retsig = currsig;
-	return retsig;
-}
-
 static void _rtl92de_query_rxphystatus(struct ieee80211_hw *hw,
 				       struct rtl_stats *pstats,
 				       struct rx_desc_92d *pdesc,
@@ -237,11 +210,11 @@ static void _rtl92de_query_rxphystatus(struct ieee80211_hw *hw,
 		}
 	}
 	if (is_cck_rate)
-		pstats->signalstrength = (u8)(_rtl92de_signal_scale_mapping(hw,
-				pwdb_all));
+		pstats->signalstrength =
+			(u8)(rtl_signal_scale_mapping(pwdb_all));
 	else if (rf_rx_num != 0)
-		pstats->signalstrength = (u8)(_rtl92de_signal_scale_mapping(hw,
-				total_rssi /= rf_rx_num));
+		pstats->signalstrength =
+			(u8)(rtl_signal_scale_mapping(total_rssi /= rf_rx_num));
 }
 
 static void rtl92d_loop_over_paths(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c
index d39ee67..de8c9f8 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c
@@ -225,11 +225,11 @@ static void _rtl92ee_query_rxphystatus(struct ieee80211_hw *hw,
 	 * make it good looking, from 0~100.
 	 */
 	if (is_cck)
-		pstatus->signalstrength = (u8)(rtl_signal_scale_mapping(hw,
-								     pwdb_all));
+		pstatus->signalstrength =
+			(u8)(rtl_signal_scale_mapping(pwdb_all));
 	else if (rf_rx_num != 0)
-		pstatus->signalstrength = (u8)(rtl_signal_scale_mapping(hw,
-						      total_rssi /= rf_rx_num));
+		pstatus->signalstrength =
+			(u8)(rtl_signal_scale_mapping(total_rssi /= rf_rx_num));
 }
 
 static void _rtl92ee_translate_rx_signal_stuff(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
index 125b29b..f88d125 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
@@ -210,11 +210,11 @@ static void _rtl92se_query_rxphystatus(struct ieee80211_hw *hw,
 	}
 
 	if (is_cck)
-		pstats->signalstrength = (u8)(rtl_signal_scale_mapping(hw,
-					 pwdb_all));
+		pstats->signalstrength =
+			(u8)(rtl_signal_scale_mapping(pwdb_all));
 	else if (rf_rx_num != 0)
-		pstats->signalstrength = (u8) (rtl_signal_scale_mapping(hw,
-				total_rssi /= rf_rx_num));
+		pstats->signalstrength =
+			(u8)(rtl_signal_scale_mapping(total_rssi /= rf_rx_num));
 }
 
 static void _rtl92se_translate_rx_signal_stuff(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
index 2f7c144..2003f11 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
@@ -229,11 +229,11 @@ static void _rtl8723e_query_rxphystatus(struct ieee80211_hw *hw,
 	 * make it good looking, from 0~100.
 	 */
 	if (is_cck)
-		pstatus->signalstrength = (u8)(rtl_signal_scale_mapping(hw,
-			pwdb_all));
+		pstatus->signalstrength =
+			(u8)(rtl_signal_scale_mapping(pwdb_all));
 	else if (rf_rx_num != 0)
-		pstatus->signalstrength = (u8)(rtl_signal_scale_mapping(hw,
-			total_rssi /= rf_rx_num));
+		pstatus->signalstrength =
+			(u8)(rtl_signal_scale_mapping(total_rssi /= rf_rx_num));
 }
 
 static void translate_rx_signal_stuff(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/trx.c b/drivers/net/wireless/rtlwifi/rtl8723be/trx.c
index 338ec9a..d7c2edc 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/trx.c
@@ -201,11 +201,11 @@ static void _rtl8723be_query_rxphystatus(struct ieee80211_hw *hw,
 	 * make it good looking, from 0~100.
 	 */
 	if (is_cck)
-		pstatus->signalstrength = (u8)(rtl_signal_scale_mapping(hw,
-								pwdb_all));
+		pstatus->signalstrength =
+			(u8)rtl_signal_scale_mapping(pwdb_all);
 	else if (rf_rx_num != 0)
-		pstatus->signalstrength = (u8)(rtl_signal_scale_mapping(hw,
-						total_rssi /= rf_rx_num));
+		pstatus->signalstrength =
+			(u8)(rtl_signal_scale_mapping(total_rssi /= rf_rx_num));
 }
 
 static void _rtl8723be_translate_rx_signal_stuff(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/trx.c b/drivers/net/wireless/rtlwifi/rtl8821ae/trx.c
index 174743a..659bac9 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/trx.c
@@ -285,11 +285,11 @@ static void query_rxphystatus(struct ieee80211_hw *hw,
 	 * make it good looking, from 0~100.
 	 */
 	if (is_cck)
-		pstatus->signalstrength = (u8)(rtl_signal_scale_mapping(hw,
-			pwdb_all));
+		pstatus->signalstrength =
+			(u8)(rtl_signal_scale_mapping(pwdb_all));
 	else if (rf_rx_num != 0)
-		pstatus->signalstrength = (u8)(rtl_signal_scale_mapping(hw,
-			total_rssi /= rf_rx_num));
+		pstatus->signalstrength =
+			(u8)(rtl_signal_scale_mapping(total_rssi /= rf_rx_num));
 	/*HW antenna diversity*/
 	rtldm->fat_table.antsel_rx_keep_0 = p_phystrpt->antidx_anta;
 	rtldm->fat_table.antsel_rx_keep_1 = p_phystrpt->antidx_antb;
diff --git a/drivers/net/wireless/rtlwifi/stats.c b/drivers/net/wireless/rtlwifi/stats.c
index d8b3069..9ebeb6e 100644
--- a/drivers/net/wireless/rtlwifi/stats.c
+++ b/drivers/net/wireless/rtlwifi/stats.c
@@ -58,7 +58,7 @@ static long rtl_translate_todbm(struct ieee80211_hw *hw,
 	return signal_power;
 }
 
-long rtl_signal_scale_mapping(struct ieee80211_hw *hw, long currsig)
+long rtl_signal_scale_mapping(long currsig)
 {
 	long retsig;
 
diff --git a/drivers/net/wireless/rtlwifi/stats.h b/drivers/net/wireless/rtlwifi/stats.h
index 2b57dff..689006b 100644
--- a/drivers/net/wireless/rtlwifi/stats.h
+++ b/drivers/net/wireless/rtlwifi/stats.h
@@ -35,7 +35,7 @@
 
 u8 rtl_query_rxpwrpercentage(char antpower);
 u8 rtl_evm_db_to_percentage(char value);
-long rtl_signal_scale_mapping(struct ieee80211_hw *hw, long currsig);
+long rtl_signal_scale_mapping(long currsig);
 void rtl_process_phyinfo(struct ieee80211_hw *hw, u8 *buffer,
 			 struct rtl_stats *pstatus);
 
-- 
2.3.3

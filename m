From: Priit Laes <plaes@plaes.org>
Subject: [PATCH 3/6] rtlwifi: Use common rtl_evm_db_to_percentage
Date: Wed, 11 Mar 2015 22:03:26 +0200
Message-ID: <1426104209-6913-4-git-send-email-plaes@plaes.org>
References: <1426104209-6913-1-git-send-email-plaes@plaes.org>
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Priit Laes <plaes@plaes.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from plaes.org ([188.166.43.21]:51911 "EHLO plaes.org"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752332AbbCKUDt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 16:03:49 -0400
In-Reply-To: <1426104209-6913-1-git-send-email-plaes@plaes.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Priit Laes <plaes@plaes.org>
---
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c | 22 +---------------------
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c | 18 +-----------------
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c | 17 +----------------
 3 files changed, 3 insertions(+), 54 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
index 4eedf39..4c7e804 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -49,26 +49,6 @@ static u8 _rtl92ce_map_hwqueue_to_fwqueue(struct sk_buff *skb, u8 hw_queue)
 	return skb->priority;
 }
 
-static u8 _rtl92c_evm_db_to_percentage(char value)
-{
-	char ret_val;
-	ret_val = value;
-
-	if (ret_val >= 0)
-		ret_val = 0;
-
-	if (ret_val <= -33)
-		ret_val = -33;
-
-	ret_val = 0 - ret_val;
-	ret_val *= 3;
-
-	if (ret_val == 99)
-		ret_val = 100;
-
-	return ret_val;
-}
-
 static long _rtl92ce_signal_scale_mapping(struct ieee80211_hw *hw,
 		long currsig)
 {
@@ -254,7 +234,7 @@ static void _rtl92ce_query_rxphystatus(struct ieee80211_hw *hw,
 			max_spatial_stream = 1;
 
 		for (i = 0; i < max_spatial_stream; i++) {
-			evm = _rtl92c_evm_db_to_percentage(p_drvinfo->rxevm[i]);
+			evm = rtl_evm_db_to_percentage(p_drvinfo->rxevm[i]);
 
 			if (packet_match_bssid) {
 				/* Fill value in RFD, Get the first
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
index f55b35c..60f2001 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
@@ -714,22 +714,6 @@ void rtl92c_set_data_filter(struct ieee80211_hw *hw, u16 filter)
 }
 /*==============================================================*/
 
-static u8 _rtl92c_evm_db_to_percentage(char value)
-{
-	char ret_val;
-
-	ret_val = value;
-	if (ret_val >= 0)
-		ret_val = 0;
-	if (ret_val <= -33)
-		ret_val = -33;
-	ret_val = 0 - ret_val;
-	ret_val *= 3;
-	if (ret_val == 99)
-		ret_val = 100;
-	return ret_val;
-}
-
 static long _rtl92c_signal_scale_mapping(struct ieee80211_hw *hw,
 		long currsig)
 {
@@ -876,7 +860,7 @@ static void _rtl92c_query_rxphystatus(struct ieee80211_hw *hw,
 		else
 			max_spatial_stream = 1;
 		for (i = 0; i < max_spatial_stream; i++) {
-			evm = _rtl92c_evm_db_to_percentage(p_drvinfo->rxevm[i]);
+			evm = rtl_evm_db_to_percentage(p_drvinfo->rxevm[i]);
 			if (packet_match_bssid) {
 				if (i == 0)
 					pstats->signalquality =
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
index 54736dd..369edd4 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
@@ -48,21 +48,6 @@ static u8 _rtl92de_map_hwqueue_to_fwqueue(struct sk_buff *skb, u8 hw_queue)
 	return skb->priority;
 }
 
-static u8 _rtl92d_evm_db_to_percentage(char value)
-{
-	char ret_val = value;
-
-	if (ret_val >= 0)
-		ret_val = 0;
-	if (ret_val <= -33)
-		ret_val = -33;
-	ret_val = 0 - ret_val;
-	ret_val *= 3;
-	if (ret_val == 99)
-		ret_val = 100;
-	return ret_val;
-}
-
 static long _rtl92de_translate_todbm(struct ieee80211_hw *hw,
 				     u8 signal_strength_index)
 {
@@ -231,7 +216,7 @@ static void _rtl92de_query_rxphystatus(struct ieee80211_hw *hw,
 		else
 			max_spatial_stream = 1;
 		for (i = 0; i < max_spatial_stream; i++) {
-			evm = _rtl92d_evm_db_to_percentage(p_drvinfo->rxevm[i]);
+			evm = rtl_evm_db_to_percentage(p_drvinfo->rxevm[i]);
 			if (packet_match_bssid) {
 				if (i == 0)
 					pstats->signalquality =
-- 
2.3.1

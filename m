From: Priit Laes <plaes@plaes.org>
Subject: [PATCH 4/6] rtlwifi: No need to export rtl_evm_dbm_jaguar anymore
Date: Wed, 11 Mar 2015 22:03:27 +0200
Message-ID: <1426104209-6913-5-git-send-email-plaes@plaes.org>
References: <1426104209-6913-1-git-send-email-plaes@plaes.org>
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Priit Laes <plaes@plaes.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from plaes.org ([188.166.43.21]:51915 "EHLO plaes.org"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752370AbbCKUDt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 16:03:49 -0400
In-Reply-To: <1426104209-6913-1-git-send-email-plaes@plaes.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is used only by rtl8821ae so move it there

Signed-off-by: Priit Laes <plaes@plaes.org>
---
 drivers/net/wireless/rtlwifi/rtl8821ae/trx.c | 16 +++++++++++++++-
 drivers/net/wireless/rtlwifi/stats.c         | 15 ---------------
 drivers/net/wireless/rtlwifi/stats.h         |  1 -
 3 files changed, 15 insertions(+), 17 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/trx.c b/drivers/net/wireless/rtlwifi/rtl8821ae/trx.c
index 72af4b9..174743a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/trx.c
@@ -64,6 +64,20 @@ static u16 odm_cfo(char value)
 	return ret_val;
 }
 
+static u8 _rtl8821ae_evm_dbm_jaguar(char value)
+{
+	char ret_val = value;
+
+	/* -33dB~0dB to 33dB ~ 0dB*/
+	if (ret_val == -128)
+		ret_val = 127;
+	else if (ret_val < 0)
+		ret_val = 0 - ret_val;
+
+	ret_val  = ret_val >> 1;
+	return ret_val;
+}
+
 static void query_rxphystatus(struct ieee80211_hw *hw,
 			      struct rtl_stats *pstatus, u8 *pdesc,
 			      struct rx_fwinfo_8821ae *p_drvinfo,
@@ -246,7 +260,7 @@ static void query_rxphystatus(struct ieee80211_hw *hw,
 
 		for (i = 0; i < max_spatial_stream; i++) {
 			evm = rtl_evm_db_to_percentage(p_phystrpt->rxevm[i]);
-			evmdbm = rtl_evm_dbm_jaguar(p_phystrpt->rxevm[i]);
+			evmdbm = _rtl8821ae_evm_dbm_jaguar(p_phystrpt->rxevm[i]);
 
 			if (bpacket_match_bssid) {
 				/* Fill value in RFD, Get the first
diff --git a/drivers/net/wireless/rtlwifi/stats.c b/drivers/net/wireless/rtlwifi/stats.c
index 2021223..7042b6e 100644
--- a/drivers/net/wireless/rtlwifi/stats.c
+++ b/drivers/net/wireless/rtlwifi/stats.c
@@ -48,21 +48,6 @@ u8 rtl_evm_db_to_percentage(char value)
 }
 EXPORT_SYMBOL(rtl_evm_db_to_percentage);
 
-u8 rtl_evm_dbm_jaguar(char value)
-{
-	char ret_val = value;
-
-	/* -33dB~0dB to 33dB ~ 0dB*/
-	if (ret_val == -128)
-		ret_val = 127;
-	else if (ret_val < 0)
-		ret_val = 0 - ret_val;
-
-	ret_val  = ret_val >> 1;
-	return ret_val;
-}
-EXPORT_SYMBOL(rtl_evm_dbm_jaguar);
-
 static long rtl_translate_todbm(struct ieee80211_hw *hw,
 			 u8 signal_strength_index)
 {
diff --git a/drivers/net/wireless/rtlwifi/stats.h b/drivers/net/wireless/rtlwifi/stats.h
index aa4eec8..2b57dff 100644
--- a/drivers/net/wireless/rtlwifi/stats.h
+++ b/drivers/net/wireless/rtlwifi/stats.h
@@ -35,7 +35,6 @@
 
 u8 rtl_query_rxpwrpercentage(char antpower);
 u8 rtl_evm_db_to_percentage(char value);
-u8 rtl_evm_dbm_jaguar(char value);
 long rtl_signal_scale_mapping(struct ieee80211_hw *hw, long currsig);
 void rtl_process_phyinfo(struct ieee80211_hw *hw, u8 *buffer,
 			 struct rtl_stats *pstatus);
-- 
2.3.1

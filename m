From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 11/11] rtlwifi: Move macro definitions to core
Date: Fri,  2 Jan 2015 10:58:28 -0600
Message-ID: <1420217908-1382-12-git-send-email-Larry.Finger@lwfinger.net>
References: <1420217908-1382-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:36273 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269AbbABQ6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 11:58:43 -0500
In-Reply-To: <1420217908-1382-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several of the drivers still were defining their own copies of various
macros. These are all moved into the core.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/core.h         | 1 +
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.h | 3 ---
 drivers/net/wireless/rtlwifi/rtl8192ee/dm.h | 3 ---
 drivers/net/wireless/rtlwifi/rtl8192se/dm.c | 6 +++---
 drivers/net/wireless/rtlwifi/rtl8192se/dm.h | 1 -
 drivers/net/wireless/rtlwifi/rtl8723be/dm.h | 3 ---
 drivers/net/wireless/rtlwifi/rtl8821ae/dm.h | 9 ---------
 7 files changed, 4 insertions(+), 22 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/core.h b/drivers/net/wireless/rtlwifi/core.h
index 1cde356..7b64e34 100644
--- a/drivers/net/wireless/rtlwifi/core.h
+++ b/drivers/net/wireless/rtlwifi/core.h
@@ -42,6 +42,7 @@
 
 #define DM_DIG_MAX			0x3e
 #define DM_DIG_MIN			0x1e
+#define DM_DIG_MAX_AP			0x32
 #define DM_DIG_BACKOFF_MAX		12
 #define DM_DIG_BACKOFF_MIN		-4
 #define DM_DIG_BACKOFF_DEFAULT		10
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/dm.h b/drivers/net/wireless/rtlwifi/rtl8188ee/dm.h
index 51ad3f9..071ccee 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/dm.h
@@ -186,9 +186,6 @@
 #define BW_AUTO_SWITCH_HIGH_LOW				25
 #define BW_AUTO_SWITCH_LOW_HIGH				30
 
-#define DM_DIG_MAX_AP					0x32
-#define DM_DIG_MIN_AP					0x20
-
 #define DM_DIG_FA_UPPER					0x3e
 #define DM_DIG_FA_LOWER					0x1e
 #define DM_DIG_FA_TH0					0x200
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/dm.h b/drivers/net/wireless/rtlwifi/rtl8192ee/dm.h
index 4880e19..107d5a4 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/dm.h
@@ -189,9 +189,6 @@
 #define BW_AUTO_SWITCH_HIGH_LOW			25
 #define BW_AUTO_SWITCH_LOW_HIGH			30
 
-#define DM_DIG_MAX_AP				0x32
-#define DM_DIG_MIN_AP				0x20
-
 #define DM_DIG_FA_UPPER				0x3e
 #define DM_DIG_FA_LOWER				0x1e
 #define DM_DIG_FA_TH0				0x200
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/dm.c b/drivers/net/wireless/rtlwifi/rtl8192se/dm.c
index 6cac70b..575980b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/dm.c
@@ -470,7 +470,7 @@ static void _rtl92s_dm_initial_gain_sta_beforeconnect(struct ieee80211_hw *hw)
 			if (digtable->backoff_enable_flag)
 				rtl92s_backoff_enable_flag(hw);
 			else
-				digtable->back_val = DM_DIG_BACKOFF;
+				digtable->back_val = DM_DIG_BACKOFF_MAX;
 
 			if ((digtable->rssi_val + 10 - digtable->back_val) >
 				digtable->rx_gain_max)
@@ -504,7 +504,7 @@ static void _rtl92s_dm_initial_gain_sta_beforeconnect(struct ieee80211_hw *hw)
 		digtable->dig_ext_port_stage = DIG_EXT_PORT_STAGE_MAX;
 		rtl92s_phy_set_fw_cmd(hw, FW_CMD_DIG_ENABLE);
 
-		digtable->back_val = DM_DIG_BACKOFF;
+		digtable->back_val = DM_DIG_BACKOFF_MAX;
 		digtable->cur_igvalue = rtlpriv->phy.default_initialgain[0];
 		digtable->pre_igvalue = 0;
 		return;
@@ -692,7 +692,7 @@ static void _rtl92s_dm_init_dig(struct ieee80211_hw *hw)
 
 	/* for dig debug rssi value */
 	digtable->rssi_val = 50;
-	digtable->back_val = DM_DIG_BACKOFF;
+	digtable->back_val = DM_DIG_BACKOFF_MAX;
 	digtable->rx_gain_max = DM_DIG_MAX;
 
 	digtable->rx_gain_min = DM_DIG_MIN;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/dm.h b/drivers/net/wireless/rtlwifi/rtl8192se/dm.h
index be07d81..de6ac79 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/dm.h
@@ -83,7 +83,6 @@ enum dm_ratr_sta {
 
 #define	DM_DIG_HIGH_PWR_THRESH_HIGH	75
 #define	DM_DIG_HIGH_PWR_THRESH_LOW	70
-#define	DM_DIG_BACKOFF			12
 #define	DM_DIG_MIN_Netcore		0x12
 
 void rtl92s_dm_watchdog(struct ieee80211_hw *hw);
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/dm.h b/drivers/net/wireless/rtlwifi/rtl8723be/dm.h
index 533b4f2..f752a2c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/dm.h
@@ -180,9 +180,6 @@
 #define BW_AUTO_SWITCH_HIGH_LOW			25
 #define BW_AUTO_SWITCH_LOW_HIGH			30
 
-#define DM_DIG_MAX_AP				0x32
-#define DM_DIG_MIN_AP				0x20
-
 #define DM_DIG_FA_UPPER				0x3e
 #define DM_DIG_FA_LOWER				0x1e
 #define DM_DIG_FA_TH0				0x200
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/dm.h b/drivers/net/wireless/rtlwifi/rtl8821ae/dm.h
index 5516557..625a6bb 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/dm.h
@@ -187,15 +187,6 @@
 #define BW_AUTO_SWITCH_HIGH_LOW		25
 #define BW_AUTO_SWITCH_LOW_HIGH		30
 
-#define DM_FALSEALARM_THRESH_LOW	400
-#define DM_FALSEALARM_THRESH_HIGH	1000
-
-#define DM_DIG_MAX					0x3e
-#define DM_DIG_MIN					0x1e
-
-#define DM_DIG_MAX_AP				0x32
-#define DM_DIG_MIN_AP				0x20
-
 #define DM_DIG_FA_UPPER				0x3e
 #define DM_DIG_FA_LOWER				0x1e
 #define DM_DIG_FA_TH0				200
-- 
2.1.2

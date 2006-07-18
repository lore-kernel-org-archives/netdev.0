From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 9/9] d80211: Add sparse bitwise annotations
Date: Tue, 18 Jul 2006 17:45:30 +0200 (CEST)
Message-ID: <20060718154530.2F064483BC@silver.suse.cz>
References: <20060718174442.485760904.midnight@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:41609 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932298AbWGRPnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 11:43:42 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060718174442.485760904.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Wu <flamingice@sourmilk.net>

This patch adds sparse bitwise annotations to d80211.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/net/d80211.h       |    6 +++---
 include/net/d80211_mgmt.h  |   42 +++++++++++++++++++++---------------------
 net/d80211/ieee80211_sta.c |    7 +------
 3 files changed, 25 insertions(+), 30 deletions(-)

2816781dfb1c8a2051a962e75cdba34da1811e22
diff --git a/include/net/d80211.h b/include/net/d80211.h
index fdb082c..85817ab 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -965,12 +965,12 @@ #define IEEE80211_MAX_FRAG_THRESHOLD 234
 #define IEEE80211_MAX_RTS_THRESHOLD 2347
 
 struct ieee80211_hdr {
-	u16 frame_control;
-	u16 duration_id;
+	__le16 frame_control;
+	__le16 duration_id;
 	u8 addr1[6];
 	u8 addr2[6];
 	u8 addr3[6];
-	u16 seq_ctrl;
+	__le16 seq_ctrl;
 	u8 addr4[6];
 } __attribute__ ((packed));
 
diff --git a/include/net/d80211_mgmt.h b/include/net/d80211_mgmt.h
index 8066af7..f623db3 100644
--- a/include/net/d80211_mgmt.h
+++ b/include/net/d80211_mgmt.h
@@ -15,50 +15,50 @@ #define D802_11_MGMT_H
 #include <linux/types.h>
 
 struct ieee80211_mgmt {
-	u16 frame_control;
-	u16 duration;
+	__le16 frame_control;
+	__le16 duration;
 	u8 da[6];
 	u8 sa[6];
 	u8 bssid[6];
-	u16 seq_ctrl;
+	__le16 seq_ctrl;
 	union {
 		struct {
-			u16 auth_alg;
-			u16 auth_transaction;
-			u16 status_code;
+			__le16 auth_alg;
+			__le16 auth_transaction;
+			__le16 status_code;
 			/* possibly followed by Challenge text */
 			u8 variable[0];
 		} __attribute__ ((packed)) auth;
 		struct {
-			u16 reason_code;
+			__le16 reason_code;
 		} __attribute__ ((packed)) deauth;
 		struct {
-			u16 capab_info;
-			u16 listen_interval;
+			__le16 capab_info;
+			__le16 listen_interval;
 			/* followed by SSID and Supported rates */
 			u8 variable[0];
 		} __attribute__ ((packed)) assoc_req;
 		struct {
-			u16 capab_info;
-			u16 status_code;
-			u16 aid;
+			__le16 capab_info;
+			__le16 status_code;
+			__le16 aid;
 			/* followed by Supported rates */
 			u8 variable[0];
 		} __attribute__ ((packed)) assoc_resp, reassoc_resp;
 		struct {
-			u16 capab_info;
-			u16 listen_interval;
+			__le16 capab_info;
+			__le16 listen_interval;
 			u8 current_ap[6];
 			/* followed by SSID and Supported rates */
 			u8 variable[0];
 		} __attribute__ ((packed)) reassoc_req;
 		struct {
-			u16 reason_code;
+			__le16 reason_code;
 		} __attribute__ ((packed)) disassoc;
 		struct {
-			u8 timestamp[8];
-			u16 beacon_int;
-			u16 capab_info;
+			__le64 timestamp;
+			__le16 beacon_int;
+			__le16 capab_info;
 			/* followed by some of SSID, Supported rates,
 			 * FH Params, DS Params, CF Params, IBSS Params, TIM */
 			u8 variable[0];
@@ -68,9 +68,9 @@ struct ieee80211_mgmt {
 			u8 variable[0];
 		} __attribute__ ((packed)) probe_req;
 		struct {
-			u8 timestamp[8];
-			u16 beacon_int;
-			u16 capab_info;
+			__le64 timestamp;
+			__le16 beacon_int;
+			__le16 capab_info;
 			/* followed by some of SSID, Supported rates,
 			 * FH Params, DS Params, CF Params, IBSS Params */
 			u8 variable[0];
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 82fbe3d..b0cfff1 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -1344,7 +1344,6 @@ static void ieee80211_rx_bss_info(struct
 	struct sta_info *sta;
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	u64 timestamp;
-	u8 *pos;
 
 	if (!beacon && memcmp(mgmt->da, dev->dev_addr, ETH_ALEN))
 		return; /* ignore ProbeResp to foreign address */
@@ -1359,11 +1358,7 @@ #endif
 	if (baselen > len)
 		return;
 
-	pos = mgmt->u.beacon.timestamp;
-	timestamp = ((u64) pos[7] << 56) | ((u64) pos[6] << 48) |
-		((u64) pos[5] << 40) | ((u64) pos[4] << 32) |
-		((u64) pos[3] << 24) | ((u64) pos[2] << 16) |
-		((u64) pos[1] << 8) | ((u64) pos[0]);
+	timestamp = le64_to_cpu(mgmt->u.beacon.timestamp);
 
 	if (sdata->type == IEEE80211_IF_TYPE_IBSS && beacon &&
 	    memcmp(mgmt->bssid, sdata->u.sta.bssid, ETH_ALEN) == 0) {
-- 
1.3.0


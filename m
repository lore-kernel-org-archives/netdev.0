From: Jiri Benc <jbenc@suse.cz>
Subject: [1/5] ieee80211: cleanup
Date: Tue, 24 May 2005 15:10:18 +0200
Message-ID: <20050524151018.3304fbeb@griffin.suse.cz>
References: <20050524150711.01632672@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, jgarzik@pobox.com, pavel@suse.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>
In-Reply-To: <20050524150711.01632672@griffin.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Cleanup of unused and duplicated constants and structures in the ieee80211
header.


Signed-off-by: Jiri Benc <jbenc@suse.cz>
Signed-off-by: Jirka Bohac <jbohac@suse.cz>

--- orig/include/net/ieee80211.h	2005-05-12 11:36:27.000000000 +0200
+++ new/include/net/ieee80211.h	2005-05-17 15:37:38.000000000 +0200
@@ -93,6 +93,8 @@
 	u16 length;
 } __attribute__ ((packed));
 
+#define IEEE80211_1ADDR_LEN 10
+#define IEEE80211_2ADDR_LEN 16
 #define IEEE80211_3ADDR_LEN 24
 #define IEEE80211_4ADDR_LEN 30
 #define IEEE80211_FCS_LEN    4
@@ -299,23 +301,6 @@
 #define WLAN_REASON_STA_REQ_ASSOC_WITHOUT_AUTH 9
 
 
-/* Information Element IDs */
-#define WLAN_EID_SSID 0
-#define WLAN_EID_SUPP_RATES 1
-#define WLAN_EID_FH_PARAMS 2
-#define WLAN_EID_DS_PARAMS 3
-#define WLAN_EID_CF_PARAMS 4
-#define WLAN_EID_TIM 5
-#define WLAN_EID_IBSS_PARAMS 6
-#define WLAN_EID_CHALLENGE 16
-#define WLAN_EID_RSN 48
-#define WLAN_EID_GENERIC 221
-
-#define IEEE80211_MGMT_HDR_LEN 24
-#define IEEE80211_DATA_HDR3_LEN 24
-#define IEEE80211_DATA_HDR4_LEN 30
-
-
 #define IEEE80211_STATMASK_SIGNAL (1<<0)
 #define IEEE80211_STATMASK_RSSI (1<<1)
 #define IEEE80211_STATMASK_NOISE (1<<2)
@@ -489,15 +474,6 @@
 
 */
 
-struct ieee80211_header_data {
-	u16 frame_ctl;
-	u16 duration_id;
-	u8 addr1[6];
-	u8 addr2[6];
-	u8 addr3[6];
-	u16 seq_ctrl;
-};
-
 #define BEACON_PROBE_SSID_ID_POSITION 12
 
 /* Management Frame Information Element Types */
@@ -542,7 +518,7 @@
 */
 
 struct ieee80211_authentication {
-	struct ieee80211_header_data header;
+	struct ieee80211_hdr_3addr header;
 	u16 algorithm;
 	u16 transaction;
 	u16 status;
@@ -551,7 +527,7 @@
 
 
 struct ieee80211_probe_response {
-	struct ieee80211_header_data header;
+	struct ieee80211_hdr_3addr header;
 	u32 time_stamp[2];
 	u16 beacon_interval;
 	u16 capability;
@@ -793,21 +769,21 @@
 
 extern inline int ieee80211_get_hdrlen(u16 fc)
 {
-	int hdrlen = 24;
+	int hdrlen = IEEE80211_3ADDR_LEN;
 
 	switch (WLAN_FC_GET_TYPE(fc)) {
 	case IEEE80211_FTYPE_DATA:
 		if ((fc & IEEE80211_FCTL_FROMDS) && (fc & IEEE80211_FCTL_TODS))
-			hdrlen = 30; /* Addr4 */
+			hdrlen = IEEE80211_4ADDR_LEN;
 		break;
 	case IEEE80211_FTYPE_CTL:
 		switch (WLAN_FC_GET_STYPE(fc)) {
 		case IEEE80211_STYPE_CTS:
 		case IEEE80211_STYPE_ACK:
-			hdrlen = 10;
+			hdrlen = IEEE80211_1ADDR_LEN;
 			break;
 		default:
-			hdrlen = 16;
+			hdrlen = IEEE80211_2ADDR_LEN;
 			break;
 		}
 		break;
--- orig/net/ieee80211/ieee80211_rx.c	2005-05-12 11:36:29.000000000 +0200
+++ new/net/ieee80211/ieee80211_rx.c	2005-05-17 15:37:38.000000000 +0200
@@ -475,7 +475,7 @@
 #endif
 
 	/* Data frame - extract src/dst addresses */
-	if (skb->len < IEEE80211_DATA_HDR3_LEN)
+	if (skb->len < IEEE80211_3ADDR_LEN)
 		goto rx_dropped;
 
 	switch (fc & (IEEE80211_FCTL_FROMDS | IEEE80211_FCTL_TODS)) {
@@ -488,7 +488,7 @@
 		memcpy(src, hdr->addr2, ETH_ALEN);
 		break;
 	case IEEE80211_FCTL_FROMDS | IEEE80211_FCTL_TODS:
-		if (skb->len < IEEE80211_DATA_HDR4_LEN)
+		if (skb->len < IEEE80211_4ADDR_LEN)
 			goto rx_dropped;
 		memcpy(dst, hdr->addr3, ETH_ALEN);
 		memcpy(src, hdr->addr4, ETH_ALEN);



--
Jiri Benc
SUSE Labs

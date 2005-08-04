From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH ieee80211] ieee80211.h: minor changes to header
Date: Thu, 4 Aug 2005 14:02:48 -0400
Message-ID: <200508041402.48868.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

This patch:
- fixes misc. whitespace/comments
- replaces u16 with __le16/__be16 where appropriate

Signed-off-by: Michael Wu <flamingice@sourmilk.net>

diff --git a/include/net/ieee80211.h b/include/net/ieee80211.h
--- a/include/net/ieee80211.h
+++ b/include/net/ieee80211.h
@@ -47,22 +47,22 @@
 #define IEEE80211_FRAME_LEN		(IEEE80211_DATA_LEN + IEEE80211_HLEN)
 
 struct ieee80211_hdr {
-	u16 frame_ctl;
-	u16 duration_id;
+	__le16 frame_ctl;
+	__le16 duration_id;
 	u8 addr1[ETH_ALEN];
 	u8 addr2[ETH_ALEN];
 	u8 addr3[ETH_ALEN];
-	u16 seq_ctl;
+	__le16 seq_ctl;
 	u8 addr4[ETH_ALEN];
 } __attribute__ ((packed));
 
 struct ieee80211_hdr_3addr {
-	u16 frame_ctl;
-	u16 duration_id;
+	__le16 frame_ctl;
+	__le16 duration_id;
 	u8 addr1[ETH_ALEN];
 	u8 addr2[ETH_ALEN];
 	u8 addr3[ETH_ALEN];
-	u16 seq_ctl;
+	__le16 seq_ctl;
 } __attribute__ ((packed));
 
 enum eap_type {
@@ -88,10 +88,10 @@ static inline const char *eap_get_type(i
 
 struct eapol {
 	u8 snap[6];
-	u16 ethertype;
+	__be16 ethertype;
 	u8 version;
 	u8 type;
-	u16 length;
+	__be16 length;
 } __attribute__ ((packed));
 
 #define IEEE80211_1ADDR_LEN 10
@@ -223,9 +223,9 @@ do { if (ieee80211_debug_level & (level)
 #include <linux/if_arp.h> /* ARPHRD_ETHER */
 
 #ifndef WIRELESS_SPY
-#define WIRELESS_SPY		// enable iwspy support
+#define WIRELESS_SPY		/* enable iwspy support */
 #endif
-#include <net/iw_handler.h>	// new driver API
+#include <net/iw_handler.h>	/* new driver API */
 
 #ifndef ETH_P_PAE
 #define ETH_P_PAE 0x888E /* Port Access Entity (IEEE 802.1X) */
@@ -520,9 +520,9 @@ struct ieee80211_info_element {
 
 struct ieee80211_authentication {
 	struct ieee80211_hdr_3addr header;
-	u16 algorithm;
-	u16 transaction;
-	u16 status;
+	__le16 algorithm;
+	__le16 transaction;
+	__le16 status;
 	struct ieee80211_info_element info_element;
 } __attribute__ ((packed));
 
@@ -530,23 +530,23 @@ struct ieee80211_authentication {
 struct ieee80211_probe_response {
 	struct ieee80211_hdr_3addr header;
 	u32 time_stamp[2];
-	u16 beacon_interval;
-	u16 capability;
+	__le16 beacon_interval;
+	__le16 capability;
 	struct ieee80211_info_element info_element;
 } __attribute__ ((packed));
 
 struct ieee80211_assoc_request_frame {
-	u16 capability;
-	u16 listen_interval;
+	__le16 capability;
+	__le16 listen_interval;
 	u8 current_ap[ETH_ALEN];
 	struct ieee80211_info_element info_element;
 } __attribute__ ((packed));
 
 struct ieee80211_assoc_response_frame {
 	struct ieee80211_hdr_3addr header;
-	u16 capability;
-	u16 status;
-	u16 aid;
+	__le16 capability;
+	__le16 status;
+	__le16 aid;
 	struct ieee80211_info_element info_element; /* supported rates */
 } __attribute__ ((packed));
 
@@ -561,7 +561,7 @@ struct ieee80211_txb {
 };
 
 
-/* SWEEP TABLE ENTRIES NUMBER*/
+/* SWEEP TABLE ENTRIES NUMBER */
 #define MAX_SWEEP_TAB_ENTRIES		  42
 #define MAX_SWEEP_TAB_ENTRIES_PER_PACKET  7
 /* MAX_RATES_LENGTH needs to be 12.  The spec says 8, and many APs
@@ -791,8 +791,6 @@ extern struct net_device *alloc_ieee8021
 extern int ieee80211_set_encryption(struct ieee80211_device *ieee);
 
 /* ieee80211_tx.c */
-
-
 extern int ieee80211_xmit(struct sk_buff *skb,
 			  struct net_device *dev);
 extern void ieee80211_txb_free(struct ieee80211_txb *);
@@ -805,7 +803,7 @@ extern void ieee80211_rx_mgt(struct ieee
 			     struct ieee80211_hdr *header,
 			     struct ieee80211_rx_stats *stats);
 
-/* iee80211_wx.c */
+/* ieee80211_wx.c */
 extern int ieee80211_wx_get_scan(struct ieee80211_device *ieee,
 				 struct iw_request_info *info,
 				 union iwreq_data *wrqu, char *key);

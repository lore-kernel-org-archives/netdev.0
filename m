From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 2/7] staging: rtl8712u: Fix endian settings for structs
 describing network packets
Date: Fri, 10 Feb 2017 21:30:25 -0600
Message-ID: <20170211033030.28827-3-Larry.Finger@lwfinger.net>
References: <20170211033030.28827-1-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170211033030.28827-1-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

The headers describing a number of network packets do not have the
correct endian settings for several types of data.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8712/ieee80211.h | 84 ++++++++++++++++++-------------------
 1 file changed, 42 insertions(+), 42 deletions(-)

diff --git a/drivers/staging/rtl8712/ieee80211.h b/drivers/staging/rtl8712/ieee80211.h
index 67ab580..68fd65e 100644
--- a/drivers/staging/rtl8712/ieee80211.h
+++ b/drivers/staging/rtl8712/ieee80211.h
@@ -138,51 +138,51 @@ struct ieee_ibss_seq {
 };
 
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
-} __packed;
+}  __packed __aligned(2);
 
 struct ieee80211_hdr_3addr {
-	u16 frame_ctl;
-	u16 duration_id;
+	__le16 frame_ctl;
+	__le16 duration_id;
 	u8 addr1[ETH_ALEN];
 	u8 addr2[ETH_ALEN];
 	u8 addr3[ETH_ALEN];
-	u16 seq_ctl;
-} __packed;
+	__le16 seq_ctl;
+}  __packed __aligned(2);
 
 struct	ieee80211_hdr_qos {
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
-	u16	qc;
-}  __packed;
+	__le16	qc;
+}   __packed __aligned(2);
 
 struct  ieee80211_hdr_3addr_qos {
-	u16 frame_ctl;
-	u16 duration_id;
+	__le16 frame_ctl;
+	__le16 duration_id;
 	u8  addr1[ETH_ALEN];
 	u8  addr2[ETH_ALEN];
 	u8  addr3[ETH_ALEN];
-	u16 seq_ctl;
-	u16 qc;
+	__le16 seq_ctl;
+	__le16 qc;
 }  __packed;
 
 struct eapol {
 	u8 snap[6];
-	u16 ethertype;
+	__be16 ethertype;
 	u8 version;
 	u8 type;
-	u16 length;
+	__le16 length;
 } __packed;
 
 enum eap_type {
@@ -514,13 +514,13 @@ struct ieee80211_security {
  */
 
 struct ieee80211_header_data {
-	u16 frame_ctl;
-	u16 duration_id;
+	__le16 frame_ctl;
+	__le16 duration_id;
 	u8 addr1[6];
 	u8 addr2[6];
 	u8 addr3[6];
-	u16 seq_ctrl;
-};
+	__le16 seq_ctrl;
+} __packed __aligned(2);
 
 #define BEACON_PROBE_SSID_ID_POSITION 12
 
@@ -552,18 +552,18 @@ struct ieee80211_info_element {
 /*
  * These are the data types that can make up management packets
  *
-	u16 auth_algorithm;
-	u16 auth_sequence;
-	u16 beacon_interval;
-	u16 capability;
+	__le16 auth_algorithm;
+	__le16 auth_sequence;
+	__le16 beacon_interval;
+	__le16 capability;
 	u8 current_ap[ETH_ALEN];
-	u16 listen_interval;
+	__le16 listen_interval;
 	struct {
 		u16 association_id:14, reserved:2;
 	} __packed;
-	u32 time_stamp[2];
-	u16 reason;
-	u16 status;
+	__le32 time_stamp[2];
+	__le16 reason;
+	__le16 status;
 */
 
 #define IEEE80211_DEFAULT_TX_ESSID "Penguin"
@@ -571,16 +571,16 @@ struct ieee80211_info_element {
 
 struct ieee80211_authentication {
 	struct ieee80211_header_data header;
-	u16 algorithm;
-	u16 transaction;
-	u16 status;
+	__le16 algorithm;
+	__le16 transaction;
+	__le16 status;
 } __packed;
 
 struct ieee80211_probe_response {
 	struct ieee80211_header_data header;
-	u32 time_stamp[2];
-	u16 beacon_interval;
-	u16 capability;
+	__le32 time_stamp[2];
+	__le16 beacon_interval;
+	__le16 capability;
 	struct ieee80211_info_element info_element;
 } __packed;
 
@@ -590,16 +590,16 @@ struct ieee80211_probe_request {
 
 struct ieee80211_assoc_request_frame {
 	struct ieee80211_hdr_3addr header;
-	u16 capability;
-	u16 listen_interval;
+	__le16 capability;
+	__le16 listen_interval;
 	struct ieee80211_info_element_hdr info_element;
 } __packed;
 
 struct ieee80211_assoc_response_frame {
 	struct ieee80211_hdr_3addr header;
-	u16 capability;
-	u16 status;
-	u16 aid;
+	__le16 capability;
+	__le16 status;
+	__le16 aid;
 } __packed;
 
 struct ieee80211_txb {
-- 
2.10.2

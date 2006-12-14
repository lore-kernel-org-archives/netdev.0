From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 1/6] d80211: add IEEE802.11e/WMM MLMEs, Status Code and Reason Code
Date: Thu, 14 Dec 2006 12:02:04 +0800
Message-ID: <20061214040204.GA10643@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25884 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750960AbWLNEOA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 23:14:00 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 include/net/d80211_mgmt.h |  148 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 148 insertions(+), 0 deletions(-)

d83f6236e756f5f0bb1484d991884444f06704de
diff --git a/include/net/d80211_mgmt.h b/include/net/d80211_mgmt.h
index 87141d4..450c0a2 100644
--- a/include/net/d80211_mgmt.h
+++ b/include/net/d80211_mgmt.h
@@ -14,6 +14,39 @@
 
 #include <linux/types.h>
 
+struct ieee802_11_ts_info {
+	__le16 traffic_type:1;
+	__le16 tsid:4;
+	__le16 direction:2;
+	__le16 access_policy:2;
+	__le16 aggregation:1;
+	__le16 apsd:1;
+	__le16 up:3;
+	__le16 ack_policy:2;
+	u8 schedule:1;
+	u8 reserved:7;
+} __attribute__ ((packed));
+
+struct ieee802_11_elem_tspec {
+	struct ieee802_11_ts_info ts_info;
+	__le16 nominal_msdu_size;
+	__le16 max_msdu_size;
+	__le32 min_service_interval;
+	__le32 max_service_interval;
+	__le32 inactivity_interval;
+	__le32 suspension_interval;
+	__le32 service_start_time;
+	__le32 min_data_rate;
+	__le32 mean_data_rate;
+	__le32 peak_data_rate;
+	__le32 burst_size;
+	__le32 delay_bound;
+	__le32 min_phy_rate;
+	__le16 surplus_band_allow;
+	__le16 medium_time;
+} __attribute__ ((packed));
+
+
 struct ieee80211_mgmt {
 	__le16 frame_control;
 	__le16 duration;
@@ -81,9 +114,51 @@ struct ieee80211_mgmt {
 				struct {
 					u8 action_code;
 					u8 dialog_token;
+					u8 variable[0];
+				} __attribute__ ((packed)) addts_req;
+				struct {
+					u8 action_code;
+					u8 dialog_token;
+					__le16 status_code;
+					u8 variable[0];
+				} __attribute__ ((packed)) addts_resp;
+				struct {
+					u8 action_code;
+					struct ieee802_11_ts_info ts_info;
+					__le16 reason_code;
+				} __attribute__ ((packed)) delts;
+				struct {
+					u8 action_code;
+					u8 dialog_token;
 					u8 status_code;
 					u8 variable[0];
 				} __attribute__ ((packed)) wme_action;
+				struct {
+					u8 action_code;
+					u8 dest[6];
+					u8 src[6];
+					__le16 capab_info;
+					__le16 timeout;
+					/* Followed by Supported Rates and
+					 * Extended Supported Rates */
+					u8 variable[0];
+				} __attribute__ ((packed)) dls_req;
+				struct {
+					u8 action_code;
+					__le16 status_code;
+					u8 dest[6];
+					u8 src[6];
+					/* Followed by Capability Information,
+					 * Supported Rates and Extended
+					 * Supported Rates */
+					u8 variable[0];
+				} __attribute__ ((packed)) dls_resp;
+				struct {
+					u8 action_code;
+					u8 dest[6];
+					u8 src[6];
+					__le16 reason_code;
+				} __attribute__ ((packed)) dls_teardown;
 				struct{
 					u8 action_code;
 					u8 element_id;
@@ -150,6 +225,18 @@ enum ieee80211_statuscode {
 	WLAN_STATUS_UNSUPP_RSN_VERSION = 44,
 	WLAN_STATUS_INVALID_RSN_IE_CAP = 45,
 	WLAN_STATUS_CIPHER_SUITE_REJECTED = 46,
+	/* 802.11e */
+	WLAN_STATUS_UNSPECIFIED_QOS = 32,
+	WLAN_STATUS_ASSOC_DENIED_NOBANDWIDTH = 33,
+	WLAN_STATUS_ASSOC_DENIED_LOWACK = 34,
+	WLAN_STATUS_ASSOC_DENIED_UNSUPP_QOS = 35,
+	WLAN_STATUS_REQUEST_DECLINED = 37,
+	WLAN_STATUS_INVALID_QOS_PARAM = 38,
+	WLAN_STATUS_CHANGE_TSPEC = 39,
+	WLAN_STATUS_WAIT_TS_DELAY = 47,
+	WLAN_STATUS_NO_DIRECT_LINK = 48,
+	WLAN_STATUS_STA_NOT_PRESENT = 49,
+	WLAN_STATUS_STA_NOT_QSTA = 50,
 };
 
 
@@ -180,9 +267,43 @@ enum ieee80211_reasoncode {
 	WLAN_REASON_INVALID_RSN_IE_CAP = 22,
 	WLAN_REASON_IEEE8021X_FAILED = 23,
 	WLAN_REASON_CIPHER_SUITE_REJECTED = 24,
+	/* 802.11e */
+	WLAN_REASON_DISASSOC_UNSPECIFIED_QOS = 32,
+	WLAN_REASON_DISASSOC_QAP_NO_BANDWIDTH = 33,
+	WLAN_REASON_DISASSOC_LOW_ACK = 34,
+	WLAN_REASON_DISASSOC_QAP_EXCEED_TXOP = 35,
+	WLAN_REASON_QSTA_LEAVE_QBSS = 36,
+	WLAN_REASON_QSTA_NOT_USE = 37,
+	WLAN_REASON_QSTA_REQUIRE_SETUP = 38,
+	WLAN_REASON_QSTA_TIMEOUT = 39,
+	WLAN_REASON_QSTA_CIPHER_NOT_SUPP = 45,
 };
 
 
+/* Category Code */
+enum ieee80211_category {
+	WLAN_CATEGORY_SPECTRUM_MGMT = 0,
+	WLAN_CATEGORY_QOS = 1,
+	WLAN_CATEGORY_DLS = 2,
+	WLAN_CATEGORY_BACK = 3,
+	WLAN_CATEGORY_WMM = 17,
+};
+
+/* QoS Action Code */
+enum ieee80211_qos_actioncode {
+	WLAN_ACTION_QOS_ADDTS_REQ = 0,
+	WLAN_ACTION_QOS_ADDTS_RESP = 1,
+	WLAN_ACTION_QOS_DELTS = 2,
+	WLAN_ACTION_QOS_SCHEDULE = 3,
+};
+
+/* DLS Action Code */
+enum ieee80211_dls_actioncode {
+	WLAN_ACTION_DLS_REQ = 0,
+	WLAN_ACTION_DLS_RESP = 1,
+	WLAN_ACTION_DLS_TEARDOWN = 2,
+};
+
 /* Information Element IDs */
 enum ieee80211_eid {
 	WLAN_EID_SSID = 0,
@@ -198,6 +319,15 @@ enum ieee80211_eid {
 	WLAN_EID_HP_PARAMS = 8,
 	WLAN_EID_HP_TABLE = 9,
 	WLAN_EID_REQUEST = 10,
+	/* 802.11e */
+	WLAN_EID_QBSS_LOAD = 11,
+	WLAN_EID_EDCA_PARAM_SET = 12,
+	WLAN_EID_TSPEC = 13,
+	WLAN_EID_TCLAS = 14,
+	WLAN_EID_SCHEDULE = 15,
+	WLAN_EID_TS_DELAY = 43,
+	WLAN_EID_TCLAS_PROCESSING = 44,
+	WLAN_EID_QOS_CAPA = 46,
 	/* 802.11h */
 	WLAN_EID_PWR_CONSTRAINT = 32,
 	WLAN_EID_PWR_CAPABILITY = 33,
@@ -220,4 +350,22 @@ enum ieee80211_eid {
 	WLAN_EID_QOS_PARAMETER = 222
 };
 
+enum ieee80211_tsinfo_direction {
+	WLAN_TSINFO_UPLINK = 0,
+	WLAN_TSINFO_DOWNLINK = 1,
+	WLAN_TSINFO_DIRECTLINK = 2,
+	WLAN_TSINFO_BIDIRECTIONAL = 3,
+};
+
+enum ieee80211_tsinfo_access {
+	WLAN_TSINFO_EDCA = 1,
+	WLAN_TSINFO_HCCA = 2,
+	WLAN_TSINFO_HEMM = 3,
+};
+
+enum ieee80211_tsinfo_psb {
+	WLAN_TSINFO_PSB_LEGACY = 0,
+	WLAN_TSINFO_PSB_APSD = 1,
+};
+
 #endif /* D802_11_MGMT_H */
-- 
1.2.6

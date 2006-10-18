From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 18/18] d80211: remove unused Super AG definitions, purge comment
Date: Wed, 18 Oct 2006 17:49:42 +0200 (CEST)
Message-ID: <20061018154942.28678481DE@silver.suse.cz>
References: <20061018174838.116675768.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:13474 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1161193AbWJRPtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 11:49:12 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061018174838.116675768.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Kimdon <david.kimdon@devicescape.com>

Remove unused Super AG structure members, enums.

In struct ieee80211_tx_status the queue_length and queue_number could
be useful outside the context of Super AG, so remove the comment and
leave the members.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/net/d80211.h        |   14 --------------
 include/net/d80211_shared.h |    4 +---
 net/d80211/hostapd_ioctl.h  |    4 ----
 3 files changed, 1 insertions(+), 21 deletions(-)

a3cdcec1a299bcb883a7bcc73588163f245b64ae
diff --git a/include/net/d80211.h b/include/net/d80211.h
index 6d91e13..f29deff 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -159,12 +159,6 @@ struct ieee80211_tx_control {
 	unsigned int requeue:1;
 	unsigned int first_fragment:1;	/* This is a first fragment of the
 					 * frame */
-	 /* following three flags are only used with Atheros Super A/G */
-	unsigned int compress:1;
-	unsigned int turbo_prime_notify:1; /* notify HostAPd after frame
-					    * transmission */
-	unsigned int fast_frame:1;
-
         unsigned int power_level:8; /* per-packet transmit power level, in dBm
 				     */
 	unsigned int antenna_sel:4; /* 0 = default/diversity,
@@ -219,7 +213,6 @@ struct ieee80211_tx_status {
 	int excessive_retries;
 	int retry_count;
 
-	/* following two fields are only used with Atheros Super A/G */
 	int queue_length;      /* information about TX queue */
 	int queue_number;
 };
@@ -265,13 +258,6 @@ struct ieee80211_conf {
         int antenna_def;
         int antenna_mode;
 
-	int atheros_super_ag_compression;
-	int atheros_super_ag_fast_frame;
-	int atheros_super_ag_burst;
-	int atheros_super_ag_wme_ele;
-	int atheros_super_ag_turbo_g;
-	int atheros_super_ag_turbo_prime;
-
 	/* Following five fields are used for IEEE 802.11H */
 	unsigned int radar_detect;
 	unsigned int spect_mgmt;
diff --git a/include/net/d80211_shared.h b/include/net/d80211_shared.h
index 11569d1..2f1bb42 100644
--- a/include/net/d80211_shared.h
+++ b/include/net/d80211_shared.h
@@ -19,9 +19,7 @@ enum {
 	MODE_ATHEROS_TURBO = 2 /* Atheros Turbo mode (2x.11a at 5 GHz) */,
 	MODE_IEEE80211G = 3 /* IEEE 802.11g (and 802.11b compatibility) */,
 	MODE_ATHEROS_TURBOG = 4 /* Atheros Turbo mode (2x.11g at 2.4 GHz) */,
-	MODE_ATHEROS_PRIME = 5 /* Atheros Dynamic Turbo mode */,
-	MODE_ATHEROS_PRIMEG = 6 /* Atheros Dynamic Turbo mode G */,
-	NUM_IEEE80211_MODES = 7
+	NUM_IEEE80211_MODES = 5
 };
 
 #define IEEE80211_CHAN_W_SCAN 0x00000001
diff --git a/net/d80211/hostapd_ioctl.h b/net/d80211/hostapd_ioctl.h
index 003f371..559d11c 100644
--- a/net/d80211/hostapd_ioctl.h
+++ b/net/d80211/hostapd_ioctl.h
@@ -182,10 +182,6 @@ struct prism2_hostapd_param {
 			u16 aid;
 			u16 capability;
 			u8 supp_rates[32];
-			/* atheros_super_ag and enc_flags are only used with
-			 * IEEE80211_ATHEROS_SUPER_AG
-			 */
-			u8 atheros_super_ag;
 			u8 wds_flags;
 #define IEEE80211_STA_DYNAMIC_ENC BIT(0)
 			u8 enc_flags;
-- 
1.3.0


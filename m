From: David Kimdon <david.kimdon@devicescape.com>
Subject: Re: [PATCH] d80211: remove unused Super AG definitions, purgecomment
Date: Tue, 17 Oct 2006 08:07:57 -0700
Message-ID: <20061017150757.GA9188@devicescape.com>
References: <20061016183935.GA2488@devicescape.com> <1161068354.2735.0.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:54439 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1751114AbWJQPIC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 11:08:02 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1161068354.2735.0.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 17, 2006 at 08:59:13AM +0200, Johannes Berg wrote:
> On Mon, 2006-10-16 at 11:39 -0700, David Kimdon wrote:
> You want to adjust that last constant there too, I guess. 

Indeed, updated patch inline.

> Why is it an
> enum anyway if things are assigned statically?

I don't have a good answer for that.

-David

Remove unused Super AG structure members, enums.

In struct ieee80211_tx_status the queue_length and queue_number could
be useful outside the context of Super AG, so remove the comment and
leave the members.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/include/net/d80211.h
===================================================================
--- wireless-dev.orig/include/net/d80211.h
+++ wireless-dev/include/net/d80211.h
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
Index: wireless-dev/net/d80211/hostapd_ioctl.h
===================================================================
--- wireless-dev.orig/net/d80211/hostapd_ioctl.h
+++ wireless-dev/net/d80211/hostapd_ioctl.h
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
Index: wireless-dev/include/net/d80211_shared.h
===================================================================
--- wireless-dev.orig/include/net/d80211_shared.h
+++ wireless-dev/include/net/d80211_shared.h
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

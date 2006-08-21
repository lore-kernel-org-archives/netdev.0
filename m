From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 08/14] ipw2200: remove the MAC timestamp present field from radiotap head
Date: Mon, 21 Aug 2006 11:38:08 +0800
Message-ID: <20060821033808.GA5389@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:62798 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932587AbWHUDkD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:40:03 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IEEE80211_RADIOTAP_TSFT is defined as the Value in microseconds of the
MAC's 64-bit 802.11 Time Synchronization Function timer when the first bit
of the MPDU arrived at the MAC. Since ipw2200 hardware doesn't provide this
value, we disable this feature from the radiotap header present flag.

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

715b4e6d66a77e89d3dfd51c167bf4cbef4c7bce
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 04efe69..0e5548a 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -7640,7 +7640,6 @@ static void ipw_handle_data_packet_monit
 	/* Big bitfield of all the fields we provide in radiotap */
 	ipw_rt->rt_hdr.it_present =
 	    ((1 << IEEE80211_RADIOTAP_FLAGS) |
-	     (1 << IEEE80211_RADIOTAP_TSFT) |
 	     (1 << IEEE80211_RADIOTAP_RATE) |
 	     (1 << IEEE80211_RADIOTAP_CHANNEL) |
 	     (1 << IEEE80211_RADIOTAP_DBM_ANTSIGNAL) |
@@ -7649,6 +7648,7 @@ static void ipw_handle_data_packet_monit
 
 	/* Zero the flags, we'll add to them as we go */
 	ipw_rt->rt_flags = 0;
+	ipw_rt->rt_tsf = 0ULL;
 
 	/* Convert signal to DBM */
 	ipw_rt->rt_dbmsignal = antsignal;
@@ -7767,7 +7767,6 @@ static void ipw_handle_promiscuous_rx(st
 	s8 noise = frame->noise;
 	u8 rate = frame->rate;
 	short len = le16_to_cpu(pkt->u.frame.length);
-	u64 tsf = 0;
 	struct sk_buff *skb;
 	int hdr_only = 0;
 	u16 filter = priv->prom_priv->filter;
@@ -7853,7 +7852,6 @@ static void ipw_handle_promiscuous_rx(st
 	/* Big bitfield of all the fields we provide in radiotap */
 	ipw_rt->rt_hdr.it_present =
 	    ((1 << IEEE80211_RADIOTAP_FLAGS) |
-	     (1 << IEEE80211_RADIOTAP_TSFT) |
 	     (1 << IEEE80211_RADIOTAP_RATE) |
 	     (1 << IEEE80211_RADIOTAP_CHANNEL) |
 	     (1 << IEEE80211_RADIOTAP_DBM_ANTSIGNAL) |
@@ -7862,8 +7860,7 @@ static void ipw_handle_promiscuous_rx(st
 
 	/* Zero the flags, we'll add to them as we go */
 	ipw_rt->rt_flags = 0;
-
-	ipw_rt->rt_tsf = tsf;
+	ipw_rt->rt_tsf = 0ULL;
 
 	/* Convert to DBM */
 	ipw_rt->rt_dbmsignal = signal;
-- 
1.2.6

From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 15/18] d80211: use FCS_LEN instead of hardcoded number.
Date: Wed, 18 Oct 2006 17:49:39 +0200 (CEST)
Message-ID: <20061018154939.109323AA6B8@silver.suse.cz>
References: <20061018174838.116675768.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:16546 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1161210AbWJRPtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 11:49:10 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061018174838.116675768.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Kimdon <david.kimdon@devicescape.com>

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

22acdd71c90cc4123d3df59a07919d432847e3e7
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 86062c9..50b2b29 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -442,7 +442,7 @@ ieee80211_tx_h_fragment(struct ieee80211
 
 	hdrlen = ieee80211_get_hdrlen(tx->fc);
 	payload_len = first->len - hdrlen;
-	per_fragm = frag_threshold - hdrlen - 4 /* FCS */;
+	per_fragm = frag_threshold - hdrlen - FCS_LEN;
 	num_fragm = (payload_len + per_fragm - 1) / per_fragm;
 
 	frags = kzalloc(num_fragm * sizeof(struct sk_buff *), GFP_ATOMIC);
@@ -1062,7 +1062,7 @@ __ieee80211_tx_prepare(struct ieee80211_
         control->no_ack = is_multicast_ether_addr(hdr->addr1);
 	tx->fragmented = local->fragmentation_threshold <
 		IEEE80211_MAX_FRAG_THRESHOLD && tx->u.tx.unicast &&
-		skb->len + 4 /* FCS */ > local->fragmentation_threshold &&
+		skb->len + FCS_LEN > local->fragmentation_threshold &&
 		(!local->hw->set_frag_threshold);
 	if (!tx->sta)
 		control->clear_dst_mask = 1;
-- 
1.3.0


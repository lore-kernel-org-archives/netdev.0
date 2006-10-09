From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch 1/3] d80211: use FCS_LEN instead of hardcoded number.
Date: Mon, 9 Oct 2006 10:02:49 -0700
Message-ID: <20061009170249.GA27239@devicescape.com>
References: <20061009170159.804032000@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:20898 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S932936AbWJIRDC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Oct 2006 13:03:02 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="FCS_LEN.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c
+++ wireless-dev/net/d80211/ieee80211.c
@@ -451,7 +451,7 @@ ieee80211_tx_h_fragment(struct ieee80211
 
 	hdrlen = ieee80211_get_hdrlen(tx->fc);
 	payload_len = first->len - hdrlen;
-	per_fragm = frag_threshold - hdrlen - 4 /* FCS */;
+	per_fragm = frag_threshold - hdrlen - FCS_LEN;
 	num_fragm = (payload_len + per_fragm - 1) / per_fragm;
 
 	frags = kzalloc(num_fragm * sizeof(struct sk_buff *), GFP_ATOMIC);
@@ -1103,7 +1103,7 @@ __ieee80211_tx_prepare(struct ieee80211_
         control->no_ack = is_multicast_ether_addr(hdr->addr1);
 	tx->fragmented = local->fragmentation_threshold <
 		IEEE80211_MAX_FRAG_THRESHOLD && tx->u.tx.unicast &&
-		skb->len + 4 /* FCS */ > local->fragmentation_threshold &&
+		skb->len + FCS_LEN > local->fragmentation_threshold &&
 		(!local->hw->set_frag_threshold);
 	if (!tx->sta)
 		control->clear_dst_mask = 1;

--

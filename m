From: Jouni Malinen <jkm@devicescape.com>
Subject: [PATCH wireless-dev 1/6] d80211: Fix RTS threshold use
Date: Mon, 07 Aug 2006 16:16:09 -0700
Message-ID: <20060807231937.208642592@localhost>
References: <20060807231608.888744720@localhost>
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	jkm@devicescape.com, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-17.dex002.intermedia.net ([64.78.21.83]:48753 "EHLO
	dhost002-17.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751194AbWHGXX7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 19:23:59 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline; filename=rts_threshold.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed dot11RTSThreshold use which was off-by-3:
- must add FCS_LEN to the skb->len
- frame length needs to be greater than threshold; not greater than
  or equal

Signed-off-by: Jouni Malinen <jkm@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c
+++ wireless-dev/net/d80211/ieee80211.c
@@ -762,7 +762,7 @@ ieee80211_tx_h_misc(struct ieee80211_txr
 	struct ieee80211_tx_control *control = tx->u.tx.control;
 
 	if (!is_multicast_ether_addr(hdr->addr1)) {
-		if (tx->skb->len >= tx->local->rts_threshold &&
+		if (tx->skb->len + FCS_LEN > tx->local->rts_threshold &&
 		    tx->local->rts_threshold < IEEE80211_MAX_RTS_THRESHOLD) {
 			control->use_rts_cts = 1;
 			control->retry_limit =

--
-- 
Jouni Malinen                                            PGP id EFC895FA

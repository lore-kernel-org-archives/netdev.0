From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] net: clear local_df when passing skb between namespaces
Date: Thu, 5 Dec 2013 23:29:19 +0100
Message-ID: <20131205222919.GD21745@order.stressinduktion.org>
References: <2134F8430051B64F815C691A62D9831816F612@XCH-BLV-504.nw.nos.boeing.com> <2134F8430051B64F815C691A62D9831816F6A4@XCH-BLV-504.nw.nos.boeing.com> <20131205201856.GC21745@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: "Templin, Fred L" <Fred.L.Templin@boeing.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34293 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754461Ab3LEW3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 17:29:20 -0500
Content-Disposition: inline
In-Reply-To: <20131205201856.GC21745@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We must clear local_df when passing the skb between namespaces as the
packet is not local to the new namespace any more and thus may not get
fragmented by local rules. Fred Templin noticed that other namespaces
do fragment IPv6 packets while forwarding. Instead they should have send
back a PTB.

The same problem should be present when forwarding DF-IPv4 packets
between namespaces.

Reported-by: Templin, Fred L <Fred.L.Templin@boeing.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/core/skbuff.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2718fed..06e72d3 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3584,6 +3584,7 @@ void skb_scrub_packet(struct sk_buff *skb, bool xnet)
 	skb->tstamp.tv64 = 0;
 	skb->pkt_type = PACKET_HOST;
 	skb->skb_iif = 0;
+	skb->local_df = 0;
 	skb_dst_drop(skb);
 	skb->mark = 0;
 	secpath_reset(skb);
-- 
1.8.3.1

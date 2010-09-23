From: Tom Herbert <therbert@google.com>
Subject: [PATCH] net: reset skb queue mapping when rx'ing over tunnel
Date: Thu, 23 Sep 2010 14:19:54 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1009231415290.25121@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: chavey@google.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:25046 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754704Ab0IWVUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 17:20:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reset queue mapping when an skb is reentering the stack via a tunnel.
On second pass, the queue mapping from the original device is no
longer valid.

Signed-off-by: Tom Herbert <therbert@google.com>
---
diff --git a/include/net/dst.h b/include/net/dst.h
index 81d1413..0238650 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -242,6 +242,7 @@ static inline void skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev)
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += skb->len;
 	skb->rxhash = 0;
+	skb_set_queue_mapping(skb, 0);
 	skb_dst_drop(skb);
 	nf_reset(skb);
 }

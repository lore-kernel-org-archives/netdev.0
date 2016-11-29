From: Eli Cooper <elicooper@gmx.com>
Subject: [PATCH net 2/2] Revert: "ip6_tunnel: Update skb->protocol to ETH_P_IPV6 in ip6_tnl_xmit()"
Date: Tue, 29 Nov 2016 10:35:29 +0800
Message-ID: <20161129023529.17645-2-elicooper@gmx.com>
References: <20161129023529.17645-1-elicooper@gmx.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:50935 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753188AbcK2Cfs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 21:35:48 -0500
In-Reply-To: <20161129023529.17645-1-elicooper@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit ae148b085876fa771d9ef2c05f85d4b4bf09ce0d
("ip6_tunnel: Update skb->protocol to ETH_P_IPV6 in ip6_tnl_xmit()").

skb->protocol is now set in ip_local_out() and ip6_local_out() right before
dst_output() is called. It is no longer necessary to do it in each tunnel.

Cc: stable@vger.kernel.org
Signed-off-by: Eli Cooper <elicooper@gmx.com>
---
 net/ipv6/ip6_tunnel.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 0a4759b..d76674e 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1181,7 +1181,6 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 	if (err)
 		return err;
 
-	skb->protocol = htons(ETH_P_IPV6);
 	skb_push(skb, sizeof(struct ipv6hdr));
 	skb_reset_network_header(skb);
 	ipv6h = ipv6_hdr(skb);
-- 
2.10.2

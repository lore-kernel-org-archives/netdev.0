From: Eli Cooper <elicooper@gmx.com>
Subject: [PATCH net] sit: Set skb->protocol properly in ipip6_tunnel_xmit()
Date: Fri, 25 Nov 2016 13:50:17 +0800
Message-ID: <20161125055017.7053-1-elicooper@gmx.com>
To: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:51362 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751625AbcKYF50 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Nov 2016 00:57:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to commit ae148b085876
("ip6_tunnel: Update skb->protocol to ETH_P_IPV6 in ip6_tnl_xmit()"),
sit tunnels also need to update skb->protocol; otherwise, TSO/GSO packets
might not be properly segmented, which causes the packets being dropped.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Tested-by: Eli Cooper <elicooper@gmx.com>
Cc: stable@vger.kernel.org
Signed-off-by: Eli Cooper <elicooper@gmx.com>
---
 net/ipv6/sit.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index b1cdf80..a05dceb 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -972,6 +972,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	}
 
 	skb_set_inner_ipproto(skb, IPPROTO_IPV6);
+	skb->protocol = htons(ETH_P_IP);
 
 	iptunnel_xmit(NULL, rt, skb, fl4.saddr, fl4.daddr, protocol, tos, ttl,
 		      df, !net_eq(tunnel->net, dev_net(dev)));
-- 
2.10.2

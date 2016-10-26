From: Eli Cooper <elicooper@gmx.com>
Subject: [PATCH] ip6_tunnel: Update skb->protocol to ETH_P_IPV6 in ip6_tnl_xmit()
Date: Wed, 26 Oct 2016 10:11:09 +0800
Message-ID: <20161026021109.19277-1-elicooper@gmx.com>
To: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:63920 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753866AbcJZCLZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Oct 2016 22:11:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates skb->protocol to ETH_P_IPV6 in ip6_tnl_xmit() when an
IPv6 header is installed to a socket buffer.

This is not a cosmetic change.  Without updating this value, GSO packets
transmitted through an ipip6 tunnel have the protocol of ETH_P_IP and
skb_mac_gso_segment() will attempt to call gso_segment() for IPv4,
which results in the packets being dropped.

Fixes: b8921ca83eed ("ip4ip6: Support for GSO/GRO")
Signed-off-by: Eli Cooper <elicooper@gmx.com>
---
 net/ipv6/ip6_tunnel.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 202d16a..03e050d 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1172,6 +1172,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 	if (err)
 		return err;
 
+	skb->protocol = htons(ETH_P_IPV6);
 	skb_push(skb, sizeof(struct ipv6hdr));
 	skb_reset_network_header(skb);
 	ipv6h = ipv6_hdr(skb);
-- 
2.10.1

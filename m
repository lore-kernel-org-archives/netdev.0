From: Eli Cooper <elicooper@gmx.com>
Subject: [PATCH] ipv6: Don't unset flowi6_proto in ipxip6_tnl_xmit()
Date: Fri, 26 Aug 2016 23:52:29 +0800
Message-ID: <20160826155229.8040-1-elicooper@gmx.com>
Cc: "David S . Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:56427 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752855AbcHZPwn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 Aug 2016 11:52:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 8eb30be0352d0916 ("ipv6: Create ip6_tnl_xmit") unsets
flowi6_proto in ip4ip6_tnl_xmit() and ip6ip6_tnl_xmit().
Since xfrm_selector_match() relies on this info, IPv6 packets
sent by an ip6tunnel cannot be properly selected by their
protocols after removing it. This patch puts flowi6_proto back.

Cc: stable@vger.kernel.org
Fixes: 8eb30be0352d ("ipv6: Create ip6_tnl_xmit")
Signed-off-by: Eli Cooper <elicooper@gmx.com>
---
 net/ipv6/ip6_tunnel.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 2050217..5c57797 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1174,6 +1174,7 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 		encap_limit = t->parms.encap_limit;
 
 	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
+	fl6.flowi6_proto = IPPROTO_IPIP;
 
 	dsfield = ipv4_get_dsfield(iph);
 
@@ -1233,6 +1234,7 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 		encap_limit = t->parms.encap_limit;
 
 	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
+	fl6.flowi6_proto = IPPROTO_IPV6;
 
 	dsfield = ipv6_get_dsfield(ipv6h);
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS)
-- 
2.9.3

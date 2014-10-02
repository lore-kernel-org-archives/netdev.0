From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] ip6_gre: fix flowi6_proto value in xmit path
Date: Thu,  2 Oct 2014 18:26:49 +0200
Message-ID: <1412267209-893-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:57651 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723AbaJBQ1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 12:27:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In xmit path, we build a flowi6 which will be used for the output route lookup.
We are sending a GRE packet, neither IPv4 nor IPv6 encapsulated packet, thus the
protocol should be IPPROTO_GRE.

Fixes: c12b395a4664 ("gre: Support GRE over IPv6")
Reported-by: Matthieu Ternisien d'Ouville <matthieu.tdo@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_gre.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index f304471477dc..97299d76c1b0 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -782,7 +782,7 @@ static inline int ip6gre_xmit_ipv4(struct sk_buff *skb, struct net_device *dev)
 		encap_limit = t->parms.encap_limit;
 
 	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
-	fl6.flowi6_proto = IPPROTO_IPIP;
+	fl6.flowi6_proto = IPPROTO_GRE;
 
 	dsfield = ipv4_get_dsfield(iph);
 
@@ -832,7 +832,7 @@ static inline int ip6gre_xmit_ipv6(struct sk_buff *skb, struct net_device *dev)
 		encap_limit = t->parms.encap_limit;
 
 	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
-	fl6.flowi6_proto = IPPROTO_IPV6;
+	fl6.flowi6_proto = IPPROTO_GRE;
 
 	dsfield = ipv6_get_dsfield(ipv6h);
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS)
-- 
2.1.0

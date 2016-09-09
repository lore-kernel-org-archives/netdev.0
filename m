From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 1/3] ipv6: Export p6_route_input_lookup symbol
Date: Fri,  9 Sep 2016 14:53:23 -0700
Message-ID: <1473458003-18431-1-git-send-email-mahesh@bandewar.net>
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33628 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754205AbcIIVx1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 17:53:27 -0400
Received: by mail-pa0-f68.google.com with SMTP id h5so4351231pao.0
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 14:53:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

Make ip6_route_input_lookup available outside of ipv6 the module
similar to ip_route_input_noref in the IPv4 world.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 include/net/ip6_route.h | 3 +++
 net/ipv6/route.c        | 7 ++++---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index d97305d0e71f..e0cd318d5103 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -64,6 +64,9 @@ static inline bool rt6_need_strict(const struct in6_addr *daddr)
 }
 
 void ip6_route_input(struct sk_buff *skb);
+struct dst_entry *ip6_route_input_lookup(struct net *net,
+					 struct net_device *dev,
+					 struct flowi6 *fl6, int flags);
 
 struct dst_entry *ip6_route_output_flags(struct net *net, const struct sock *sk,
 					 struct flowi6 *fl6, int flags);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 09d43ff11a8d..9563eedd4f97 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1147,15 +1147,16 @@ static struct rt6_info *ip6_pol_route_input(struct net *net, struct fib6_table *
 	return ip6_pol_route(net, table, fl6->flowi6_iif, fl6, flags);
 }
 
-static struct dst_entry *ip6_route_input_lookup(struct net *net,
-						struct net_device *dev,
-						struct flowi6 *fl6, int flags)
+struct dst_entry *ip6_route_input_lookup(struct net *net,
+					 struct net_device *dev,
+					 struct flowi6 *fl6, int flags)
 {
 	if (rt6_need_strict(&fl6->daddr) && dev->type != ARPHRD_PIMREG)
 		flags |= RT6_LOOKUP_F_IFACE;
 
 	return fib6_rule_lookup(net, fl6, flags, ip6_pol_route_input);
 }
+EXPORT_SYMBOL_GPL(ip6_route_input_lookup);
 
 void ip6_route_input(struct sk_buff *skb)
 {
-- 
2.8.0.rc3.226.g39d4020

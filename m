From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/1] ipv6: ip6_route_output does not modify sk parameter, so make it const
Date: Tue, 22 Mar 2011 23:01:32 +0100
Message-ID: <1300831292-25378-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:59341 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755548Ab1CVWHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 18:07:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This avoids explicit cast to avoid 'discards qualifiers'
compiler warning in a netfilter patch that i've been working on.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/ip6_route.h |    2 +-
 net/ipv6/route.c        |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 642a80b..c850e5f 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -70,7 +70,7 @@ static inline struct inet_peer *rt6_get_peer(struct rt6_info *rt)
 extern void			ip6_route_input(struct sk_buff *skb);
 
 extern struct dst_entry *	ip6_route_output(struct net *net,
-						 struct sock *sk,
+						 const struct sock *sk,
 						 struct flowi6 *fl6);
 
 extern int			ip6_route_init(void);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 6814c87..843406f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -854,7 +854,7 @@ static struct rt6_info *ip6_pol_route_output(struct net *net, struct fib6_table
 	return ip6_pol_route(net, table, fl6->flowi6_oif, fl6, flags);
 }
 
-struct dst_entry * ip6_route_output(struct net *net, struct sock *sk,
+struct dst_entry * ip6_route_output(struct net *net, const struct sock *sk,
 				    struct flowi6 *fl6)
 {
 	int flags = 0;
-- 
1.7.3.4


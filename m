From: pablo@netfilter.org
Subject: [PATCH 03/19] ipv6: add ip6_route_lookup
Date: Sun, 25 Dec 2011 02:57:19 +0100
Message-ID: <1324778255-2830-4-git-send-email-pablo@netfilter.org>
References: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55996 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758016Ab1LYB6D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Dec 2011 20:58:03 -0500
In-Reply-To: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

like rt6_lookup, but allows caller to pass in flowi6 structure.
Will be used by the upcoming ipv6 netfilter reverse path filter
match.

Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/ip6_route.h |    2 ++
 net/ipv6/route.c        |    7 +++++++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 5e91b72..9c9399c 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -70,6 +70,8 @@ extern void			ip6_route_input(struct sk_buff *skb);
 extern struct dst_entry *	ip6_route_output(struct net *net,
 						 const struct sock *sk,
 						 struct flowi6 *fl6);
+extern struct dst_entry *	ip6_route_lookup(struct net *net,
+						 struct flowi6 *fl6, int flags);
 
 extern int			ip6_route_init(void);
 extern void			ip6_route_cleanup(void);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 1138b0a..ab48b02 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -658,6 +658,13 @@ out:
 
 }
 
+struct dst_entry * ip6_route_lookup(struct net *net, struct flowi6 *fl6,
+				    int flags)
+{
+	return fib6_rule_lookup(net, fl6, flags, ip6_pol_route_lookup);
+}
+EXPORT_SYMBOL_GPL(ip6_route_lookup);
+
 struct rt6_info *rt6_lookup(struct net *net, const struct in6_addr *daddr,
 			    const struct in6_addr *saddr, int oif, int strict)
 {
-- 
1.7.2.5

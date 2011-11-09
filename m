From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 3/4] ipv6: add ip6_route_lookup
Date: Wed,  9 Nov 2011 23:19:47 +0100
Message-ID: <1320877188-1972-4-git-send-email-fw@strlen.de>
References: <1320877188-1972-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:44197 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753558Ab1KIWZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 17:25:35 -0500
In-Reply-To: <1320877188-1972-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

like rt6_lookup, but allows caller to pass in flowi6 structure.
Will be used by the upcoming ipv6 netfilter reverse path filter
match.

Signed-off-by: Florian Westphal <fw@strlen.de>
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
index 8473016..9ea01e9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -656,6 +656,13 @@ out:
 
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
1.7.3.4

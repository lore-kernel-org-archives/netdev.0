From: Florian Westphal <fw@strlen.de>
Subject: [RFC PATCH 4/5] ipv6: add ip6_route_lookup
Date: Mon, 12 Sep 2011 21:42:31 +0200
Message-ID: <1315856552-1422-5-git-send-email-fw@strlen.de>
References: <1315856552-1422-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1315856552-1422-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
index 216ff31..183722c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -629,6 +629,13 @@ out:
 
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


From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 4/4] gre6: fix rtnl dump messages
Date: Fri,  9 Nov 2012 10:51:11 +0100
Message-ID: <1352454671-4336-5-git-send-email-nicolas.dichtel@6wind.com>
References: <1352454671-4336-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:57272 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751679Ab2KIJk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 04:40:26 -0500
In-Reply-To: <1352454671-4336-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Spotted after a code review.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_gre.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index bbe2e7b..12aa473 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1633,9 +1633,9 @@ static size_t ip6gre_get_size(const struct net_device *dev)
 		/* IFLA_GRE_OKEY */
 		nla_total_size(4) +
 		/* IFLA_GRE_LOCAL */
-		nla_total_size(4) +
+		nla_total_size(sizeof(struct in6_addr)) +
 		/* IFLA_GRE_REMOTE */
-		nla_total_size(4) +
+		nla_total_size(sizeof(struct in6_addr)) +
 		/* IFLA_GRE_TTL */
 		nla_total_size(1) +
 		/* IFLA_GRE_TOS */
@@ -1659,8 +1659,8 @@ static int ip6gre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_be16(skb, IFLA_GRE_OFLAGS, p->o_flags) ||
 	    nla_put_be32(skb, IFLA_GRE_IKEY, p->i_key) ||
 	    nla_put_be32(skb, IFLA_GRE_OKEY, p->o_key) ||
-	    nla_put(skb, IFLA_GRE_LOCAL, sizeof(struct in6_addr), &p->raddr) ||
-	    nla_put(skb, IFLA_GRE_REMOTE, sizeof(struct in6_addr), &p->laddr) ||
+	    nla_put(skb, IFLA_GRE_LOCAL, sizeof(struct in6_addr), &p->laddr) ||
+	    nla_put(skb, IFLA_GRE_REMOTE, sizeof(struct in6_addr), &p->raddr) ||
 	    nla_put_u8(skb, IFLA_GRE_TTL, p->hop_limit) ||
 	    /*nla_put_u8(skb, IFLA_GRE_TOS, t->priority) ||*/
 	    nla_put_u8(skb, IFLA_GRE_ENCAP_LIMIT, p->encap_limit) ||
-- 
1.7.12

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] gre6: fix rtnl dump messages
Date: Fri,  9 Nov 2012 16:34:56 +0100
Message-ID: <1352475296-14675-1-git-send-email-nicolas.dichtel@6wind.com>
References: <1352467361.19779.569.camel@edumazet-glaptop>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:57856 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754021Ab2KIPXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 10:23:02 -0500
In-Reply-To: <1352467361.19779.569.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Spotted after a code review.
Introduced by c12b395a46646bab69089ce7016ac78177f6001f (gre: Support GRE over
IPv6).

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
v2: rebase the patch against net
    add the commit that introduces the bug

 net/ipv6/ip6_gre.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 0185679..d5cb3c4 100644
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

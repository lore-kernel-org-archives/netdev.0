From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH 1/2] ip6_gre: Fix get_size calculation for gre6 tunnel
Date: Wed, 11 May 2016 18:48:31 +0800
Message-ID: <1462963712-13781-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
	Dmitry Kozlov <xeb@mail.ru>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do not include attribute IFLA_GRE_TOS.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 net/ipv6/ip6_gre.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index ee62ec4..3c25fe6 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1394,8 +1394,6 @@ static size_t ip6gre_get_size(const struct net_device *dev)
 		nla_total_size(sizeof(struct in6_addr)) +
 		/* IFLA_GRE_TTL */
 		nla_total_size(1) +
-		/* IFLA_GRE_TOS */
-		nla_total_size(1) +
 		/* IFLA_GRE_ENCAP_LIMIT */
 		nla_total_size(1) +
 		/* IFLA_GRE_FLOWINFO */
@@ -1420,7 +1418,6 @@ static int ip6gre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_in6_addr(skb, IFLA_GRE_LOCAL, &p->laddr) ||
 	    nla_put_in6_addr(skb, IFLA_GRE_REMOTE, &p->raddr) ||
 	    nla_put_u8(skb, IFLA_GRE_TTL, p->hop_limit) ||
-	    /*nla_put_u8(skb, IFLA_GRE_TOS, t->priority) ||*/
 	    nla_put_u8(skb, IFLA_GRE_ENCAP_LIMIT, p->encap_limit) ||
 	    nla_put_be32(skb, IFLA_GRE_FLOWINFO, p->flowinfo) ||
 	    nla_put_u32(skb, IFLA_GRE_FLAGS, p->flags))
-- 
1.8.3.1

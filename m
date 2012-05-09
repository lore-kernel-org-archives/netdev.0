From: Joe Perches <joe@perches.com>
Subject: [PATCH 10/13] netfilter: Convert compare_ether_addr to ether_addr_equal
Date: Tue,  8 May 2012 21:56:54 -0700
Message-ID: <6fc964a05b125385dc75798c24226bf20e16aa5d.1336538938.git.joe@perches.com>
References: <cover.1336538937.git.joe@perches.com>
Cc: netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <cover.1336538937.git.joe@perches.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the new bool function ether_addr_equal to add
some clarity and reduce the likelihood for misuse
of compare_ether_addr for sorting.

Done via cocci script:

$ cat compare_ether_addr.cocci
@@
expression a,b;
@@
-	!compare_ether_addr(a, b)
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	compare_ether_addr(a, b)
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!ether_addr_equal(a, b) == 0
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!ether_addr_equal(a, b) != 0
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	ether_addr_equal(a, b) == 0
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	ether_addr_equal(a, b) != 0
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!!ether_addr_equal(a, b)
+	ether_addr_equal(a, b)

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/netfilter/ipset/ip_set_bitmap_ipmac.c |    4 ++--
 net/netfilter/xt_mac.c                    |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index 0bb16c4..d7eaf10 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -111,7 +111,7 @@ bitmap_ipmac_test(struct ip_set *set, void *value, u32 timeout, u32 flags)
 		return -EAGAIN;
 	case MAC_FILLED:
 		return data->ether == NULL ||
-		       compare_ether_addr(data->ether, elem->ether) == 0;
+		       ether_addr_equal(data->ether, elem->ether);
 	}
 	return 0;
 }
@@ -225,7 +225,7 @@ bitmap_ipmac_ttest(struct ip_set *set, void *value, u32 timeout, u32 flags)
 		return -EAGAIN;
 	case MAC_FILLED:
 		return (data->ether == NULL ||
-			compare_ether_addr(data->ether, elem->ether) == 0) &&
+			ether_addr_equal(data->ether, elem->ether)) &&
 		       !bitmap_expired(map, data->id);
 	}
 	return 0;
diff --git a/net/netfilter/xt_mac.c b/net/netfilter/xt_mac.c
index 8160f6b..d5b4fd4 100644
--- a/net/netfilter/xt_mac.c
+++ b/net/netfilter/xt_mac.c
@@ -36,7 +36,7 @@ static bool mac_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		return false;
 	if (skb_mac_header(skb) + ETH_HLEN > skb->data)
 		return false;
-	ret  = compare_ether_addr(eth_hdr(skb)->h_source, info->srcaddr) == 0;
+	ret  = ether_addr_equal(eth_hdr(skb)->h_source, info->srcaddr);
 	ret ^= info->invert;
 	return ret;
 }
-- 
1.7.8.111.gad25c.dirty


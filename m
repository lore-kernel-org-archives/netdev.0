From: kaber@trash.net
Subject: [PATCH 7/7] netfilter: xt_iprange: add IPv6 match debug print code
Date: Mon, 31 Jan 2011 21:10:20 +0100
Message-ID: <1296504620-820-8-git-send-email-kaber@trash.net>
References: <1296504620-820-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1296504620-820-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Jacob <jacob@internet24.de>

Signed-off-by: Thomas Jacob <jacob@internet24.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_iprange.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_iprange.c b/net/netfilter/xt_iprange.c
index 77b9ebc..d3eb5ed 100644
--- a/net/netfilter/xt_iprange.c
+++ b/net/netfilter/xt_iprange.c
@@ -78,15 +78,27 @@ iprange_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 		m  = iprange_ipv6_sub(&iph->saddr, &info->src_min.in6) < 0;
 		m |= iprange_ipv6_sub(&iph->saddr, &info->src_max.in6) > 0;
 		m ^= !!(info->flags & IPRANGE_SRC_INV);
-		if (m)
+		if (m) {
+			pr_debug("src IP %pI6 NOT in range %s%pI6-%pI6\n",
+				 &iph->saddr,
+				 (info->flags & IPRANGE_SRC_INV) ? "(INV) " : "",
+				 &info->src_min.in6,
+				 &info->src_max.in6);
 			return false;
+		}
 	}
 	if (info->flags & IPRANGE_DST) {
 		m  = iprange_ipv6_sub(&iph->daddr, &info->dst_min.in6) < 0;
 		m |= iprange_ipv6_sub(&iph->daddr, &info->dst_max.in6) > 0;
 		m ^= !!(info->flags & IPRANGE_DST_INV);
-		if (m)
+		if (m) {
+			pr_debug("dst IP %pI6 NOT in range %s%pI6-%pI6\n",
+				 &iph->daddr,
+				 (info->flags & IPRANGE_DST_INV) ? "(INV) " : "",
+				 &info->dst_min.in6,
+				 &info->dst_max.in6);
 			return false;
+		}
 	}
 	return true;
 }
-- 
1.7.2.3


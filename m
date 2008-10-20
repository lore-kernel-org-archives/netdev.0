From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/07: xt_iprange: fix range inversion match
Date: Mon, 20 Oct 2008 11:54:12 +0200 (MEST)
Message-ID: <20081020095412.25670.68587.sendpatchset@x2.localnet>
References: <20081020095408.25670.37455.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081020095408.25670.37455.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 22e6543a9c21a1674ab5c1feddd141305a665dbd
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Sat Oct 18 15:20:56 2008 +0200

    netfilter: xt_iprange: fix range inversion match
    
    Inverted IPv4 v1 and IPv6 v0 matches don't match anything since 2.6.25-rc1!
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Acked-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_iprange.c b/net/netfilter/xt_iprange.c
index 6f62c36..7ac54ea 100644
--- a/net/netfilter/xt_iprange.c
+++ b/net/netfilter/xt_iprange.c
@@ -61,7 +61,7 @@ iprange_mt4(const struct sk_buff *skb, const struct xt_match_param *par)
 	if (info->flags & IPRANGE_SRC) {
 		m  = ntohl(iph->saddr) < ntohl(info->src_min.ip);
 		m |= ntohl(iph->saddr) > ntohl(info->src_max.ip);
-		m ^= info->flags & IPRANGE_SRC_INV;
+		m ^= !!(info->flags & IPRANGE_SRC_INV);
 		if (m) {
 			pr_debug("src IP " NIPQUAD_FMT " NOT in range %s"
 			         NIPQUAD_FMT "-" NIPQUAD_FMT "\n",
@@ -75,7 +75,7 @@ iprange_mt4(const struct sk_buff *skb, const struct xt_match_param *par)
 	if (info->flags & IPRANGE_DST) {
 		m  = ntohl(iph->daddr) < ntohl(info->dst_min.ip);
 		m |= ntohl(iph->daddr) > ntohl(info->dst_max.ip);
-		m ^= info->flags & IPRANGE_DST_INV;
+		m ^= !!(info->flags & IPRANGE_DST_INV);
 		if (m) {
 			pr_debug("dst IP " NIPQUAD_FMT " NOT in range %s"
 			         NIPQUAD_FMT "-" NIPQUAD_FMT "\n",
@@ -114,14 +114,14 @@ iprange_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 	if (info->flags & IPRANGE_SRC) {
 		m  = iprange_ipv6_sub(&iph->saddr, &info->src_min.in6) < 0;
 		m |= iprange_ipv6_sub(&iph->saddr, &info->src_max.in6) > 0;
-		m ^= info->flags & IPRANGE_SRC_INV;
+		m ^= !!(info->flags & IPRANGE_SRC_INV);
 		if (m)
 			return false;
 	}
 	if (info->flags & IPRANGE_DST) {
 		m  = iprange_ipv6_sub(&iph->daddr, &info->dst_min.in6) < 0;
 		m |= iprange_ipv6_sub(&iph->daddr, &info->dst_max.in6) > 0;
-		m ^= info->flags & IPRANGE_DST_INV;
+		m ^= !!(info->flags & IPRANGE_DST_INV);
 		if (m)
 			return false;
 	}

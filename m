From: kaber@trash.net
Subject: [PATCH 19/84] netfilter: xtables: clean up xt_mac match routine
Date: Mon, 10 May 2010 22:17:50 +0200
Message-ID: <1273522735-24672-20-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/netfilter/xt_mac.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/xt_mac.c b/net/netfilter/xt_mac.c
index c200711..2039d07 100644
--- a/net/netfilter/xt_mac.c
+++ b/net/netfilter/xt_mac.c
@@ -26,14 +26,16 @@ MODULE_ALIAS("ip6t_mac");
 
 static bool mac_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 {
-    const struct xt_mac_info *info = par->matchinfo;
-
-    /* Is mac pointer valid? */
-    return skb_mac_header(skb) >= skb->head &&
-	   skb_mac_header(skb) + ETH_HLEN <= skb->data
-	   /* If so, compare... */
-	   && ((!compare_ether_addr(eth_hdr(skb)->h_source, info->srcaddr))
-		^ info->invert);
+	const struct xt_mac_info *info = par->matchinfo;
+	bool ret;
+
+	if (skb_mac_header(skb) < skb->head)
+		return false;
+	if (skb_mac_header(skb) + ETH_HLEN > skb->data)
+		return false;
+	ret  = compare_ether_addr(eth_hdr(skb)->h_source, info->srcaddr) == 0;
+	ret ^= info->invert;
+	return ret;
 }
 
 static struct xt_match mac_mt_reg __read_mostly = {
-- 
1.7.0.4


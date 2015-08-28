From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/9] netfilter: nf_dup: fix sparse warnings
Date: Sat, 29 Aug 2015 00:50:13 +0200
Message-ID: <1440802217-13080-6-git-send-email-pablo@netfilter.org>
References: <1440802217-13080-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1440802217-13080-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> net/ipv4/netfilter/nft_dup_ipv4.c:29:37: sparse: incorrect type in initializer (different base types)
   net/ipv4/netfilter/nft_dup_ipv4.c:29:37:    expected restricted __be32 [user type] s_addr
   net/ipv4/netfilter/nft_dup_ipv4.c:29:37:    got unsigned int [unsigned] <noident>

>> net/ipv6/netfilter/nf_dup_ipv6.c:48:23: sparse: incorrect type in assignment (different base types)
   net/ipv6/netfilter/nf_dup_ipv6.c:48:23:    expected restricted __be32 [addressable] [assigned] [usertype] flowlabel
   net/ipv6/netfilter/nf_dup_ipv6.c:48:23:    got int

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nft_dup_ipv4.c |    2 +-
 net/ipv6/netfilter/nf_dup_ipv6.c  |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/netfilter/nft_dup_ipv4.c b/net/ipv4/netfilter/nft_dup_ipv4.c
index 25419fb..b45932d 100644
--- a/net/ipv4/netfilter/nft_dup_ipv4.c
+++ b/net/ipv4/netfilter/nft_dup_ipv4.c
@@ -26,7 +26,7 @@ static void nft_dup_ipv4_eval(const struct nft_expr *expr,
 {
 	struct nft_dup_ipv4 *priv = nft_expr_priv(expr);
 	struct in_addr gw = {
-		.s_addr = regs->data[priv->sreg_addr],
+		.s_addr = (__force __be32)regs->data[priv->sreg_addr],
 	};
 	int oif = regs->data[priv->sreg_dev];
 
diff --git a/net/ipv6/netfilter/nf_dup_ipv6.c b/net/ipv6/netfilter/nf_dup_ipv6.c
index d8ab654..c5c87e9 100644
--- a/net/ipv6/netfilter/nf_dup_ipv6.c
+++ b/net/ipv6/netfilter/nf_dup_ipv6.c
@@ -45,8 +45,8 @@ static bool nf_dup_ipv6_route(struct sk_buff *skb, const struct in6_addr *gw,
 		fl6.flowi6_oif = oif;
 
 	fl6.daddr = *gw;
-	fl6.flowlabel = ((iph->flow_lbl[0] & 0xF) << 16) |
-			 (iph->flow_lbl[1] << 8) | iph->flow_lbl[2];
+	fl6.flowlabel = (__force __be32)(((iph->flow_lbl[0] & 0xF) << 16) |
+			(iph->flow_lbl[1] << 8) | iph->flow_lbl[2]);
 	dst = ip6_route_output(net, NULL, &fl6);
 	if (dst->error) {
 		dst_release(dst);
-- 
1.7.10.4


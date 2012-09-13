From: pablo@netfilter.org
Subject: [PATCH 2/5] netfilter: nf_nat: fix out-of-bounds access in address selection
Date: Thu, 13 Sep 2012 13:01:29 +0200
Message-ID: <1347534092-3579-3-git-send-email-pablo@netfilter.org>
References: <1347534092-3579-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1347534092-3579-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

include/linux/jhash.h:138:16: warning: array subscript is above array bounds
[jhash2() expects the number of u32 in the key]

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_nat_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 29d4452..1816ad3 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -255,7 +255,7 @@ find_best_ips_proto(u16 zone, struct nf_conntrack_tuple *tuple,
 	 * client coming from the same IP (some Internet Banking sites
 	 * like this), even across reboots.
 	 */
-	j = jhash2((u32 *)&tuple->src.u3, sizeof(tuple->src.u3),
+	j = jhash2((u32 *)&tuple->src.u3, sizeof(tuple->src.u3) / sizeof(u32),
 		   range->flags & NF_NAT_RANGE_PERSISTENT ?
 			0 : (__force u32)tuple->dst.u3.all[max] ^ zone);
 
-- 
1.7.10.4


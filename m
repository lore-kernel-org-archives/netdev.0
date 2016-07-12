From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/6] netfilter: nft_meta: set skb->nf_trace appropriately
Date: Tue, 12 Jul 2016 18:10:58 +0200
Message-ID: <1468339862-4028-3-git-send-email-pablo@netfilter.org>
References: <1468339862-4028-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1468339862-4028-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <liping.zhang@spreadtrum.com>

When user add a nft rule to set nftrace to zero, for example:

  # nft add rule ip filter input nftrace set 0

We should set nf_trace to zero also.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_meta.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 16c50b0..f4bad9d 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -227,7 +227,7 @@ void nft_meta_set_eval(const struct nft_expr *expr,
 			skb->pkt_type = value;
 		break;
 	case NFT_META_NFTRACE:
-		skb->nf_trace = 1;
+		skb->nf_trace = !!value;
 		break;
 	default:
 		WARN_ON(1);
-- 
2.1.4


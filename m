From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 7/8] netfilter: nf_tables: reject NFT_SET_ELEM_INTERVAL_END flag for non-interval sets
Date: Mon, 23 Mar 2015 12:36:23 +0100
Message-ID: <1427110584-5190-8-git-send-email-pablo@netfilter.org>
References: <1427110584-5190-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1427110584-5190-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index a072d87..f7e3371 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3138,6 +3138,9 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 		elem.flags = ntohl(nla_get_be32(nla[NFTA_SET_ELEM_FLAGS]));
 		if (elem.flags & ~NFT_SET_ELEM_INTERVAL_END)
 			return -EINVAL;
+		if (!(set->flags & NFT_SET_INTERVAL) &&
+		    elem.flags & NFT_SET_ELEM_INTERVAL_END)
+			return -EINVAL;
 	}
 
 	if (set->flags & NFT_SET_MAP) {
-- 
1.7.10.4


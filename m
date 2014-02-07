From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/18] netfilter: nf_tables: do not allow NFT_SET_ELEM_INTERVAL_END flag and data
Date: Fri,  7 Feb 2014 18:41:41 +0100
Message-ID: <1391794904-4017-16-git-send-email-pablo@netfilter.org>
References: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This combination is not allowed since end interval elements cannot
contain data.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_tables_api.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 3a2e480..d0c790e3e 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2741,6 +2741,9 @@ static int nft_add_set_elem(const struct nft_ctx *ctx, struct nft_set *set,
 		if (nla[NFTA_SET_ELEM_DATA] == NULL &&
 		    !(elem.flags & NFT_SET_ELEM_INTERVAL_END))
 			return -EINVAL;
+		if (nla[NFTA_SET_ELEM_DATA] != NULL &&
+		    elem.flags & NFT_SET_ELEM_INTERVAL_END)
+			return -EINVAL;
 	} else {
 		if (nla[NFTA_SET_ELEM_DATA] != NULL)
 			return -EINVAL;
-- 
1.7.10.4


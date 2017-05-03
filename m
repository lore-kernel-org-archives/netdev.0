From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/16] netfilter: nf_tables: check if same extensions are set when adding elements
Date: Wed,  3 May 2017 11:32:11 +0200
Message-ID: <1493803931-2837-17-git-send-email-pablo@netfilter.org>
References: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If no NLM_F_EXCL is set and the element already exists in the set, make
sure that both elements have the same extensions.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 434c739dfeca..11a96e8dd3cd 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3749,6 +3749,11 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 	err = set->ops->insert(ctx->net, set, &elem, &ext2);
 	if (err) {
 		if (err == -EEXIST) {
+			if (nft_set_ext_exists(ext, NFT_SET_EXT_DATA) ^
+			    nft_set_ext_exists(ext2, NFT_SET_EXT_DATA) ||
+			    nft_set_ext_exists(ext, NFT_SET_EXT_OBJREF) ^
+			    nft_set_ext_exists(ext2, NFT_SET_EXT_OBJREF))
+				return -EBUSY;
 			if ((nft_set_ext_exists(ext, NFT_SET_EXT_DATA) &&
 			     nft_set_ext_exists(ext2, NFT_SET_EXT_DATA) &&
 			     memcmp(nft_set_ext_data(ext),
-- 
2.1.4


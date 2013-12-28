From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 8/8] netfilter: nf_tables: fix wrong datatype in nft_validate_data_load()
Date: Sat, 28 Dec 2013 23:03:07 +0100
Message-ID: <1388268187-11569-9-git-send-email-pablo@netfilter.org>
References: <1388268187-11569-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1388268187-11569-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes dictionary mappings, eg.

 add rule ip filter input meta dnat set tcp dport map { 22 => 1.1.1.1, 23 => 2.2.2.2 }

The kernel was returning -EINVAL in nft_validate_data_load() since
the type of the set element data that is passed was the real userspace
datatype instead of NFT_DATA_VALUE.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index d65c80b..71a9f49 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2382,7 +2382,9 @@ static int nf_tables_bind_check_setelem(const struct nft_ctx *ctx,
 	enum nft_registers dreg;
 
 	dreg = nft_type_to_reg(set->dtype);
-	return nft_validate_data_load(ctx, dreg, &elem->data, set->dtype);
+	return nft_validate_data_load(ctx, dreg, &elem->data,
+				      set->dtype == NFT_DATA_VERDICT ?
+				      NFT_DATA_VERDICT : NFT_DATA_VALUE);
 }
 
 int nf_tables_bind_set(const struct nft_ctx *ctx, struct nft_set *set,
-- 
1.7.10.4


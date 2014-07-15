From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/4] netfilter: nf_tables: skip transaction if no update flags in tables
Date: Tue, 15 Jul 2014 16:05:19 +0200
Message-ID: <1405433122-7440-2-git-send-email-pablo@netfilter.org>
References: <1405433122-7440-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1405433122-7440-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Skip transaction handling for table updates with no changes in
the flags. This fixes a crash when passing the table flag with all
bits unset.

Reported-by: Ana Rey <anarey@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index ab4566c..da5dc37 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -407,6 +407,9 @@ static int nf_tables_updtable(struct nft_ctx *ctx)
 	if (flags & ~NFT_TABLE_F_DORMANT)
 		return -EINVAL;
 
+	if (flags == ctx->table->flags)
+		return 0;
+
 	trans = nft_trans_alloc(ctx, NFT_MSG_NEWTABLE,
 				sizeof(struct nft_trans_table));
 	if (trans == NULL)
-- 
1.7.10.4


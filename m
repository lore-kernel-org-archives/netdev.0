From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] netfilter: nf_tables: Release memory obtained by kasprintf
Date: Wed, 20 Sep 2017 12:31:28 +0530
Message-ID: <385554261c080cd3fc4adc093e68366a6d3dff77.1505889128.git.arvind.yadav.cs@gmail.com>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Free memory region, if nf_tables_set_alloc_name is not successful.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 net/netfilter/nf_tables_api.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 9299271..393e37e 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2741,8 +2741,10 @@ static int nf_tables_set_alloc_name(struct nft_ctx *ctx, struct nft_set *set,
 	list_for_each_entry(i, &ctx->table->sets, list) {
 		if (!nft_is_active_next(ctx->net, i))
 			continue;
-		if (!strcmp(set->name, i->name))
+		if (!strcmp(set->name, i->name)) {
+			kfree(set->name);
 			return -ENFILE;
+		}
 	}
 	return 0;
 }
-- 
1.9.1

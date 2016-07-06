From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/26] netfilter: nft_rbtree: check for next generation when deactivating elements
Date: Wed,  6 Jul 2016 16:23:59 +0200
Message-ID: <1467815048-2240-18-git-send-email-pablo@netfilter.org>
References: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

set->ops->deactivate() is invoked from nft_del_setelem() that happens
from the transaction path, so we have to check if the object is active
in the next generation, not the current.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_rbtree.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nft_rbtree.c b/net/netfilter/nft_rbtree.c
index f762094..86fbe5e 100644
--- a/net/netfilter/nft_rbtree.c
+++ b/net/netfilter/nft_rbtree.c
@@ -170,7 +170,7 @@ static void *nft_rbtree_deactivate(const struct nft_set *set,
 	const struct nft_rbtree *priv = nft_set_priv(set);
 	const struct rb_node *parent = priv->root.rb_node;
 	struct nft_rbtree_elem *rbe, *this = elem->priv;
-	u8 genmask = nft_genmask_cur(read_pnet(&set->pnet));
+	u8 genmask = nft_genmask_next(read_pnet(&set->pnet));
 	int d;
 
 	while (parent != NULL) {
-- 
2.1.4


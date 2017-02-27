From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/6] netfilter: nft_set_bitmap: incorrect bitmap size
Date: Mon, 27 Feb 2017 12:35:42 +0100
Message-ID: <1488195342-2678-7-git-send-email-pablo@netfilter.org>
References: <1488195342-2678-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1488195342-2678-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

priv->bitmap_size stores the real bitmap size, instead of the full
struct nft_bitmap object.

Fixes: 665153ff5752 ("netfilter: nf_tables: add bitmap set type")
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_set_bitmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nft_set_bitmap.c b/net/netfilter/nft_set_bitmap.c
index 97f9649bcc7e..152d226552c1 100644
--- a/net/netfilter/nft_set_bitmap.c
+++ b/net/netfilter/nft_set_bitmap.c
@@ -258,7 +258,7 @@ static int nft_bitmap_init(const struct nft_set *set,
 {
 	struct nft_bitmap *priv = nft_set_priv(set);
 
-	priv->bitmap_size = nft_bitmap_total_size(set->klen);
+	priv->bitmap_size = nft_bitmap_size(set->klen);
 
 	return 0;
 }
-- 
2.1.4


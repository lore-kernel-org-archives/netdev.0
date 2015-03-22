From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/6] netfilter: Fix potential crash in nft_hash walker
Date: Sun, 22 Mar 2015 19:46:34 +0100
Message-ID: <1427049998-5665-3-git-send-email-pablo@netfilter.org>
References: <1427049998-5665-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1427049998-5665-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>

When we get back an EAGAIN from rhashtable_walk_next we were
treating it as a valid object which obviously doesn't work too
well.

Luckily this is hard to trigger so it seems nobody has run into
it yet.

This patch fixes it by redoing the next call when we get an EAGAIN.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_hash.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index c82df0a..37c15e6 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -153,6 +153,8 @@ static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_set *set,
 				iter->err = err;
 				goto out;
 			}
+
+			continue;
 		}
 
 		if (iter->count < iter->skip)
-- 
1.7.10.4


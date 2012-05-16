From: pablo@netfilter.org
Subject: [PATCH 3/7] netfilter: xt_HMARK: modulus is expensive for hash calculation
Date: Thu, 17 May 2012 01:06:40 +0200
Message-ID: <1337209604-3412-4-git-send-email-pablo@netfilter.org>
References: <1337209604-3412-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1337209604-3412-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Use:

((u64)(HASH_VAL * HASH_SIZE)) >> 32

as suggested by David S. Miller.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_HMARK.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/xt_HMARK.c b/net/netfilter/xt_HMARK.c
index 5817d03..0a96a43 100644
--- a/net/netfilter/xt_HMARK.c
+++ b/net/netfilter/xt_HMARK.c
@@ -109,7 +109,7 @@ hmark_hash(struct hmark_tuple *t, const struct xt_hmark_info *info)
 	hash = jhash_3words(t->src, t->dst, t->uports.v32, info->hashrnd);
 	hash = hash ^ (t->proto & info->proto_mask);
 
-	return (hash % info->hmodulus) + info->hoffset;
+	return (((u64)hash * info->hmodulus) >> 32) + info->hoffset;
 }
 
 static void
-- 
1.7.10


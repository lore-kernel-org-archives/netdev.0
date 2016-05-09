From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 34/36] netfilter: conntrack: make netns address part of nat bysrc hash
Date: Mon,  9 May 2016 20:46:52 +0200
Message-ID: <1462819614-5402-35-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Will be needed soon when we place all in the same hash table.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_nat_core.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index d74e716..069912c 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -118,7 +118,7 @@ EXPORT_SYMBOL(nf_xfrm_me_harder);
 
 /* We keep an extra hash for each conntrack, for fast searching. */
 static inline unsigned int
-hash_by_src(const struct net *net, const struct nf_conntrack_tuple *tuple)
+hash_by_src(const struct net *n, const struct nf_conntrack_tuple *tuple)
 {
 	unsigned int hash;
 
@@ -126,9 +126,9 @@ hash_by_src(const struct net *net, const struct nf_conntrack_tuple *tuple)
 
 	/* Original src, to ensure we map it consistently if poss. */
 	hash = jhash2((u32 *)&tuple->src, sizeof(tuple->src) / sizeof(u32),
-		      tuple->dst.protonum ^ nf_nat_hash_rnd);
+		      tuple->dst.protonum ^ nf_nat_hash_rnd ^ net_hash_mix(n));
 
-	return reciprocal_scale(hash, net->ct.nat_htable_size);
+	return reciprocal_scale(hash, n->ct.nat_htable_size);
 }
 
 /* Is this tuple already taken? (not by us) */
-- 
2.1.4


From: Josh Hunt <johunt@akamai.com>
Subject: [PATCH v2 2/2] nft_hash: define max_shift rhashtable parameter
Date: Tue, 24 Feb 2015 11:10:58 -0500
Message-ID: <1424794259-30241-3-git-send-email-johunt@akamai.com>
References: <1424794259-30241-1-git-send-email-johunt@akamai.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Josh Hunt <johunt@akamai.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1424794259-30241-1-git-send-email-johunt@akamai.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You must define a max_shift parameter to rhashtable or else the table cannot
grow. This sets max_shift for nft_hash to 24, which will allow the table to
grow to 2^24 or 16 million buckets.

Signed-off-by: Josh Hunt <johunt@akamai.com>
---
 net/netfilter/nft_hash.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 61e6c40..839ed30 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -23,6 +23,9 @@
 /* We target a hash table size of 4, element hint is 75% of final size */
 #define NFT_HASH_ELEMENT_HINT 3
 
+/* Set default of 2^24 buckets or 16 million entries */
+#define NFT_HASH_MAX_ELEMENTS 24
+
 struct nft_hash_elem {
 	struct rhash_head		node;
 	struct nft_data			key;
@@ -192,6 +195,7 @@ static int nft_hash_init(const struct nft_set *set,
 		.key_offset = offsetof(struct nft_hash_elem, key),
 		.key_len = set->klen,
 		.hashfn = jhash,
+		.max_shift = NFT_HASH_MAX_ELEMENTS,
 		.grow_decision = rht_grow_above_75,
 		.shrink_decision = rht_shrink_below_30,
 	};
-- 
1.7.9.5


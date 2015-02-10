From: Josh Hunt <johunt@akamai.com>
Subject: [PATCH 2/3] nft_hash: define max_shift rhashtable param
Date: Mon,  9 Feb 2015 19:48:30 -0500
Message-ID: <1423529311-26050-3-git-send-email-johunt@akamai.com>
References: <1423529311-26050-1-git-send-email-johunt@akamai.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Josh Hunt <johunt@akamai.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay06.akamai.com ([96.6.114.98]:42876 "EHLO
	prod-mail-xrelay06.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756181AbbBJAsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 19:48:52 -0500
In-Reply-To: <1423529311-26050-1-git-send-email-johunt@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Starting with commit "rhashtable: require max_shift definition" all users of
rhashtable must define a max_shift value to set an upper bound the table can
grow to. nft sets presently use nft_set_desc.size to enforce a limit on the size
a set can grow. Use this value to also set the ceiling for rhashtables.

If a user doesn't define a size it will fall back to a newly defined default of
10 (1024 elements.)

Signed-off-by: Josh Hunt <johunt@akamai.com>
---
 net/netfilter/nft_hash.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 61e6c40..08ec179 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -23,6 +23,9 @@
 /* We target a hash table size of 4, element hint is 75% of final size */
 #define NFT_HASH_ELEMENT_HINT 3
 
+/* Default max number of elements if user doesn't specify a size */
+#define NFT_HASH_MAX_ELEMENTS 10
+
 struct nft_hash_elem {
 	struct rhash_head		node;
 	struct nft_data			key;
@@ -194,6 +197,8 @@ static int nft_hash_init(const struct nft_set *set,
 		.hashfn = jhash,
 		.grow_decision = rht_grow_above_75,
 		.shrink_decision = rht_shrink_below_30,
+		.max_shift = desc->size ?
+			roundup_pow_of_two(desc->size) : NFT_HASH_MAX_ELEMENTS,
 	};
 
 	return rhashtable_init(priv, &params);
-- 
1.7.9.5

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 14/14] netfilter: Use default rhashtable hashfn
Date: Sun, 15 Mar 2015 21:44:40 +1100
Message-ID: <E1YX62C-0005pt-4M@gondolin.me.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:38357 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752517AbbCOKop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 06:44:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the explicit jhash value for the hashfn parameter
of rhashtable.  The default is now jhash so removing the setting
makes no difference apart from making one less copy of jhash in
the kernel.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/netfilter/nft_hash.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 1fcae5e..397bdd3 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -13,7 +13,6 @@
 #include <linux/module.h>
 #include <linux/list.h>
 #include <linux/log2.h>
-#include <linux/jhash.h>
 #include <linux/netlink.h>
 #include <linux/rhashtable.h>
 #include <linux/netfilter.h>
@@ -171,7 +170,6 @@ static int nft_hash_init(const struct nft_set *set,
 		.head_offset = offsetof(struct nft_hash_elem, node),
 		.key_offset = offsetof(struct nft_hash_elem, key),
 		.key_len = set->klen,
-		.hashfn = jhash,
 	};
 
 	return rhashtable_init(priv, &params);

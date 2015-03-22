From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH 6/10] netfilter: Use default rhashtable hashfn
Date: Sun, 22 Mar 2015 19:04:04 +1100
Message-ID: <E1YZarc-0000vx-O6@gondolin.me.apana.org.au>
References: <20150322080330.GA3416@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:56011 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbbCVIE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 04:04:27 -0400
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
index 4585c57..3bda4e7 100644
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
@@ -169,7 +168,6 @@ static unsigned int nft_hash_privsize(const struct nlattr * const nla[])
 static const struct rhashtable_params nft_hash_params = {
 	.head_offset = offsetof(struct nft_hash_elem, node),
 	.key_offset = offsetof(struct nft_hash_elem, key),
-	.hashfn = jhash,
 };
 
 static int nft_hash_init(const struct nft_set *set,

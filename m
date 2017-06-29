From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/29] netfilter: nft_set_hash: add nft_hash_buckets()
Date: Fri, 30 Jun 2017 00:53:13 +0200
Message-ID: <1498776807-11124-16-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57660 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752369AbdF2Wxz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 18:53:55 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 596C4BDF63
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:37 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 4A7F2D1CA9
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:37 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 2B052DA7F4
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:35 +0200 (CEST)
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add nft_hash_buckets() helper function to calculate the number of
hashtable buckets based on the elements. This function can be reused
from the follow up patch to add non-resizable hashtables.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_set_hash.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nft_set_hash.c b/net/netfilter/nft_set_hash.c
index 455a11ce8cd0..466cb7092dfa 100644
--- a/net/netfilter/nft_set_hash.c
+++ b/net/netfilter/nft_set_hash.c
@@ -363,12 +363,17 @@ static void nft_rhash_destroy(const struct nft_set *set)
 				    (void *)set);
 }
 
+static u32 nft_hash_buckets(u32 size)
+{
+	return roundup_pow_of_two(size * 4 / 3);
+}
+
 static bool nft_rhash_estimate(const struct nft_set_desc *desc, u32 features,
 			       struct nft_set_estimate *est)
 {
 	if (desc->size)
 		est->size = sizeof(struct nft_rhash) +
-			    roundup_pow_of_two(desc->size * 4 / 3) *
+			    nft_hash_buckets(desc->size) *
 			    sizeof(struct nft_rhash_elem *) +
 			    desc->size * sizeof(struct nft_rhash_elem);
 	else
-- 
2.1.4

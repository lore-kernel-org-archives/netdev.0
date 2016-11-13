From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/39] netfilter: nft_hash: get random bytes if seed is not specified
Date: Sun, 13 Nov 2016 23:25:05 +0100
Message-ID: <1479075933-4491-12-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47690 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964832AbcKMW0M (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Nov 2016 17:26:12 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 35010A7F25
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:09 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 1684DDA80B
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:09 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 26129DA862
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:07 +0100 (CET)
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the user doesn't specify a seed, generate one at configuration time.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_hash.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index baf694de3935..97ad8e30e4b4 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -57,7 +57,6 @@ static int nft_hash_init(const struct nft_ctx *ctx,
 	if (!tb[NFTA_HASH_SREG] ||
 	    !tb[NFTA_HASH_DREG] ||
 	    !tb[NFTA_HASH_LEN]  ||
-	    !tb[NFTA_HASH_SEED] ||
 	    !tb[NFTA_HASH_MODULUS])
 		return -EINVAL;
 
@@ -80,7 +79,10 @@ static int nft_hash_init(const struct nft_ctx *ctx,
 	if (priv->offset + priv->modulus - 1 < priv->offset)
 		return -EOVERFLOW;
 
-	priv->seed = ntohl(nla_get_be32(tb[NFTA_HASH_SEED]));
+	if (tb[NFTA_HASH_SEED])
+		priv->seed = ntohl(nla_get_be32(tb[NFTA_HASH_SEED]));
+	else
+		get_random_bytes(&priv->seed, sizeof(priv->seed));
 
 	return nft_validate_register_load(priv->sreg, len) &&
 	       nft_validate_register_store(ctx, priv->dreg, NULL,
-- 
2.1.4

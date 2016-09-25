From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 26/53] netfilter: nft_hash: fix hash overflow validation
Date: Mon, 26 Sep 2016 01:06:36 +0200
Message-ID: <1474844823-2026-27-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54688 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034635AbcIYXHs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:07:48 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id B8A09C0B49
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:45 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A9134DA851
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:45 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 8CA37DA84A
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:43 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Laura Garcia Liebana <nevola@gmail.com>

The overflow validation in the init() function establishes that the
maximum value that the hash could reach is less than U32_MAX, which is
likely to be true.

The fix detects the overflow when the maximum hash value is less than
the offset itself.

Fixes: 70ca767ea1b2 ("netfilter: nft_hash: Add hash offset value")
Reported-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Laura Garcia Liebana <nevola@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_hash.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index bd12f7a801c2..09473b415b95 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -76,7 +76,7 @@ static int nft_hash_init(const struct nft_ctx *ctx,
 	if (priv->modulus <= 1)
 		return -ERANGE;
 
-	if (priv->offset + priv->modulus - 1 < U32_MAX)
+	if (priv->offset + priv->modulus - 1 < priv->offset)
 		return -EOVERFLOW;
 
 	priv->seed = ntohl(nla_get_be32(tb[NFTA_HASH_SEED]));
-- 
2.1.4

From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 35/53] netfilter: nft_lookup: remove superfluous element found check
Date: Mon, 26 Sep 2016 01:06:45 +0200
Message-ID: <1474844823-2026-36-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54744 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034816AbcIYXH4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:07:56 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id CACF7C1081
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:54 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id BABEDDA84B
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:54 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B7E7EDA842
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:52 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We already checked for !found just a bit before:

        if (!found) {
                regs->verdict.code = NFT_BREAK;
                return;
        }

        if (found && set->flags & NFT_SET_MAP)
            ^^^^^

So this redundant check can just go away.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_lookup.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
index e164325d1bc0..8166b6994cc7 100644
--- a/net/netfilter/nft_lookup.c
+++ b/net/netfilter/nft_lookup.c
@@ -43,7 +43,7 @@ static void nft_lookup_eval(const struct nft_expr *expr,
 		return;
 	}
 
-	if (found && set->flags & NFT_SET_MAP)
+	if (set->flags & NFT_SET_MAP)
 		nft_data_copy(&regs->data[priv->dreg],
 			      nft_set_ext_data(ext), set->dlen);
 
-- 
2.1.4

From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/11] netfilter: nft_range: add the missing NULL pointer check
Date: Wed, 30 Nov 2016 22:57:22 +0100
Message-ID: <1480543045-3389-9-git-send-email-pablo@netfilter.org>
References: <1480543045-3389-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42172 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754781AbcK3V5s (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 16:57:48 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id E5C0413C0E7
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 22:57:44 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D79D3DA86B
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 22:57:44 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id E1E05DA865
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 22:57:42 +0100 (CET)
In-Reply-To: <1480543045-3389-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

Otherwise, kernel panic will happen if the user does not specify
the related attributes.

Fixes: 0f3cd9b36977 ("netfilter: nf_tables: add range expression")
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_range.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/netfilter/nft_range.c b/net/netfilter/nft_range.c
index fbc88009ca2e..8f0aaaea1376 100644
--- a/net/netfilter/nft_range.c
+++ b/net/netfilter/nft_range.c
@@ -59,6 +59,12 @@ static int nft_range_init(const struct nft_ctx *ctx, const struct nft_expr *expr
 	int err;
 	u32 op;
 
+	if (!tb[NFTA_RANGE_SREG]      ||
+	    !tb[NFTA_RANGE_OP]	      ||
+	    !tb[NFTA_RANGE_FROM_DATA] ||
+	    !tb[NFTA_RANGE_TO_DATA])
+		return -EINVAL;
+
 	err = nft_data_init(NULL, &priv->data_from, sizeof(priv->data_from),
 			    &desc_from, tb[NFTA_RANGE_FROM_DATA]);
 	if (err < 0)
-- 
2.1.4

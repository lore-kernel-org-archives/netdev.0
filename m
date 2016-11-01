From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/12] netfilter: nf_tables: remove useless U8_MAX validation
Date: Tue,  1 Nov 2016 22:26:32 +0100
Message-ID: <1478035593-1362-12-git-send-email-pablo@netfilter.org>
References: <1478035593-1362-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52640 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932451AbcKAV1K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 17:27:10 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 6138E16839A
        for <netdev@vger.kernel.org>; Tue,  1 Nov 2016 22:27:09 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 51EA1BAC2A
        for <netdev@vger.kernel.org>; Tue,  1 Nov 2016 22:27:09 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 2FACBBAC2D
        for <netdev@vger.kernel.org>; Tue,  1 Nov 2016 22:27:07 +0100 (CET)
In-Reply-To: <1478035593-1362-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

After call nft_data_init, size is already validated and desc.len will
not exceed the sizeof(struct nft_data), i.e. 16 bytes. So it will never
exceed U8_MAX.

Furthermore, in nft_immediate_init, we forget to call nft_data_uninit
when desc.len exceeds U8_MAX, although this will not happen, but it's
a logical mistake.

Now remove these redundant validation introduced by commit 36b701fae12a
("netfilter: nf_tables: validate maximum value of u32 netlink attributes")

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_cmp.c       | 3 ---
 net/netfilter/nft_immediate.c | 3 ---
 2 files changed, 6 deletions(-)

diff --git a/net/netfilter/nft_cmp.c b/net/netfilter/nft_cmp.c
index 2e53739812b1..e25b35d70e4d 100644
--- a/net/netfilter/nft_cmp.c
+++ b/net/netfilter/nft_cmp.c
@@ -84,9 +84,6 @@ static int nft_cmp_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	if (err < 0)
 		return err;
 
-	if (desc.len > U8_MAX)
-		return -ERANGE;
-
 	priv->op  = ntohl(nla_get_be32(tb[NFTA_CMP_OP]));
 	priv->len = desc.len;
 	return 0;
diff --git a/net/netfilter/nft_immediate.c b/net/netfilter/nft_immediate.c
index d17018ff54e6..4528adea7ede 100644
--- a/net/netfilter/nft_immediate.c
+++ b/net/netfilter/nft_immediate.c
@@ -54,9 +54,6 @@ static int nft_immediate_init(const struct nft_ctx *ctx,
 	if (err < 0)
 		return err;
 
-	if (desc.len > U8_MAX)
-		return -ERANGE;
-
 	priv->dlen = desc.len;
 
 	priv->dreg = nft_parse_register(tb[NFTA_IMMEDIATE_DREG]);
-- 
2.1.4

From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/11] netfilter: nft_hash: validate maximum value of u32 netlink hash attribute
Date: Wed, 30 Nov 2016 22:57:18 +0100
Message-ID: <1480543045-3389-5-git-send-email-pablo@netfilter.org>
References: <1480543045-3389-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42136 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755024AbcK3V5s (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 16:57:48 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id E2A0213C0E5
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 22:57:41 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D0CFBDA861
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 22:57:41 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DAC4CDA817
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 22:57:39 +0100 (CET)
In-Reply-To: <1480543045-3389-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Laura Garcia Liebana <nevola@gmail.com>

Use the function nft_parse_u32_check() to fetch the value and validate
the u32 attribute into the hash len u8 field.

This patch revisits 4da449ae1df9 ("netfilter: nft_exthdr: Add size check
on u8 nft_exthdr attributes").

Fixes: cb1b69b0b15b ("netfilter: nf_tables: add hash expression")
Signed-off-by: Laura Garcia Liebana <nevola@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_hash.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index baf694de3935..d5447a22275c 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -53,6 +53,7 @@ static int nft_hash_init(const struct nft_ctx *ctx,
 {
 	struct nft_hash *priv = nft_expr_priv(expr);
 	u32 len;
+	int err;
 
 	if (!tb[NFTA_HASH_SREG] ||
 	    !tb[NFTA_HASH_DREG] ||
@@ -67,8 +68,10 @@ static int nft_hash_init(const struct nft_ctx *ctx,
 	priv->sreg = nft_parse_register(tb[NFTA_HASH_SREG]);
 	priv->dreg = nft_parse_register(tb[NFTA_HASH_DREG]);
 
-	len = ntohl(nla_get_be32(tb[NFTA_HASH_LEN]));
-	if (len == 0 || len > U8_MAX)
+	err = nft_parse_u32_check(tb[NFTA_HASH_LEN], U8_MAX, &len);
+	if (err < 0)
+		return err;
+	if (len == 0)
 		return -ERANGE;
 
 	priv->len = len;
-- 
2.1.4

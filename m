From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/12] netfilter: nft_numgen: start round robin from zero
Date: Tue,  1 Nov 2016 22:26:25 +0100
Message-ID: <1478035593-1362-5-git-send-email-pablo@netfilter.org>
References: <1478035593-1362-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52518 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754561AbcKAV0t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 17:26:49 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 6E6931683AF
        for <netdev@vger.kernel.org>; Tue,  1 Nov 2016 22:26:46 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5EDA4BAC25
        for <netdev@vger.kernel.org>; Tue,  1 Nov 2016 22:26:46 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D1DA5DA855
        for <netdev@vger.kernel.org>; Tue,  1 Nov 2016 22:26:41 +0100 (CET)
In-Reply-To: <1478035593-1362-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

Currently we start round robin from 1, but it's better to start round
robin from 0. This is to keep consistent with xt_statistic in iptables.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_numgen.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nft_numgen.c b/net/netfilter/nft_numgen.c
index 55bc5ab78d4a..a66b36097b8f 100644
--- a/net/netfilter/nft_numgen.c
+++ b/net/netfilter/nft_numgen.c
@@ -65,7 +65,7 @@ static int nft_ng_inc_init(const struct nft_ctx *ctx,
 		return -EOVERFLOW;
 
 	priv->dreg = nft_parse_register(tb[NFTA_NG_DREG]);
-	atomic_set(&priv->counter, 0);
+	atomic_set(&priv->counter, priv->modulus - 1);
 
 	return nft_validate_register_store(ctx, priv->dreg, NULL,
 					   NFT_DATA_VALUE, sizeof(u32));
-- 
2.1.4

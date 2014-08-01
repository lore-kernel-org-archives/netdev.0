From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/3] netfilter: nf_tables: Avoid duplicate call to nft_data_uninit() for same key
Date: Fri,  1 Aug 2014 18:40:39 +0200
Message-ID: <1406911239-6250-4-git-send-email-pablo@netfilter.org>
References: <1406911239-6250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47145 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754697AbaHAQkg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2014 12:40:36 -0400
In-Reply-To: <1406911239-6250-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>

nft_del_setelem() currently calls nft_data_uninit() twice on the same
key. Once to release the key which is guaranteed to be NFT_DATA_VALUE
and a second time in the error path to which it falls through.

The second call has been harmless so far though because the type
passed is always NFT_DATA_VALUE which is currently a no-op.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 8746ff9..b35ba83 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3218,6 +3218,7 @@ static int nft_del_setelem(struct nft_ctx *ctx, struct nft_set *set,
 	if (set->flags & NFT_SET_MAP)
 		nft_data_uninit(&elem.data, set->dtype);
 
+	return 0;
 err2:
 	nft_data_uninit(&elem.key, desc.type);
 err1:
-- 
1.7.10.4

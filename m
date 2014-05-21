From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 19/25] netfilter: nf_tables: disabling table hooks always succeeds
Date: Wed, 21 May 2014 11:43:16 +0200
Message-ID: <1400665402-5835-19-git-send-email-pablo@netfilter.org>
References: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56029 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752203AbaEUJnu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 05:43:50 -0400
In-Reply-To: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nf_tables_table_disable() always succeeds, make this function void.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 7a1149f..5f71703 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -381,7 +381,7 @@ err:
 	return err;
 }
 
-static int nf_tables_table_disable(const struct nft_af_info *afi,
+static void nf_tables_table_disable(const struct nft_af_info *afi,
 				   struct nft_table *table)
 {
 	struct nft_chain *chain;
@@ -391,8 +391,6 @@ static int nf_tables_table_disable(const struct nft_af_info *afi,
 			nf_unregister_hooks(nft_base_chain(chain)->ops,
 					    afi->nops);
 	}
-
-	return 0;
 }
 
 static int nf_tables_updtable(struct sock *nlsk, struct sk_buff *skb,
@@ -412,9 +410,8 @@ static int nf_tables_updtable(struct sock *nlsk, struct sk_buff *skb,
 
 		if ((flags & NFT_TABLE_F_DORMANT) &&
 		    !(table->flags & NFT_TABLE_F_DORMANT)) {
-			ret = nf_tables_table_disable(afi, table);
-			if (ret >= 0)
-				table->flags |= NFT_TABLE_F_DORMANT;
+			nf_tables_table_disable(afi, table);
+			table->flags |= NFT_TABLE_F_DORMANT;
 		} else if (!(flags & NFT_TABLE_F_DORMANT) &&
 			   table->flags & NFT_TABLE_F_DORMANT) {
 			ret = nf_tables_table_enable(afi, table);
-- 
1.7.10.4

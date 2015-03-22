From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/6] netfilter: nf_tables: allow to change chain policy without hook if it exists
Date: Sun, 22 Mar 2015 19:46:35 +0100
Message-ID: <1427049998-5665-4-git-send-email-pablo@netfilter.org>
References: <1427049998-5665-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33394 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751875AbbCVSmt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Mar 2015 14:42:49 -0400
In-Reply-To: <1427049998-5665-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If there's an existing base chain, we have to allow to change the
default policy without indicating the hook information.

However, if the chain doesn't exists, we have to enforce the presence of
the hook attribute.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 6ab7779..ac1a952 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1225,7 +1225,10 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 
 	if (nla[NFTA_CHAIN_POLICY]) {
 		if ((chain != NULL &&
-		    !(chain->flags & NFT_BASE_CHAIN)) ||
+		    !(chain->flags & NFT_BASE_CHAIN)))
+			return -EOPNOTSUPP;
+
+		if (chain == NULL &&
 		    nla[NFTA_CHAIN_HOOK] == NULL)
 			return -EOPNOTSUPP;
 
-- 
1.7.10.4

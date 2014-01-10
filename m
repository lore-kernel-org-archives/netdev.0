From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/23] netfilter: nf_tables: fix check for table overflow
Date: Fri, 10 Jan 2014 01:35:32 +0100
Message-ID: <1389314142-17969-14-git-send-email-pablo@netfilter.org>
References: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51554 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757202AbaAJAgL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 19:36:11 -0500
In-Reply-To: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

The table use counter is only increased for new chains, so move the check
to the correct position.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index d275d38..290472c 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -834,9 +834,6 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 	if (IS_ERR(table))
 		return PTR_ERR(table);
 
-	if (table->use == UINT_MAX)
-		return -EOVERFLOW;
-
 	chain = NULL;
 	name = nla[NFTA_CHAIN_NAME];
 
@@ -899,6 +896,9 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 		goto notify;
 	}
 
+	if (table->use == UINT_MAX)
+		return -EOVERFLOW;
+
 	if (nla[NFTA_CHAIN_HOOK]) {
 		struct nf_hook_ops *ops;
 		nf_hookfn *hookfn;
-- 
1.7.10.4

From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/13] netfilter: nf_tables: fix wrong type in transaction when replacing rules
Date: Wed, 18 Jun 2014 11:44:33 +0200
Message-ID: <1403084679-11227-8-git-send-email-pablo@netfilter.org>
References: <1403084679-11227-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41433 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965670AbaFRJoz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2014 05:44:55 -0400
In-Reply-To: <1403084679-11227-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In b380e5c ("netfilter: nf_tables: add message type to transactions"),
I used the wrong message type in the rule replacement case. The rule
that is replaced needs to be handled as a deleted rule.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 19f438d..39369ea 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1792,7 +1792,7 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 
 	if (nlh->nlmsg_flags & NLM_F_REPLACE) {
 		if (nft_rule_is_active_next(net, old_rule)) {
-			trans = nft_trans_rule_add(&ctx, NFT_MSG_NEWRULE,
+			trans = nft_trans_rule_add(&ctx, NFT_MSG_DELRULE,
 						   old_rule);
 			if (trans == NULL) {
 				err = -ENOMEM;
-- 
1.7.10.4

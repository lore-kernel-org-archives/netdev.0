From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/13] netfilter: nf_tables: use RCU-safe list insertion when replacing rules
Date: Wed, 18 Jun 2014 11:44:30 +0200
Message-ID: <1403084679-11227-5-git-send-email-pablo@netfilter.org>
References: <1403084679-11227-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41409 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965626AbaFRJow (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2014 05:44:52 -0400
In-Reply-To: <1403084679-11227-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch 5e94846 ("netfilter: nf_tables: add insert operation") did
not include RCU-safe list insertion when replacing rules.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 624e083..ba37c10 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1796,7 +1796,7 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 				goto err2;
 			}
 			nft_rule_disactivate_next(net, old_rule);
-			list_add_tail(&rule->list, &old_rule->list);
+			list_add_tail_rcu(&rule->list, &old_rule->list);
 		} else {
 			err = -ENOENT;
 			goto err2;
-- 
1.7.10.4

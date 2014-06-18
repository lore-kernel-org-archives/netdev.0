From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/13] netfilter: nf_tables: decrement chain use counter when replacing rules
Date: Wed, 18 Jun 2014 11:44:32 +0200
Message-ID: <1403084679-11227-7-git-send-email-pablo@netfilter.org>
References: <1403084679-11227-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1403084679-11227-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thus, the chain use counter remains with the same value after the
rule replacement.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 5586426..19f438d 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1799,6 +1799,7 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 				goto err2;
 			}
 			nft_rule_disactivate_next(net, old_rule);
+			chain->use--;
 			list_add_tail_rcu(&rule->list, &old_rule->list);
 		} else {
 			err = -ENOENT;
@@ -1829,6 +1830,7 @@ err3:
 		list_del_rcu(&nft_trans_rule(trans)->list);
 		nft_rule_clear(net, nft_trans_rule(trans));
 		nft_trans_destroy(trans);
+		chain->use++;
 	}
 err2:
 	nf_tables_rule_destroy(&ctx, rule);
-- 
1.7.10.4


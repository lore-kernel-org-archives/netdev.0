From: simran singhal <singhalsimran0@gmail.com>
Subject: [PATCH] net: netfilter: Use list_{next/prev}_entry instead of
 list_entry
Date: Wed, 29 Mar 2017 11:15:40 +0530
Message-ID: <20170329054540.GA15593@singhal-Inspiron-5558>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        outreachy-kernel@googlegroups.com
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35953 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752729AbdC2Fpp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 01:45:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replace list_entry with list_prev_entry as it makes the
code more clear to read.

Signed-off-by: simran singhal <singhalsimran0@gmail.com>
---
 net/netfilter/nf_tables_api.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index b7645d7..a341eaf 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1895,7 +1895,7 @@ static int nf_tables_fill_rule_info(struct sk_buff *skb, struct net *net,
 		goto nla_put_failure;
 
 	if ((event != NFT_MSG_DELRULE) && (rule->list.prev != &chain->rules)) {
-		prule = list_entry(rule->list.prev, struct nft_rule, list);
+		prule = list_prev_entry(rule, list);
 		if (nla_put_be64(skb, NFTA_RULE_POSITION,
 				 cpu_to_be64(prule->handle),
 				 NFTA_RULE_PAD))
-- 
2.7.4

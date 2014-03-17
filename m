From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/38] netfilter: nf_tables: add nft_dereference() macro
Date: Mon, 17 Mar 2014 13:42:26 +0100
Message-ID: <1395060178-11833-7-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59383 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933115AbaCQMnc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 08:43:32 -0400
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |    4 ++++
 net/netfilter/nf_tables_api.c     |    3 +--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index e7e14ff..81abd61 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -3,6 +3,7 @@
 
 #include <linux/list.h>
 #include <linux/netfilter.h>
+#include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/nf_tables.h>
 #include <net/netlink.h>
@@ -521,6 +522,9 @@ void nft_unregister_chain_type(const struct nf_chain_type *);
 int nft_register_expr(struct nft_expr_type *);
 void nft_unregister_expr(struct nft_expr_type *);
 
+#define nft_dereference(p)					\
+	nfnl_dereference(p, NFNL_SUBSYS_NFTABLES)
+
 #define MODULE_ALIAS_NFT_FAMILY(family)	\
 	MODULE_ALIAS("nft-afinfo-" __stringify(family))
 
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index adce01e..4b7e14d 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -794,9 +794,8 @@ nf_tables_counters(struct nft_base_chain *chain, const struct nlattr *attr)
 	stats->pkts = be64_to_cpu(nla_get_be64(tb[NFTA_COUNTER_PACKETS]));
 
 	if (chain->stats) {
-		/* nfnl_lock is held, add some nfnl function for this, later */
 		struct nft_stats __percpu *oldstats =
-			rcu_dereference_protected(chain->stats, 1);
+				nft_dereference(chain->stats);
 
 		rcu_assign_pointer(chain->stats, newstats);
 		synchronize_rcu();
-- 
1.7.10.4

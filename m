From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/6 -stable] netfilter: nf_tables: don't update chain with unset counters
Date: Fri, 26 Sep 2014 13:43:44 +0200
Message-ID: <1411731824-15051-7-git-send-email-pablo@netfilter.org>
References: <1411731824-15051-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36257 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754062AbaIZLmr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Sep 2014 07:42:47 -0400
In-Reply-To: <1411731824-15051-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ upstream commit b88825de8545ad252c31543fef13cadf4de7a2bc ]

Fix possible replacement of the per-cpu chain counters by null
pointer when updating an existing chain in the commit path.

Cc: <stable@vger.kernel.org> # 3.16.x
Reported-by: Matteo Croce <technoboy85@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index c6f9d3d..9aa31f1 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -899,6 +899,9 @@ static struct nft_stats __percpu *nft_stats_alloc(const struct nlattr *attr)
 static void nft_chain_stats_replace(struct nft_base_chain *chain,
 				    struct nft_stats __percpu *newstats)
 {
+	if (newstats == NULL)
+		return;
+
 	if (chain->stats) {
 		struct nft_stats __percpu *oldstats =
 				nft_dereference(chain->stats);
-- 
1.7.10.4

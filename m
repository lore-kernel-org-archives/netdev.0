From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/4] netfilter: nf_tables: don't update chain with unset counters
Date: Mon, 11 Aug 2014 19:06:17 +0200
Message-ID: <1407776779-9113-3-git-send-email-pablo@netfilter.org>
References: <1407776779-9113-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1407776779-9113-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix possible replacement of the per-cpu chain counters by null
pointer when updating an existing chain in the commit path.

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


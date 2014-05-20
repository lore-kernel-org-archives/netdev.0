From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/6] netfilter: nf_tables: fix bogus rulenum after goto action
Date: Tue, 20 May 2014 11:45:24 +0200
Message-ID: <1400579126-6451-5-git-send-email-pablo@netfilter.org>
References: <1400579126-6451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1400579126-6451-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After returning from the chain that we just went to with no matchings,
we get a bogus rule number in the trace. To fix this, we would need
to iterate over the list of remaining rules in the chain to update the
rule number counter.

Patrick suggested to set this to the maximum value since the default
base chain policy is the very last action when the processing the base
chain is over.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index f55fb28..be08a96 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -202,7 +202,7 @@ next_rule:
 	}
 
 	if (unlikely(pkt->skb->nf_trace))
-		nft_trace_packet(pkt, basechain, ++rulenum, NFT_TRACE_POLICY);
+		nft_trace_packet(pkt, basechain, -1, NFT_TRACE_POLICY);
 
 	rcu_read_lock_bh();
 	stats = rcu_dereference(nft_base_chain(basechain)->stats);
-- 
1.7.10.4


From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/18] netfilter: nf_tables: unininline nft_trace_packet()
Date: Fri,  7 Feb 2014 18:41:44 +0100
Message-ID: <1391794904-4017-19-git-send-email-pablo@netfilter.org>
References: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

It makes no sense to inline a rarely used function meant for debugging
only that is called a total of five times in the main evaluation loop.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_core.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 0d879fc..90998a6 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -103,9 +103,9 @@ static struct nf_loginfo trace_loginfo = {
 	},
 };
 
-static inline void nft_trace_packet(const struct nft_pktinfo *pkt,
-				    const struct nft_chain *chain,
-				    int rulenum, enum nft_trace type)
+static void nft_trace_packet(const struct nft_pktinfo *pkt,
+			     const struct nft_chain *chain,
+			     int rulenum, enum nft_trace type)
 {
 	struct net *net = dev_net(pkt->in ? pkt->in : pkt->out);
 
-- 
1.7.10.4


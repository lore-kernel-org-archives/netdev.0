From: kaber@trash.net
Subject: [PATCH 16/79] IPVS: Only match pe_data created by the same pe
Date: Wed, 19 Jan 2011 20:14:16 +0100
Message-ID: <1295464519-21763-17-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>

Only match persistence engine data if it was
created by the same persistence engine.

Reported-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 64a9ca3..261db1a 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -354,7 +354,7 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
 		if (p->pe_data && p->pe->ct_match) {
-			if (p->pe->ct_match(p, cp))
+			if (p->pe == cp->pe && p->pe->ct_match(p, cp))
 				goto out;
 			continue;
 		}
-- 
1.7.2.3


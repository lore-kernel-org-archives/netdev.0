From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/29] ipvs: use nf_ct_kill helper
Date: Mon,  5 Sep 2016 12:58:20 +0200
Message-ID: <1473073124-5015-6-git-send-email-pablo@netfilter.org>
References: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Once timer is removed from nf_conn struct we cannot open-code
the removal sequence anymore.

Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipvs/ip_vs_nfct.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_nfct.c b/net/netfilter/ipvs/ip_vs_nfct.c
index f04fd8d..fc230d9 100644
--- a/net/netfilter/ipvs/ip_vs_nfct.c
+++ b/net/netfilter/ipvs/ip_vs_nfct.c
@@ -281,13 +281,10 @@ void ip_vs_conn_drop_conntrack(struct ip_vs_conn *cp)
 	h = nf_conntrack_find_get(cp->ipvs->net, &nf_ct_zone_dflt, &tuple);
 	if (h) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
-		/* Show what happens instead of calling nf_ct_kill() */
-		if (del_timer(&ct->timeout)) {
-			IP_VS_DBG(7, "%s: ct=%p, deleted conntrack timer for tuple="
+		if (nf_ct_kill(ct)) {
+			IP_VS_DBG(7, "%s: ct=%p, deleted conntrack for tuple="
 				FMT_TUPLE "\n",
 				__func__, ct, ARG_TUPLE(&tuple));
-			if (ct->timeout.function)
-				ct->timeout.function(ct->timeout.data);
 		} else {
 			IP_VS_DBG(7, "%s: ct=%p, no conntrack timer for tuple="
 				FMT_TUPLE "\n",
-- 
2.1.4


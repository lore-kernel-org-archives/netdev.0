From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/17] netfilter: Deletion of unnecessary checks before two function calls
Date: Mon, 24 Nov 2014 14:27:53 +0100
Message-ID: <1416835674-11871-17-git-send-email-pablo@netfilter.org>
References: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>

The functions free_percpu() and module_put() test whether their argument
is NULL and then return immediately. Thus the test around the call is
not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
Acked-by: Julian Anastasov <ja@ssi.bg>
Acked-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipvs/ip_vs_ctl.c   |    3 +--
 net/netfilter/ipvs/ip_vs_pe.c    |    3 +--
 net/netfilter/ipvs/ip_vs_sched.c |    3 +--
 net/netfilter/ipvs/ip_vs_sync.c  |    3 +--
 net/netfilter/nf_tables_api.c    |    3 +--
 5 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index ac7ba68..b8295a4 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -465,8 +465,7 @@ __ip_vs_bind_svc(struct ip_vs_dest *dest, struct ip_vs_service *svc)
 
 static void ip_vs_service_free(struct ip_vs_service *svc)
 {
-	if (svc->stats.cpustats)
-		free_percpu(svc->stats.cpustats);
+	free_percpu(svc->stats.cpustats);
 	kfree(svc);
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_pe.c b/net/netfilter/ipvs/ip_vs_pe.c
index 1a82b29..0df17ca 100644
--- a/net/netfilter/ipvs/ip_vs_pe.c
+++ b/net/netfilter/ipvs/ip_vs_pe.c
@@ -37,8 +37,7 @@ struct ip_vs_pe *__ip_vs_pe_getbyname(const char *pe_name)
 			rcu_read_unlock();
 			return pe;
 		}
-		if (pe->module)
-			module_put(pe->module);
+		module_put(pe->module);
 	}
 	rcu_read_unlock();
 
diff --git a/net/netfilter/ipvs/ip_vs_sched.c b/net/netfilter/ipvs/ip_vs_sched.c
index 4dbcda6..199760c 100644
--- a/net/netfilter/ipvs/ip_vs_sched.c
+++ b/net/netfilter/ipvs/ip_vs_sched.c
@@ -104,8 +104,7 @@ static struct ip_vs_scheduler *ip_vs_sched_getbyname(const char *sched_name)
 			mutex_unlock(&ip_vs_sched_mutex);
 			return sched;
 		}
-		if (sched->module)
-			module_put(sched->module);
+		module_put(sched->module);
 	}
 
 	mutex_unlock(&ip_vs_sched_mutex);
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 7162c86..c47ffd7 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -820,8 +820,7 @@ ip_vs_conn_fill_param_sync(struct net *net, int af, union ip_vs_sync_conn *sc,
 
 		p->pe_data = kmemdup(pe_data, pe_data_len, GFP_ATOMIC);
 		if (!p->pe_data) {
-			if (p->pe->module)
-				module_put(p->pe->module);
+			module_put(p->pe->module);
 			return -ENOMEM;
 		}
 		p->pe_data_len = pe_data_len;
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 1ffb253..18a9dae 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3674,8 +3674,7 @@ static int nf_tables_abort(struct sk_buff *skb)
 			break;
 		case NFT_MSG_NEWCHAIN:
 			if (nft_trans_chain_update(trans)) {
-				if (nft_trans_chain_stats(trans))
-					free_percpu(nft_trans_chain_stats(trans));
+				free_percpu(nft_trans_chain_stats(trans));
 
 				nft_trans_destroy(trans);
 			} else {
-- 
1.7.10.4


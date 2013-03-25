From: pablo@netfilter.org
Subject: [PATCH 08/12] ipvs: fix some sparse warnings
Date: Mon, 25 Mar 2013 13:15:48 +0100
Message-ID: <1364213752-3934-9-git-send-email-pablo@netfilter.org>
References: <1364213752-3934-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46563 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757281Ab3CYMQU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 08:16:20 -0400
In-Reply-To: <1364213752-3934-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

Add missing __percpu annotations and make ip_vs_net_id static.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |    2 +-
 net/netfilter/ipvs/ip_vs_core.c |    8 +-------
 net/netfilter/ipvs/ip_vs_est.c  |    2 +-
 3 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 68c69d5..29bc055 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -459,7 +459,7 @@ struct ip_vs_estimator {
 struct ip_vs_stats {
 	struct ip_vs_stats_user	ustats;		/* statistics */
 	struct ip_vs_estimator	est;		/* estimator */
-	struct ip_vs_cpu_stats	*cpustats;	/* per cpu counters */
+	struct ip_vs_cpu_stats __percpu	*cpustats;	/* per cpu counters */
 	spinlock_t		lock;		/* spin lock */
 	struct ip_vs_stats_user	ustats0;	/* reset values */
 };
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 47edf5a..3e5e80b 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -69,10 +69,7 @@ EXPORT_SYMBOL(ip_vs_conn_put);
 EXPORT_SYMBOL(ip_vs_get_debug_level);
 #endif
 
-int ip_vs_net_id __read_mostly;
-#ifdef IP_VS_GENERIC_NETNS
-EXPORT_SYMBOL(ip_vs_net_id);
-#endif
+static int ip_vs_net_id __read_mostly;
 /* netns cnt used for uniqueness */
 static atomic_t ipvs_netns_cnt = ATOMIC_INIT(0);
 
@@ -1181,9 +1178,6 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 						iph.len)))) {
 #ifdef CONFIG_IP_VS_IPV6
 				if (af == AF_INET6) {
-					struct net *net =
-						dev_net(skb_dst(skb)->dev);
-
 					if (!skb->dev)
 						skb->dev = net->loopback_dev;
 					icmpv6_send(skb,
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 0fac601..6bee6d0 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -56,7 +56,7 @@
  * Make a summary from each cpu
  */
 static void ip_vs_read_cpu_stats(struct ip_vs_stats_user *sum,
-				 struct ip_vs_cpu_stats *stats)
+				 struct ip_vs_cpu_stats __percpu *stats)
 {
 	int i;
 
-- 
1.7.10.4

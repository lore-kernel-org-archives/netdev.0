From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net: use the new API kvfree()
Date: Mon,  2 Jun 2014 15:55:22 -0700
Message-ID: <1401749722-19210-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:37096 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036AbaFBWzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 18:55:46 -0400
Received: by mail-pb0-f48.google.com with SMTP id rr13so4674179pbb.35
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 15:55:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is available since v3.15-rc5.

Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: "David S. Miller" <davem@davemloft.net> 
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
 net/core/dev.c                    | 10 ++--------
 net/ipv4/tcp_metrics.c            |  5 +----
 net/netfilter/ipset/ip_set_core.c |  5 +----
 net/netfilter/nft_hash.c          |  5 +----
 net/netfilter/xt_recent.c         |  5 +----
 net/sched/sch_choke.c             |  7 +------
 net/sched/sch_fq.c                |  5 +----
 net/sched/sch_fq_codel.c          |  7 +------
 net/sched/sch_hhf.c               |  7 +------
 net/sched/sch_netem.c             |  7 +------
 net/sched/sch_sfq.c               |  7 +------
 11 files changed, 12 insertions(+), 58 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0355ca5..2b0c8b4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5918,10 +5918,7 @@ static void netdev_init_one_queue(struct net_device *dev,
 
 static void netif_free_tx_queues(struct net_device *dev)
 {
-	if (is_vmalloc_addr(dev->_tx))
-		vfree(dev->_tx);
-	else
-		kfree(dev->_tx);
+	kvfree(dev->_tx);
 }
 
 static int netif_alloc_netdev_queues(struct net_device *dev)
@@ -6395,10 +6392,7 @@ void netdev_freemem(struct net_device *dev)
 {
 	char *addr = (char *)dev - dev->padded;
 
-	if (is_vmalloc_addr(addr))
-		vfree(addr);
-	else
-		kfree(addr);
+	kvfree(addr);
 }
 
 /**
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index dcaf72f..4fe0418 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -1159,10 +1159,7 @@ static void __net_exit tcp_net_metrics_exit(struct net *net)
 			tm = next;
 		}
 	}
-	if (is_vmalloc_addr(net->ipv4.tcp_metrics_hash))
-		vfree(net->ipv4.tcp_metrics_hash);
-	else
-		kfree(net->ipv4.tcp_metrics_hash);
+	kvfree(net->ipv4.tcp_metrics_hash);
 }
 
 static __net_initdata struct pernet_operations tcp_net_metrics_ops = {
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 1172083..ec8114f 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -271,10 +271,7 @@ ip_set_free(void *members)
 {
 	pr_debug("%p: free with %s\n", members,
 		 is_vmalloc_addr(members) ? "vfree" : "kfree");
-	if (is_vmalloc_addr(members))
-		vfree(members);
-	else
-		kfree(members);
+	kvfree(members);
 }
 EXPORT_SYMBOL_GPL(ip_set_free);
 
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 1dfeb67..4080ed6 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -76,10 +76,7 @@ static bool nft_hash_lookup(const struct nft_set *set,
 
 static void nft_hash_tbl_free(const struct nft_hash_table *tbl)
 {
-	if (is_vmalloc_addr(tbl))
-		vfree(tbl);
-	else
-		kfree(tbl);
+	kvfree(tbl);
 }
 
 static unsigned int nft_hash_tbl_size(unsigned int nelem)
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 1e657cf..a9faae8 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -313,10 +313,7 @@ out:
 
 static void recent_table_free(void *addr)
 {
-	if (is_vmalloc_addr(addr))
-		vfree(addr);
-	else
-		kfree(addr);
+	kvfree(addr);
 }
 
 static int recent_mt_check(const struct xt_mtchk_param *par,
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 2aee028..ed30e43 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -391,12 +391,7 @@ static const struct nla_policy choke_policy[TCA_CHOKE_MAX + 1] = {
 
 static void choke_free(void *addr)
 {
-	if (addr) {
-		if (is_vmalloc_addr(addr))
-			vfree(addr);
-		else
-			kfree(addr);
-	}
+	kvfree(addr);
 }
 
 static int choke_change(struct Qdisc *sch, struct nlattr *opt)
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 23c682b..ba32c2b 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -591,10 +591,7 @@ static void *fq_alloc_node(size_t sz, int node)
 
 static void fq_free(void *addr)
 {
-	if (addr && is_vmalloc_addr(addr))
-		vfree(addr);
-	else
-		kfree(addr);
+	kvfree(addr);
 }
 
 static int fq_resize(struct Qdisc *sch, u32 log)
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 0bf432c..063b726 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -365,12 +365,7 @@ static void *fq_codel_zalloc(size_t sz)
 
 static void fq_codel_free(void *addr)
 {
-	if (addr) {
-		if (is_vmalloc_addr(addr))
-			vfree(addr);
-		else
-			kfree(addr);
-	}
+	kvfree(addr);
 }
 
 static void fq_codel_destroy(struct Qdisc *sch)
diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index 6aab861..d85b681 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -494,12 +494,7 @@ static void *hhf_zalloc(size_t sz)
 
 static void hhf_free(void *addr)
 {
-	if (addr) {
-		if (is_vmalloc_addr(addr))
-			vfree(addr);
-		else
-			kfree(addr);
-	}
+	kvfree(addr);
 }
 
 static void hhf_destroy(struct Qdisc *sch)
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index f1669a00..111d70f 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -648,12 +648,7 @@ static void netem_reset(struct Qdisc *sch)
 
 static void dist_free(struct disttable *d)
 {
-	if (d) {
-		if (is_vmalloc_addr(d))
-			vfree(d);
-		else
-			kfree(d);
-	}
+	kvfree(d);
 }
 
 /*
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 87317ff..1af2f73 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -716,12 +716,7 @@ static void *sfq_alloc(size_t sz)
 
 static void sfq_free(void *addr)
 {
-	if (addr) {
-		if (is_vmalloc_addr(addr))
-			vfree(addr);
-		else
-			kfree(addr);
-	}
+	kvfree(addr);
 }
 
 static void sfq_destroy(struct Qdisc *sch)

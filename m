From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 03/09]: sch_ingress: remove qdisc_priv() wrapper
Date: Sun, 20 Jan 2008 15:32:33 +0100 (MET)
Message-ID: <20080120143134.27801.64769.sendpatchset@localhost.localdomain>
References: <20080120143130.27801.94188.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	hadi@cyberus.ca
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59150 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753600AbYATOce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 09:32:34 -0500
In-Reply-To: <20080120143130.27801.94188.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit ec46354d4ba87fe98b8510f2d91fff4e106022ec
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jan 16 12:22:07 2008 +0100

    [NET_SCHED]: sch_ingress: remove qdisc_priv() wrapper
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index bdda28d..cb8ba8b 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -19,8 +19,6 @@
 #include <net/pkt_sched.h>
 
 
-#define PRIV(sch) qdisc_priv(sch)
-
 /* Thanks to Doron Oz for this hack */
 #ifndef CONFIG_NET_CLS_ACT
 #ifdef CONFIG_NETFILTER
@@ -74,7 +72,7 @@ static void ingress_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 
 static struct tcf_proto **ingress_find_tcf(struct Qdisc *sch, unsigned long cl)
 {
-	struct ingress_qdisc_data *p = PRIV(sch);
+	struct ingress_qdisc_data *p = qdisc_priv(sch);
 
 	return &p->filter_list;
 }
@@ -83,7 +81,7 @@ static struct tcf_proto **ingress_find_tcf(struct Qdisc *sch, unsigned long cl)
 
 static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
-	struct ingress_qdisc_data *p = PRIV(sch);
+	struct ingress_qdisc_data *p = qdisc_priv(sch);
 	struct tcf_result res;
 	int result;
 
@@ -180,7 +178,7 @@ static struct nf_hook_ops ing_ops[] __read_mostly = {
 
 static int ingress_init(struct Qdisc *sch, struct rtattr *opt)
 {
-	struct ingress_qdisc_data *p = PRIV(sch);
+	struct ingress_qdisc_data *p = qdisc_priv(sch);
 
 	/* Make sure either netfilter or preferably CLS_ACT is
 	 * compiled in */
@@ -217,7 +215,7 @@ static void ingress_reset(struct Qdisc *sch)
 
 static void ingress_destroy(struct Qdisc *sch)
 {
-	struct ingress_qdisc_data *p = PRIV(sch);
+	struct ingress_qdisc_data *p = qdisc_priv(sch);
 
 	tcf_destroy_chain(p->filter_list);
 }

From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 06/09]: sch_ingress: remove unnecessary ops
Date: Sun, 20 Jan 2008 15:32:37 +0100 (MET)
Message-ID: <20080120143139.27801.92450.sendpatchset@localhost.localdomain>
References: <20080120143130.27801.94188.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	hadi@cyberus.ca
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59168 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753685AbYATOcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 09:32:39 -0500
In-Reply-To: <20080120143130.27801.94188.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit c96158287d0c87fc3e4d005ce8bf2c778a5c2cb6
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jan 16 12:22:07 2008 +0100

    [NET_SCHED]: sch_ingress: remove unnecessary ops
    
    - ->reset is optional
    - sch_api provides identical defaults for ->dequeue/->requeue
    - ->drop can't happen since ingress never has a parent qdisc
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 1bbc648..c69e7bc 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -118,21 +118,6 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return result;
 }
 
-static struct sk_buff *ingress_dequeue(struct Qdisc *sch)
-{
-	return NULL;
-}
-
-static int ingress_requeue(struct sk_buff *skb, struct Qdisc *sch)
-{
-	return 0;
-}
-
-static unsigned int ingress_drop(struct Qdisc *sch)
-{
-	return 0;
-}
-
 #ifndef CONFIG_NET_CLS_ACT
 #ifdef CONFIG_NETFILTER
 static unsigned int ing_hook(unsigned int hook, struct sk_buff *skb,
@@ -202,11 +187,6 @@ static int ingress_init(struct Qdisc *sch, struct rtattr *opt)
 	return 0;
 }
 
-static void ingress_reset(struct Qdisc *sch)
-{
-	return;
-}
-
 /* ------------------------------------------------------------- */
 
 static void ingress_destroy(struct Qdisc *sch)
@@ -248,11 +228,7 @@ static struct Qdisc_ops ingress_qdisc_ops __read_mostly = {
 	.id		=	"ingress",
 	.priv_size	=	sizeof(struct ingress_qdisc_data),
 	.enqueue	=	ingress_enqueue,
-	.dequeue	=	ingress_dequeue,
-	.requeue	=	ingress_requeue,
-	.drop		=	ingress_drop,
 	.init		=	ingress_init,
-	.reset		=	ingress_reset,
 	.destroy	=	ingress_destroy,
 	.dump		=	ingress_dump,
 	.owner		=	THIS_MODULE,

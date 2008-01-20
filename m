From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 02/09]: sch_ingress: remove excessive debugging
Date: Sun, 20 Jan 2008 15:32:32 +0100 (MET)
Message-ID: <20080120143133.27801.54028.sendpatchset@localhost.localdomain>
References: <20080120143130.27801.94188.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	hadi@cyberus.ca
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59145 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753467AbYATOcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 09:32:33 -0500
In-Reply-To: <20080120143130.27801.94188.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit fdb1b974189eeab782ba3595d1ca550a1a5ee79e
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jan 16 12:22:06 2008 +0100

    [NET_SCHED]: sch_ingress: remove excessive debugging
    
    Remove excessive debugging statements and some "future use" stuff.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 4880d44..bdda28d 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -19,20 +19,6 @@
 #include <net/pkt_sched.h>
 
 
-#undef DEBUG_INGRESS
-
-#ifdef DEBUG_INGRESS  /* control */
-#define DPRINTK(format, args...) printk(KERN_DEBUG format,##args)
-#else
-#define DPRINTK(format, args...)
-#endif
-
-#if 0  /* data */
-#define D2PRINTK(format, args...) printk(KERN_DEBUG format,##args)
-#else
-#define D2PRINTK(format, args...)
-#endif
-
 #define PRIV(sch) qdisc_priv(sch)
 
 /* Thanks to Doron Oz for this hack */
@@ -52,13 +38,6 @@ struct ingress_qdisc_data {
 static int ingress_graft(struct Qdisc *sch, unsigned long arg,
 			 struct Qdisc *new, struct Qdisc **old)
 {
-#ifdef DEBUG_INGRESS
-	struct ingress_qdisc_data *p = PRIV(sch);
-#endif
-
-	DPRINTK("ingress_graft(sch %p,[qdisc %p],new %p,old %p)\n",
-		sch, p, new, old);
-	DPRINTK("\n ingress_graft: You cannot add qdiscs to classes");
 	return 1;
 }
 
@@ -69,11 +48,6 @@ static struct Qdisc *ingress_leaf(struct Qdisc *sch, unsigned long arg)
 
 static unsigned long ingress_get(struct Qdisc *sch, u32 classid)
 {
-#ifdef DEBUG_INGRESS
-	struct ingress_qdisc_data *p = PRIV(sch);
-#endif
-	DPRINTK("ingress_get(sch %p,[qdisc %p],classid %x)\n",
-		sch, p, classid);
 	return TC_H_MIN(classid) + 1;
 }
 
@@ -90,22 +64,12 @@ static void ingress_put(struct Qdisc *sch, unsigned long cl)
 static int ingress_change(struct Qdisc *sch, u32 classid, u32 parent,
 			  struct rtattr **tca, unsigned long *arg)
 {
-#ifdef DEBUG_INGRESS
-	struct ingress_qdisc_data *p = PRIV(sch);
-#endif
-	DPRINTK("ingress_change(sch %p,[qdisc %p],classid %x,parent %x),"
-		"arg 0x%lx\n", sch, p, classid, parent, *arg);
-	DPRINTK("No effect. sch_ingress doesn't maintain classes at the moment");
 	return 0;
 }
 
 static void ingress_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 {
-#ifdef DEBUG_INGRESS
-	struct ingress_qdisc_data *p = PRIV(sch);
-#endif
-	DPRINTK("ingress_walk(sch %p,[qdisc %p],walker %p)\n", sch, p, walker);
-	DPRINTK("No effect. sch_ingress doesn't maintain classes at the moment");
+	return;
 }
 
 static struct tcf_proto **ingress_find_tcf(struct Qdisc *sch, unsigned long cl)
@@ -123,9 +87,8 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	struct tcf_result res;
 	int result;
 
-	D2PRINTK("ingress_enqueue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
 	result = tc_classify(skb, p->filter_list, &res);
-	D2PRINTK("result %d class 0x%04x\n", result, res.classid);
+
 	/*
 	 * Unlike normal "enqueue" functions, ingress_enqueue returns a
 	 * firewall FW_* code.
@@ -150,7 +113,6 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		break;
 	}
 #else
-	D2PRINTK("Overriding result to ACCEPT\n");
 	result = NF_ACCEPT;
 	sch->bstats.packets++;
 	sch->bstats.bytes += skb->len;
@@ -161,28 +123,16 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 static struct sk_buff *ingress_dequeue(struct Qdisc *sch)
 {
-/*
-	struct ingress_qdisc_data *p = PRIV(sch);
-	D2PRINTK("ingress_dequeue(sch %p,[qdisc %p])\n",sch,PRIV(p));
-*/
 	return NULL;
 }
 
 static int ingress_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
-/*
-	struct ingress_qdisc_data *p = PRIV(sch);
-	D2PRINTK("ingress_requeue(skb %p,sch %p,[qdisc %p])\n",skb,sch,PRIV(p));
-*/
 	return 0;
 }
 
 static unsigned int ingress_drop(struct Qdisc *sch)
 {
-#ifdef DEBUG_INGRESS
-	struct ingress_qdisc_data *p = PRIV(sch);
-#endif
-	DPRINTK("ingress_drop(sch %p,[qdisc %p])\n", sch, p);
 	return 0;
 }
 
@@ -198,11 +148,6 @@ static unsigned int ing_hook(unsigned int hook, struct sk_buff *skb,
 	struct net_device *dev = skb->dev;
 	int fwres = NF_ACCEPT;
 
-	DPRINTK("ing_hook: skb %s dev=%s len=%u\n",
-		skb->sk ? "(owned)" : "(unowned)",
-		skb->dev ? skb->dev->name : "(no dev)",
-		skb->len);
-
 	if (dev->qdisc_ingress) {
 		spin_lock(&dev->ingress_lock);
 		if ((q = dev->qdisc_ingress) != NULL)
@@ -259,26 +204,13 @@ static int ingress_init(struct Qdisc *sch, struct rtattr *opt)
 	}
 #endif
 #endif
-
-	DPRINTK("ingress_init(sch %p,[qdisc %p],opt %p)\n", sch, p, opt);
 	p->q = &noop_qdisc;
 	return 0;
 }
 
 static void ingress_reset(struct Qdisc *sch)
 {
-	struct ingress_qdisc_data *p = PRIV(sch);
-
-	DPRINTK("ingress_reset(sch %p,[qdisc %p])\n", sch, p);
-
-/*
-#if 0
-*/
-/* for future use */
-	qdisc_reset(p->q);
-/*
-#endif
-*/
+	return;
 }
 
 /* ------------------------------------------------------------- */
@@ -287,12 +219,7 @@ static void ingress_destroy(struct Qdisc *sch)
 {
 	struct ingress_qdisc_data *p = PRIV(sch);
 
-	DPRINTK("ingress_destroy(sch %p,[qdisc %p])\n", sch, p);
 	tcf_destroy_chain(p->filter_list);
-#if 0
-/* for future use */
-	qdisc_destroy(p->q);
-#endif
 }
 
 static int ingress_dump(struct Qdisc *sch, struct sk_buff *skb)

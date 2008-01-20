From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 01/09]: sch_ingress: formatting fixes
Date: Sun, 20 Jan 2008 15:32:30 +0100 (MET)
Message-ID: <20080120143131.27801.69499.sendpatchset@localhost.localdomain>
References: <20080120143130.27801.94188.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	hadi@cyberus.ca
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59138 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753063AbYATOcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 09:32:32 -0500
In-Reply-To: <20080120143130.27801.94188.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit e237be7bc5b3009d1021e0764d1745e9a4c3cefb
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jan 16 12:22:06 2008 +0100

    [NET_SCHED]: sch_ingress: formatting fixes
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 89c32a9..4880d44 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -22,23 +22,20 @@
 #undef DEBUG_INGRESS
 
 #ifdef DEBUG_INGRESS  /* control */
-#define DPRINTK(format,args...) printk(KERN_DEBUG format,##args)
+#define DPRINTK(format, args...) printk(KERN_DEBUG format,##args)
 #else
-#define DPRINTK(format,args...)
+#define DPRINTK(format, args...)
 #endif
 
 #if 0  /* data */
-#define D2PRINTK(format,args...) printk(KERN_DEBUG format,##args)
+#define D2PRINTK(format, args...) printk(KERN_DEBUG format,##args)
 #else
-#define D2PRINTK(format,args...)
+#define D2PRINTK(format, args...)
 #endif
 
-
 #define PRIV(sch) qdisc_priv(sch)
 
-
-/* Thanks to Doron Oz for this hack
-*/
+/* Thanks to Doron Oz for this hack */
 #ifndef CONFIG_NET_CLS_ACT
 #ifdef CONFIG_NETFILTER
 static int nf_registered;
@@ -50,12 +47,10 @@ struct ingress_qdisc_data {
 	struct tcf_proto	*filter_list;
 };
 
-
 /* ------------------------- Class/flow operations ------------------------- */
 
-
-static int ingress_graft(struct Qdisc *sch,unsigned long arg,
-    struct Qdisc *new,struct Qdisc **old)
+static int ingress_graft(struct Qdisc *sch, unsigned long arg,
+			 struct Qdisc *new, struct Qdisc **old)
 {
 #ifdef DEBUG_INGRESS
 	struct ingress_qdisc_data *p = PRIV(sch);
@@ -67,37 +62,33 @@ static int ingress_graft(struct Qdisc *sch,unsigned long arg,
 	return 1;
 }
 
-
 static struct Qdisc *ingress_leaf(struct Qdisc *sch, unsigned long arg)
 {
 	return NULL;
 }
 
-
-static unsigned long ingress_get(struct Qdisc *sch,u32 classid)
+static unsigned long ingress_get(struct Qdisc *sch, u32 classid)
 {
 #ifdef DEBUG_INGRESS
 	struct ingress_qdisc_data *p = PRIV(sch);
 #endif
-	DPRINTK("ingress_get(sch %p,[qdisc %p],classid %x)\n", sch, p, classid);
+	DPRINTK("ingress_get(sch %p,[qdisc %p],classid %x)\n",
+		sch, p, classid);
 	return TC_H_MIN(classid) + 1;
 }
 
-
 static unsigned long ingress_bind_filter(struct Qdisc *sch,
-    unsigned long parent, u32 classid)
+					 unsigned long parent, u32 classid)
 {
 	return ingress_get(sch, classid);
 }
 
-
 static void ingress_put(struct Qdisc *sch, unsigned long cl)
 {
 }
 
-
 static int ingress_change(struct Qdisc *sch, u32 classid, u32 parent,
-    struct rtattr **tca, unsigned long *arg)
+			  struct rtattr **tca, unsigned long *arg)
 {
 #ifdef DEBUG_INGRESS
 	struct ingress_qdisc_data *p = PRIV(sch);
@@ -108,9 +99,7 @@ static int ingress_change(struct Qdisc *sch, u32 classid, u32 parent,
 	return 0;
 }
 
-
-
-static void ingress_walk(struct Qdisc *sch,struct qdisc_walker *walker)
+static void ingress_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 {
 #ifdef DEBUG_INGRESS
 	struct ingress_qdisc_data *p = PRIV(sch);
@@ -119,19 +108,16 @@ static void ingress_walk(struct Qdisc *sch,struct qdisc_walker *walker)
 	DPRINTK("No effect. sch_ingress doesn't maintain classes at the moment");
 }
 
-
-static struct tcf_proto **ingress_find_tcf(struct Qdisc *sch,unsigned long cl)
+static struct tcf_proto **ingress_find_tcf(struct Qdisc *sch, unsigned long cl)
 {
 	struct ingress_qdisc_data *p = PRIV(sch);
 
 	return &p->filter_list;
 }
 
-
 /* --------------------------- Qdisc operations ---------------------------- */
 
-
-static int ingress_enqueue(struct sk_buff *skb,struct Qdisc *sch)
+static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct ingress_qdisc_data *p = PRIV(sch);
 	struct tcf_result res;
@@ -148,20 +134,20 @@ static int ingress_enqueue(struct sk_buff *skb,struct Qdisc *sch)
 	sch->bstats.packets++;
 	sch->bstats.bytes += skb->len;
 	switch (result) {
-		case TC_ACT_SHOT:
-			result = TC_ACT_SHOT;
-			sch->qstats.drops++;
-			break;
-		case TC_ACT_STOLEN:
-		case TC_ACT_QUEUED:
-			result = TC_ACT_STOLEN;
-			break;
-		case TC_ACT_RECLASSIFY:
-		case TC_ACT_OK:
-			skb->tc_index = TC_H_MIN(res.classid);
-		default:
-			result = TC_ACT_OK;
-			break;
+	case TC_ACT_SHOT:
+		result = TC_ACT_SHOT;
+		sch->qstats.drops++;
+		break;
+	case TC_ACT_STOLEN:
+	case TC_ACT_QUEUED:
+		result = TC_ACT_STOLEN;
+		break;
+	case TC_ACT_RECLASSIFY:
+	case TC_ACT_OK:
+		skb->tc_index = TC_H_MIN(res.classid);
+	default:
+		result = TC_ACT_OK;
+		break;
 	}
 #else
 	D2PRINTK("Overriding result to ACCEPT\n");
@@ -173,7 +159,6 @@ static int ingress_enqueue(struct sk_buff *skb,struct Qdisc *sch)
 	return result;
 }
 
-
 static struct sk_buff *ingress_dequeue(struct Qdisc *sch)
 {
 /*
@@ -183,8 +168,7 @@ static struct sk_buff *ingress_dequeue(struct Qdisc *sch)
 	return NULL;
 }
 
-
-static int ingress_requeue(struct sk_buff *skb,struct Qdisc *sch)
+static int ingress_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
 /*
 	struct ingress_qdisc_data *p = PRIV(sch);
@@ -204,8 +188,7 @@ static unsigned int ingress_drop(struct Qdisc *sch)
 
 #ifndef CONFIG_NET_CLS_ACT
 #ifdef CONFIG_NETFILTER
-static unsigned int
-ing_hook(unsigned int hook, struct sk_buff *skb,
+static unsigned int ing_hook(unsigned int hook, struct sk_buff *skb,
 			     const struct net_device *indev,
 			     const struct net_device *outdev,
 			     int (*okfn)(struct sk_buff *))
@@ -213,7 +196,7 @@ ing_hook(unsigned int hook, struct sk_buff *skb,
 
 	struct Qdisc *q;
 	struct net_device *dev = skb->dev;
-	int fwres=NF_ACCEPT;
+	int fwres = NF_ACCEPT;
 
 	DPRINTK("ing_hook: skb %s dev=%s len=%u\n",
 		skb->sk ? "(owned)" : "(unowned)",
@@ -247,16 +230,15 @@ static struct nf_hook_ops ing_ops[] __read_mostly = {
 		.priority       = NF_IP6_PRI_FILTER + 1,
 	},
 };
-
 #endif
 #endif
 
-static int ingress_init(struct Qdisc *sch,struct rtattr *opt)
+static int ingress_init(struct Qdisc *sch, struct rtattr *opt)
 {
 	struct ingress_qdisc_data *p = PRIV(sch);
 
-/* Make sure either netfilter or preferably CLS_ACT is
-* compiled in */
+	/* Make sure either netfilter or preferably CLS_ACT is
+	 * compiled in */
 #ifndef CONFIG_NET_CLS_ACT
 #ifndef CONFIG_NETFILTER
 	printk("You MUST compile classifier actions into the kernel\n");
@@ -278,12 +260,11 @@ static int ingress_init(struct Qdisc *sch,struct rtattr *opt)
 #endif
 #endif
 
-	DPRINTK("ingress_init(sch %p,[qdisc %p],opt %p)\n",sch,p,opt);
+	DPRINTK("ingress_init(sch %p,[qdisc %p],opt %p)\n", sch, p, opt);
 	p->q = &noop_qdisc;
 	return 0;
 }
 
-
 static void ingress_reset(struct Qdisc *sch)
 {
 	struct ingress_qdisc_data *p = PRIV(sch);
@@ -302,9 +283,6 @@ static void ingress_reset(struct Qdisc *sch)
 
 /* ------------------------------------------------------------- */
 
-
-/* ------------------------------------------------------------- */
-
 static void ingress_destroy(struct Qdisc *sch)
 {
 	struct ingress_qdisc_data *p = PRIV(sch);
@@ -317,13 +295,12 @@ static void ingress_destroy(struct Qdisc *sch)
 #endif
 }
 
-
 static int ingress_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct rtattr *rta;
 
-	rta = (struct rtattr *) b;
+	rta = (struct rtattr *)b;
 	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
 	rta->rta_len = skb_tail_pointer(skb) - b;
 	return skb->len;
@@ -339,16 +316,13 @@ static const struct Qdisc_class_ops ingress_class_ops = {
 	.get		=	ingress_get,
 	.put		=	ingress_put,
 	.change		=	ingress_change,
-	.delete		=	NULL,
 	.walk		=	ingress_walk,
 	.tcf_chain	=	ingress_find_tcf,
 	.bind_tcf	=	ingress_bind_filter,
 	.unbind_tcf	=	ingress_put,
-	.dump		=	NULL,
 };
 
 static struct Qdisc_ops ingress_qdisc_ops __read_mostly = {
-	.next		=	NULL,
 	.cl_ops		=	&ingress_class_ops,
 	.id		=	"ingress",
 	.priv_size	=	sizeof(struct ingress_qdisc_data),
@@ -359,7 +333,6 @@ static struct Qdisc_ops ingress_qdisc_ops __read_mostly = {
 	.init		=	ingress_init,
 	.reset		=	ingress_reset,
 	.destroy	=	ingress_destroy,
-	.change		=	NULL,
 	.dump		=	ingress_dump,
 	.owner		=	THIS_MODULE,
 };
@@ -375,6 +348,7 @@ static int __init ingress_module_init(void)
 
 	return ret;
 }
+
 static void __exit ingress_module_exit(void)
 {
 	unregister_qdisc(&ingress_qdisc_ops);
@@ -385,6 +359,7 @@ static void __exit ingress_module_exit(void)
 #endif
 #endif
 }
+
 module_init(ingress_module_init)
 module_exit(ingress_module_exit)
 MODULE_LICENSE("GPL");

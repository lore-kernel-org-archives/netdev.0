From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 08/09]: sch_ingress: avoid a few
Date: Sun, 20 Jan 2008 15:32:40 +0100 (MET)
Message-ID: <20080120143141.27801.77683.sendpatchset@localhost.localdomain>
References: <20080120143130.27801.94188.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	hadi@cyberus.ca
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59178 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753626AbYATOcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 09:32:41 -0500
In-Reply-To: <20080120143130.27801.94188.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 3320bc3c5d9a6c1dd96d515b7b6a4dee9cd31fd7
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Jan 17 09:17:58 2008 +0100

    [NET_SCHED]: sch_ingress: avoid a few #ifdefs
    
    Move the repeating "ifndef CONFIG_NET_CLS_ACT/ifdef CONFIG_NETFILTER" ifdefs
    into a single condition.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index b30ca01..4c7f7e7 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -20,11 +20,9 @@
 
 
 /* Thanks to Doron Oz for this hack */
-#ifndef CONFIG_NET_CLS_ACT
-#ifdef CONFIG_NETFILTER
+#if !defined(CONFIG_NET_CLS_ACT) && defined(CONFIG_NETFILTER)
 static int nf_registered;
 #endif
-#endif
 
 struct ingress_qdisc_data {
 	struct tcf_proto	*filter_list;
@@ -118,8 +116,7 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return result;
 }
 
-#ifndef CONFIG_NET_CLS_ACT
-#ifdef CONFIG_NETFILTER
+#if !defined(CONFIG_NET_CLS_ACT) && defined(CONFIG_NETFILTER)
 static unsigned int ing_hook(unsigned int hook, struct sk_buff *skb,
 			     const struct net_device *indev,
 			     const struct net_device *outdev,
@@ -158,12 +155,10 @@ static struct nf_hook_ops ing_ops[] __read_mostly = {
 	},
 };
 #endif
-#endif
 
 static int ingress_init(struct Qdisc *sch, struct rtattr *opt)
 {
-#ifndef CONFIG_NET_CLS_ACT
-#ifdef CONFIG_NETFILTER
+#if !defined(CONFIG_NET_CLS_ACT) && defined(CONFIG_NETFILTER)
 	printk("Ingress scheduler: Classifier actions prefered over netfilter\n");
 
 	if (!nf_registered) {
@@ -174,7 +169,6 @@ static int ingress_init(struct Qdisc *sch, struct rtattr *opt)
 		nf_registered++;
 	}
 #endif
-#endif
 	return 0;
 }
 
@@ -240,12 +234,10 @@ static int __init ingress_module_init(void)
 static void __exit ingress_module_exit(void)
 {
 	unregister_qdisc(&ingress_qdisc_ops);
-#ifndef CONFIG_NET_CLS_ACT
-#ifdef CONFIG_NETFILTER
+#if !defined(CONFIG_NET_CLS_ACT) && defined(CONFIG_NETFILTER)
 	if (nf_registered)
 		nf_unregister_hooks(ing_ops, ARRAY_SIZE(ing_ops));
 #endif
-#endif
 }
 
 module_init(ingress_module_init)

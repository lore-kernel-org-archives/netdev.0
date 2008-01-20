From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 07/09]: sch_ingress: move dependencies to Kconfig
Date: Sun, 20 Jan 2008 15:32:39 +0100 (MET)
Message-ID: <20080120143140.27801.30437.sendpatchset@localhost.localdomain>
References: <20080120143130.27801.94188.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	hadi@cyberus.ca
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59172 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753720AbYATOck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 09:32:40 -0500
In-Reply-To: <20080120143130.27801.94188.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 4c939213974319d9457dbbf038d38ef1fcf57ef9
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jan 16 12:22:08 2008 +0100

    [NET_SCHED]: sch_ingress: move dependencies to Kconfig
    
    Instead of complaining at scheduler initialization time, check the dependencies
    in Kconfig.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 4eb73ec..a047cd5 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -204,6 +204,7 @@ config NET_SCH_NETEM
 
 config NET_SCH_INGRESS
 	tristate "Ingress Qdisc"
+	depends on NET_CLS_ACT || NETFILTER
 	---help---
 	  Say Y here if you want to use classifiers for incoming packets.
 	  If unsure, say Y.
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index c69e7bc..b30ca01 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -162,19 +162,10 @@ static struct nf_hook_ops ing_ops[] __read_mostly = {
 
 static int ingress_init(struct Qdisc *sch, struct rtattr *opt)
 {
-	/* Make sure either netfilter or preferably CLS_ACT is
-	 * compiled in */
 #ifndef CONFIG_NET_CLS_ACT
-#ifndef CONFIG_NETFILTER
-	printk("You MUST compile classifier actions into the kernel\n");
-	return -EINVAL;
-#else
+#ifdef CONFIG_NETFILTER
 	printk("Ingress scheduler: Classifier actions prefered over netfilter\n");
-#endif
-#endif
 
-#ifndef CONFIG_NET_CLS_ACT
-#ifdef CONFIG_NETFILTER
 	if (!nf_registered) {
 		if (nf_register_hooks(ing_ops, ARRAY_SIZE(ing_ops)) < 0) {
 			printk("ingress qdisc registration error \n");

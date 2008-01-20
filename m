From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 09/09]: sch_ingress: remove useless printk
Date: Sun, 20 Jan 2008 15:32:42 +0100 (MET)
Message-ID: <20080120143143.27801.70711.sendpatchset@localhost.localdomain>
References: <20080120143130.27801.94188.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	hadi@cyberus.ca
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59182 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753748AbYATOcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 09:32:43 -0500
In-Reply-To: <20080120143130.27801.94188.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit f8d51e131177c26c1033dfc804f11d9cac7637f4
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Jan 17 09:17:59 2008 +0100

    [NET_SCHED]: sch_ingress: remove useless printk
    
    The printk about ingress qdisc registration error can't be triggered under
    normal circumstances. Since register_qdisc only fails for two identical
    registrations, the only way to trigger it is by loading the sch_ingress
    modules multiple times under different names, in which case we already
    return -EEXIST to userspace.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 4c7f7e7..7252571 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -221,14 +221,7 @@ static struct Qdisc_ops ingress_qdisc_ops __read_mostly = {
 
 static int __init ingress_module_init(void)
 {
-	int ret = 0;
-
-	if ((ret = register_qdisc(&ingress_qdisc_ops)) < 0) {
-		printk("Unable to register Ingress qdisc\n");
-		return ret;
-	}
-
-	return ret;
+	return register_qdisc(&ingress_qdisc_ops);
 }
 
 static void __exit ingress_module_exit(void)

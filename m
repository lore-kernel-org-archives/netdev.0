From: frank.blaschka@de.ibm.com
Subject: [patch 7/9] [PATCH] iucv: get rid of compile warning
Date: Thu, 12 May 2011 07:43:25 +0200
Message-ID: <20110512054416.080758394@de.ibm.com>
References: <20110512054318.241733700@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([194.196.100.166]:44912 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753962Ab1ELFoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 01:44:18 -0400
Content-Disposition: inline; filename=606-iucv-compile-warning.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

-Wunused-but-set-variable generates a compile warning. The affected
variable is removed.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---


 net/iucv/iucv.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
diff -urpN linux-2.6/net/iucv/iucv.c linux-2.6-patched/net/iucv/iucv.c
--- linux-2.6/net/iucv/iucv.c	2011-05-10 09:14:08.000000000 +0200
+++ linux-2.6-patched/net/iucv/iucv.c	2011-05-10 09:14:26.000000000 +0200
@@ -828,14 +828,14 @@ EXPORT_SYMBOL(iucv_unregister);
 static int iucv_reboot_event(struct notifier_block *this,
 			     unsigned long event, void *ptr)
 {
-	int i, rc;
+	int i;
 
 	get_online_cpus();
 	on_each_cpu(iucv_block_cpu, NULL, 1);
 	preempt_disable();
 	for (i = 0; i < iucv_max_pathid; i++) {
 		if (iucv_path_table[i])
-			rc = iucv_sever_pathid(i, NULL);
+			iucv_sever_pathid(i, NULL);
 	}
 	preempt_enable();
 	put_online_cpus();


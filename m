From: Thomas Gleixner <tglx@linutronix.de>
Subject: netfilter: Use proper rwlock init function
Date: Wed, 5 Oct 2011 15:24:43 +0200 (CEST)
Message-ID: <alpine.LFD.2.02.1110051522410.18778@ionos>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:32912 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934700Ab1JENYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 09:24:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the open coded initialization with the init function.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/net/netfilter/ipvs/ip_vs_ctl.c
===================================================================
--- linux-2.6.orig/net/netfilter/ipvs/ip_vs_ctl.c
+++ linux-2.6/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3679,7 +3679,7 @@ int __net_init __ip_vs_control_init(stru
 	int idx;
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	ipvs->rs_lock = __RW_LOCK_UNLOCKED(ipvs->rs_lock);
+	rwlock_init(&ipvs->rs_lock);
 
 	/* Initialize rs_table */
 	for (idx = 0; idx < IP_VS_RTAB_SIZE; idx++)

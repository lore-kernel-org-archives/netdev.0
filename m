From: Horms <horms@verge.net.au>
Subject: [PATCH] [IPVS] replace if .. goto with while
Date: Mon, 18 Dec 2006 12:11:11 +0900
Message-ID: <20061218031110.GA32036@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Wensong Zhan <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>,
	Roberto Nibali <ratz@drugphish.ch>,
	Joseph Mack NA3T <jmack@wm7d.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:46514 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752663AbWLRDgB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Dec 2006 22:36:01 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I guess that this code used to be more complex, but replacing
the goto with a while seems to make things a bit more readable.
Or in other words, two fairly gratuitous goto are removed.

On a related note, I wonder if there should be a limit to how
many times it tries.

Signed-Off-By: Simon Horman <horms@verge.net.au>

Index: linux-2.6/net/ipv4/ipvs/ip_vs_sync.c
===================================================================
--- linux-2.6.orig/net/ipv4/ipvs/ip_vs_sync.c	2006-11-29 09:50:37.000000000 +0900
+++ linux-2.6/net/ipv4/ipvs/ip_vs_sync.c	2006-11-29 10:03:11.000000000 +0900
@@ -822,12 +822,10 @@
 
 	/* fork the sync thread here, then the parent process of the
 	   sync thread is the init process after this thread exits. */
-  repeat:
-	if ((pid = kernel_thread(sync_thread, startup, 0)) < 0) {
+	while ((pid = kernel_thread(sync_thread, startup, 0)) < 0) {
 		IP_VS_ERR("could not create sync_thread due to %d... "
 			  "retrying.\n", pid);
 		msleep_interruptible(1000);
-		goto repeat;
 	}
 
 	return 0;
@@ -856,12 +854,10 @@
 		ip_vs_backup_syncid = syncid;
 	}
 
-  repeat:
-	if ((pid = kernel_thread(fork_sync_thread, &startup, 0)) < 0) {
+	while ((pid = kernel_thread(fork_sync_thread, &startup, 0)) < 0) {
 		IP_VS_ERR("could not create fork_sync_thread due to %d... "
 			  "retrying.\n", pid);
 		msleep_interruptible(1000);
-		goto repeat;
 	}
 
 	wait_for_completion(&startup);

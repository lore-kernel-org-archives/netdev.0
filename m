From: akpm@osdl.org
Subject: [patch 03/17] eliminate unused /proc/sys/net/ethernet
Date: Thu, 01 Jun 2006 20:32:23 -0700
Message-ID: <200606020328.k523S4oY028811@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, jes@sgi.com, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:61876 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751197AbWFBD2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 23:28:14 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Jes Sorensen <jes@sgi.com>

The /proc/sys/net/ethernet directory has been sitting empty for more than
10 years!  Time to eliminate it!

Signed-off-by: Jes Sorensen <jes@sgi.com>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 net/ethernet/Makefile           |    1 -
 net/ethernet/sysctl_net_ether.c |   14 --------------
 net/sysctl_net.c                |    8 --------
 3 files changed, 23 deletions(-)

diff -puN net/ethernet/Makefile~eliminate-unused-proc-sys-net-ethernet net/ethernet/Makefile
--- devel/net/ethernet/Makefile~eliminate-unused-proc-sys-net-ethernet	2006-06-01 20:31:49.000000000 -0700
+++ devel-akpm/net/ethernet/Makefile	2006-06-01 20:31:49.000000000 -0700
@@ -3,6 +3,5 @@
 #
 
 obj-y					+= eth.o
-obj-$(CONFIG_SYSCTL)			+= sysctl_net_ether.o
 obj-$(subst m,y,$(CONFIG_IPX))		+= pe2.o
 obj-$(subst m,y,$(CONFIG_ATALK))	+= pe2.o
diff -L net/ethernet/sysctl_net_ether.c -puN net/ethernet/sysctl_net_ether.c~eliminate-unused-proc-sys-net-ethernet /dev/null
--- devel/net/ethernet/sysctl_net_ether.c
+++ /dev/null	2006-06-01 17:04:03.273681250 -0700
@@ -1,14 +0,0 @@
-/* -*- linux-c -*-
- * sysctl_net_ether.c: sysctl interface to net Ethernet subsystem.
- *
- * Begun April 1, 1996, Mike Shaver.
- * Added /proc/sys/net/ether directory entry (empty =) ). [MS]
- */
-
-#include <linux/mm.h>
-#include <linux/sysctl.h>
-#include <linux/if_ether.h>
-
-ctl_table ether_table[] = {
-	{0}
-};
diff -puN net/sysctl_net.c~eliminate-unused-proc-sys-net-ethernet net/sysctl_net.c
--- devel/net/sysctl_net.c~eliminate-unused-proc-sys-net-ethernet	2006-06-01 20:31:49.000000000 -0700
+++ devel-akpm/net/sysctl_net.c	2006-06-01 20:31:49.000000000 -0700
@@ -37,14 +37,6 @@ struct ctl_table net_table[] = {
 		.mode		= 0555,
 		.child		= core_table,
 	},
-#ifdef CONFIG_NET
-	{
-		.ctl_name	= NET_ETHER,
-		.procname	= "ethernet",
-		.mode		= 0555,
-		.child		= ether_table,
-	},
-#endif
 #ifdef CONFIG_INET
 	{
 		.ctl_name	= NET_IPV4,
_

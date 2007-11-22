From: Andi Kleen <ak@suse.de>
Subject: [PATCH RFC] [8/9] Put UDP exports into a namespace
Date: Thu, 22 Nov 2007 03:43:13 +0100 (CET)
Message-ID: <20071122024313.EE23514D68@wotan.suse.de>
References: <20071122343.446909000@suse.de>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:37773 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751919AbXKVCnP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 21:43:15 -0500
In-Reply-To: <20071122343.446909000@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The UDP exports are only used by UDPv6 and UDP lite. They are internal functions
not supposed to be used by anybody else. So turn them into a name space that 
only allows those.

---
 net/ipv4/udp.c     |   27 +++++++++++++++------------
 net/ipv4/udplite.c |    6 +++---
 2 files changed, 18 insertions(+), 15 deletions(-)

Index: linux/net/ipv4/udp.c
===================================================================
--- linux.orig/net/ipv4/udp.c
+++ linux/net/ipv4/udp.c
@@ -105,6 +105,9 @@
 #include <net/xfrm.h>
 #include "udp_impl.h"
 
+MODULE_NAMESPACE_ALLOW(udp, udplite);
+MODULE_NAMESPACE_ALLOW(udp, ipv6);
+
 /*
  *	Snmp MIB for the UDP layer
  */
@@ -1641,18 +1644,18 @@ void udp4_proc_exit(void)
 }
 #endif /* CONFIG_PROC_FS */
 
-EXPORT_SYMBOL(udp_disconnect);
-EXPORT_SYMBOL(udp_hash);
-EXPORT_SYMBOL(udp_hash_lock);
-EXPORT_SYMBOL(udp_ioctl);
-EXPORT_SYMBOL(udp_get_port);
-EXPORT_SYMBOL(udp_prot);
-EXPORT_SYMBOL(udp_sendmsg);
-EXPORT_SYMBOL(udp_lib_getsockopt);
-EXPORT_SYMBOL(udp_lib_setsockopt);
-EXPORT_SYMBOL(udp_poll);
+EXPORT_SYMBOL_NS(udp, udp_disconnect);
+EXPORT_SYMBOL_NS(udp, udp_hash);
+EXPORT_SYMBOL_NS(udp, udp_hash_lock);
+EXPORT_SYMBOL_NS(udp, udp_ioctl);
+EXPORT_SYMBOL_NS(udp, udp_get_port);
+EXPORT_SYMBOL_NS(udp, udp_prot);
+EXPORT_SYMBOL_NS(udp, udp_sendmsg);
+EXPORT_SYMBOL_NS(udp, udp_lib_getsockopt);
+EXPORT_SYMBOL_NS(udp, udp_lib_setsockopt);
+EXPORT_SYMBOL_NS(udp, udp_poll);
 
 #ifdef CONFIG_PROC_FS
-EXPORT_SYMBOL(udp_proc_register);
-EXPORT_SYMBOL(udp_proc_unregister);
+EXPORT_SYMBOL_NS(udp, udp_proc_register);
+EXPORT_SYMBOL_NS(udp, udp_proc_unregister);
 #endif
Index: linux/net/ipv4/udplite.c
===================================================================
--- linux.orig/net/ipv4/udplite.c
+++ linux/net/ipv4/udplite.c
@@ -113,6 +113,6 @@ out_register_err:
 	printk(KERN_CRIT "%s: Cannot add UDP-Lite protocol.\n", __FUNCTION__);
 }
 
-EXPORT_SYMBOL(udplite_hash);
-EXPORT_SYMBOL(udplite_prot);
-EXPORT_SYMBOL(udplite_get_port);
+EXPORT_SYMBOL_NS(udp, udplite_hash);
+EXPORT_SYMBOL_NS(udp, udplite_prot);
+EXPORT_SYMBOL_NS(udp, udplite_get_port);

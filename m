From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 31/41: auto-load ip_queue module when socket opened
Date: Tue, 24 Mar 2009 15:03:48 +0100 (MET)
Message-ID: <20090324140344.31401.98568.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34809 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758524AbZCXODu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:03:50 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 95ba434f898c3cb5c7457dce265bf0ab72ba8ce9
Author: Scott James Remnant <scott@canonical.com>
Date:   Mon Mar 16 15:31:10 2009 +0100

    netfilter: auto-load ip_queue module when socket opened
    
    The ip_queue module is missing the net-pf-16-proto-3 alias that would
    causae it to be auto-loaded when a socket of that type is opened.  This
    patch adds the alias.
    
    Signed-off-by: Scott James Remnant <scott@canonical.com>
    Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index 432ce9d..5f22c91 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -24,6 +24,7 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/security.h>
+#include <linux/net.h>
 #include <linux/mutex.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
@@ -640,6 +641,7 @@ static void __exit ip_queue_fini(void)
 MODULE_DESCRIPTION("IPv4 packet queue handler");
 MODULE_AUTHOR("James Morris <jmorris@intercode.com.au>");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_NET_PF_PROTO(PF_NETLINK, NETLINK_FIREWALL);
 
 module_init(ip_queue_init);
 module_exit(ip_queue_fini);

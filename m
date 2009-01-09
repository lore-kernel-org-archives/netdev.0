From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 10/45] appletalk: remove unneeded stubs
Date: Fri, 09 Jan 2009 15:01:07 -0800
Message-ID: <20090109230137.455459633@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghosprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42169 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753903AbZAIXRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:17:55 -0500
Content-Disposition: inline; filename=atalk-dev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With net_device_ops if set_mac_address is null, then error
is -EOPNOTSUPPORTED.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/appletalk/dev.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

--- a/net/appletalk/dev.c	2009-01-08 10:18:09.643260397 -0800
+++ b/net/appletalk/dev.c	2009-01-08 10:18:59.546256496 -0800
@@ -9,22 +9,20 @@
 #include <linux/if_arp.h>
 #include <linux/if_ltalk.h>
 
+#ifdef CONFIG_COMPAT_NET_DEV_OPS
 static int ltalk_change_mtu(struct net_device *dev, int mtu)
 {
 	return -EINVAL;
 }
-
-static int ltalk_mac_addr(struct net_device *dev, void *addr)
-{
-	return -EINVAL;
-}
+#endif
 
 static void ltalk_setup(struct net_device *dev)
 {
 	/* Fill in the fields of the device structure with localtalk-generic values. */
 
+#ifdef CONFIG_COMPAT_NET_DEV_OPS
 	dev->change_mtu		= ltalk_change_mtu;
-	dev->set_mac_address 	= ltalk_mac_addr;
+#endif
 
 	dev->type		= ARPHRD_LOCALTLK;
 	dev->hard_header_len 	= LTALK_HLEN;



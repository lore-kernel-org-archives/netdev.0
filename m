From: Ezequiel Lara Gomez <ezegomez@amazon.com>
Subject: [PATCH v2] Cleanup some warning from timestamping code.
Date: Tue, 14 Mar 2017 11:16:26 +0000
Message-ID: <20170314111626.GC9827@u480fcf44e5b8574c5490.ant.amazon.com>
References: <20170311202841.GA26844@u480fcf44e5b8574c5490.ant.amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-2101.amazon.com ([72.21.196.25]:37983 "EHLO
        smtp-fw-2101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750965AbdCNLQa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 07:16:30 -0400
Received: from u480fcf44e5b8574c5490.ant.amazon.com (iad1-ws-svc-lb91-vlan2.amazon.com [10.0.103.146])
        by email-inbound-relay-71007.iad55.amazon.com (8.14.7/8.14.7) with ESMTP id v2EBGQbK030990
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 11:16:28 GMT
Received: from u480fcf44e5b8574c5490.ant.amazon.com (localhost [127.0.0.1])
        by u480fcf44e5b8574c5490.ant.amazon.com (8.14.4/8.14.4/Debian-4.1ubuntu1) with ESMTP id v2EBGRvt017330
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 11:16:27 GMT
Received: (from ezegomez@localhost)
        by u480fcf44e5b8574c5490.ant.amazon.com (8.14.4/8.14.4/Submit) id v2EBGQTU017327
        for netdev@vger.kernel.org; Tue, 14 Mar 2017 11:16:26 GMT
Content-Disposition: inline
In-Reply-To: <20170311202841.GA26844@u480fcf44e5b8574c5490.ant.amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>From f85a5b8bfc420ce1f20d81974e87604bc8d60e45 Mon Sep 17 00:00:00 2001
From: Ezequiel Lara Gomez <ezegomez@amazon.com>
Date: Sat, 11 Mar 2017 20:06:01 +0000
Subject: [PATCH v2] Cleanup some warning from timestamping code.

Following checkpatch.pl recommendations (which include
replacing with <linux/io.h> the <asm/io.h>, since linux/io.h includes
it).

Signed-off-by: Ezequiel Lara Gomez <ezegomez@amazon.com>
---
Changes:
* v2: fixed two remaining warnings about /* comments. Also, added clarification on the commit as to why switch headers.

 drivers/net/loopback.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index b23b719..7957b9a 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -13,7 +13,7 @@
  *
  *		Alan Cox	:	Fixed oddments for NET3.014
  *		Alan Cox	:	Rejig for NET3.029 snap #3
- *		Alan Cox	: 	Fixed NET3.029 bugs and sped up
+ *		Alan Cox	:	Fixed NET3.029 bugs and sped up
  *		Larry McVoy	:	Tiny tweak to double performance
  *		Alan Cox	:	Backed out LMV's tweak - the linux mm
  *					can't take it...
@@ -41,7 +41,7 @@
 #include <linux/in.h>
 
 #include <linux/uaccess.h>
-#include <asm/io.h>
+#include <linux/io.h>
 
 #include <linux/inet.h>
 #include <linux/netdevice.h>
@@ -64,8 +64,7 @@ struct pcpu_lstats {
 	struct u64_stats_sync	syncp;
 };
 
-/*
- * The higher levels take care of making this non-reentrant (it's
+/* The higher levels take care of making this non-reentrant (it's
  * called with bh's disabled).
  */
 static netdev_tx_t loopback_xmit(struct sk_buff *skb,
@@ -149,14 +148,13 @@ static void loopback_dev_free(struct net_device *dev)
 }
 
 static const struct net_device_ops loopback_ops = {
-	.ndo_init      = loopback_dev_init,
-	.ndo_start_xmit= loopback_xmit,
+	.ndo_init        = loopback_dev_init,
+	.ndo_start_xmit  = loopback_xmit,
 	.ndo_get_stats64 = loopback_get_stats64,
 	.ndo_set_mac_address = eth_mac_addr,
 };
 
-/*
- * The loopback device is special. There is only one instance
+/* The loopback device is special. There is only one instance
  * per network namespace.
  */
 static void loopback_setup(struct net_device *dev)
@@ -170,7 +168,7 @@ static void loopback_setup(struct net_device *dev)
 	dev->priv_flags		|= IFF_LIVE_ADDR_CHANGE | IFF_NO_QUEUE;
 	netif_keep_dst(dev);
 	dev->hw_features	= NETIF_F_GSO_SOFTWARE;
-	dev->features 		= NETIF_F_SG | NETIF_F_FRAGLIST
+	dev->features		= NETIF_F_SG | NETIF_F_FRAGLIST
 		| NETIF_F_GSO_SOFTWARE
 		| NETIF_F_HW_CSUM
 		| NETIF_F_RXCSUM
@@ -206,7 +204,6 @@ static __net_init int loopback_net_init(struct net *net)
 	net->loopback_dev = dev;
 	return 0;
 
-
 out_free_netdev:
 	free_netdev(dev);
 out:
@@ -217,5 +214,5 @@ static __net_init int loopback_net_init(struct net *net)
 
 /* Registered in net/core/dev.c */
 struct pernet_operations __net_initdata loopback_net_ops = {
-       .init = loopback_net_init,
+	.init = loopback_net_init,
 };
-- 
1.9.1

Amazon Data Services Ireland Limited registered office: One Burlington Plaza, Burlington Road, Dublin 4, Ireland. Registered in Ireland. Registration number 390566.

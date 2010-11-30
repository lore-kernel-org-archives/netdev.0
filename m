From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH net-next-2.6] net: dummy: add auto_up module parameter
Date: Tue, 30 Nov 2010 17:57:27 +0200
Message-ID: <1291132647-15018-1-git-send-email-opurdila@ixiacom.com>
Cc: Vlad Dogaru <ddvlad@rosedu.org>,
	Lucian Grijincu <lucian.grijincu@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:21121 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754221Ab0K3QMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 11:12:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add auto_up module parameter to automatically bring up the created
devices. This is useful when using the dummy driver for testing net
device register / unregister performance.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 drivers/net/dummy.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index ff2d29b..ce653b0 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -39,6 +39,7 @@
 #include <linux/u64_stats_sync.h>
 
 static int numdummies = 1;
+static int auto_up;
 
 static int dummy_set_address(struct net_device *dev, void *p)
 {
@@ -132,6 +133,8 @@ static void dummy_setup(struct net_device *dev)
 	/* Fill in device structure with ethernet-generic values. */
 	dev->tx_queue_len = 0;
 	dev->flags |= IFF_NOARP;
+	if (auto_up)
+		dev->flags |= IFF_UP;
 	dev->flags &= ~IFF_MULTICAST;
 	dev->features	|= NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO;
 	dev->features	|= NETIF_F_NO_CSUM | NETIF_F_HIGHDMA | NETIF_F_LLTX;
@@ -159,6 +162,9 @@ static struct rtnl_link_ops dummy_link_ops __read_mostly = {
 module_param(numdummies, int, 0);
 MODULE_PARM_DESC(numdummies, "Number of dummy pseudo devices");
 
+module_param(auto_up, int, 0);
+MODULE_PARM_DESC(auto_up, "Automatically bring up the device when created");
+
 static int __init dummy_init_one(void)
 {
 	struct net_device *dev_dummy;
-- 
1.7.1


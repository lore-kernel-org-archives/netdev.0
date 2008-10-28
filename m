From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 2/2] veth:  remove unused list
Date: Tue, 28 Oct 2008 22:11:44 +0100
Message-ID: <20081028212120.658842697@fr.ibm.com>
References: <20081028211142.359911603@fr.ibm.com>
Cc: netdev@vger.kernel.org, xemul@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.uk.ibm.com ([195.212.29.141]:52807 "EHLO
	mtagate8.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754017AbYJ1VWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 17:22:37 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate8.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m9SLLRP0033378
	for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 21:21:27 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9SLLRlk4194514
	for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 21:21:27 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9SLLQGY009050
	for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 21:21:27 GMT
Content-Disposition: inline; filename=remove-unused-veth-list.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The veth network device is stored in a list in the netdev private.
AFAICS, this list is never used so I removed this list from the code.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 drivers/net/veth.c |   13 -------------
 1 file changed, 13 deletions(-)

Index: net-2.6/drivers/net/veth.c
===================================================================
--- net-2.6.orig/drivers/net/veth.c
+++ net-2.6/drivers/net/veth.c
@@ -8,7 +8,6 @@
  *
  */
 
-#include <linux/list.h>
 #include <linux/netdevice.h>
 #include <linux/ethtool.h>
 #include <linux/etherdevice.h>
@@ -30,13 +29,10 @@ struct veth_net_stats {
 
 struct veth_priv {
 	struct net_device *peer;
-	struct list_head list;
 	struct veth_net_stats *stats;
 	unsigned ip_summed;
 };
 
-static LIST_HEAD(veth_list);
-
 /*
  * ethtool interface
  */
@@ -420,11 +416,9 @@ static int veth_newlink(struct net_devic
 
 	priv = netdev_priv(dev);
 	priv->peer = peer;
-	list_add(&priv->list, &veth_list);
 
 	priv = netdev_priv(peer);
 	priv->peer = dev;
-	INIT_LIST_HEAD(&priv->list);
 	return 0;
 
 err_register_dev:
@@ -446,13 +440,6 @@ static void veth_dellink(struct net_devi
 	priv = netdev_priv(dev);
 	peer = priv->peer;
 
-	if (!list_empty(&priv->list))
-		list_del(&priv->list);
-
-	priv = netdev_priv(peer);
-	if (!list_empty(&priv->list))
-		list_del(&priv->list);
-
 	unregister_netdevice(dev);
 	unregister_netdevice(peer);
 }

-- 

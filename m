From: dlezcano@fr.ibm.com
Subject: [NET-2.6.24][VETH][patch 1/1]  fix bad netif_carrier_off place
Date: Wed, 19 Sep 2007 15:38:22 +0200
Message-ID: <20070919140850.607582917@mai.toulouse-stg.fr.ibm.com>
References: <20070919133821.495385952@mai.toulouse-stg.fr.ibm.com>
Cc: xemul@openvz.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:16304 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754937AbXISOLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 10:11:30 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id l8JEBSVf075762
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 14:11:28 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8JEBRPN2158772
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 16:11:27 +0200
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8JEBRUV018626
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 16:11:27 +0200
Content-Disposition: inline; filename=fix-veth-netcarrier-off.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Lezcano <dlezcano@fr.ibm.com>

If the netif_carrier_off is called before register_netdev
that will use and generate an event for a non initialized network
device and that leads to a Oops.

I moved the netif_carrier_off from the setup function after each 
register_netdev call.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 drivers/net/veth.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: net-2.6.24/drivers/net/veth.c
===================================================================
--- net-2.6.24.orig/drivers/net/veth.c
+++ net-2.6.24/drivers/net/veth.c
@@ -286,7 +286,6 @@ static void veth_setup(struct net_device
 	dev->features |= NETIF_F_LLTX;
 	dev->init = veth_dev_init;
 	dev->destructor = veth_dev_free;
-	netif_carrier_off(dev);
 }
 
 /*
@@ -357,6 +356,8 @@ static int veth_newlink(struct net_devic
 	if (err < 0)
 		goto err_register_peer;
 
+	netif_carrier_off(peer);
+
 	/*
 	 * register dev last
 	 *
@@ -382,6 +383,8 @@ static int veth_newlink(struct net_devic
 	if (err < 0)
 		goto err_register_dev;
 
+	netif_carrier_off(dev);
+
 	/*
 	 * tie the deviced together
 	 */

-- 

From: dhananjay@netxen.com
Subject: [RESEND 1/2] netxen: re-init station address after h/w init
Date: Wed, 25 Jul 2007 20:13:11 +0530
Message-ID: <20070725144515.533385702@netxen.com>
References: <20070725144310.500691352@netxen.com>
Cc: rob@netxen.com, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.199.144.227] ([203.199.144.227]:2390 "EHLO
	stellar.unminc.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760598AbXGYOv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 10:51:29 -0400
Content-Disposition: inline; filename=dma.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a workaround for firmware bug with 2nd port of multiport adapter,
where MAC address is reset. Driver just needs to overwrite it with the
value read from PROM.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Index: netdev-2.6/drivers/net/netxen/netxen_nic_main.c
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic_main.c
+++ netdev-2.6/drivers/net/netxen/netxen_nic_main.c
@@ -895,8 +895,6 @@ static int netxen_nic_open(struct net_de
 
 	/* Done here again so that even if phantom sw overwrote it,
 	 * we set it */
-	if (adapter->macaddr_set)
-		adapter->macaddr_set(adapter, netdev->dev_addr);
 	if (adapter->init_port
 	    && adapter->init_port(adapter, adapter->portnum) != 0) {
 	    del_timer_sync(&adapter->watchdog_timer);
@@ -904,6 +902,8 @@ static int netxen_nic_open(struct net_de
 				netxen_nic_driver_name, adapter->portnum);
 		return -EIO;
 	}
+	if (adapter->macaddr_set)
+		adapter->macaddr_set(adapter, netdev->dev_addr);
 
 	netxen_nic_set_link_parameters(adapter);
 

-- 

From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 1/5] NetXen: Fixed /sys mapping between device and driver
Date: Thu, 30 Nov 2006 10:48:57 -0800
Message-ID: <20061130184857.GA32292@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: amitkale@netxen.com, jeff@garzik.org, netxenproj@linsyssoft.com,
	rob@netxen.com, sanjeev@netxen.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:42125 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1031180AbWK3StD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 13:49:03 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kAUIn2Re016780
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 13:49:02 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAUIn2Mw228650
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 13:49:02 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAUIn1tY004394
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 13:49:02 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Amit S. Kale <amitkale@netxen.com>

diff -Nupr netdev-2.6/drivers/net/netxen.orig/netxen_nic_main.c netdev-2.6/drivers/net/netxen/netxen_nic_main.c
--- netdev-2.6/drivers/net/netxen.orig/netxen_nic_main.c	2006-11-29 12:13:58.000000000 -0800
+++ netdev-2.6/drivers/net/netxen/netxen_nic_main.c	2006-11-30 09:17:51.000000000 -0800
@@ -273,6 +273,7 @@ netxen_nic_probe(struct pci_dev *pdev, c
 		}
 
 		SET_MODULE_OWNER(netdev);
+		SET_NETDEV_DEV(netdev, &pdev->dev);
 
 		port = netdev_priv(netdev);
 		port->netdev = netdev;
@@ -1043,7 +1044,7 @@ static int netxen_nic_poll(struct net_de
 		netxen_nic_enable_int(adapter);
 	}
 
-	return (done ? 0 : 1);
+	return !done;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-- 
Don Fry
brazilnut@us.ibm.com

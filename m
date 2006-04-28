From: Santiago Leon <santil@us.ibm.com>
Subject: [PATCH] ibmveth support for netpoll
Date: Fri, 28 Apr 2006 16:53:24 -0500
Message-ID: <44528ED4.5000502@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040601040303000006000801"
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:2959 "EHLO e34.co.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751429AbWD1Vzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 17:55:37 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k3SLtaAG008952
	for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 17:55:36 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3SLtavY273602
	for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 15:55:36 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k3SLtaB2020723
	for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 15:55:36 -0600
To: jgarzik@pobox.com, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040601040303000006000801
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds NETPOLL support for the ibmveth driver. Please apply.

Signed-off-by: Santiago Leon <santil@us.ibm.com>

  ibmveth.c |   11 +++++++++++
  1 file changed, 11 insertions(+)

--------------040601040303000006000801
Content-Type: text/plain;
 name="ibmveth_netpoll.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ibmveth_netpoll.patch"

--- a/drivers/net/ibmveth.c	2006-04-28 13:16:22.244724056 -0500
+++ b/drivers/net/ibmveth.c	2006-04-28 13:17:59.971778584 -0500
@@ -918,6 +918,14 @@ static int ibmveth_change_mtu(struct net
 	return 0;	
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void ibmveth_poll_controller(struct net_device *dev)
+{
+	ibmveth_replenish_task(dev->priv);
+	ibmveth_interrupt(dev->irq, dev, NULL);
+}
+#endif
+
 static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
 {
 	int rc, i;
@@ -989,6 +997,9 @@ static int __devinit ibmveth_probe(struc
 	netdev->ethtool_ops           = &netdev_ethtool_ops;
 	netdev->change_mtu         = ibmveth_change_mtu;
 	SET_NETDEV_DEV(netdev, &dev->dev);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	netdev->poll_controller = ibmveth_poll_controller;
+#endif
  	netdev->features |= NETIF_F_LLTX; 
 	spin_lock_init(&adapter->stats_lock);
 

--------------040601040303000006000801--


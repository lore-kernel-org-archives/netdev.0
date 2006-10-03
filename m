From: Santiago Leon <santil@us.ibm.com>
Subject: [PATCH 2/5] ibmveth: Add netpoll function
Date: Tue, 03 Oct 2006 12:24:28 -0500
Message-ID: <20061003172428.14851.1281.sendpatchset@ltcml8p1.rchland.ibm.com>
References: <20061003172417.14851.63625.sendpatchset@ltcml8p1.rchland.ibm.com>
Cc: Santiago Leon <santil@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:45487 "EHLO
	e31.co.us.ibm.com") by vger.kernel.org with ESMTP id S1030455AbWJCS11
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 14:27:27 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k93IRQ59017952
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 14:27:27 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k93IRQxc175704
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 12:27:26 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k93IRGb9026304
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 12:27:16 -0600
To: netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20061003172417.14851.63625.sendpatchset@ltcml8p1.rchland.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santiago Leon <santil@us.ibm.com>

This patch adds the net poll controller function to ibmveth to support netconsole and netdump.

Signed-off-by: Santiago Leon <santil@us.ibm.com>
---
 drivers/net/ibmveth.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff -urNp a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
--- a/drivers/net/ibmveth.c	2006-07-12 11:07:41.940202928 -0500
+++ b/drivers/net/ibmveth.c	2006-07-12 11:09:45.344207680 -0500
@@ -925,6 +925,14 @@ static int ibmveth_change_mtu(struct net
 	return -EINVAL;
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
@@ -997,6 +1005,9 @@ static int __devinit ibmveth_probe(struc
 	netdev->ethtool_ops           = &netdev_ethtool_ops;
 	netdev->change_mtu         = ibmveth_change_mtu;
 	SET_NETDEV_DEV(netdev, &dev->dev);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	netdev->poll_controller = ibmveth_poll_controller;
+#endif
  	netdev->features |= NETIF_F_LLTX;
 	spin_lock_init(&adapter->stats_lock);
 

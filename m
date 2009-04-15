From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 05/26] ibmveth: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:39 +0400
Message-ID: <1239835980-22502-5-git-send-email-a.beregalov@gmail.com>
References: <1239835980-22502-1-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-2-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-3-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-4-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.187]:22291 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754306AbZDOWxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:09 -0400
Received: by fk-out-0910.google.com with SMTP id 18so54609fkq.5
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:07 -0700 (PDT)
In-Reply-To: <1239835980-22502-4-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/ibmveth.c |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 5c6315d..0a51b0b 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -1203,6 +1203,20 @@ static unsigned long ibmveth_get_desired_dma(struct vio_dev *vdev)
 	return ret;
 }
 
+static const struct net_device_ops ibmveth_netdev_ops = {
+	.ndo_open		= ibmveth_open,
+	.ndo_stop		= ibmveth_close,
+	.ndo_start_xmit		= ibmveth_start_xmit,
+	.ndo_set_multicast_list	= ibmveth_set_multicast_list,
+	.ndo_do_ioctl		= ibmveth_ioctl,
+	.ndo_change_mtu		= ibmveth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= ibmveth_poll_controller,
+#endif
+};
+
 static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
 {
 	int rc, i;
@@ -1265,17 +1279,9 @@ static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_
 	memcpy(&adapter->mac_addr, mac_addr_p, 6);
 
 	netdev->irq = dev->irq;
-	netdev->open               = ibmveth_open;
-	netdev->stop               = ibmveth_close;
-	netdev->hard_start_xmit    = ibmveth_start_xmit;
-	netdev->set_multicast_list = ibmveth_set_multicast_list;
-	netdev->do_ioctl           = ibmveth_ioctl;
-	netdev->ethtool_ops           = &netdev_ethtool_ops;
-	netdev->change_mtu         = ibmveth_change_mtu;
+	netdev->netdev_ops = &ibmveth_netdev_ops;
+	netdev->ethtool_ops = &netdev_ethtool_ops;
 	SET_NETDEV_DEV(netdev, &dev->dev);
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	netdev->poll_controller = ibmveth_poll_controller;
-#endif
  	netdev->features |= NETIF_F_LLTX;
 	spin_lock_init(&adapter->stats_lock);
 
-- 
1.6.2.3


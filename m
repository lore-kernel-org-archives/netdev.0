From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 19/22] qla3xxx: convert to net_device_ops
Date: Fri, 21 Nov 2008 15:21:57 -0800
Message-ID: <20081121232240.517617345@vyatta.com>
References: <20081121232138.343333942@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57069 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754636AbYKUXXg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 18:23:36 -0500
Content-Disposition: inline; filename=qla3xxx.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert this driver to net_device_ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/qla3xxx.c	2008-11-21 14:37:52.000000000 -0800
+++ b/drivers/net/qla3xxx.c	2008-11-21 14:41:14.000000000 -0800
@@ -3900,6 +3900,17 @@ static void ql3xxx_timer(unsigned long p
 	queue_delayed_work(qdev->workqueue, &qdev->link_state_work, 0);
 }
 
+static const struct net_device_ops ql3xxx_netdev_ops = {
+	.ndo_open		= ql3xxx_open,
+	.ndo_start_xmit		= ql3xxx_send,
+	.ndo_stop		= ql3xxx_close,
+	.ndo_set_multicast_list = NULL, /* not allowed on NIC side */
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= ql3xxx_set_mac_address,
+	.ndo_tx_timeout		= ql3xxx_tx_timeout,
+};
+
 static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 				  const struct pci_device_id *pci_entry)
 {
@@ -3978,17 +3989,8 @@ static int __devinit ql3xxx_probe(struct
 	spin_lock_init(&qdev->hw_lock);
 
 	/* Set driver entry points */
-	ndev->open = ql3xxx_open;
-	ndev->hard_start_xmit = ql3xxx_send;
-	ndev->stop = ql3xxx_close;
-	/* ndev->set_multicast_list
-	 * This device is one side of a two-function adapter
-	 * (NIC and iSCSI).  Promiscuous mode setting/clearing is
-	 * not allowed from the NIC side.
-	 */
+	ndev->netdev_ops = &ql3xxx_netdev_ops;
 	SET_ETHTOOL_OPS(ndev, &ql3xxx_ethtool_ops);
-	ndev->set_mac_address = ql3xxx_set_mac_address;
-	ndev->tx_timeout = ql3xxx_tx_timeout;
 	ndev->watchdog_timeo = 5 * HZ;
 
 	netif_napi_add(ndev, &qdev->napi, ql_poll, 64);

-- 


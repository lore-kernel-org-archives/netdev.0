From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: [PATCH net-next] vmxnet3: set netdev parant device before calling
 netdev_info
Date: Wed, 20 Jul 2011 19:01:11 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1107201834220.19334@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: pv-drivers@vmware.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:27150 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751686Ab1GUCBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 22:01:08 -0400
Received: from mailhost3.vmware.com (mailhost3.vmware.com [10.16.27.45])
	by smtp-outbound-2.vmware.com (Postfix) with ESMTP id 714442C015
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 19:01:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Parent device for netdev should be set before netdev_info() can be called
otherwise there is a NULL pointer dereference and probe() fails.

Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>

--

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 009277e..1a8cc5b 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2993,6 +2993,7 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 		goto err_ver;
 	}
 
+	SET_NETDEV_DEV(netdev, &pdev->dev);
 	vmxnet3_declare_features(adapter, dma64);
 
 	adapter->dev_number = atomic_read(&devices_found);
@@ -3038,7 +3039,6 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	netif_set_real_num_tx_queues(adapter->netdev, adapter->num_tx_queues);
 	netif_set_real_num_rx_queues(adapter->netdev, adapter->num_rx_queues);
 
-	SET_NETDEV_DEV(netdev, &pdev->dev);
 	err = register_netdev(netdev);
 
 	if (err) {

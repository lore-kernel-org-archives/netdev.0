From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 09/39] vxge: stop using net_device.{base_addr, irq}.
Date: Fri,  6 Apr 2012 12:06:23 +0200
Message-ID: <5a6c96842f5ca982949538ce74a9d687c684707e.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>, Jon Mason <jdmason@kudzu.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43474 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755996Ab2DFKKj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:39 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/ethernet/neterion/vxge/vxge-main.c |   18 +++++++-----------
 1 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 95fb611..51387c3 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -1882,25 +1882,24 @@ static int vxge_poll_inta(struct napi_struct *napi, int budget)
  */
 static void vxge_netpoll(struct net_device *dev)
 {
-	struct __vxge_hw_device *hldev;
-	struct vxgedev *vdev;
-
-	vdev = netdev_priv(dev);
-	hldev = pci_get_drvdata(vdev->pdev);
+	struct vxgedev *vdev = netdev_priv(dev);
+	struct pci_dev *pdev = vdev->pdev;
+	struct __vxge_hw_device *hldev = pci_get_drvdata(pdev);
+	const int irq = pdev->irq;
 
 	vxge_debug_entryexit(VXGE_TRACE, "%s:%d", __func__, __LINE__);
 
-	if (pci_channel_offline(vdev->pdev))
+	if (pci_channel_offline(pdev))
 		return;
 
-	disable_irq(dev->irq);
+	disable_irq(irq);
 	vxge_hw_device_clear_tx_rx(hldev);
 
 	vxge_hw_device_clear_tx_rx(hldev);
 	VXGE_COMPLETE_ALL_RX(vdev);
 	VXGE_COMPLETE_ALL_TX(vdev);
 
-	enable_irq(dev->irq);
+	enable_irq(irq);
 
 	vxge_debug_entryexit(VXGE_TRACE,
 		"%s:%d  Exiting...", __func__, __LINE__);
@@ -3424,9 +3423,6 @@ static int __devinit vxge_device_register(struct __vxge_hw_device *hldev,
 	ndev->features |= ndev->hw_features |
 		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
 
-	/*  Driver entry points */
-	ndev->irq = vdev->pdev->irq;
-	ndev->base_addr = (unsigned long) hldev->bar0;
 
 	ndev->netdev_ops = &vxge_netdev_ops;
 
-- 
1.7.7.6

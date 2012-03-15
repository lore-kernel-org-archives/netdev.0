From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 09/34] vxge: stop using net_device.{base_addr, irq}.
Date: Thu, 15 Mar 2012 14:57:06 +0100
Message-ID: <bfe92ff6fcf89b8cbbdfc6f4fd86865d26b06e1f.1331814082.git.romieu@fr.zoreil.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>, Jon Mason <jdmason@kudzu.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51853 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754012Ab2CON7p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 09:59:45 -0400
In-Reply-To: <cover.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/ethernet/neterion/vxge/vxge-main.c |   18 +++++++-----------
 1 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index ef76725..a84e342 100644
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

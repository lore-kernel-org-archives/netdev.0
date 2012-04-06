From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 35/39] myri10ge: stop using net_device.{base_addr, irq}.
Date: Fri,  6 Apr 2012 12:06:49 +0200
Message-ID: <a5a6d0922ea55d7c8e7792633135e8cb94ccd1c2.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>, Jon Mason <mason@myri.com>,
	Andrew Gallatin <gallatin@myri.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43486 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756038Ab2DFKKm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:42 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Jon Mason <mason@myri.com>
Cc: Andrew Gallatin <gallatin@myri.com>
---
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 27273ae..90153fc 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -4033,7 +4033,6 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netdev->netdev_ops = &myri10ge_netdev_ops;
 	netdev->mtu = myri10ge_initial_mtu;
-	netdev->base_addr = mgp->iomem_base;
 	netdev->hw_features = mgp->features | NETIF_F_LRO | NETIF_F_RXCSUM;
 	netdev->features = netdev->hw_features;
 
@@ -4047,12 +4046,10 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		netdev->vlan_features &= ~NETIF_F_TSO;
 
 	/* make sure we can get an irq, and that MSI can be
-	 * setup (if available).  Also ensure netdev->irq
-	 * is set to correct value if MSI is enabled */
+	 * setup (if available). */
 	status = myri10ge_request_irq(mgp);
 	if (status != 0)
 		goto abort_with_firmware;
-	netdev->irq = pdev->irq;
 	myri10ge_free_irq(mgp);
 
 	/* Save configuration space to be restored if the
@@ -4077,7 +4074,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	else
 		dev_info(dev, "%s IRQ %d, tx bndry %d, fw %s, WC %s\n",
 			 mgp->msi_enabled ? "MSI" : "xPIC",
-			 netdev->irq, mgp->tx_boundary, mgp->fw_name,
+			 pdev->irq, mgp->tx_boundary, mgp->fw_name,
 			 (mgp->wc_enabled ? "Enabled" : "Disabled"));
 
 	board_number++;
-- 
1.7.7.6

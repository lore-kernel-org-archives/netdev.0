From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH] marvell sky2 driver: fix irq number assignment bug
Date: Tue, 3 Apr 2012 11:10:14 -0400
Message-ID: <201204031526.q33FQvFO031746@farm-0027.internal.tilera.com>
To: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix a minor bug that will display wrong IRQ number in ifconfig output.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/marvell/sky2.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 423a1a2..879b0a4 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -4978,6 +4978,13 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 			goto err_out_free_netdev;
  	}
 
+	/*
+	 * Need to set the IRQ # for the net_device here again after
+	 * setting it in sky2_init_netdev() initially, because MSI
+	 * will assign a new IRQ # to this PCI device.
+	 */
+	dev->irq = hw->pdev->irq;
+
 	err = register_netdev(dev);
 	if (err) {
 		dev_err(&pdev->dev, "cannot register net device\n");
-- 
1.6.5.2

From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 11/34] atl1e: stop using net_device.{base_addr, irq}.
Date: Thu, 15 Mar 2012 14:57:08 +0100
Message-ID: <48cf326fcc518b2782b6c6d31ebaf2b75ac0a70e.1331814082.git.romieu@fr.zoreil.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51859 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759561Ab2CON7q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 09:59:46 -0400
In-Reply-To: <cover.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Jay Cliburn <jcliburn@gmail.com>
Cc: Chris Snook <chris.snook@gmail.com>
---
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c |   17 ++++++-----------
 1 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index 93ff2b2..1220e51 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -1883,27 +1883,24 @@ static int atl1e_request_irq(struct atl1e_adapter *adapter)
 	int err = 0;
 
 	adapter->have_msi = true;
-	err = pci_enable_msi(adapter->pdev);
+	err = pci_enable_msi(pdev);
 	if (err) {
-		netdev_dbg(adapter->netdev,
+		netdev_dbg(netdev,
 			   "Unable to allocate MSI interrupt Error: %d\n", err);
 		adapter->have_msi = false;
-	} else
-		netdev->irq = pdev->irq;
-
+	}
 
 	if (!adapter->have_msi)
 		flags |= IRQF_SHARED;
-	err = request_irq(adapter->pdev->irq, atl1e_intr, flags,
-			netdev->name, netdev);
+	err = request_irq(pdev->irq, atl1e_intr, flags, netdev->name, netdev);
 	if (err) {
 		netdev_dbg(adapter->netdev,
 			   "Unable to allocate interrupt Error: %d\n", err);
 		if (adapter->have_msi)
-			pci_disable_msi(adapter->pdev);
+			pci_disable_msi(pdev);
 		return err;
 	}
-	netdev_dbg(adapter->netdev, "atl1e_request_irq OK\n");
+	netdev_dbg(netdev, "atl1e_request_irq OK\n");
 	return err;
 }
 
@@ -2233,7 +2230,6 @@ static int atl1e_init_netdev(struct net_device *netdev, struct pci_dev *pdev)
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 	pci_set_drvdata(pdev, netdev);
 
-	netdev->irq  = pdev->irq;
 	netdev->netdev_ops = &atl1e_netdev_ops;
 
 	netdev->watchdog_timeo = AT_TX_WATCHDOG;
@@ -2319,7 +2315,6 @@ static int __devinit atl1e_probe(struct pci_dev *pdev,
 		netdev_err(netdev, "cannot map device registers\n");
 		goto err_ioremap;
 	}
-	netdev->base_addr = (unsigned long)adapter->hw.hw_addr;
 
 	/* init mii data */
 	adapter->mii.dev = netdev;
-- 
1.7.7.6

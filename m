From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 04/39] atl1c: stop using net_device.{base_addr, irq}.
Date: Fri,  6 Apr 2012 12:06:18 +0200
Message-ID: <b581457262a49dac7f66edf3fcbb6aa9e728b59b.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43476 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755997Ab2DFKKj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:39 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Jay Cliburn <jcliburn@gmail.com>
Cc: Chris Snook <chris.snook@gmail.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 1ef0c92..ef5b85b 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -2307,8 +2307,7 @@ static int atl1c_request_irq(struct atl1c_adapter *adapter)
 				"Unable to allocate MSI interrupt Error: %d\n",
 				err);
 		adapter->have_msi = false;
-	} else
-		netdev->irq = pdev->irq;
+	}
 
 	if (!adapter->have_msi)
 		flags |= IRQF_SHARED;
@@ -2616,7 +2615,6 @@ static int atl1c_init_netdev(struct net_device *netdev, struct pci_dev *pdev)
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 	pci_set_drvdata(pdev, netdev);
 
-	netdev->irq  = pdev->irq;
 	netdev->netdev_ops = &atl1c_netdev_ops;
 	netdev->watchdog_timeo = AT_TX_WATCHDOG;
 	atl1c_set_ethtool_ops(netdev);
@@ -2706,7 +2704,6 @@ static int __devinit atl1c_probe(struct pci_dev *pdev,
 		dev_err(&pdev->dev, "cannot map device registers\n");
 		goto err_ioremap;
 	}
-	netdev->base_addr = (unsigned long)adapter->hw.hw_addr;
 
 	/* init mii data */
 	adapter->mii.dev = netdev;
-- 
1.7.7.6

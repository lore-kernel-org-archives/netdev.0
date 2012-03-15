From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 04/34] atl1c: stop using net_device.{base_addr, irq}.
Date: Thu, 15 Mar 2012 14:57:01 +0100
Message-ID: <5b3f004f647d3de0775615a26170a73be799fc0c.1331814082.git.romieu@fr.zoreil.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51805 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752752Ab2CON7g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 09:59:36 -0400
In-Reply-To: <cover.1331814082.git.romieu@fr.zoreil.com>
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

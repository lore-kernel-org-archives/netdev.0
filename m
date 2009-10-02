From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] e1000e/igb/ixgbe: Don't report an error if devices
	don't support AER
Date: Fri, 02 Oct 2009 00:15:48 -0700
Message-ID: <20091002071542.5072.23381.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Frans Pop <elendil@planet.nl>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:40328 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755064AbZJBHPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 03:15:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frans Pop <elendil@planet.nl>

The only error returned by pci_{en,dis}able_pcie_error_reporting() is
-EIO which simply means that Advanced Error Reporting is not supported.
There is no need to report that, so remove the error check from e1000e,
igb and ixgbe.

Signed-off-by: Frans Pop <elendil@planet.nl>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c    |   13 ++-----------
 drivers/net/igb/igb_main.c     |   13 ++-----------
 drivers/net/ixgbe/ixgbe_main.c |   13 ++-----------
 3 files changed, 6 insertions(+), 33 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 16c193a..0687c6a 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4982,12 +4982,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		goto err_pci_reg;
 
 	/* AER (Advanced Error Reporting) hooks */
-	err = pci_enable_pcie_error_reporting(pdev);
-	if (err) {
-		dev_err(&pdev->dev, "pci_enable_pcie_error_reporting failed "
-		        "0x%x\n", err);
-		/* non-fatal, continue */
-	}
+	pci_enable_pcie_error_reporting(pdev);
 
 	pci_set_master(pdev);
 	/* PCI config space info */
@@ -5263,7 +5258,6 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	int err;
 
 	/*
 	 * flush_scheduled work may reschedule our watchdog task, so
@@ -5299,10 +5293,7 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 	free_netdev(netdev);
 
 	/* AER disable */
-	err = pci_disable_pcie_error_reporting(pdev);
-	if (err)
-		dev_err(&pdev->dev,
-		        "pci_disable_pcie_error_reporting failed 0x%x\n", err);
+	pci_disable_pcie_error_reporting(pdev);
 
 	pci_disable_device(pdev);
 }
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 5d6c153..714c3a4 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1246,12 +1246,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_pci_reg;
 
-	err = pci_enable_pcie_error_reporting(pdev);
-	if (err) {
-		dev_err(&pdev->dev, "pci_enable_pcie_error_reporting failed "
-		        "0x%x\n", err);
-		/* non-fatal, continue */
-	}
+	pci_enable_pcie_error_reporting(pdev);
 
 	pci_set_master(pdev);
 	pci_save_state(pdev);
@@ -1628,7 +1623,6 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	int err;
 
 	/* flush_scheduled work may reschedule our watchdog task, so
 	 * explicitly disable watchdog tasks from being rescheduled  */
@@ -1682,10 +1676,7 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 
 	free_netdev(netdev);
 
-	err = pci_disable_pcie_error_reporting(pdev);
-	if (err)
-		dev_err(&pdev->dev,
-		        "pci_disable_pcie_error_reporting failed 0x%x\n", err);
+	pci_disable_pcie_error_reporting(pdev);
 
 	pci_disable_device(pdev);
 }
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 1cbc6a3..28fbb9d 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5507,12 +5507,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		goto err_pci_reg;
 	}
 
-	err = pci_enable_pcie_error_reporting(pdev);
-	if (err) {
-		dev_err(&pdev->dev, "pci_enable_pcie_error_reporting failed "
-		                    "0x%x\n", err);
-		/* non-fatal, continue */
-	}
+	pci_enable_pcie_error_reporting(pdev);
 
 	pci_set_master(pdev);
 	pci_save_state(pdev);
@@ -5821,7 +5816,6 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	int err;
 
 	set_bit(__IXGBE_DOWN, &adapter->state);
 	/* clear the module not found bit to make sure the worker won't
@@ -5872,10 +5866,7 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 
 	free_netdev(netdev);
 
-	err = pci_disable_pcie_error_reporting(pdev);
-	if (err)
-		dev_err(&pdev->dev,
-		        "pci_disable_pcie_error_reporting failed 0x%x\n", err);
+	pci_disable_pcie_error_reporting(pdev);
 
 	pci_disable_device(pdev);
 }


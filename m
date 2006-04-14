From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 01/10] e1000: Remove PM warning DPRINTKs breaking 2.4.x kernels
Date: Fri, 14 Apr 2006 11:36:49 -0700
Message-ID: <20060414183649.3461.54520.stgit@gitlost.site>
References: <20060414183423.3461.32772.stgit@gitlost.site>
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeff" <Jeffrey.t.kirsher@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:46084 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751397AbWDNSdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2006 14:33:16 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Miller, David" <davem@davemloft.net>
In-Reply-To: <20060414183423.3461.32772.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


remove DPRINTKs that were printing warnings about power management on
2.4 kernels.  Since we really don't react differently these printk
statements are not needed.  This code was originally added to fix
some compile time warnings that got fixed by newer kernels.


Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/e1000/e1000_main.c |   42 ++++++++++------------------------------
 1 files changed, 10 insertions(+), 32 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index add8dc4..ac1e838 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -4515,21 +4515,13 @@ e1000_suspend(struct pci_dev *pdev, pm_m
 
 		E1000_WRITE_REG(&adapter->hw, WUC, E1000_WUC_PME_EN);
 		E1000_WRITE_REG(&adapter->hw, WUFC, wufc);
-		retval = pci_enable_wake(pdev, PCI_D3hot, 1);
-		if (retval)
-			DPRINTK(PROBE, ERR, "Error enabling D3 wake\n");
-		retval = pci_enable_wake(pdev, PCI_D3cold, 1);
-		if (retval)
-			DPRINTK(PROBE, ERR, "Error enabling D3 cold wake\n");
+		pci_enable_wake(pdev, PCI_D3hot, 1);
+		pci_enable_wake(pdev, PCI_D3cold, 1);
 	} else {
 		E1000_WRITE_REG(&adapter->hw, WUC, 0);
 		E1000_WRITE_REG(&adapter->hw, WUFC, 0);
-		retval = pci_enable_wake(pdev, PCI_D3hot, 0);
-		if (retval)
-			DPRINTK(PROBE, ERR, "Error enabling D3 wake\n");
-		retval = pci_enable_wake(pdev, PCI_D3cold, 0);
-		if (retval)
-			DPRINTK(PROBE, ERR, "Error enabling D3 cold wake\n");
+		pci_enable_wake(pdev, PCI_D3hot, 0);
+		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
 
 	if (adapter->hw.mac_type >= e1000_82540 &&
@@ -4538,13 +4530,8 @@ e1000_suspend(struct pci_dev *pdev, pm_m
 		if (manc & E1000_MANC_SMBUS_EN) {
 			manc |= E1000_MANC_ARP_EN;
 			E1000_WRITE_REG(&adapter->hw, MANC, manc);
-			retval = pci_enable_wake(pdev, PCI_D3hot, 1);
-			if (retval)
-				DPRINTK(PROBE, ERR, "Error enabling D3 wake\n");
-			retval = pci_enable_wake(pdev, PCI_D3cold, 1);
-			if (retval)
-				DPRINTK(PROBE, ERR,
-				        "Error enabling D3 cold wake\n");
+			pci_enable_wake(pdev, PCI_D3hot, 1);
+			pci_enable_wake(pdev, PCI_D3cold, 1);
 		}
 	}
 
@@ -4554,9 +4541,7 @@ e1000_suspend(struct pci_dev *pdev, pm_m
 
 	pci_disable_device(pdev);
 
-	retval = pci_set_power_state(pdev, pci_choose_state(pdev, state));
-	if (retval)
-		DPRINTK(PROBE, ERR, "Error in setting power state\n");
+	pci_set_power_state(pdev, pci_choose_state(pdev, state));
 
 	return 0;
 }
@@ -4567,22 +4552,15 @@ e1000_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	int retval;
 	uint32_t manc, ret_val;
 
-	retval = pci_set_power_state(pdev, PCI_D0);
-	if (retval)
-		DPRINTK(PROBE, ERR, "Error in setting power state\n");
+	pci_set_power_state(pdev, PCI_D0);
 	e1000_pci_restore_state(adapter);
 	ret_val = pci_enable_device(pdev);
 	pci_set_master(pdev);
 
-	retval = pci_enable_wake(pdev, PCI_D3hot, 0);
-	if (retval)
-		DPRINTK(PROBE, ERR, "Error enabling D3 wake\n");
-	retval = pci_enable_wake(pdev, PCI_D3cold, 0);
-	if (retval)
-		DPRINTK(PROBE, ERR, "Error enabling D3 cold wake\n");
+	pci_enable_wake(pdev, PCI_D3hot, 0);
+	pci_enable_wake(pdev, PCI_D3cold, 0);
 
 	e1000_reset(adapter);
 	E1000_WRITE_REG(&adapter->hw, WUS, ~0);



--
Auke Kok <auke-jan.h.kok@intel.com>
Intel Pro Ethernet Driver Group
LAN Access Division / Digital Enterprise Group 

From: Alan Cox <alan@linux.intel.com>
Subject: [PATCH 08/26] et131x: Take a kref for the PCI pointer we cache
Date: Tue, 25 Aug 2009 15:58:47 +0100
Message-ID: <20090825145844.16176.42524.stgit@localhost.localdomain>
References: <20090825145619.16176.68780.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: greg@kroah.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:42593 "EHLO
	bob.linux.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755291AbZHYPEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 11:04:09 -0400
In-Reply-To: <20090825145619.16176.68780.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/staging/et131x/et131x_initpci.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)


diff --git a/drivers/staging/et131x/et131x_initpci.c b/drivers/staging/et131x/et131x_initpci.c
index 86bd55d..5485dd7 100644
--- a/drivers/staging/et131x/et131x_initpci.c
+++ b/drivers/staging/et131x/et131x_initpci.c
@@ -742,6 +742,7 @@ void __devexit et131x_pci_remove(struct pci_dev *pdev)
 	unregister_netdev(netdev);
 	et131x_adapter_memory_free(adapter);
 	iounmap(adapter->CSRAddress);
+	pci_dev_put(adapter->pdev);
 	free_netdev(netdev);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
@@ -878,7 +879,7 @@ int __devinit et131x_pci_setup(struct pci_dev *pdev,
 
 	/* Allocate private adapter struct and copy in relevant information */
 	adapter = netdev_priv(netdev);
-	adapter->pdev = pdev;
+	adapter->pdev = pci_dev_get(pdev);
 	adapter->netdev = netdev;
 
 	/* Do the same for the netdev struct */
@@ -1022,6 +1023,7 @@ err_mem_free:
 err_iounmap:
 	iounmap(adapter->CSRAddress);
 err_free_dev:
+	pci_dev_put(pdev);
 	free_netdev(netdev);
 err_release_res:
 	pci_release_regions(pdev);


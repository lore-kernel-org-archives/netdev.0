From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e100: free IRQ to remove warningwhenrebooting
Date: Wed, 12 Dec 2007 16:30:42 -0800
Message-ID: <20071213003042.1895.34327.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	ianw@gelato.unsw.edu.au
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55621 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752131AbXLMAbE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 19:31:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adapted from Ian Wienand <ianw@gelato.unsw.edu.au>

Explicitly free the IRQ before removing the device to remove a
warning "Destroying IRQ without calling free_irq"

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Cc: Ian Wienand <ianw@gelato.unsw.edu.au>
---

 drivers/net/e100.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 27f4d4a..f630ea9 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2807,8 +2807,9 @@ static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
 		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
 
-	pci_disable_device(pdev);
 	free_irq(pdev->irq, netdev);
+
+	pci_disable_device(pdev);
 	pci_set_power_state(pdev, PCI_D3hot);
 
 	return 0;
@@ -2850,6 +2851,8 @@ static void e100_shutdown(struct pci_dev *pdev)
 		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
 
+	free_irq(pdev->irq, netdev);
+
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, PCI_D3hot);
 }

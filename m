From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 3/7] PCI: call pcie_flr from reset_chelsio_generic_dev
Date: Thu, 13 Apr 2017 16:53:35 +0200
Message-ID: <20170413145339.20186-4-hch@lst.de>
References: <20170413145339.20186-1-hch@lst.de>
Cc: linux-pci@vger.kernel.org, qat-linux@intel.com,
        linux-crypto@vger.kernel.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bjorn Helgaas <bhelgaas@google.com>,
        Giovanni Cabiddu <giovanni.cabiddu@intel.com>,
        Salvatore Benedetto <salvatore.benedetto@intel.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20170413145339.20186-1-hch@lst.de>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of copy & pasting and old version of the code.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/pci/quirks.c | 15 +--------------
 1 file changed, 1 insertion(+), 14 deletions(-)

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index b1775354cc69..b54c0d986f2a 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -3751,20 +3751,7 @@ static int reset_chelsio_generic_dev(struct pci_dev *dev, int probe)
 				      PCI_MSIX_FLAGS_ENABLE |
 				      PCI_MSIX_FLAGS_MASKALL);
 
-	/*
-	 * Start of pcie_flr() code sequence.  This reset code is a copy of
-	 * the guts of pcie_flr() because that's not an exported function.
-	 */
-
-	if (!pci_wait_for_pending_transaction(dev))
-		dev_err(&dev->dev, "transaction is not cleared; proceeding with reset anyway\n");
-
-	pcie_capability_set_word(dev, PCI_EXP_DEVCTL, PCI_EXP_DEVCTL_BCR_FLR);
-	msleep(100);
-
-	/*
-	 * End of pcie_flr() code sequence.
-	 */
+	pcie_flr(dev);
 
 	/*
 	 * Restore the configuration information (BAR values, etc.) including
-- 
2.11.0

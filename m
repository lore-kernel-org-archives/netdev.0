From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 7/7] liquidio: use pcie_flr instead of duplicating it
Date: Thu, 13 Apr 2017 16:53:39 +0200
Message-ID: <20170413145339.20186-8-hch@lst.de>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170413145339.20186-1-hch@lst.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 15 +--------------
 1 file changed, 1 insertion(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 7b83be4ce1fe..321fe1d5b7b9 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -899,20 +899,7 @@ static void octeon_pci_flr(struct octeon_device *oct)
 	pci_write_config_word(oct->pci_dev, PCI_COMMAND,
 			      PCI_COMMAND_INTX_DISABLE);
 
-	/* Wait for Transaction Pending bit clean */
-	msleep(100);
-	pcie_capability_read_word(oct->pci_dev, PCI_EXP_DEVSTA, &status);
-	if (status & PCI_EXP_DEVSTA_TRPND) {
-		dev_info(&oct->pci_dev->dev, "Function reset incomplete after 100ms, sleeping for 5 seconds\n");
-		ssleep(5);
-		pcie_capability_read_word(oct->pci_dev, PCI_EXP_DEVSTA,
-					  &status);
-		if (status & PCI_EXP_DEVSTA_TRPND)
-			dev_info(&oct->pci_dev->dev, "Function reset still incomplete after 5s, reset anyway\n");
-	}
-	pcie_capability_set_word(oct->pci_dev, PCI_EXP_DEVCTL,
-				 PCI_EXP_DEVCTL_BCR_FLR);
-	mdelay(100);
+	pcie_flr(oct->pci_dev);
 
 	pci_cfg_access_unlock(oct->pci_dev);
 
-- 
2.11.0

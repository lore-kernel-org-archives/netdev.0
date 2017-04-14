From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 6/7] crypto: qat: use pcie_flr instead of duplicating it
Date: Fri, 14 Apr 2017 21:11:30 +0200
Message-ID: <20170414191131.14286-7-hch@lst.de>
References: <20170414191131.14286-1-hch@lst.de>
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
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20170414191131.14286-1-hch@lst.de>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/crypto/qat/qat_common/adf_aer.c | 15 +--------------
 1 file changed, 1 insertion(+), 14 deletions(-)

diff --git a/drivers/crypto/qat/qat_common/adf_aer.c b/drivers/crypto/qat/qat_common/adf_aer.c
index 2839fccdd84b..d3e25c37dc33 100644
--- a/drivers/crypto/qat/qat_common/adf_aer.c
+++ b/drivers/crypto/qat/qat_common/adf_aer.c
@@ -109,20 +109,7 @@ EXPORT_SYMBOL_GPL(adf_reset_sbr);
 
 void adf_reset_flr(struct adf_accel_dev *accel_dev)
 {
-	struct pci_dev *pdev = accel_to_pci_dev(accel_dev);
-	u16 control = 0;
-	int pos = 0;
-
-	dev_info(&GET_DEV(accel_dev), "Function level reset\n");
-	pos = pci_pcie_cap(pdev);
-	if (!pos) {
-		dev_err(&GET_DEV(accel_dev), "Restart device failed\n");
-		return;
-	}
-	pci_read_config_word(pdev, pos + PCI_EXP_DEVCTL, &control);
-	control |= PCI_EXP_DEVCTL_BCR_FLR;
-	pci_write_config_word(pdev, pos + PCI_EXP_DEVCTL, control);
-	msleep(100);
+	pcie_flr(accel_to_pci_dev(accel_dev));
 }
 EXPORT_SYMBOL_GPL(adf_reset_flr);
 
-- 
2.11.0

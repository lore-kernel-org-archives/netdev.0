From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 14/21] ixgbevf: restore hw_addr on resume or error
Date: Tue,  3 Jan 2017 13:07:50 -0800
Message-ID: <20170103210757.38847-15-jeffrey.t.kirsher@intel.com>
References: <20170103210757.38847-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:3461 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966321AbdACVIR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 16:08:17 -0500
In-Reply-To: <20170103210757.38847-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Restore adapter->hw.hw_addr after handling an error, or a resume
operation to make sure we can access the registers.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index a78e490..dc23f56 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3851,6 +3851,8 @@ static int ixgbevf_resume(struct pci_dev *pdev)
 		dev_err(&pdev->dev, "Cannot enable PCI device from suspend\n");
 		return err;
 	}
+
+	adapter->hw.hw_addr = adapter->io_addr;
 	smp_mb__before_atomic();
 	clear_bit(__IXGBEVF_DISABLED, &adapter->state);
 	pci_set_master(pdev);
@@ -4285,6 +4287,7 @@ static pci_ers_result_t ixgbevf_io_slot_reset(struct pci_dev *pdev)
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 
+	adapter->hw.hw_addr = adapter->io_addr;
 	smp_mb__before_atomic();
 	clear_bit(__IXGBEVF_DISABLED, &adapter->state);
 	pci_set_master(pdev);
-- 
2.9.3

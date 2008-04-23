From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 7/8] [RESEND] igb: save and restore pcie/msi state to support
	EEH recovery
Date: Wed, 23 Apr 2008 11:09:34 -0700
Message-ID: <20080423180934.24972.85834.stgit@localhost.localdomain>
References: <20080423180900.24972.84015.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5974 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755750AbYDWSJv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2008 14:09:51 -0400
In-Reply-To: <20080423180900.24972.84015.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To enable EEH support for pci-express network adapters, pcie/msi state
needs to be saved and restored for that adapter.

[after similar patches for ixgbe and e1000e from Wendy Xiong]

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Cc: Wendy Xiong <wendyx@us.ibm.com>
---

 drivers/net/igb/igb_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index aaee02e..ae398f0 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -871,6 +871,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		goto err_pci_reg;
 
 	pci_set_master(pdev);
+	pci_save_state(pdev);
 
 	err = -ENOMEM;
 	netdev = alloc_etherdev(sizeof(struct igb_adapter));
@@ -4079,6 +4080,7 @@ static pci_ers_result_t igb_io_slot_reset(struct pci_dev *pdev)
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 	pci_set_master(pdev);
+	pci_restore_state(pdev);
 
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);


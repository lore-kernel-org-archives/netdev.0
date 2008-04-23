From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 5/8] ixgbe: save and restore pcie/msi state to support EEH
	recovery
Date: Wed, 23 Apr 2008 11:09:24 -0700
Message-ID: <20080423180924.24972.60794.stgit@localhost.localdomain>
References: <20080423180900.24972.84015.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:13613 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753798AbYDWSXK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2008 14:23:10 -0400
In-Reply-To: <20080423180900.24972.84015.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wendy Xiong <wendyx@us.ibm.com>

To enable EEH support for pci-express network adapters, pcie/msi state
needs to be saved and restored for that adapter.

Tested this EEH patch with Intel 10G pci-express ixgbe adapter.

Signed-off-by: Wendy Xiong <wendyx@us.ibm.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index cb371a8..7b85922 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3431,6 +3431,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	}
 
 	pci_set_master(pdev);
+	pci_save_state(pdev);
 
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	netdev = alloc_etherdev_mq(sizeof(struct ixgbe_adapter), MAX_TX_QUEUES);
@@ -3721,6 +3722,7 @@ static pci_ers_result_t ixgbe_io_slot_reset(struct pci_dev *pdev)
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 	pci_set_master(pdev);
+	pci_restore_state(pdev);
 
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);


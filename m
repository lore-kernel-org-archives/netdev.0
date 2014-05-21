From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] i40e: Check PCI_IOV config to avoid compile error
Date: Wed, 21 May 2014 05:01:11 -0700
Message-ID: <1400673673-31626-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3720 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752461AbaEUMBq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 08:01:46 -0400
In-Reply-To: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The call to i40e_alloc_vfs needs to be wrapped in CONFIG_PCI_IOV because
the function itself is wrapped in the same conditional compile block.

Change-ID: I663c5f1b85e5cfba0b36da8966f7db1a034f408b
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e965cc5..0b34e8b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8368,6 +8368,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		}
 	}
 
+#ifdef CONFIG_PCI_IOV
 	/* prep for VF support */
 	if ((pf->flags & I40E_FLAG_SRIOV_ENABLED) &&
 	    (pf->flags & I40E_FLAG_MSIX_ENABLED) &&
@@ -8390,6 +8391,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 					 err);
 		}
 	}
+#endif /* CONFIG_PCI_IOV */
 
 	pfs_found++;
 
-- 
1.9.0

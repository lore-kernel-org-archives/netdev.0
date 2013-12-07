From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/14] i40e: Add a new variable to track number of pf instances
Date: Fri,  6 Dec 2013 18:17:23 -0800
Message-ID: <1386382643-29055-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:61597 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758203Ab3LGCRe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 21:17:34 -0500
In-Reply-To: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Track the number of physical functions (PFs) found, this is a global counter
on purpose so that each pf loaded has a unique ID.

Change-Id: I74d618520afbce4a774d0235449e3b5f97ff6d4a
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      | 2 ++
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ++++
 2 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 5aa2ea2..001d7cf 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -276,6 +276,8 @@ struct i40e_pf {
 	struct dentry *i40e_dbg_pf;
 #endif /* CONFIG_DEBUG_FS */
 
+	u16 instance; /* A unique number per i40e_pf instance in the system */
+
 	/* sr-iov config info */
 	struct i40e_vf *vf;
 	int num_alloc_vfs;	/* actual number of VFs allocated */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 08ac960..d2b48bb2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7176,6 +7176,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct i40e_driver_version dv;
 	struct i40e_pf *pf;
 	struct i40e_hw *hw;
+	static u16 pfs_found;
 	int err = 0;
 	u32 len;
 
@@ -7241,6 +7242,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	hw->subsystem_device_id = pdev->subsystem_device;
 	hw->bus.device = PCI_SLOT(pdev->devfn);
 	hw->bus.func = PCI_FUNC(pdev->devfn);
+	pf->instance = pfs_found;
 
 	/* do a special CORER for clearing PXE mode once at init */
 	if (hw->revision_id == 0 &&
@@ -7391,6 +7393,8 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		i40e_flush(hw);
 	}
 
+	pfs_found++;
+
 	i40e_dbg_pf_init(pf);
 
 	/* tell the firmware that we're starting */
-- 
1.8.3.1

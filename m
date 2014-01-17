From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [PATCH v6 net-next 1/2] ixgbe: define IXGBE_MAX_VFS_DRV_LIMIT macro and cleanup const 63
Date: Thu, 16 Jan 2014 19:41:04 -0800
Message-ID: <1389930065-3330-2-git-send-email-aaron.f.brown@intel.com>
References: <1389930065-3330-1-git-send-email-aaron.f.brown@intel.com>
Cc: "ethan.zhao" <ethan.zhao@oracle.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, ethan.kernel@gmail.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:30935 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750898AbaAQDlL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 22:41:11 -0500
In-Reply-To: <1389930065-3330-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "ethan.zhao" <ethan.zhao@oracle.com>

Because ixgbe driver limit the max number of VF
 functions could be enabled to 63, so define one macro IXGBE_MAX_VFS_DRV_LIMIT
 and cleanup the const 63 in code.

v3: revised for net-next tree.

Signed-off-by: Ethan Zhao <ethan.kernel@gmail.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h | 5 +++++
 3 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index b445ad1..3fd4d3f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5067,7 +5067,7 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 
 	/* assign number of SR-IOV VFs */
 	if (hw->mac.type != ixgbe_mac_82598EB) {
-		if (max_vfs > 63) {
+		if (max_vfs > IXGBE_MAX_VFS_DRV_LIMIT) {
 			adapter->num_vfs = 0;
 			e_dev_warn("max_vfs parameter out of range. Not assigning any SR-IOV VFs\n");
 		} else {
@@ -8020,7 +8020,7 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	ixgbe_init_mbx_params_pf(hw);
 	memcpy(&hw->mbx.ops, ii->mbx_ops, sizeof(hw->mbx.ops));
 	ixgbe_enable_sriov(adapter);
-	pci_sriov_set_totalvfs(pdev, 63);
+	pci_sriov_set_totalvfs(pdev, IXGBE_MAX_VFS_DRV_LIMIT);
 skip_sriov:
 
 #endif
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 0558c71..dff0977 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -148,7 +148,7 @@ void ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 		 * physical function.  If the user requests greater thn
 		 * 63 VFs then it is an error - reset to default of zero.
 		 */
-		adapter->num_vfs = min_t(unsigned int, adapter->num_vfs, 63);
+		adapter->num_vfs = min_t(unsigned int, adapter->num_vfs, IXGBE_MAX_VFS_DRV_LIMIT);
 
 		err = pci_enable_sriov(adapter->pdev, adapter->num_vfs);
 		if (err) {
@@ -257,7 +257,7 @@ static int ixgbe_pci_sriov_enable(struct pci_dev *dev, int num_vfs)
 	 * PF.  The PCI bus driver already checks for other values out of
 	 * range.
 	 */
-	if (num_vfs > 63) {
+	if (num_vfs > IXGBE_MAX_VFS_DRV_LIMIT) {
 		err = -EPERM;
 		goto err_out;
 	}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
index 4713f9f..8bd2919 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
@@ -28,6 +28,11 @@
 #ifndef _IXGBE_SRIOV_H_
 #define _IXGBE_SRIOV_H_
 
+/*  ixgbe driver limit the max number of VFs could be enabled to
+ *  63 (IXGBE_MAX_VF_FUNCTIONS - 1)
+ */
+#define IXGBE_MAX_VFS_DRV_LIMIT  (IXGBE_MAX_VF_FUNCTIONS - 1)
+
 void ixgbe_restore_vf_multicasts(struct ixgbe_adapter *adapter);
 void ixgbe_msg_task(struct ixgbe_adapter *adapter);
 int ixgbe_vf_configuration(struct pci_dev *pdev, unsigned int event_mask);
-- 
1.8.5.GIT

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/11] ixgbe: cleanup ixgbe_enumerate_functions
Date: Thu, 24 Oct 2013 08:27:33 -0700
Message-ID: <1382628458-26601-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1382628458-26601-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:12355 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755713Ab3JXP1s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Oct 2013 11:27:48 -0400
In-Reply-To: <1382628458-26601-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This function previously had the same check as used by the
ixgbe_pcie_from_parent. As the hardcode is due to the device having an internal
switch, this function should simply use the call from ixgbe_pcie_from_parent.
This reduces code complexity and makes it less likely a developer will forget
to update the list in the future.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 43b777a..6828d0e7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7362,19 +7362,16 @@ static const struct net_device_ops ixgbe_netdev_ops = {
  **/
 static inline int ixgbe_enumerate_functions(struct ixgbe_adapter *adapter)
 {
-	struct ixgbe_hw *hw = &adapter->hw;
 	struct list_head *entry;
 	int physfns = 0;
 
-	/* Some cards can not use the generic count PCIe functions method, and
-	 * so must be hardcoded to the correct value.
+	/* Some cards can not use the generic count PCIe functions method,
+	 * because they are behind a parent switch, so we hardcode these with
+	 * the correct number of functions.
 	 */
-	switch (hw->device_id) {
-	case IXGBE_DEV_ID_82599_SFP_SF_QP:
-	case IXGBE_DEV_ID_82599_QSFP_SF_QP:
+	if (ixgbe_pcie_from_parent(&adapter->hw)) {
 		physfns = 4;
-		break;
-	default:
+	} else {
 		list_for_each(entry, &adapter->pdev->bus_list) {
 			struct pci_dev *pdev =
 				list_entry(entry, struct pci_dev, bus_list);
-- 
1.8.3.1

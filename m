From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/11] ixgbe: use pcie_capability_read_word() to simplify code
Date: Thu, 24 Oct 2013 08:27:34 -0700
Message-ID: <1382628458-26601-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1382628458-26601-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yijing Wang <wangyijing@huawei.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:44781 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755715Ab3JXP1s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Oct 2013 11:27:48 -0400
In-Reply-To: <1382628458-26601-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yijing Wang <wangyijing@huawei.com>

use pcie_capability_read_word() to simplify code.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 6828d0e7..ce3eb60 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -153,7 +153,6 @@ MODULE_VERSION(DRV_VERSION);
 static int ixgbe_read_pci_cfg_word_parent(struct ixgbe_adapter *adapter,
 					  u32 reg, u16 *value)
 {
-	int pos = 0;
 	struct pci_dev *parent_dev;
 	struct pci_bus *parent_bus;
 
@@ -165,11 +164,10 @@ static int ixgbe_read_pci_cfg_word_parent(struct ixgbe_adapter *adapter,
 	if (!parent_dev)
 		return -1;
 
-	pos = pci_find_capability(parent_dev, PCI_CAP_ID_EXP);
-	if (!pos)
+	if (!pci_is_pcie(parent_dev))
 		return -1;
 
-	pci_read_config_word(parent_dev, pos + reg, value);
+	pcie_capability_read_word(parent_dev, reg, value);
 	return 0;
 }
 
-- 
1.8.3.1

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/6] igb: SR-IOV init reordering
Date: Tue, 26 Mar 2013 03:42:32 -0700
Message-ID: <1364294554-7967-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1364294554-7967-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alex Williamson <alex.williamson@redhat.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:39352 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759695Ab3CZKmj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 06:42:39 -0400
In-Reply-To: <1364294554-7967-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Williamson <alex.williamson@redhat.com>

igb is ineffective at setting a lower total VFs because:

int pci_sriov_set_totalvfs(struct pci_dev *dev, u16 numvfs)
{
        ...
        /* Shouldn't change if VFs already enabled */
        if (dev->sriov->ctrl & PCI_SRIOV_CTRL_VFE)
                return -EBUSY;

Swap init ordering.

Signed-off-by: Alex Williamson <alex.williamson@redhat.com>
Acked-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 2ae8886..8496adf 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2542,8 +2542,8 @@ static void igb_probe_vfs(struct igb_adapter *adapter)
 	if ((hw->mac.type == e1000_i210) || (hw->mac.type == e1000_i211))
 		return;
 
-	igb_enable_sriov(pdev, max_vfs);
 	pci_sriov_set_totalvfs(pdev, 7);
+	igb_enable_sriov(pdev, max_vfs);
 
 #endif /* CONFIG_PCI_IOV */
 }
-- 
1.7.11.7

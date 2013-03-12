From: Alex Williamson <alex.williamson@redhat.com>
Subject: [PATCH] igb: SR-IOV init reordering
Date: Tue, 12 Mar 2013 15:25:58 -0600
Message-ID: <20130312212533.19552.92159.stgit@bling.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ddutile@redhat.com,
	linux-kernel@vger.kernel.org, sassmann@redhat.com
To: gregory.v.rose@intel.com, jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

igb is ineffective at setting a lower total VFs because:

int pci_sriov_set_totalvfs(struct pci_dev *dev, u16 numvfs)
{
        ...
        /* Shouldn't change if VFs already enabled */
        if (dev->sriov->ctrl & PCI_SRIOV_CTRL_VFE)
                return -EBUSY;

Swap init ordering.

Signed-off-by: Alex Williamson <alex.williamson@redhat.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index d5b8289..ac65c39 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2546,8 +2546,8 @@ static void igb_probe_vfs(struct igb_adapter *adapter)
 	if ((hw->mac.type == e1000_i210) || (hw->mac.type == e1000_i211))
 		return;
 
-	igb_enable_sriov(pdev, max_vfs);
 	pci_sriov_set_totalvfs(pdev, 7);
+	igb_enable_sriov(pdev, max_vfs);
 
 #endif /* CONFIG_PCI_IOV */
 }

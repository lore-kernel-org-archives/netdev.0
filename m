From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 06/15] fm10k: prevent null pointer dereference of msix_entries table
Date: Tue,  5 Apr 2016 13:02:18 -0700
Message-ID: <1459886547-146445-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459886547-146445-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56328 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759865AbcDEUCb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 16:02:31 -0400
In-Reply-To: <1459886547-146445-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

According to the C standard dereferencing a variable before it is
checked invokes undefined behavior, and thus compilers are free to
assume the check for NULL isn't necessary. Prevent this by re-ordering
the NULL check of msix_entries in fm10k_free_mbx_irq.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 6190a81..8c23fb3d 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1143,14 +1143,16 @@ static irqreturn_t fm10k_msix_mbx_pf(int __always_unused irq, void *data)
 
 void fm10k_mbx_free_irq(struct fm10k_intfc *interface)
 {
-	struct msix_entry *entry = &interface->msix_entries[FM10K_MBX_VECTOR];
 	struct fm10k_hw *hw = &interface->hw;
+	struct msix_entry *entry;
 	int itr_reg;
 
 	/* no mailbox IRQ to free if MSI-X is not enabled */
 	if (!interface->msix_entries)
 		return;
 
+	entry = &interface->msix_entries[FM10K_MBX_VECTOR];
+
 	/* disconnect the mailbox */
 	hw->mbx.ops.disconnect(hw, &hw->mbx);
 
-- 
2.5.5

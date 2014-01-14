From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 2/6] i40e: associate VMDq queue with VM type
Date: Tue, 14 Jan 2014 00:49:50 -0800
Message-ID: <1389689394-22369-3-git-send-email-aaron.f.brown@intel.com>
References: <1389689394-22369-1-git-send-email-aaron.f.brown@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:37134 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751362AbaANItq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 03:49:46 -0500
In-Reply-To: <1389689394-22369-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Fix a bug where the queue was not associated with the right set-up
within the hardware.  The fix is to use the right QTX_CTL VSI type
when associating it to the VSI.

Change-ID: I65ef6c5a8205601c640a6593e4b7e78d6ba45545
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/Module.symvers | 0
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 5 ++++-
 drivers/net/ethernet/intel/i40e/i40e_type.h    | 1 +
 3 files changed, 5 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/intel/i40e/Module.symvers

diff --git a/drivers/net/ethernet/intel/i40e/Module.symvers b/drivers/net/ethernet/intel/i40e/Module.symvers
new file mode 100644
index 0000000..e69de29
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ad04da2..14e4f4a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2206,7 +2206,10 @@ static int i40e_configure_tx_ring(struct i40e_ring *ring)
 	}
 
 	/* Now associate this queue with this PCI function */
-	qtx_ctl = I40E_QTX_CTL_PF_QUEUE;
+	if (vsi->type == I40E_VSI_VMDQ2)
+		qtx_ctl = I40E_QTX_CTL_VM_QUEUE;
+	else
+		qtx_ctl = I40E_QTX_CTL_PF_QUEUE;
 	qtx_ctl |= ((hw->pf_id << I40E_QTX_CTL_PF_INDX_SHIFT) &
 		    I40E_QTX_CTL_PF_INDX_MASK);
 	wr32(hw, I40E_QTX_CTL(pf_q), qtx_ctl);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 80cf240..ccfc52d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -75,6 +75,7 @@ typedef void (*I40E_ADMINQ_CALLBACK)(struct i40e_hw *, struct i40e_aq_desc *);
 
 /* bitfields for Tx queue mapping in QTX_CTL */
 #define I40E_QTX_CTL_VF_QUEUE	0x0
+#define I40E_QTX_CTL_VM_QUEUE	0x1
 #define I40E_QTX_CTL_PF_QUEUE	0x2
 
 /* debug masks - set these bits in hw->debug_mask to control output */
-- 
1.8.5.GIT

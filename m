From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/11] i40e: configure VM ID in qtx_ctl
Date: Mon,  3 Nov 2014 06:56:38 -0800
Message-ID: <1415026599-16232-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1415026599-16232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Patrick Lu <patrick.lu@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44876 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752720AbaKCO44 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 09:56:56 -0500
In-Reply-To: <1415026599-16232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

We must insert the VSI ID in the QTX_CTL register when
configuring queues for VMDQ VSIs.

Change-ID: Iedfe36bd42ca0adc90a7cc2b7cf04795a98f4761
Reported-by: Marc Neustadter <marc.neustadter@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Patrick Lu <patrick.lu@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ea62267..1b0c437 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2462,10 +2462,14 @@ static int i40e_configure_tx_ring(struct i40e_ring *ring)
 	}
 
 	/* Now associate this queue with this PCI function */
-	if (vsi->type == I40E_VSI_VMDQ2)
+	if (vsi->type == I40E_VSI_VMDQ2) {
 		qtx_ctl = I40E_QTX_CTL_VM_QUEUE;
-	else
+		qtx_ctl |= ((vsi->id) << I40E_QTX_CTL_VFVM_INDX_SHIFT) &
+			   I40E_QTX_CTL_VFVM_INDX_MASK;
+	} else {
 		qtx_ctl = I40E_QTX_CTL_PF_QUEUE;
+	}
+
 	qtx_ctl |= ((hw->pf_id << I40E_QTX_CTL_PF_INDX_SHIFT) &
 		    I40E_QTX_CTL_PF_INDX_MASK);
 	wr32(hw, I40E_QTX_CTL(pf_q), qtx_ctl);
-- 
1.9.3

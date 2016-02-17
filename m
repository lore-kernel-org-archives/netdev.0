From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40e: drop unused function
Date: Wed, 17 Feb 2016 09:51:40 -0800
Message-ID: <1455731506-62165-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17063 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161628AbcBQRvv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 12:51:51 -0500
In-Reply-To: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Delete the unused irq_dynamic_disable function.

Change-ID: Ia46071066babd121c7c90f141b6210b00078de3f
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Reviewed-by: Anjali Singhai <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  1 -
 drivers/net/ethernet/intel/i40e/i40e_main.c | 16 ----------------
 2 files changed, 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 175bec3..65cf344 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -757,7 +757,6 @@ static inline void i40e_irq_dynamic_enable(struct i40e_vsi *vsi, int vector)
 	/* skip the flush */
 }
 
-void i40e_irq_dynamic_disable(struct i40e_vsi *vsi, int vector);
 void i40e_irq_dynamic_disable_icr0(struct i40e_pf *pf);
 void i40e_irq_dynamic_enable_icr0(struct i40e_pf *pf);
 #ifdef I40E_FCOE
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e147db2..38fd942 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3273,22 +3273,6 @@ void i40e_irq_dynamic_enable_icr0(struct i40e_pf *pf)
 }
 
 /**
- * i40e_irq_dynamic_disable - Disable default interrupt generation settings
- * @vsi: pointer to a vsi
- * @vector: disable a particular Hw Interrupt vector
- **/
-void i40e_irq_dynamic_disable(struct i40e_vsi *vsi, int vector)
-{
-	struct i40e_pf *pf = vsi->back;
-	struct i40e_hw *hw = &pf->hw;
-	u32 val;
-
-	val = I40E_ITR_NONE << I40E_PFINT_DYN_CTLN_ITR_INDX_SHIFT;
-	wr32(hw, I40E_PFINT_DYN_CTLN(vector - 1), val);
-	i40e_flush(hw);
-}
-
-/**
  * i40e_msix_clean_rings - MSIX mode Interrupt Handler
  * @irq: interrupt number
  * @data: pointer to a q_vector
-- 
2.5.0

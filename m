From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/16] i40evf: Use the correct defines to match the VF registers
Date: Wed, 19 Aug 2015 17:58:01 -0700
Message-ID: <1440032286-30054-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1440032286-30054-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10447 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752104AbbHTA6L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 20:58:11 -0400
In-Reply-To: <1440032286-30054-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Use CTLN1 instead of CTLN for the VF relative register space.

Change-ID: Iefba63faf0307af55fec8dbb64f26059f7d91318
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c   | 28 +++++++++---------
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 38 ++++++++++++-------------
 2 files changed, 33 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 7309479..7e91d82 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1293,17 +1293,17 @@ static inline void i40e_update_enable_itr(struct i40e_vsi *vsi,
 		old_itr = q_vector->rx.itr;
 		i40e_set_new_dynamic_itr(&q_vector->rx);
 		if (old_itr != q_vector->rx.itr) {
-			val = I40E_VFINT_DYN_CTLN_INTENA_MASK |
-			I40E_VFINT_DYN_CTLN_CLEARPBA_MASK |
+			val = I40E_VFINT_DYN_CTLN1_INTENA_MASK |
+			I40E_VFINT_DYN_CTLN1_CLEARPBA_MASK |
 			(I40E_RX_ITR <<
-				I40E_VFINT_DYN_CTLN_ITR_INDX_SHIFT) |
+				I40E_VFINT_DYN_CTLN1_ITR_INDX_SHIFT) |
 			(q_vector->rx.itr <<
-				I40E_VFINT_DYN_CTLN_INTERVAL_SHIFT);
+				I40E_VFINT_DYN_CTLN1_INTERVAL_SHIFT);
 		} else {
-			val = I40E_VFINT_DYN_CTLN_INTENA_MASK |
-			I40E_VFINT_DYN_CTLN_CLEARPBA_MASK |
+			val = I40E_VFINT_DYN_CTLN1_INTENA_MASK |
+			I40E_VFINT_DYN_CTLN1_CLEARPBA_MASK |
 			(I40E_ITR_NONE <<
-				I40E_VFINT_DYN_CTLN_ITR_INDX_SHIFT);
+				I40E_VFINT_DYN_CTLN1_ITR_INDX_SHIFT);
 		}
 		if (!test_bit(__I40E_DOWN, &vsi->state))
 			wr32(hw, I40E_VFINT_DYN_CTLN1(vector - 1), val);
@@ -1315,18 +1315,18 @@ static inline void i40e_update_enable_itr(struct i40e_vsi *vsi,
 		old_itr = q_vector->tx.itr;
 		i40e_set_new_dynamic_itr(&q_vector->tx);
 		if (old_itr != q_vector->tx.itr) {
-			val = I40E_VFINT_DYN_CTLN_INTENA_MASK |
-				I40E_VFINT_DYN_CTLN_CLEARPBA_MASK |
+			val = I40E_VFINT_DYN_CTLN1_INTENA_MASK |
+				I40E_VFINT_DYN_CTLN1_CLEARPBA_MASK |
 				(I40E_TX_ITR <<
-				   I40E_VFINT_DYN_CTLN_ITR_INDX_SHIFT) |
+				   I40E_VFINT_DYN_CTLN1_ITR_INDX_SHIFT) |
 				(q_vector->tx.itr <<
-				   I40E_VFINT_DYN_CTLN_INTERVAL_SHIFT);
+				   I40E_VFINT_DYN_CTLN1_INTERVAL_SHIFT);
 
 		} else {
-			val = I40E_VFINT_DYN_CTLN_INTENA_MASK |
-				I40E_VFINT_DYN_CTLN_CLEARPBA_MASK |
+			val = I40E_VFINT_DYN_CTLN1_INTENA_MASK |
+				I40E_VFINT_DYN_CTLN1_CLEARPBA_MASK |
 				(I40E_ITR_NONE <<
-				   I40E_VFINT_DYN_CTLN_ITR_INDX_SHIFT);
+				   I40E_VFINT_DYN_CTLN1_ITR_INDX_SHIFT);
 		}
 		if (!test_bit(__I40E_DOWN, &vsi->state))
 			wr32(hw, I40E_VFINT_DYN_CTLN1(vector - 1), val);
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 4f3f603..956affb 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -126,7 +126,7 @@ static void i40evf_misc_irq_enable(struct i40evf_adapter *adapter)
 
 	wr32(hw, I40E_VFINT_DYN_CTL01, I40E_VFINT_DYN_CTL01_INTENA_MASK |
 				       I40E_VFINT_DYN_CTL01_ITR_INDX_MASK);
-	wr32(hw, I40E_VFINT_ICR0_ENA1, I40E_VFINT_ICR0_ENA_ADMINQ_MASK);
+	wr32(hw, I40E_VFINT_ICR0_ENA1, I40E_VFINT_ICR0_ENA1_ADMINQ_MASK);
 
 	/* read flush */
 	rd32(hw, I40E_VFGEN_RSTAT);
@@ -167,7 +167,7 @@ void i40evf_irq_enable_queues(struct i40evf_adapter *adapter, u32 mask)
 			wr32(hw, I40E_VFINT_DYN_CTLN1(i - 1),
 			     I40E_VFINT_DYN_CTLN1_INTENA_MASK |
 			     I40E_VFINT_DYN_CTLN1_ITR_INDX_MASK |
-			     I40E_VFINT_DYN_CTLN_CLEARPBA_MASK);
+			     I40E_VFINT_DYN_CTLN1_CLEARPBA_MASK);
 		}
 	}
 }
@@ -185,17 +185,17 @@ static void i40evf_fire_sw_int(struct i40evf_adapter *adapter, u32 mask)
 
 	if (mask & 1) {
 		dyn_ctl = rd32(hw, I40E_VFINT_DYN_CTL01);
-		dyn_ctl |= I40E_VFINT_DYN_CTLN_SWINT_TRIG_MASK |
+		dyn_ctl |= I40E_VFINT_DYN_CTLN1_SWINT_TRIG_MASK |
 			   I40E_VFINT_DYN_CTLN1_ITR_INDX_MASK |
-			   I40E_VFINT_DYN_CTLN_CLEARPBA_MASK;
+			   I40E_VFINT_DYN_CTLN1_CLEARPBA_MASK;
 		wr32(hw, I40E_VFINT_DYN_CTL01, dyn_ctl);
 	}
 	for (i = 1; i < adapter->num_msix_vectors; i++) {
 		if (mask & BIT(i)) {
 			dyn_ctl = rd32(hw, I40E_VFINT_DYN_CTLN1(i - 1));
-			dyn_ctl |= I40E_VFINT_DYN_CTLN_SWINT_TRIG_MASK |
+			dyn_ctl |= I40E_VFINT_DYN_CTLN1_SWINT_TRIG_MASK |
 				   I40E_VFINT_DYN_CTLN1_ITR_INDX_MASK |
-				   I40E_VFINT_DYN_CTLN_CLEARPBA_MASK;
+				   I40E_VFINT_DYN_CTLN1_CLEARPBA_MASK;
 			wr32(hw, I40E_VFINT_DYN_CTLN1(i - 1), dyn_ctl);
 		}
 	}
@@ -235,7 +235,7 @@ static irqreturn_t i40evf_msix_aq(int irq, void *data)
 
 
 	val = rd32(hw, I40E_VFINT_DYN_CTL01);
-	val = val | I40E_PFINT_DYN_CTL0_CLEARPBA_MASK;
+	val = val | I40E_VFINT_DYN_CTL01_CLEARPBA_MASK;
 	wr32(hw, I40E_VFINT_DYN_CTL01, val);
 
 	/* schedule work on the private workqueue */
@@ -1701,34 +1701,34 @@ static void i40evf_adminq_task(struct work_struct *work)
 	/* check for error indications */
 	val = rd32(hw, hw->aq.arq.len);
 	oldval = val;
-	if (val & I40E_VF_ARQLEN_ARQVFE_MASK) {
+	if (val & I40E_VF_ARQLEN1_ARQVFE_MASK) {
 		dev_info(&adapter->pdev->dev, "ARQ VF Error detected\n");
-		val &= ~I40E_VF_ARQLEN_ARQVFE_MASK;
+		val &= ~I40E_VF_ARQLEN1_ARQVFE_MASK;
 	}
-	if (val & I40E_VF_ARQLEN_ARQOVFL_MASK) {
+	if (val & I40E_VF_ARQLEN1_ARQOVFL_MASK) {
 		dev_info(&adapter->pdev->dev, "ARQ Overflow Error detected\n");
-		val &= ~I40E_VF_ARQLEN_ARQOVFL_MASK;
+		val &= ~I40E_VF_ARQLEN1_ARQOVFL_MASK;
 	}
-	if (val & I40E_VF_ARQLEN_ARQCRIT_MASK) {
+	if (val & I40E_VF_ARQLEN1_ARQCRIT_MASK) {
 		dev_info(&adapter->pdev->dev, "ARQ Critical Error detected\n");
-		val &= ~I40E_VF_ARQLEN_ARQCRIT_MASK;
+		val &= ~I40E_VF_ARQLEN1_ARQCRIT_MASK;
 	}
 	if (oldval != val)
 		wr32(hw, hw->aq.arq.len, val);
 
 	val = rd32(hw, hw->aq.asq.len);
 	oldval = val;
-	if (val & I40E_VF_ATQLEN_ATQVFE_MASK) {
+	if (val & I40E_VF_ATQLEN1_ATQVFE_MASK) {
 		dev_info(&adapter->pdev->dev, "ASQ VF Error detected\n");
-		val &= ~I40E_VF_ATQLEN_ATQVFE_MASK;
+		val &= ~I40E_VF_ATQLEN1_ATQVFE_MASK;
 	}
-	if (val & I40E_VF_ATQLEN_ATQOVFL_MASK) {
+	if (val & I40E_VF_ATQLEN1_ATQOVFL_MASK) {
 		dev_info(&adapter->pdev->dev, "ASQ Overflow Error detected\n");
-		val &= ~I40E_VF_ATQLEN_ATQOVFL_MASK;
+		val &= ~I40E_VF_ATQLEN1_ATQOVFL_MASK;
 	}
-	if (val & I40E_VF_ATQLEN_ATQCRIT_MASK) {
+	if (val & I40E_VF_ATQLEN1_ATQCRIT_MASK) {
 		dev_info(&adapter->pdev->dev, "ASQ Critical Error detected\n");
-		val &= ~I40E_VF_ATQLEN_ATQCRIT_MASK;
+		val &= ~I40E_VF_ATQLEN1_ATQCRIT_MASK;
 	}
 	if (oldval != val)
 		wr32(hw, hw->aq.asq.len, val);
-- 
2.4.3

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] i40e: trigger SW INT with no ITR wait
Date: Tue, 18 Nov 2014 20:10:56 -0800
Message-ID: <1416370256-16834-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416370256-16834-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58731 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754598AbaKSELM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2014 23:11:12 -0500
In-Reply-To: <1416370256-16834-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Since we want the SW INT to go off as soon as possible, write the
extra bits that will turn off the ITR wait for the interrupt.

Change-ID: I6d5382ba60840fa32abb7dea17c839eb4b5f68f7
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |  5 ++++-
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 10 ++++++++--
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index bb1698a..b2402851 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1400,7 +1400,10 @@ static int i40e_intr_test(struct net_device *netdev, u64 *data)
 	netif_info(pf, hw, netdev, "interrupt test\n");
 	wr32(&pf->hw, I40E_PFINT_DYN_CTL0,
 	     (I40E_PFINT_DYN_CTL0_INTENA_MASK |
-	      I40E_PFINT_DYN_CTL0_SWINT_TRIG_MASK));
+	      I40E_PFINT_DYN_CTL0_SWINT_TRIG_MASK |
+	      I40E_PFINT_DYN_CTL0_ITR_INDX_MASK |
+	      I40E_PFINT_DYN_CTL0_SW_ITR_INDX_ENA_MASK |
+	      I40E_PFINT_DYN_CTL0_SW_ITR_INDX_MASK));
 	usleep_range(1000, 2000);
 	*data = (swc_old == pf->sw_int_count);
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 3ebab03..3913329 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5565,11 +5565,17 @@ static void i40e_check_hang_subtask(struct i40e_pf *pf)
 			if (!(pf->flags & I40E_FLAG_MSIX_ENABLED)) {
 				wr32(&vsi->back->hw, I40E_PFINT_DYN_CTL0,
 				     (I40E_PFINT_DYN_CTL0_INTENA_MASK |
-				      I40E_PFINT_DYN_CTL0_SWINT_TRIG_MASK));
+				      I40E_PFINT_DYN_CTL0_SWINT_TRIG_MASK |
+				      I40E_PFINT_DYN_CTL0_ITR_INDX_MASK |
+				      I40E_PFINT_DYN_CTL0_SW_ITR_INDX_ENA_MASK |
+				      I40E_PFINT_DYN_CTL0_SW_ITR_INDX_MASK));
 			} else {
 				u16 vec = vsi->base_vector - 1;
 				u32 val = (I40E_PFINT_DYN_CTLN_INTENA_MASK |
-					   I40E_PFINT_DYN_CTLN_SWINT_TRIG_MASK);
+				      I40E_PFINT_DYN_CTLN_SWINT_TRIG_MASK |
+				      I40E_PFINT_DYN_CTLN_ITR_INDX_MASK |
+				      I40E_PFINT_DYN_CTLN_SW_ITR_INDX_ENA_MASK |
+				      I40E_PFINT_DYN_CTLN_SW_ITR_INDX_MASK);
 				for (i = 0; i < vsi->num_q_vectors; i++, vec++)
 					wr32(&vsi->back->hw,
 					     I40E_PFINT_DYN_CTLN(vec), val);
-- 
1.9.3

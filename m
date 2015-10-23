From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/17] i40evf: clean up local variable initialization
Date: Fri, 23 Oct 2015 06:17:54 -0700
Message-ID: <1445606279-19345-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jean Sacren <sakiwit@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42466 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750892AbbJWNSE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 09:18:04 -0400
In-Reply-To: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>

In i40evf_msix_aq(), the first two lines of rd32() are mainly to clear
the registers. If we initialize 'val' at this point, it will be
overwritten immediately. We shall simply discard the return value here.

When we initialize 'val', we might as well include the mask in one step.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index f358366..d962164 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -306,15 +306,14 @@ static irqreturn_t i40evf_msix_aq(int irq, void *data)
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
 	struct i40e_hw *hw = &adapter->hw;
 	u32 val;
-	u32 ena_mask;
 
 	/* handle non-queue interrupts */
-	val = rd32(hw, I40E_VFINT_ICR01);
-	ena_mask = rd32(hw, I40E_VFINT_ICR0_ENA1);
+	rd32(hw, I40E_VFINT_ICR01);
+	rd32(hw, I40E_VFINT_ICR0_ENA1);
 
 
-	val = rd32(hw, I40E_VFINT_DYN_CTL01);
-	val = val | I40E_VFINT_DYN_CTL01_CLEARPBA_MASK;
+	val = rd32(hw, I40E_VFINT_DYN_CTL01) |
+	      I40E_VFINT_DYN_CTL01_CLEARPBA_MASK;
 	wr32(hw, I40E_VFINT_DYN_CTL01, val);
 
 	/* schedule work on the private workqueue */
-- 
2.4.3

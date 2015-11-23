From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40evf: fix compiler warning of unused variable
Date: Mon, 23 Nov 2015 11:36:13 -0800
Message-ID: <1448307376-20063-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:41412 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754851AbbKWTgZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 14:36:25 -0500
In-Reply-To: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Compiler complained of an unused variable, which the driver was just
using to store the result of a rd32 which is used to clear a register
unconditionally.  Just drop the unused variable and re-use one.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index d962164..6ad6265 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -307,10 +307,9 @@ static irqreturn_t i40evf_msix_aq(int irq, void *data)
 	struct i40e_hw *hw = &adapter->hw;
 	u32 val;
 
-	/* handle non-queue interrupts */
-	rd32(hw, I40E_VFINT_ICR01);
-	rd32(hw, I40E_VFINT_ICR0_ENA1);
-
+	/* handle non-queue interrupts, these reads clear the registers */
+	val = rd32(hw, I40E_VFINT_ICR01);
+	val = rd32(hw, I40E_VFINT_ICR0_ENA1);
 
 	val = rd32(hw, I40E_VFINT_DYN_CTL01) |
 	      I40E_VFINT_DYN_CTL01_CLEARPBA_MASK;
-- 
2.5.0

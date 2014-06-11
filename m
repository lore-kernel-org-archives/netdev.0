From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] i40e: use stored base_queue value
Date: Wed, 11 Jun 2014 09:33:23 -0700
Message-ID: <1402504404-8954-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402504404-8954-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55595 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932438AbaFKQdf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 12:33:35 -0400
In-Reply-To: <1402504404-8954-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

No need to read the PCI register for the PF's base queue on every single Tx
queue enable and disable as we already have the value stored from reading
the capability features at startup.

Change-ID: Ic02fb622757742f43cb8269369c3d972d4f66555
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 8e4b33c..6e65f19 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -665,10 +665,9 @@ i40e_status i40e_get_mac_addr(struct i40e_hw *hw, u8 *mac_addr)
  **/
 void i40e_pre_tx_queue_cfg(struct i40e_hw *hw, u32 queue, bool enable)
 {
-	u32 reg_val = rd32(hw, I40E_PFLAN_QALLOC);
-	u32 first_queue = (reg_val & I40E_PFLAN_QALLOC_FIRSTQ_MASK);
-	u32 abs_queue_idx = first_queue + queue;
+	u32 abs_queue_idx = hw->func_caps.base_queue + queue;
 	u32 reg_block = 0;
+	u32 reg_val;
 
 	if (abs_queue_idx >= 128)
 		reg_block = abs_queue_idx / 128;
-- 
1.9.3

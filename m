From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/14] i40e: limit GLLAN_TXPRE_QDIS to QINDX 0-127
Date: Tue,  1 Jul 2014 04:35:06 -0700
Message-ID: <1404214511-26868-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1404214511-26868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Christopher Pau <christopher.pau@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7330 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757811AbaGALfS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2014 07:35:18 -0400
In-Reply-To: <1404214511-26868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christopher Pau <christopher.pau@intel.com>

Prevent writing to reserved bits, queue index is 0-127

Change-ID: Ic923e1c92012a265983414acd8f547c4bdac2e34
Signed-off-by: Christopher Pau <christopher.pau@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 8305c8a..9d09ab3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -669,8 +669,10 @@ void i40e_pre_tx_queue_cfg(struct i40e_hw *hw, u32 queue, bool enable)
 	u32 reg_block = 0;
 	u32 reg_val;
 
-	if (abs_queue_idx >= 128)
+	if (abs_queue_idx >= 128) {
 		reg_block = abs_queue_idx / 128;
+		abs_queue_idx %= 128;
+	}
 
 	reg_val = rd32(hw, I40E_GLLAN_TXPRE_QDIS(reg_block));
 	reg_val &= ~I40E_GLLAN_TXPRE_QDIS_QINDX_MASK;
-- 
1.9.3

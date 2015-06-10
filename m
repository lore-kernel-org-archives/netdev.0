From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 18/18] ixgbe: Remember to write ixfi changes after modifying
Date: Tue,  9 Jun 2015 18:10:29 -0700
Message-ID: <1433898629-76729-19-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:59836 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754128AbbFJBLB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 21:11:01 -0400
In-Reply-To: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch corrects a bug in ixgbe_setup_ixfi_x550em where we were
reading and modifying IXGBE_KRM_LINK_CTRL_1 but forgot to write the
results back.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index bb1439c..7581da1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -795,7 +795,7 @@ static s32 ixgbe_setup_ixfi_x550em(struct ixgbe_hw *hw, ixgbe_link_speed *speed)
 	}
 
 	status = ixgbe_write_iosf_sb_reg_x550(hw,
-				IXGBE_KRM_RX_TRN_LINKUP_CTRL(hw->bus.lan_id),
+				IXGBE_KRM_LINK_CTRL_1(hw->bus.lan_id),
 				IXGBE_SB_IOSF_TARGET_KR_PHY, reg_val);
 	if (status)
 		return status;
-- 
2.4.2

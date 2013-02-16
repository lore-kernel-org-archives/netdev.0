From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] ixgbe: fix possible data corruption in read_i2c_byte
Date: Sat, 16 Feb 2013 00:33:32 -0800
Message-ID: <1361003616-3422-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:21658 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752490Ab3BPIds (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Feb 2013 03:33:48 -0500
In-Reply-To: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch makes sure that the SW lock is released after all i2c
operations complete in the retry code path.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index eb534a0..d7b5bd0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -1307,9 +1307,9 @@ s32 ixgbe_read_i2c_byte_generic(struct ixgbe_hw *hw, u8 byte_offset,
 		break;
 
 fail:
+		ixgbe_i2c_bus_clear(hw);
 		hw->mac.ops.release_swfw_sync(hw, swfw_mask);
 		msleep(100);
-		ixgbe_i2c_bus_clear(hw);
 		retry++;
 		if (retry < max_retry)
 			hw_dbg(hw, "I2C byte read error - Retrying.\n");
-- 
1.7.11.7

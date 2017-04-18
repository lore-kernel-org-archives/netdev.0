From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] ixgbe: add check for VETO bit when configuring link for KR
Date: Tue, 18 Apr 2017 16:02:03 -0700
Message-ID: <20170418230205.37223-14-jeffrey.t.kirsher@intel.com>
References: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:58032 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757689AbdDRXCQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 19:02:16 -0400
In-Reply-To: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

We did not have a check in place for MMNGC.MNG_VETO when setting up link
on X550EM_X KR devices which resulted in link loss for the BMC when
loading the driver.

This patch adds a check for ixgbe_check_reset_blocked() in setup_link()
since in that case there is no PHY reset function.

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 04d6c744b936..2658394599e4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -2526,6 +2526,9 @@ static s32 ixgbe_setup_kr_x550em(struct ixgbe_hw *hw)
 	if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_2_5GB_FULL)
 		return 0;
 
+	if (ixgbe_check_reset_blocked(hw))
+		return 0;
+
 	return ixgbe_setup_kr_speed_x550em(hw, hw->phy.autoneg_advertised);
 }
 
-- 
2.12.2

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/18] ixgbe: Update ixgbe_disable_pcie_master flow for X550*
Date: Wed, 23 Sep 2015 23:59:35 -0700
Message-ID: <1443077981-55791-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443077981-55791-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31471 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932721AbbIXG76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 02:59:58 -0400
In-Reply-To: <1443077981-55791-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

This patch skips the PCI transactions pending check in
ixgbe_disable_pcie_master. This is done to addresses a known HW
issue where the PCI transactions pending bit sticks high when there
are pending transactions. HW engineering instructed to workaround
this issue by wait and then continue with our reset flow.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 2cd0c3a..b620d7a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -2476,6 +2476,9 @@ static s32 ixgbe_disable_pcie_master(struct ixgbe_hw *hw)
 	hw_dbg(hw, "GIO Master Disable bit didn't clear - requesting resets\n");
 	hw->mac.flags |= IXGBE_FLAGS_DOUBLE_RESET_REQUIRED;
 
+	if (hw->mac.type >= ixgbe_mac_X550)
+		return 0;
+
 	/*
 	 * Before proceeding, make sure that the PCIe block does not have
 	 * transactions pending.
-- 
2.4.3

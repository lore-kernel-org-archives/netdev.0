From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 20/24] ixgbe: store permanent address before initializing Rx addresses
Date: Thu,  3 Mar 2011 05:03:45 -0800
Message-ID: <1299157429-15878-21-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34597 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758214Ab1CCNEZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 08:04:25 -0500
In-Reply-To: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

We were reading the address after it had been initialized and this results
in the permanent address on the system being changed.  This change corrects
that by storing the address before we re-initialize it.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82598.c |    6 +++---
 drivers/net/ixgbe/ixgbe_82599.c |    6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 8f5e347..8f6205e 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -831,15 +831,15 @@ mac_reset_top:
 		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, hw->mac.orig_autoc);
 	}
 
+	/* Store the permanent mac address */
+	hw->mac.ops.get_mac_addr(hw, hw->mac.perm_addr);
+
 	/*
 	 * Store MAC address from RAR0, clear receive address registers, and
 	 * clear the multicast table
 	 */
 	hw->mac.ops.init_rx_addrs(hw);
 
-	/* Store the permanent mac address */
-	hw->mac.ops.get_mac_addr(hw, hw->mac.perm_addr);
-
 reset_hw_out:
 	if (phy_status)
 		status = phy_status;
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 5e2edcd..3d40e68 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -965,6 +965,9 @@ mac_reset_top:
 		}
 	}
 
+	/* Store the permanent mac address */
+	hw->mac.ops.get_mac_addr(hw, hw->mac.perm_addr);
+
 	/*
 	 * Store MAC address from RAR0, clear receive address registers, and
 	 * clear the multicast table.  Also reset num_rar_entries to 128,
@@ -973,9 +976,6 @@ mac_reset_top:
 	hw->mac.num_rar_entries = 128;
 	hw->mac.ops.init_rx_addrs(hw);
 
-	/* Store the permanent mac address */
-	hw->mac.ops.get_mac_addr(hw, hw->mac.perm_addr);
-
 	/* Store the permanent SAN mac address */
 	hw->mac.ops.get_san_mac_addr(hw, hw->mac.san_addr);
 
-- 
1.7.4


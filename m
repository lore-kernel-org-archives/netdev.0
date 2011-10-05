From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/10] ixgbe: do not disable flow control in ixgbe_check_mac_link
Date: Wed,  5 Oct 2011 03:20:22 -0700
Message-ID: <1317810024-20846-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317810024-20846-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:52400 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934290Ab1JEKUd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Oct 2011 06:20:33 -0400
In-Reply-To: <1317810024-20846-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Disabling flow control in ixgbe_check_mac_link() results in incorrect
reporting by ethtool when link goes down, so remove it.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c  |    5 -----
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |    6 ------
 2 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index fa079bb..56c32dc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -650,11 +650,6 @@ static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw,
 	    (ixgbe_validate_link_ready(hw) != 0))
 		*link_up = false;
 
-	/* if link is down, zero out the current_mode */
-	if (*link_up == false) {
-		hw->fc.current_mode = ixgbe_fc_none;
-		hw->fc.fc_was_autonegged = false;
-	}
 out:
 	return 0;
 }
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 59cd54c..35fa444 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -3095,12 +3095,6 @@ s32 ixgbe_check_mac_link_generic(struct ixgbe_hw *hw, ixgbe_link_speed *speed,
 	else
 		*speed = IXGBE_LINK_SPEED_UNKNOWN;
 
-	/* if link is down, zero out the current_mode */
-	if (*link_up == false) {
-		hw->fc.current_mode = ixgbe_fc_none;
-		hw->fc.fc_was_autonegged = false;
-	}
-
 	return 0;
 }
 
-- 
1.7.6.4

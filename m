From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/11] ixgbe: do not disable flow control in ixgbe_check_mac_link
Date: Thu, 29 Sep 2011 22:24:48 -0700
Message-ID: <1317360291-5576-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317360291-5576-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:2856 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753808Ab1I3FY7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Sep 2011 01:24:59 -0400
In-Reply-To: <1317360291-5576-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
1.7.6.2

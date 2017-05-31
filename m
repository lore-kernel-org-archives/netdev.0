From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] ixgbe: always call setup_mac_link for multispeed fiber
Date: Wed, 31 May 2017 14:19:34 -0700
Message-ID: <20170531211936.63417-14-jeffrey.t.kirsher@intel.com>
References: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:17444 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751216AbdEaVTz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 17:19:55 -0400
In-Reply-To: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Remove the logic which would previously skip the link configuration
in the case where we are already at the requested speed in
ixgbe_setup_mac_link_multispeed_fiber().

By exiting early we are skipping the link configuration and as such
the driver may not always configure the PHY correctly for SFP+.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 18 ------------------
 1 file changed, 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 76ad0e0bd542..7af85f505bad 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -4121,15 +4121,6 @@ s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
 		speedcnt++;
 		highest_link_speed = IXGBE_LINK_SPEED_10GB_FULL;
 
-		/* If we already have link at this speed, just jump out */
-		status = hw->mac.ops.check_link(hw, &link_speed, &link_up,
-						false);
-		if (status)
-			return status;
-
-		if (link_speed == IXGBE_LINK_SPEED_10GB_FULL && link_up)
-			goto out;
-
 		/* Set the module link speed */
 		switch (hw->phy.media_type) {
 		case ixgbe_media_type_fiber:
@@ -4181,15 +4172,6 @@ s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
 		if (highest_link_speed == IXGBE_LINK_SPEED_UNKNOWN)
 			highest_link_speed = IXGBE_LINK_SPEED_1GB_FULL;
 
-		/* If we already have link at this speed, just jump out */
-		status = hw->mac.ops.check_link(hw, &link_speed, &link_up,
-						false);
-		if (status)
-			return status;
-
-		if (link_speed == IXGBE_LINK_SPEED_1GB_FULL && link_up)
-			goto out;
-
 		/* Set the module link speed */
 		switch (hw->phy.media_type) {
 		case ixgbe_media_type_fiber:
-- 
2.12.2

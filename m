From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 18/24] ixgbe: Specific check for 100 Full link speed
Date: Thu,  3 Mar 2011 05:03:43 -0800
Message-ID: <1299157429-15878-19-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34597 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758212Ab1CCNEZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 08:04:25 -0500
In-Reply-To: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch specifically checks for 100 Full link speed instead of
assuming we are linked at 100 if not linked at 10G and 1G.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_common.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 4fa195e..a12f7c7 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -2658,10 +2658,13 @@ s32 ixgbe_check_mac_link_generic(struct ixgbe_hw *hw, ixgbe_link_speed *speed,
 	    IXGBE_LINKS_SPEED_10G_82599)
 		*speed = IXGBE_LINK_SPEED_10GB_FULL;
 	else if ((links_reg & IXGBE_LINKS_SPEED_82599) ==
-	         IXGBE_LINKS_SPEED_1G_82599)
+		 IXGBE_LINKS_SPEED_1G_82599)
 		*speed = IXGBE_LINK_SPEED_1GB_FULL;
-	else
+	else if ((links_reg & IXGBE_LINKS_SPEED_82599) ==
+		 IXGBE_LINKS_SPEED_100_82599)
 		*speed = IXGBE_LINK_SPEED_100_FULL;
+	else
+		*speed = IXGBE_LINK_SPEED_UNKNOWN;
 
 	/* if link is down, zero out the current_mode */
 	if (*link_up == false) {
-- 
1.7.4


From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 21/24] ixgbe: explicitly disable 100H for x540
Date: Wed, 13 Apr 2011 18:02:17 -0700
Message-ID: <1302742940-22141-22-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:26341 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758246Ab1DNBCm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:02:42 -0400
In-Reply-To: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

100H is not supported on this HW, but the bit is set on the PHY.
This can result in link at 100F when advertising only 1000F.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_phy.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index 31cc29e..fd381ea 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -449,7 +449,8 @@ s32 ixgbe_setup_phy_link_generic(struct ixgbe_hw *hw)
 				     MDIO_MMD_AN,
 				     &autoneg_reg);
 
-		autoneg_reg &= ~ADVERTISE_100FULL;
+		autoneg_reg &= ~(ADVERTISE_100FULL |
+				 ADVERTISE_100HALF);
 		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_100_FULL)
 			autoneg_reg |= ADVERTISE_100FULL;
 
-- 
1.7.4.2


From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/10] ixgbe: Use MDIO_PRTAD_NONE consistently
Date: Fri, 23 Sep 2016 00:51:39 -0700
Message-ID: <1474617103-59530-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474617103-59530-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:6929 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757585AbcIWHvr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 03:51:47 -0400
In-Reply-To: <1474617103-59530-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

The value MDIO_PRTAD_NONE should be used to indicate no PHY address.
Not 0, not 0xFFFF. Use the MDIO_PRTAD_NONE value consistently.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c  | 4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index db0731e..021ab9b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -346,8 +346,8 @@ s32 ixgbe_identify_phy_generic(struct ixgbe_hw *hw)
 				return 0;
 			}
 		}
-		/* clear value if nothing found */
-		hw->phy.mdio.prtad = 0;
+		/* indicate no PHY found */
+		hw->phy.mdio.prtad = MDIO_PRTAD_NONE;
 		return IXGBE_ERR_PHY_ADDR_INVALID;
 	}
 	return 0;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index cd22efb..7e6b926 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -1459,7 +1459,7 @@ ixgbe_setup_mac_link_sfp_x550a(struct ixgbe_hw *hw, ixgbe_link_speed speed,
 	/* Configure internal PHY for KR/KX. */
 	ixgbe_setup_kr_speed_x550em(hw, speed);
 
-	if (!hw->phy.mdio.prtad || hw->phy.mdio.prtad == 0xFFFF)
+	if (hw->phy.mdio.prtad == MDIO_PRTAD_NONE)
 		return IXGBE_ERR_PHY_ADDR_INVALID;
 
 	/* Get external PHY device id */
-- 
2.7.4

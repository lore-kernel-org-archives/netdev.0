From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/21] ixgbe: Configure advertised speeds correctly for KR/KX backplane
Date: Fri, 30 Dec 2016 01:33:35 -0800
Message-ID: <20161230093341.14674-16-jeffrey.t.kirsher@intel.com>
References: <20161230093341.14674-1-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:54391 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752320AbcL3Jdt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Dec 2016 04:33:49 -0500
In-Reply-To: <20161230093341.14674-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch ensures that the advertised link speeds are configured
for X553 KR/KX backplane.  Without this patch the link remains at
1G when resuming form low power after being downshifted by LPLU.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 92f2b5e..675c198 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -2187,12 +2187,11 @@ static s32 ixgbe_setup_kx4_x550em(struct ixgbe_hw *hw)
 /**
  * ixgbe_setup_kr_x550em - Configure the KR PHY
  * @hw: pointer to hardware structure
- *
- * Configures the integrated KR PHY for X550EM_x.
  **/
 static s32 ixgbe_setup_kr_x550em(struct ixgbe_hw *hw)
 {
-	if (hw->mac.type != ixgbe_mac_X550EM_x)
+	/* leave linke alone for 2.5G */
+	if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_2_5GB_FULL)
 		return 0;
 
 	return ixgbe_setup_kr_speed_x550em(hw, hw->phy.autoneg_advertised);
-- 
2.9.3

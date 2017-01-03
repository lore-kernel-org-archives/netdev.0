From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 15/21] ixgbe: Configure advertised speeds correctly for KR/KX backplane
Date: Tue,  3 Jan 2017 13:07:51 -0800
Message-ID: <20170103210757.38847-16-jeffrey.t.kirsher@intel.com>
References: <20170103210757.38847-1-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:25260 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966322AbdACVIR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 16:08:17 -0500
In-Reply-To: <20170103210757.38847-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch ensures that the advertised link speeds are configured
for X553 KR/KX backplane.  Without this patch the link remains at
1G when resuming from low power after being downshifted by LPLU.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 92f2b5e..e3d14f4 100644
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
+	/* leave link alone for 2.5G */
+	if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_2_5GB_FULL)
 		return 0;
 
 	return ixgbe_setup_kr_speed_x550em(hw, hw->phy.autoneg_advertised);
-- 
2.9.3

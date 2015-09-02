From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/19] ixgbe: Remove second instance of lan_id variable
Date: Tue,  1 Sep 2015 18:13:56 -0700
Message-ID: <1441156443-33381-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59618 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754610AbbIBBON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 21:14:13 -0400
In-Reply-To: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch removes the redundant lan_id in the phy struct and uses
the bus version.  Both variables exist and intend to represent the
STATUS register LAN_ID field.  However, phy.lan_id is not bit shifted
so the phy.lan_id = 0x0 for LAN Id 0 and phy.lan_id = 0x4 for LAN Id 1.
Where bus.lan_id is bit shifted so bus.lan_id = 0x0 for LAN Id 0 and
bus.lan_id = 0x1 for LAN Id 1. There seems no need for the additional
lan_id variable and this should make the code less confusing.

Signed-off-by: Donald C Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c  | 4 +---
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h | 1 -
 2 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index 526a20b..740e566 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -243,9 +243,7 @@ s32 ixgbe_identify_phy_generic(struct ixgbe_hw *hw)
 	u16 ext_ability = 0;
 
 	if (!hw->phy.phy_semaphore_mask) {
-		hw->phy.lan_id = IXGBE_READ_REG(hw, IXGBE_STATUS) &
-				 IXGBE_STATUS_LAN_ID_1;
-		if (hw->phy.lan_id)
+		if (hw->bus.lan_id)
 			hw->phy.phy_semaphore_mask = IXGBE_GSSR_PHY1_SM;
 		else
 			hw->phy.phy_semaphore_mask = IXGBE_GSSR_PHY0_SM;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 1c5a5b3..a3eec19 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -3381,7 +3381,6 @@ struct ixgbe_phy_info {
 	bool                            sfp_setup_needed;
 	u32                             revision;
 	enum ixgbe_media_type           media_type;
-	u8				lan_id;
 	u32				phy_semaphore_mask;
 	bool                            reset_disable;
 	ixgbe_autoneg_advertised        autoneg_advertised;
-- 
2.4.3

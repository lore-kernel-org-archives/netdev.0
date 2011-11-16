From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/8] intel: Convert <FOO>_LENGTH_OF_ADDRESS to ETH_ALEN
Date: Wed, 16 Nov 2011 04:51:32 -0800
Message-ID: <1321447892-14381-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1321447892-14381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:24682 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756550Ab1KPMvl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 07:51:41 -0500
In-Reply-To: <1321447892-14381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Use the normal #defines not module specific ones.

Signed-off-by: Joe Perches <joe@perches.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_hw.h    |    1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  |    8 +++-----
 drivers/net/ethernet/intel/ixgbevf/defines.h   |    1 -
 drivers/net/ethernet/intel/ixgbevf/vf.c        |    4 ++--
 5 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_hw.h b/drivers/net/ethernet/intel/e1000/e1000_hw.h
index 5c9a840..cf7e3c0 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_hw.h
+++ b/drivers/net/ethernet/intel/e1000/e1000_hw.h
@@ -448,7 +448,6 @@ void e1000_io_write(struct e1000_hw *hw, unsigned long port, u32 value);
 #define E1000_DEV_ID_INTEL_CE4100_GBE    0x2E6E
 
 #define NODE_ADDRESS_SIZE 6
-#define ETH_LENGTH_OF_ADDRESS 6
 
 /* MAC decode size is 128K - This is the size of BAR0 */
 #define MAC_DECODE_SIZE (128 * 1024)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 00fcd39..cf6812d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -572,7 +572,7 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 
 		/* reply to reset with ack and vf mac address */
 		msgbuf[0] = IXGBE_VF_RESET | IXGBE_VT_MSGTYPE_ACK;
-		memcpy(new_mac, vf_mac, IXGBE_ETH_LENGTH_OF_ADDRESS);
+		memcpy(new_mac, vf_mac, ETH_ALEN);
 		/*
 		 * Piggyback the multicast filter type so VF can compute the
 		 * correct vectors
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 6c5cca8..242643a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -1710,8 +1710,6 @@ enum {
 #define IXGBE_NVM_POLL_WRITE       1  /* Flag for polling for write complete */
 #define IXGBE_NVM_POLL_READ        0  /* Flag for polling for read complete */
 
-#define IXGBE_ETH_LENGTH_OF_ADDRESS   6
-
 #define IXGBE_EEPROM_PAGE_SIZE_MAX       128
 #define IXGBE_EEPROM_RD_BUFFER_MAX_COUNT 512 /* EEPROM words # read in burst */
 #define IXGBE_EEPROM_WR_BUFFER_MAX_COUNT 256 /* EEPROM words # wr in burst */
@@ -2802,9 +2800,9 @@ struct ixgbe_eeprom_info {
 struct ixgbe_mac_info {
 	struct ixgbe_mac_operations     ops;
 	enum ixgbe_mac_type             type;
-	u8                              addr[IXGBE_ETH_LENGTH_OF_ADDRESS];
-	u8                              perm_addr[IXGBE_ETH_LENGTH_OF_ADDRESS];
-	u8                              san_addr[IXGBE_ETH_LENGTH_OF_ADDRESS];
+	u8                              addr[ETH_ALEN];
+	u8                              perm_addr[ETH_ALEN];
+	u8                              san_addr[ETH_ALEN];
 	/* prefix for World Wide Node Name (WWNN) */
 	u16                             wwnn_prefix;
 	/* prefix for World Wide Port Name (WWPN) */
diff --git a/drivers/net/ethernet/intel/ixgbevf/defines.h b/drivers/net/ethernet/intel/ixgbevf/defines.h
index 78abb6f..2eb89cb 100644
--- a/drivers/net/ethernet/intel/ixgbevf/defines.h
+++ b/drivers/net/ethernet/intel/ixgbevf/defines.h
@@ -35,7 +35,6 @@
 #define IXGBE_VF_IRQ_CLEAR_MASK         7
 #define IXGBE_VF_MAX_TX_QUEUES          1
 #define IXGBE_VF_MAX_RX_QUEUES          1
-#define IXGBE_ETH_LENGTH_OF_ADDRESS     6
 
 /* Link speed */
 typedef u32 ixgbe_link_speed;
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index aa3682e..21533e3 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -108,7 +108,7 @@ static s32 ixgbevf_reset_hw_vf(struct ixgbe_hw *hw)
 	if (msgbuf[0] != (IXGBE_VF_RESET | IXGBE_VT_MSGTYPE_ACK))
 		return IXGBE_ERR_INVALID_MAC_ADDR;
 
-	memcpy(hw->mac.perm_addr, addr, IXGBE_ETH_LENGTH_OF_ADDRESS);
+	memcpy(hw->mac.perm_addr, addr, ETH_ALEN);
 	hw->mac.mc_filter_type = msgbuf[IXGBE_VF_MC_TYPE_WORD];
 
 	return 0;
@@ -211,7 +211,7 @@ static s32 ixgbevf_mta_vector(struct ixgbe_hw *hw, u8 *mc_addr)
  **/
 static s32 ixgbevf_get_mac_addr_vf(struct ixgbe_hw *hw, u8 *mac_addr)
 {
-	memcpy(mac_addr, hw->mac.perm_addr, IXGBE_ETH_LENGTH_OF_ADDRESS);
+	memcpy(mac_addr, hw->mac.perm_addr, ETH_ALEN);
 
 	return 0;
 }
-- 
1.7.6.4

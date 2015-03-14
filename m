From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [next-queue 7/7] ixgbevf: Use ether_addr_copy() instead of memcpy()
Date: Fri, 13 Mar 2015 17:00:48 -0700
Message-ID: <1426291248-14739-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1426291248-14739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:19110 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752190AbbCNAAy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2015 20:00:54 -0400
In-Reply-To: <1426291248-14739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the macro to copy the Ethernet address instead of memcpy().

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/vf.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index 0d7da03..2614fd3 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -117,7 +117,7 @@ static s32 ixgbevf_reset_hw_vf(struct ixgbe_hw *hw)
 	    msgbuf[0] != (IXGBE_VF_RESET | IXGBE_VT_MSGTYPE_NACK))
 		return IXGBE_ERR_INVALID_MAC_ADDR;
 
-	memcpy(hw->mac.perm_addr, addr, ETH_ALEN);
+	ether_addr_copy(hw->mac.perm_addr, addr);
 	hw->mac.mc_filter_type = msgbuf[IXGBE_VF_MC_TYPE_WORD];
 
 	return 0;
@@ -219,7 +219,7 @@ static s32 ixgbevf_mta_vector(struct ixgbe_hw *hw, u8 *mc_addr)
  **/
 static s32 ixgbevf_get_mac_addr_vf(struct ixgbe_hw *hw, u8 *mac_addr)
 {
-	memcpy(mac_addr, hw->mac.perm_addr, ETH_ALEN);
+	ether_addr_copy(mac_addr, hw->mac.perm_addr);
 
 	return 0;
 }
@@ -240,7 +240,7 @@ static s32 ixgbevf_set_uc_addr_vf(struct ixgbe_hw *hw, u32 index, u8 *addr)
 	msgbuf[0] |= index << IXGBE_VT_MSGINFO_SHIFT;
 	msgbuf[0] |= IXGBE_VF_SET_MACVLAN;
 	if (addr)
-		memcpy(msg_addr, addr, ETH_ALEN);
+		ether_addr_copy(msg_addr, addr);
 	ret_val = mbx->ops.write_posted(hw, msgbuf, 3);
 
 	if (!ret_val)
@@ -273,7 +273,7 @@ static s32 ixgbevf_set_rar_vf(struct ixgbe_hw *hw, u32 index, u8 *addr,
 
 	memset(msgbuf, 0, sizeof(msgbuf));
 	msgbuf[0] = IXGBE_VF_SET_MAC_ADDR;
-	memcpy(msg_addr, addr, ETH_ALEN);
+	ether_addr_copy(msg_addr, addr);
 	ret_val = mbx->ops.write_posted(hw, msgbuf, 3);
 
 	if (!ret_val)
-- 
1.9.3

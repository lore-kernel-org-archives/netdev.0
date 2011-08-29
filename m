From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/10] ixgbe: PFC not cleared on X540 devices
Date: Mon, 29 Aug 2011 01:41:04 -0700
Message-ID: <1314607268-26958-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1314607268-26958-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:35742 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753336Ab1H2IlP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Aug 2011 04:41:15 -0400
In-Reply-To: <1314607268-26958-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

X540 devices do not clear PFC before sets. This results in
the device possibly responding to PFC frames that the user
has disabled. Although it would also be wrong for the peer
to be transmitting these frames. Now we clear the register
before set.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c |    4 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      |    1 +
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c
index ade9820..d64fb87 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c
@@ -252,8 +252,10 @@ s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw, u8 pfc_en)
 		reg &= ~IXGBE_MFLCN_RFCE;
 		reg |= IXGBE_MFLCN_RPFCE | IXGBE_MFLCN_DPF;
 
-		if (hw->mac.type == ixgbe_mac_X540)
+		if (hw->mac.type == ixgbe_mac_X540) {
+			reg &= ~IXGBE_MFLCN_RPFCE_MASK;
 			reg |= pfc_en << IXGBE_MFLCN_RPFCE_SHIFT;
+		}
 
 		IXGBE_WRITE_REG(hw, IXGBE_MFLCN, reg);
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index e0d970e..9f618ee 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -1834,6 +1834,7 @@ enum {
 #define IXGBE_MFLCN_DPF         0x00000002 /* Discard Pause Frame */
 #define IXGBE_MFLCN_RPFCE       0x00000004 /* Receive Priority FC Enable */
 #define IXGBE_MFLCN_RFCE        0x00000008 /* Receive FC Enable */
+#define IXGBE_MFLCN_RPFCE_MASK	0x00000FE0 /* Receive FC Mask */
 
 #define IXGBE_MFLCN_RPFCE_SHIFT		 4
 
-- 
1.7.6

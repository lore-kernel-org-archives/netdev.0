From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 v2 12/15] ixgbe: fix namespace issue with ixgbe_dcb_txq_to_tc
Date: Fri, 11 Feb 2011 09:20:59 -0800
Message-ID: <1297444862-32091-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1297444862-32091-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:46175 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757881Ab1BKRV0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 12:21:26 -0500
In-Reply-To: <1297444862-32091-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

We didn't need the prototype and it was causing namespace complaints so
I made it static.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h      |    1 -
 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index d04afde..12769b5 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -525,7 +525,6 @@ extern void ixgbe_unmap_and_free_tx_resource(struct ixgbe_ring *,
 extern void ixgbe_alloc_rx_buffers(struct ixgbe_ring *, u16);
 extern void ixgbe_write_eitr(struct ixgbe_q_vector *);
 extern int ethtool_ioctl(struct ifreq *ifr);
-extern u8 ixgbe_dcb_txq_to_tc(struct ixgbe_adapter *adapter, u8 index);
 extern s32 ixgbe_reinit_fdir_tables_82599(struct ixgbe_hw *hw);
 extern s32 ixgbe_init_fdir_signature_82599(struct ixgbe_hw *hw, u32 pballoc);
 extern s32 ixgbe_init_fdir_perfect_82599(struct ixgbe_hw *hw, u32 pballoc);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index c2e09b9..34fdda2 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -648,7 +648,7 @@ void ixgbe_unmap_and_free_tx_resource(struct ixgbe_ring *tx_ring,
  *
  * Returns : a tc index for use in range 0-7, or 0-3
  */
-u8 ixgbe_dcb_txq_to_tc(struct ixgbe_adapter *adapter, u8 reg_idx)
+static u8 ixgbe_dcb_txq_to_tc(struct ixgbe_adapter *adapter, u8 reg_idx)
 {
 	int tc = -1;
 	int dcb_i = adapter->ring_feature[RING_F_DCB].indices;
-- 
1.7.4


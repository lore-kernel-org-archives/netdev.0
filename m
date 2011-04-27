From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 07/12] ixgbe: fix static functions
Date: Wed, 27 Apr 2011 02:34:46 -0700
Message-ID: <1303896891-16006-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1303896891-16006-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:63274 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756073Ab1D0JfA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2011 05:35:00 -0400
In-Reply-To: <1303896891-16006-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Define functions as static added C=1 (sparse) to my make line
brought these to my attention.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82599.c     |    2 +-
 drivers/net/ixgbe/ixgbe_dcb_82598.c |    2 +-
 drivers/net/ixgbe/ixgbe_main.c      |    4 ++--
 drivers/net/ixgbe/ixgbe_sriov.c     |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index d521baf..d1cda36 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -494,7 +494,7 @@ static void ixgbe_flap_tx_laser_multispeed_fiber(struct ixgbe_hw *hw)
  *
  *  Set the link speed in the AUTOC register and restarts link.
  **/
-s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
+static s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
                                           ixgbe_link_speed speed,
                                           bool autoneg,
                                           bool autoneg_wait_to_complete)
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.c b/drivers/net/ixgbe/ixgbe_dcb_82598.c
index 1bc57e5..771d01a 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82598.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82598.c
@@ -289,7 +289,7 @@ s32 ixgbe_dcb_config_pfc_82598(struct ixgbe_hw *hw, u8 pfc_en)
  * Configure queue statistics registers, all queues belonging to same traffic
  * class uses a single set of queue statistics counters.
  */
-s32 ixgbe_dcb_config_tc_stats_82598(struct ixgbe_hw *hw)
+static s32 ixgbe_dcb_config_tc_stats_82598(struct ixgbe_hw *hw)
 {
 	u32 reg = 0;
 	u8  i   = 0;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index dbe29e5..227a9b4 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4566,8 +4566,8 @@ static inline bool ixgbe_cache_ring_rss(struct ixgbe_adapter *adapter)
 #ifdef CONFIG_IXGBE_DCB
 
 /* ixgbe_get_first_reg_idx - Return first register index associated with ring */
-void ixgbe_get_first_reg_idx(struct ixgbe_adapter *adapter, u8 tc,
-			     unsigned int *tx, unsigned int *rx)
+static void ixgbe_get_first_reg_idx(struct ixgbe_adapter *adapter, u8 tc,
+				    unsigned int *tx, unsigned int *rx)
 {
 	struct net_device *dev = adapter->netdev;
 	struct ixgbe_hw *hw = &adapter->hw;
diff --git a/drivers/net/ixgbe/ixgbe_sriov.c b/drivers/net/ixgbe/ixgbe_sriov.c
index 6e50d83..4765027 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ixgbe/ixgbe_sriov.c
@@ -110,7 +110,7 @@ static int ixgbe_set_vf_vlan(struct ixgbe_adapter *adapter, int add, int vid,
 	return adapter->hw.mac.ops.set_vfta(&adapter->hw, vid, vf, (bool)add);
 }
 
-void ixgbe_set_vf_lpe(struct ixgbe_adapter *adapter, u32 *msgbuf)
+static void ixgbe_set_vf_lpe(struct ixgbe_adapter *adapter, u32 *msgbuf)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	int new_mtu = msgbuf[1];
-- 
1.7.4.4


From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next-2.6 PATCH 05/10] [RFC] ixgbe: add support for different Rx
	packet buffer sizes
Date: Fri, 25 Feb 2011 15:33:05 -0800
Message-ID: <20110225233305.7920.13868.stgit@gitlad.jf.intel.com>
References: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:39055 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933008Ab1BYXdF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 18:33:05 -0500
In-Reply-To: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change adds support for hardware that can have different Rx packet
buffer sizes.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c |    2 ++
 drivers/net/ixgbe/ixgbe_82599.c |    2 ++
 drivers/net/ixgbe/ixgbe_type.h  |    1 +
 drivers/net/ixgbe/ixgbe_x540.c  |    2 ++
 4 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index d0f1d9d..d2dc50c 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -37,6 +37,7 @@
 #define IXGBE_82598_RAR_ENTRIES   16
 #define IXGBE_82598_MC_TBL_SIZE  128
 #define IXGBE_82598_VFT_TBL_SIZE 128
+#define IXGBE_82598_RX_PB_SIZE   512
 
 static s32 ixgbe_setup_copper_link_82598(struct ixgbe_hw *hw,
                                          ixgbe_link_speed speed,
@@ -123,6 +124,7 @@ static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw)
 	mac->mcft_size = IXGBE_82598_MC_TBL_SIZE;
 	mac->vft_size = IXGBE_82598_VFT_TBL_SIZE;
 	mac->num_rar_entries = IXGBE_82598_RAR_ENTRIES;
+	mac->rx_pb_size = IXGBE_82598_RX_PB_SIZE;
 	mac->max_rx_queues = IXGBE_82598_MAX_RX_QUEUES;
 	mac->max_tx_queues = IXGBE_82598_MAX_TX_QUEUES;
 	mac->max_msix_vectors = ixgbe_get_pcie_msix_count_82598(hw);
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index a21f581..c9bfa64 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -38,6 +38,7 @@
 #define IXGBE_82599_RAR_ENTRIES   128
 #define IXGBE_82599_MC_TBL_SIZE   128
 #define IXGBE_82599_VFT_TBL_SIZE  128
+#define IXGBE_82599_RX_PB_SIZE    512
 
 static void ixgbe_disable_tx_laser_multispeed_fiber(struct ixgbe_hw *hw);
 static void ixgbe_enable_tx_laser_multispeed_fiber(struct ixgbe_hw *hw);
@@ -168,6 +169,7 @@ static s32 ixgbe_get_invariants_82599(struct ixgbe_hw *hw)
 	mac->vft_size = IXGBE_82599_VFT_TBL_SIZE;
 	mac->num_rar_entries = IXGBE_82599_RAR_ENTRIES;
 	mac->max_rx_queues = IXGBE_82599_MAX_RX_QUEUES;
+	mac->rx_pb_size = IXGBE_82599_RX_PB_SIZE;
 	mac->max_tx_queues = IXGBE_82599_MAX_TX_QUEUES;
 	mac->max_msix_vectors = ixgbe_get_pcie_msix_count_generic(hw);
 
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index ab65d13..2f8ba73 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2571,6 +2571,7 @@ struct ixgbe_mac_info {
 	u32                             vft_size;
 	u32                             num_rar_entries;
 	u32                             rar_highwater;
+	u32                             rx_pb_size;
 	u32                             max_tx_queues;
 	u32                             max_rx_queues;
 	u32                             max_msix_vectors;
diff --git a/drivers/net/ixgbe/ixgbe_x540.c b/drivers/net/ixgbe/ixgbe_x540.c
index f2518b0..fa095f8 100644
--- a/drivers/net/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ixgbe/ixgbe_x540.c
@@ -38,6 +38,7 @@
 #define IXGBE_X540_RAR_ENTRIES   128
 #define IXGBE_X540_MC_TBL_SIZE   128
 #define IXGBE_X540_VFT_TBL_SIZE  128
+#define IXGBE_X540_RX_PB_SIZE    384
 
 static s32 ixgbe_update_flash_X540(struct ixgbe_hw *hw);
 static s32 ixgbe_poll_flash_update_done_X540(struct ixgbe_hw *hw);
@@ -62,6 +63,7 @@ static s32 ixgbe_get_invariants_X540(struct ixgbe_hw *hw)
 	mac->vft_size = IXGBE_X540_VFT_TBL_SIZE;
 	mac->num_rar_entries = IXGBE_X540_RAR_ENTRIES;
 	mac->max_rx_queues = IXGBE_X540_MAX_RX_QUEUES;
+	mac->rx_pb_size = IXGBE_X540_RX_PB_SIZE;
 	mac->max_tx_queues = IXGBE_X540_MAX_TX_QUEUES;
 	mac->max_msix_vectors = ixgbe_get_pcie_msix_count_generic(hw);
 


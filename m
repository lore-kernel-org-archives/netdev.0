From: Mao Wenan <maowenan@huawei.com>
Subject: [PATCH net-next 1/2] ixgbevf and 82598 relax order mode support
Date: Fri, 3 Feb 2017 17:30:32 +0800
Message-ID: <1486114233-9800-2-git-send-email-maowenan@huawei.com>
References: <1486114233-9800-1-git-send-email-maowenan@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <alexander.duyck@gmail.com>,
        <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:34305 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752729AbdBCJbq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 04:31:46 -0500
In-Reply-To: <1486114233-9800-1-git-send-email-maowenan@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows one to use common macro
CONFIG_ARCH_WANT_RELAX_ORDER to enable or
disable to relax order mode.

Signed-off-by: Mao Wenan <maowenan@huawei.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c    | 4 ++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index 523f9d0..167d1fc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -175,7 +175,7 @@ static s32 ixgbe_init_phy_ops_82598(struct ixgbe_hw *hw)
  **/
 static s32 ixgbe_start_hw_82598(struct ixgbe_hw *hw)
 {
-#ifndef CONFIG_SPARC
+#ifndef CONFIG_ARCH_WANT_RELAX_ORDER
 	u32 regval;
 	u32 i;
 #endif
@@ -183,7 +183,7 @@ static s32 ixgbe_start_hw_82598(struct ixgbe_hw *hw)
 
 	ret_val = ixgbe_start_hw_generic(hw);
 
-#ifndef CONFIG_SPARC
+#ifndef CONFIG_ARCH_WANT_RELAX_ORDER
 	/* Disable relaxed ordering */
 	for (i = 0; ((i < hw->mac.max_tx_queues) &&
 	     (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index b068635..0efbf0b 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1765,7 +1765,7 @@ static void ixgbevf_configure_rx_ring(struct ixgbevf_adapter *adapter,
 	IXGBE_WRITE_REG(hw, IXGBE_VFRDLEN(reg_idx),
 			ring->count * sizeof(union ixgbe_adv_rx_desc));
 
-#ifndef CONFIG_SPARC
+#ifndef CONFIG_ARCH_WANT_RELAX_ORDER
 	/* enable relaxed ordering */
 	IXGBE_WRITE_REG(hw, IXGBE_VFDCA_RXCTRL(reg_idx),
 			IXGBE_DCA_RXCTRL_DESC_RRO_EN);
-- 
2.7.0

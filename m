From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 2/4] ixgbe: ixgbevf: Clear the CONFIG_SPARC for ixgbevf and 82598
Date: Sat, 1 Apr 2017 15:25:52 +0800
Message-ID: <1491031554-19516-3-git-send-email-dingtianhong@huawei.com>
References: <1491031554-19516-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ding Tianhong <dingtianhong@huawei.com>
To: <catalin.marinas@arm.com>, <will.deacon@arm.com>,
        <mark.rutland@arm.com>, <robin.murphy@arm.com>,
        <jeffrey.t.kirsher@intel.com>, <davem@davemloft.net>,
        <alexander.duyck@gmail.com>,
        <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([45.249.212.187]:5292 "EHLO
        dggrg01-dlp.huawei.com" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750801AbdDAH0p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 03:26:45 -0400
In-Reply-To: <1491031554-19516-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The CONFIG_SPARC in ixgbevf and ixgbe_82598 is only used
to enable relaxed ordering, the CONFIG_IXBGE_WANT_RELAXED_ORDER
already did this, so rename this config for the same setting.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c    | 4 ++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index 523f9d0..c7f95ae 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -175,7 +175,7 @@ static s32 ixgbe_init_phy_ops_82598(struct ixgbe_hw *hw)
  **/
 static s32 ixgbe_start_hw_82598(struct ixgbe_hw *hw)
 {
-#ifndef CONFIG_SPARC
+#ifndef CONFIG_IXGBE_ALLOW_RELAXED_ORDER
 	u32 regval;
 	u32 i;
 #endif
@@ -183,7 +183,7 @@ static s32 ixgbe_start_hw_82598(struct ixgbe_hw *hw)
 
 	ret_val = ixgbe_start_hw_generic(hw);
 
-#ifndef CONFIG_SPARC
+#ifndef CONFIG_IXGBE_ALLOW_RELAXED_ORDER
 	/* Disable relaxed ordering */
 	for (i = 0; ((i < hw->mac.max_tx_queues) &&
 	     (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 80bab26..c27932d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1713,7 +1713,7 @@ static void ixgbevf_configure_rx_ring(struct ixgbevf_adapter *adapter,
 	IXGBE_WRITE_REG(hw, IXGBE_VFRDLEN(reg_idx),
 			ring->count * sizeof(union ixgbe_adv_rx_desc));
 
-#ifndef CONFIG_SPARC
+#ifndef CONFIG_IXGBE_ALLOW_RELAXED_ORDER
 	/* enable relaxed ordering */
 	IXGBE_WRITE_REG(hw, IXGBE_VFDCA_RXCTRL(reg_idx),
 			IXGBE_DCA_RXCTRL_DESC_RRO_EN);
-- 
1.9.0

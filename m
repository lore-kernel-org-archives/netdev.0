From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 3/7] ixgbe: Initialize 64-bit stats seqcounts
Date: Tue,  1 Aug 2017 12:11:08 -0700
Message-ID: <20170801191113.8754-4-f.fainelli@gmail.com>
References: <20170801191113.8754-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, edumazet@google.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org (moderated list:INTEL ETHERNET DRIVERS),
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170801191113.8754-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 32-bit hosts and with CONFIG_DEBUG_LOCK_ALLOC we should be seeing a
lockdep splat indicating this seqcount is not correctly initialized, fix
that.

Fixes: 4197aa7bb818 ("ixgbevf: provide 64 bit statistics")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 084c53582793..032f8ac06357 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2988,6 +2988,8 @@ int ixgbevf_setup_tx_resources(struct ixgbevf_ring *tx_ring)
 	if (!tx_ring->tx_buffer_info)
 		goto err;
 
+	u64_stats_init(&tx_ring->syncp);
+
 	/* round up to nearest 4K */
 	tx_ring->size = tx_ring->count * sizeof(union ixgbe_adv_tx_desc);
 	tx_ring->size = ALIGN(tx_ring->size, 4096);
@@ -3046,6 +3048,8 @@ int ixgbevf_setup_rx_resources(struct ixgbevf_ring *rx_ring)
 	if (!rx_ring->rx_buffer_info)
 		goto err;
 
+	u64_stats_init(&rx_ring->syncp);
+
 	/* Round up to nearest 4K */
 	rx_ring->size = rx_ring->count * sizeof(union ixgbe_adv_rx_desc);
 	rx_ring->size = ALIGN(rx_ring->size, 4096);
-- 
2.9.3

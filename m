From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/11] ixgbe: Resolve warnings produced in W=2 builds
Date: Fri, 12 Sep 2014 05:33:41 -0700
Message-ID: <1410525231-19851-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1410525231-19851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:39378 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753663AbaILMd6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2014 08:33:58 -0400
In-Reply-To: <1410525231-19851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

This patch resolves warnings produced by ixgbe in W=2 kernel
builds. There are missing-field-initializers warnings and shadow
warnings. None of these point to any deeper problem, so just
resolve them so any new warnings get analyzed.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 18 +++++++++---------
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index e4100b5..cff383b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1303,7 +1303,7 @@ static const struct ixgbe_reg_test reg_test_82599[] = {
 	{ IXGBE_RAL(0), 16, TABLE64_TEST_LO, 0xFFFFFFFF, 0xFFFFFFFF },
 	{ IXGBE_RAL(0), 16, TABLE64_TEST_HI, 0x8001FFFF, 0x800CFFFF },
 	{ IXGBE_MTA(0), 128, TABLE32_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
-	{ 0, 0, 0, 0 }
+	{ .reg = 0 }
 };
 
 /* default 82598 register test */
@@ -1331,7 +1331,7 @@ static const struct ixgbe_reg_test reg_test_82598[] = {
 	{ IXGBE_RAL(0), 16, TABLE64_TEST_LO, 0xFFFFFFFF, 0xFFFFFFFF },
 	{ IXGBE_RAL(0), 16, TABLE64_TEST_HI, 0x800CFFFF, 0x800CFFFF },
 	{ IXGBE_MTA(0), 128, TABLE32_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
-	{ 0, 0, 0, 0 }
+	{ .reg = 0 }
 };
 
 static bool reg_pattern_test(struct ixgbe_adapter *adapter, u64 *data, int reg,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 166dc00..87613806 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -440,7 +440,7 @@ static const struct ixgbe_reg_info ixgbe_reg_info_tbl[] = {
 	{IXGBE_TXDCTL(0), "TXDCTL"},
 
 	/* List Terminator */
-	{}
+	{ .name = NULL }
 };
 
 
@@ -5186,15 +5186,15 @@ int ixgbe_setup_tx_resources(struct ixgbe_ring *tx_ring)
 {
 	struct device *dev = tx_ring->dev;
 	int orig_node = dev_to_node(dev);
-	int numa_node = -1;
+	int ring_node = -1;
 	int size;
 
 	size = sizeof(struct ixgbe_tx_buffer) * tx_ring->count;
 
 	if (tx_ring->q_vector)
-		numa_node = tx_ring->q_vector->numa_node;
+		ring_node = tx_ring->q_vector->numa_node;
 
-	tx_ring->tx_buffer_info = vzalloc_node(size, numa_node);
+	tx_ring->tx_buffer_info = vzalloc_node(size, ring_node);
 	if (!tx_ring->tx_buffer_info)
 		tx_ring->tx_buffer_info = vzalloc(size);
 	if (!tx_ring->tx_buffer_info)
@@ -5206,7 +5206,7 @@ int ixgbe_setup_tx_resources(struct ixgbe_ring *tx_ring)
 	tx_ring->size = tx_ring->count * sizeof(union ixgbe_adv_tx_desc);
 	tx_ring->size = ALIGN(tx_ring->size, 4096);
 
-	set_dev_node(dev, numa_node);
+	set_dev_node(dev, ring_node);
 	tx_ring->desc = dma_alloc_coherent(dev,
 					   tx_ring->size,
 					   &tx_ring->dma,
@@ -5270,15 +5270,15 @@ int ixgbe_setup_rx_resources(struct ixgbe_ring *rx_ring)
 {
 	struct device *dev = rx_ring->dev;
 	int orig_node = dev_to_node(dev);
-	int numa_node = -1;
+	int ring_node = -1;
 	int size;
 
 	size = sizeof(struct ixgbe_rx_buffer) * rx_ring->count;
 
 	if (rx_ring->q_vector)
-		numa_node = rx_ring->q_vector->numa_node;
+		ring_node = rx_ring->q_vector->numa_node;
 
-	rx_ring->rx_buffer_info = vzalloc_node(size, numa_node);
+	rx_ring->rx_buffer_info = vzalloc_node(size, ring_node);
 	if (!rx_ring->rx_buffer_info)
 		rx_ring->rx_buffer_info = vzalloc(size);
 	if (!rx_ring->rx_buffer_info)
@@ -5290,7 +5290,7 @@ int ixgbe_setup_rx_resources(struct ixgbe_ring *rx_ring)
 	rx_ring->size = rx_ring->count * sizeof(union ixgbe_adv_rx_desc);
 	rx_ring->size = ALIGN(rx_ring->size, 4096);
 
-	set_dev_node(dev, numa_node);
+	set_dev_node(dev, ring_node);
 	rx_ring->desc = dma_alloc_coherent(dev,
 					   rx_ring->size,
 					   &rx_ring->dma,
-- 
1.9.3

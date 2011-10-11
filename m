From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/11] igb: avoid unnecessary conversions from u16 to int
Date: Tue, 11 Oct 2011 08:45:44 -0700
Message-ID: <1318347952-25068-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318347952-25068-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52698 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754694Ab1JKPp4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 11:45:56 -0400
In-Reply-To: <1318347952-25068-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

There are a number of places where we have values that are stored as u16
but are being converted to int unnecessarily.  In order to avoid that we
should convert all variables that deal with the next_to_clean, next_to_use,
and count to u16 values.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c |    5 +++--
 drivers/net/ethernet/intel/igb/igb_main.c    |    9 ++++-----
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 174540f..c364d84 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1577,8 +1577,8 @@ static int igb_clean_test_rings(struct igb_ring *rx_ring,
 	union e1000_adv_rx_desc *rx_desc;
 	struct igb_rx_buffer *rx_buffer_info;
 	struct igb_tx_buffer *tx_buffer_info;
-	int rx_ntc, tx_ntc, count = 0;
 	u32 staterr;
+	u16 rx_ntc, tx_ntc, count = 0;
 
 	/* initialize next to clean and descriptor values */
 	rx_ntc = rx_ring->next_to_clean;
@@ -1630,7 +1630,8 @@ static int igb_run_loopback_test(struct igb_adapter *adapter)
 {
 	struct igb_ring *tx_ring = &adapter->test_tx_ring;
 	struct igb_ring *rx_ring = &adapter->test_rx_ring;
-	int i, j, lc, good_cnt, ret_val = 0;
+	u16 i, j, lc, good_cnt;
+	int ret_val = 0;
 	unsigned int size = IGB_RX_HDR_LEN;
 	netdev_tx_t tx_ret_val;
 	struct sk_buff *skb;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 1c234f0..150bf4e 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -338,14 +338,13 @@ static void igb_dump(struct igb_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_hw *hw = &adapter->hw;
 	struct igb_reg_info *reginfo;
-	int n = 0;
 	struct igb_ring *tx_ring;
 	union e1000_adv_tx_desc *tx_desc;
 	struct my_u0 { u64 a; u64 b; } *u0;
 	struct igb_ring *rx_ring;
 	union e1000_adv_rx_desc *rx_desc;
 	u32 staterr;
-	int i = 0;
+	u16 i, n;
 
 	if (!netif_msg_hw(adapter))
 		return;
@@ -3169,7 +3168,7 @@ static void igb_clean_tx_ring(struct igb_ring *tx_ring)
 {
 	struct igb_tx_buffer *buffer_info;
 	unsigned long size;
-	unsigned int i;
+	u16 i;
 
 	if (!tx_ring->tx_buffer_info)
 		return;
@@ -4285,7 +4284,7 @@ dma_error:
 	tx_ring->next_to_use = i;
 }
 
-static int __igb_maybe_stop_tx(struct igb_ring *tx_ring, int size)
+static int __igb_maybe_stop_tx(struct igb_ring *tx_ring, const u16 size)
 {
 	struct net_device *netdev = tx_ring->netdev;
 
@@ -4311,7 +4310,7 @@ static int __igb_maybe_stop_tx(struct igb_ring *tx_ring, int size)
 	return 0;
 }
 
-static inline int igb_maybe_stop_tx(struct igb_ring *tx_ring, int size)
+static inline int igb_maybe_stop_tx(struct igb_ring *tx_ring, const u16 size)
 {
 	if (igb_desc_unused(tx_ring) >= size)
 		return 0;
-- 
1.7.6.4

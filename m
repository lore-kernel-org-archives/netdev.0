From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40e/i40evf: use __GFP_NOWARN
Date: Wed, 17 Feb 2016 19:38:53 -0800
Message-ID: <1455766737-11911-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455766737-11911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:14529 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1424877AbcBRDjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 22:39:06 -0500
In-Reply-To: <1455766737-11911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The i40e and i40evf drivers now cleanly handle allocation
failures and can avoid kernel log spew from the memory allocator
when allocations fail, so set __GFP_NOWARN on Rx buffer alloc.

Change-ID: Ic9e1b83c495e2a3ef6b069ba7fb6e52ce134cd23
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 12 ++++++++----
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 12 ++++++++----
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 8049206..baaf093 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1292,8 +1292,10 @@ bool i40e_alloc_rx_buffers_1buf(struct i40e_ring *rx_ring, u16 cleaned_count)
 		skb = bi->skb;
 
 		if (!skb) {
-			skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
-							rx_ring->rx_buf_len);
+			skb = __netdev_alloc_skb_ip_align(rx_ring->netdev,
+							  rx_ring->rx_buf_len,
+							  GFP_ATOMIC |
+							  __GFP_NOWARN);
 			if (!skb) {
 				rx_ring->rx_stats.alloc_buff_failed++;
 				goto no_buffers;
@@ -1571,8 +1573,10 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, const int budget)
 		rx_bi = &rx_ring->rx_bi[i];
 		skb = rx_bi->skb;
 		if (likely(!skb)) {
-			skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
-							rx_ring->rx_hdr_len);
+			skb = __netdev_alloc_skb_ip_align(rx_ring->netdev,
+							  rx_ring->rx_hdr_len,
+							  GFP_ATOMIC |
+							  __GFP_NOWARN);
 			if (!skb) {
 				rx_ring->rx_stats.alloc_buff_failed++;
 				failure = true;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 616daae..1dbdcf8 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -764,8 +764,10 @@ bool i40evf_alloc_rx_buffers_1buf(struct i40e_ring *rx_ring, u16 cleaned_count)
 		skb = bi->skb;
 
 		if (!skb) {
-			skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
-							rx_ring->rx_buf_len);
+			skb = __netdev_alloc_skb_ip_align(rx_ring->netdev,
+							  rx_ring->rx_buf_len,
+							  GFP_ATOMIC |
+							  __GFP_NOWARN);
 			if (!skb) {
 				rx_ring->rx_stats.alloc_buff_failed++;
 				goto no_buffers;
@@ -1034,8 +1036,10 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, const int budget)
 		rx_bi = &rx_ring->rx_bi[i];
 		skb = rx_bi->skb;
 		if (likely(!skb)) {
-			skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
-							rx_ring->rx_hdr_len);
+			skb = __netdev_alloc_skb_ip_align(rx_ring->netdev,
+							  rx_ring->rx_hdr_len,
+							  GFP_ATOMIC |
+							  __GFP_NOWARN);
 			if (!skb) {
 				rx_ring->rx_stats.alloc_buff_failed++;
 				failure = true;
-- 
2.5.0

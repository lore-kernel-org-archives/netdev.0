From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 3/4] i40e/i40evf: Use dma_rmb where appropriate
Date: Wed, 08 Apr 2015 18:49:43 -0700
Message-ID: <20150409014943.4434.58640.stgit@ahduyck-vm-fedora22>
References: <20150409014001.4434.85280.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46245 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753811AbbDIBto (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 21:49:44 -0400
In-Reply-To: <20150409014001.4434.85280.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update i40e and i40evf to use dma_rmb.  This should improve performance by
decreasing the barrier overhead on strong ordered architectures.

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   |    4 ++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index d8989f9d1798..4bd3a80aba82 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1554,7 +1554,7 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 		 * any other fields out of the rx_desc until we know the
 		 * DD bit is set.
 		 */
-		rmb();
+		dma_rmb();
 		if (i40e_rx_is_programming_status(qword)) {
 			i40e_clean_programming_status(rx_ring, rx_desc);
 			I40E_RX_INCREMENT(rx_ring, i);
@@ -1745,7 +1745,7 @@ static int i40e_clean_rx_irq_1buf(struct i40e_ring *rx_ring, int budget)
 		 * any other fields out of the rx_desc until we know the
 		 * DD bit is set.
 		 */
-		rmb();
+		dma_rmb();
 
 		if (i40e_rx_is_programming_status(qword)) {
 			i40e_clean_programming_status(rx_ring, rx_desc);
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index e2ddb30e96f5..b077e02a0cc7 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1034,7 +1034,7 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 		 * any other fields out of the rx_desc until we know the
 		 * DD bit is set.
 		 */
-		rmb();
+		dma_rmb();
 		rx_bi = &rx_ring->rx_bi[i];
 		skb = rx_bi->skb;
 		if (likely(!skb)) {
@@ -1213,7 +1213,7 @@ static int i40e_clean_rx_irq_1buf(struct i40e_ring *rx_ring, int budget)
 		 * any other fields out of the rx_desc until we know the
 		 * DD bit is set.
 		 */
-		rmb();
+		dma_rmb();
 
 		rx_bi = &rx_ring->rx_bi[i];
 		skb = rx_bi->skb;

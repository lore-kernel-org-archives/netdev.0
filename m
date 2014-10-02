From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/9] i40e/igb: Convert to dev_consume_skb_any()
Date: Thu,  2 Oct 2014 03:16:33 -0700
Message-ID: <1412244994-23636-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1412244994-23636-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:25396 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751526AbaJBKQp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 06:16:45 -0400
In-Reply-To: <1412244994-23636-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>

Convert two more Intel NIC drivers to dev_consume_skb_any() to help
make dropped packet profiling sane.

Signed-off-by: Rick Jones <rick.jones2@hp.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 2 +-
 drivers/net/ethernet/intel/igb/igb_main.c   | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index be039dd..267992b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -702,7 +702,7 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
 		total_packets += tx_buf->gso_segs;
 
 		/* free the skb */
-		dev_kfree_skb_any(tx_buf->skb);
+		dev_consume_skb_any(tx_buf->skb);
 
 		/* unmap skb header data */
 		dma_unmap_single(tx_ring->dev,
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 2a4e6f1..3566fea 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6374,7 +6374,7 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 		total_packets += tx_buffer->gso_segs;
 
 		/* free the skb */
-		dev_kfree_skb_any(tx_buffer->skb);
+		dev_consume_skb_any(tx_buffer->skb);
 
 		/* unmap skb header data */
 		dma_unmap_single(tx_ring->dev,
-- 
1.9.3

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/2] igb: Fix NULL assignment to incorrect variable in igb_reset_q_vector
Date: Thu,  7 May 2015 05:21:33 -0700
Message-ID: <1431001293-19424-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1431001293-19424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:46152 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751367AbbEGMVh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2015 08:21:37 -0400
In-Reply-To: <1431001293-19424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

adapter->tx_ring is set to NULL where rx_ring should be.

Fixes: 5536d2102a2d ("igb: Combine q_vector and ring allocation into a single function")
Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 783d60ea..a0a9b1f 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1036,7 +1036,7 @@ static void igb_reset_q_vector(struct igb_adapter *adapter, int v_idx)
 		adapter->tx_ring[q_vector->tx.ring->queue_index] = NULL;
 
 	if (q_vector->rx.ring)
-		adapter->tx_ring[q_vector->rx.ring->queue_index] = NULL;
+		adapter->rx_ring[q_vector->rx.ring->queue_index] = NULL;
 
 	netif_napi_del(&q_vector->napi);
 
-- 
2.1.0

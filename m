From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 01/14] ixgbe: on recv increment rx.ring->stats.yields
Date: Mon,  4 Apr 2016 17:58:52 -0700
Message-ID: <1459817945-144915-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459817945-144915-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:38979 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754238AbcDEA7J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2016 20:59:09 -0400
In-Reply-To: <1459817945-144915-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>

It seem to be non intentionally changed to Tx in
commit adc810900a70 ("ixgbe: Refactor busy poll socket code to address
multiple issues")

Lock is taken from ixgbe_low_latency_recv, and there under this
lock we use ixgbe_clean_rx_irq so it looks wrong for me to increment
Tx counter.

Yield stats can be shown through ethtool:
ethtool -S enp129s0 | grep yield

Signed-off-by: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index e4949af..9f64354 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -456,7 +456,7 @@ static inline bool ixgbe_qv_lock_poll(struct ixgbe_q_vector *q_vector)
 				IXGBE_QV_STATE_POLL);
 #ifdef BP_EXTENDED_STATS
 	if (rc != IXGBE_QV_STATE_IDLE)
-		q_vector->tx.ring->stats.yields++;
+		q_vector->rx.ring->stats.yields++;
 #endif
 	return rc == IXGBE_QV_STATE_IDLE;
 }
-- 
2.5.5

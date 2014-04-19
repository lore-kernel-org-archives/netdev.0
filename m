From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 5/7] igb: fix stats for i210 rx_fifo_errors
Date: Fri, 18 Apr 2014 18:59:25 -0700
Message-ID: <1397872767-4001-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1397872767-4001-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:52335 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751429AbaDSB7d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2014 21:59:33 -0400
In-Reply-To: <1397872767-4001-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

RQDPC on i210/i211 is R/W not ReadClear. Clear after reading.

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index fb98d46..16430a8 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5193,8 +5193,10 @@ void igb_update_stats(struct igb_adapter *adapter,
 
 	rcu_read_lock();
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		u32 rqdpc = rd32(E1000_RQDPC(i));
 		struct igb_ring *ring = adapter->rx_ring[i];
+		u32 rqdpc = rd32(E1000_RQDPC(i));
+		if (hw->mac.type >= e1000_i210)
+			wr32(E1000_RQDPC(i), 0);
 
 		if (rqdpc) {
 			ring->rx_stats.drops += rqdpc;
-- 
1.9.0

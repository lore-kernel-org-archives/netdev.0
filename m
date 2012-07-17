From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] ixgbevf: Fix panic when loading driver
Date: Tue, 17 Jul 2012 02:44:48 -0700
Message-ID: <1342518288-13522-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:63913 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751898Ab2GQJoy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 05:44:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch addresses a kernel panic seen when setting up the interface.
Specifically we see a NULL pointer dereference on the Tx descriptor cleanup
path when enabling interrupts.  This change corrects that so it cannot
occur.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 8b304a4..41e3225 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -201,6 +201,9 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_adapter *adapter,
 	unsigned int i, eop, count = 0;
 	unsigned int total_bytes = 0, total_packets = 0;
 
+	if (test_bit(__IXGBEVF_DOWN, &adapter->state))
+		return true;
+
 	i = tx_ring->next_to_clean;
 	eop = tx_ring->tx_buffer_info[i].next_to_watch;
 	eop_desc = IXGBE_TX_DESC_ADV(*tx_ring, eop);
-- 
1.7.10.4

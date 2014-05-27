From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] e1000: Use is_broadcast_ether_addr/is_multicast_ether_addr helpers
Date: Tue, 27 May 2014 02:12:30 -0700
Message-ID: <1401181951-31358-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Tobias Klauser <tklauser@distanz.ch>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17021 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751854AbaE0JMq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 05:12:46 -0400
In-Reply-To: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>

Use the is_broadcast_ether_addr/is_multicast_ether_addr helper functions
from linux/etherdevice.h instead of open coding them.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_hw.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_hw.c b/drivers/net/ethernet/intel/e1000/e1000_hw.c
index c1d3fdb..e9b07cc 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_hw.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_hw.c
@@ -4877,10 +4877,10 @@ void e1000_tbi_adjust_stats(struct e1000_hw *hw, struct e1000_hw_stats *stats,
 	 * since the test for a multicast frame will test positive on
 	 * a broadcast frame.
 	 */
-	if ((mac_addr[0] == (u8) 0xff) && (mac_addr[1] == (u8) 0xff))
+	if (is_broadcast_ether_addr(mac_addr))
 		/* Broadcast packet */
 		stats->bprc++;
-	else if (*mac_addr & 0x01)
+	else if (is_multicast_ether_addr(mac_addr))
 		/* Multicast packet */
 		stats->mprc++;
 
-- 
1.9.3

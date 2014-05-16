From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] e1000: Use is_broadcast_ether_addr/is_multicast_ether_addr helpers
Date: Fri, 16 May 2014 10:00:38 +0200
Message-ID: <1400227238-13428-1-git-send-email-tklauser@distanz.ch>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:57950 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754848AbaEPIA6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 04:00:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the is_broadcast_ether_addr/is_multicast_ether_addr helper functions
from linux/etherdevice.h instead of open coding them.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/intel/e1000/e1000_hw.c |    4 ++--
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
1.7.9.5

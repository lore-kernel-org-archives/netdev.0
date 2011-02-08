From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 1/7] e1000e: tx_timeout should not increment for non-hang events
Date: Tue,  8 Feb 2011 01:44:33 -0800
Message-ID: <1297158279-20277-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1297158279-20277-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:25861 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752307Ab1BHJoo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Feb 2011 04:44:44 -0500
In-Reply-To: <1297158279-20277-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Currently the driver increments the tx_timeout counter (an error counter)
when simply resetting the part with outstanding transmit work pending.
This is an unnecessary count of an error, when all we should be doing is
just resetting the part and discarding the transmits.  With this change the
only increment of tx_timeout is when the stack calls the watchdog reset
function due to a true Tx timeout.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Reviewed-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/netdev.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 1c18f26..3065870 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4309,7 +4309,6 @@ link_up:
 			 * to get done, so reset controller to flush Tx.
 			 * (Do the reset outside of interrupt context).
 			 */
-			adapter->tx_timeout_count++;
 			schedule_work(&adapter->reset_task);
 			/* return immediately since reset is imminent */
 			return;
-- 
1.7.4


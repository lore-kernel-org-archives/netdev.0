From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/7] e1000e: Cleanup code logic in e1000_check_for_serdes_link_82571()
Date: Sat, 14 Jul 2012 16:06:59 -0700
Message-ID: <1342307225-28917-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342307225-28917-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Tushar Dave <tushar.n.dave@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:31575 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752196Ab2GNXH3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jul 2012 19:07:29 -0400
In-Reply-To: <1342307225-28917-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tushar Dave <tushar.n.dave@intel.com>

Cleanup code to make it more clean and readable.

Signed-off-by: Tushar Dave <tushar.n.dave@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/82571.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index 36db4df..19f4cb9 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -1677,16 +1677,18 @@ static s32 e1000_check_for_serdes_link_82571(struct e1000_hw *hw)
 			e_dbg("ANYSTATE  -> DOWN\n");
 		} else {
 			/*
-			 * Check several times, if Sync and Config
-			 * both are consistently 1 then simply ignore
-			 * the Invalid bit and restart Autoneg
+			 * Check several times, if SYNCH bit and CONFIG
+			 * bit both are consistently 1 then simply ignore
+			 * the IV bit and restart Autoneg
 			 */
 			for (i = 0; i < AN_RETRY_COUNT; i++) {
 				udelay(10);
 				rxcw = er32(RXCW);
-				if ((rxcw & E1000_RXCW_IV) &&
-				    !((rxcw & E1000_RXCW_SYNCH) &&
-				      (rxcw & E1000_RXCW_C))) {
+				if ((rxcw & E1000_RXCW_SYNCH) &&
+				    (rxcw & E1000_RXCW_C))
+					continue;
+
+				if (rxcw & E1000_RXCW_IV) {
 					mac->serdes_has_link = false;
 					mac->serdes_link_state =
 					    e1000_serdes_link_down;
-- 
1.7.10.4

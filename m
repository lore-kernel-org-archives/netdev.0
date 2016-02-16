From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] igb: Remove unnecessary flag setting in igb_set_flag_queue_pairs()
Date: Mon, 15 Feb 2016 19:21:42 -0800
Message-ID: <1455592915-82261-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455592915-82261-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shota Suzuki <suzuki_shota_t3@lab.ntt.co.jp>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:14083 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753311AbcBPDWA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2016 22:22:00 -0500
In-Reply-To: <1455592915-82261-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shota Suzuki <suzuki_shota_t3@lab.ntt.co.jp>

If VFs are enabled (max_vfs >= 1), both max_rss_queues and
adapter->rss_queues are set to 2 in the case of e1000_82576.
In this case, IGB_FLAG_QUEUE_PAIRS is always set in the default block as a
result of fall-through, thus setting it in the e1000_82576 block is not
necessary.

Signed-off-by: Shota Suzuki <suzuki_shota_t3@lab.ntt.co.jp>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 31e5f39..eb24b40 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2921,14 +2921,6 @@ void igb_set_flag_queue_pairs(struct igb_adapter *adapter,
 		/* Device supports enough interrupts without queue pairing. */
 		break;
 	case e1000_82576:
-		/* If VFs are going to be allocated with RSS queues then we
-		 * should pair the queues in order to conserve interrupts due
-		 * to limited supply.
-		 */
-		if ((adapter->rss_queues > 1) &&
-		    (adapter->vfs_allocated_count > 6))
-			adapter->flags |= IGB_FLAG_QUEUE_PAIRS;
-		/* fall through */
 	case e1000_82580:
 	case e1000_i350:
 	case e1000_i354:
-- 
2.5.0

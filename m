From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] igb: Unpair the queues when changing the number of queues
Date: Mon, 15 Feb 2016 19:21:43 -0800
Message-ID: <1455592915-82261-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455592915-82261-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shota Suzuki <suzuki_shota_t3@lab.ntt.co.jp>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35022 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753312AbcBPDWB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2016 22:22:01 -0500
In-Reply-To: <1455592915-82261-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shota Suzuki <suzuki_shota_t3@lab.ntt.co.jp>

By the commit 72ddef0506da ("igb: Fix oops caused by missing queue
pairing"), the IGB_FLAG_QUEUE_PAIRS flag can now be set when changing the
number of queues by "ethtool -L", but it is never cleared unless the igb
driver is reloaded.
This patch clears it if queue pairing becomes unnecessary as a result of
"ethtool -L".

Signed-off-by: Shota Suzuki <suzuki_shota_t3@lab.ntt.co.jp>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index eb24b40..85c47aa 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2931,6 +2931,8 @@ void igb_set_flag_queue_pairs(struct igb_adapter *adapter,
 		 */
 		if (adapter->rss_queues > (max_rss_queues / 2))
 			adapter->flags |= IGB_FLAG_QUEUE_PAIRS;
+		else
+			adapter->flags &= ~IGB_FLAG_QUEUE_PAIRS;
 		break;
 	}
 }
-- 
2.5.0

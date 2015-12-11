From: Shota Suzuki <suzuki_shota_t3@lab.ntt.co.jp>
Subject: [PATCH net-next 2/2] igb: Unpair the queues when changing the number of queues
Date: Fri, 11 Dec 2015 18:44:00 +0900
Message-ID: <1449827040-1806-2-git-send-email-suzuki_shota_t3@lab.ntt.co.jp>
References: <1449827040-1806-1-git-send-email-suzuki_shota_t3@lab.ntt.co.jp>
Cc: suzuki_shota_t3@lab.ntt.co.jp
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:51008 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753641AbbLKJpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 04:45:23 -0500
In-Reply-To: <1449827040-1806-1-git-send-email-suzuki_shota_t3@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By the commit 72ddef0506da ("igb: Fix oops caused by missing queue
pairing"), the IGB_FLAG_QUEUE_PAIRS flag can now be set when changing the
number of queues by "ethtool -L", but it is never cleared unless the igb
driver is reloaded.
This patch clears it if queue pairing becomes unnecessary as a result of
"ethtool -L".

Signed-off-by: Shota Suzuki <suzuki_shota_t3@lab.ntt.co.jp>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 340ba4fb..75ee25e 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2932,6 +2932,8 @@ void igb_set_flag_queue_pairs(struct igb_adapter *adapter,
 		 */
 		if (adapter->rss_queues > (max_rss_queues / 2))
 			adapter->flags |= IGB_FLAG_QUEUE_PAIRS;
+		else
+			adapter->flags &= ~IGB_FLAG_QUEUE_PAIRS;
 		break;
 	}
 }
-- 
1.8.3.1

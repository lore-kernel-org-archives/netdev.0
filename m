From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] e1000e: remove redundant if clause from PTP work
Date: Wed, 26 Mar 2014 11:03:31 -0700
Message-ID: <1395857013-7568-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395857013-7568-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47346 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755593AbaCZSEd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 14:04:33 -0400
In-Reply-To: <1395857013-7568-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <kubakici@wp.pl>

tx_hwtstamp_skb is always set before work is scheduled,
work is cancelled before tx_hwtstamp_skb is set to NULL.
PTP work cannot ever see tx_hwtstamp_skb set to NULL.

Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index b8d252f..f1cce59 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1148,9 +1148,6 @@ static void e1000e_tx_hwtstamp_work(struct work_struct *work)
 						     tx_hwtstamp_work);
 	struct e1000_hw *hw = &adapter->hw;
 
-	if (!adapter->tx_hwtstamp_skb)
-		return;
-
 	if (er32(TSYNCTXCTL) & E1000_TSYNCTXCTL_VALID) {
 		struct skb_shared_hwtstamps shhwtstamps;
 		u64 txstmp;
-- 
1.8.3.1

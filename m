From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 08/24] e1000e: fix stats locking in e1000_watchdog_task
Date: Wed, 13 Apr 2011 18:02:04 -0700
Message-ID: <1302742940-22141-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Flavio Leitner <fleitner@redhat.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:21314 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757102Ab1DNBCb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:02:31 -0400
In-Reply-To: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fleitner@redhat.com>

Just move the unlock down a bit because it unlocks too
early leaving a chance for get_stats64() run in parallel
while it is still accessing the stats.

Signed-off-by: Flavio Leitner <fleitner@redhat.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 8812eb2..8a3145e 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4339,7 +4339,6 @@ static void e1000_watchdog_task(struct work_struct *work)
 link_up:
 	spin_lock(&adapter->stats64_lock);
 	e1000e_update_stats(adapter);
-	spin_unlock(&adapter->stats64_lock);
 
 	mac->tx_packet_delta = adapter->stats.tpt - adapter->tpt_old;
 	adapter->tpt_old = adapter->stats.tpt;
@@ -4350,6 +4349,7 @@ link_up:
 	adapter->gorc_old = adapter->stats.gorc;
 	adapter->gotc = adapter->stats.gotc - adapter->gotc_old;
 	adapter->gotc_old = adapter->stats.gotc;
+	spin_unlock(&adapter->stats64_lock);
 
 	e1000e_update_adaptive(&adapter->hw);
 
-- 
1.7.4.2


From: David Miller <davem@davemloft.net>
Subject: [PATCH 19/31]: pkt_sched: dev_init_scheduler() does not need to
 lock qdisc tree.
Date: Thu, 17 Jul 2008 05:17:19 -0700 (PDT)
Message-ID: <20080717.051719.04384502.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51668
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757732AbYGQMRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 08:17:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We are registering the device, there is no way anyone can get
at this object's qdiscs yet in any meaningful way.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_generic.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index dd5c4e7..7e078c5 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -741,10 +741,8 @@ static void dev_init_scheduler_queue(struct net_device *dev,
 
 void dev_init_scheduler(struct net_device *dev)
 {
-	qdisc_lock_tree(dev);
 	netdev_for_each_tx_queue(dev, dev_init_scheduler_queue, &noop_qdisc);
 	dev_init_scheduler_queue(dev, &dev->rx_queue, NULL);
-	qdisc_unlock_tree(dev);
 
 	setup_timer(&dev->watchdog_timer, dev_watchdog, (unsigned long)dev);
 }
-- 
1.5.6.2.255.gbed62


From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net] net: poll tx timeout only on active tx queues
Date: Thu, 30 Jun 2016 16:58:05 +0300
Message-ID: <1467295085-9204-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Tom Herbert <tom@herbertland.com>,
	Mohamad Haj Yahia <mohamad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:33352 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752123AbcF3N6u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 09:58:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Change the netdev watchdog to poll only the real active tx queues
instead of polling all tx queues.
The netdev driver doesn't necessarily have to start/stop all the
tx queues including the inactive tx queues.

Fixes: fd2ea0a79faa ('net: Use queue aware tests throughout.')
Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 net/sched/sch_generic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index f9e0e9c..a10f0ff 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -253,7 +253,7 @@ static void dev_watchdog(unsigned long arg)
 			unsigned int i;
 			unsigned long trans_start;
 
-			for (i = 0; i < dev->num_tx_queues; i++) {
+			for (i = 0; i < dev->real_num_tx_queues; i++) {
 				struct netdev_queue *txq;
 
 				txq = netdev_get_tx_queue(dev, i);
-- 
2.8.0

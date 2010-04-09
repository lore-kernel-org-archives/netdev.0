From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: Dont use netdev_warn()
Date: Fri, 09 Apr 2010 09:26:13 +0200
Message-ID: <1270797973.2623.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:43260 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752680Ab0DIH0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 03:26:17 -0400
Received: by bwz1 with SMTP id 1so2311600bwz.21
        for <netdev@vger.kernel.org>; Fri, 09 Apr 2010 00:26:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dont use netdev_warn() in dev_cap_txqueue() and get_rps_cpu() so that we
can catch following warnings without crash.

bond0.2240 received packet on queue 6, but number of RX queues is 1
bond0.2240 received packet on queue 11, but number of RX queues is 1

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
Or maybe netdev_warn() implementation should be changed ?

 net/core/dev.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b98ddc6..ad51ffb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1986,9 +1986,9 @@ static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_index)
 {
 	if (unlikely(queue_index >= dev->real_num_tx_queues)) {
 		if (net_ratelimit()) {
-			netdev_warn(dev, "selects TX queue %d, but "
-			     "real number of TX queues is %d\n",
-			     queue_index, dev->real_num_tx_queues);
+			pr_warning("%s selects TX queue %d, but "
+				"real number of TX queues is %d\n",
+				dev->name, queue_index, dev->real_num_tx_queues);
 		}
 		return 0;
 	}
@@ -2222,9 +2222,9 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb)
 		u16 index = skb_get_rx_queue(skb);
 		if (unlikely(index >= dev->num_rx_queues)) {
 			if (net_ratelimit()) {
-				netdev_warn(dev, "received packet on queue "
-				    "%u, but number of RX queues is %u\n",
-				     index, dev->num_rx_queues);
+				pr_warning("%s received packet on queue "
+					"%u, but number of RX queues is %u\n",
+					dev->name, index, dev->num_rx_queues);
 			}
 			goto done;
 		}



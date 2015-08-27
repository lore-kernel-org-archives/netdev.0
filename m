From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH 2/4] net: sched: ignore tx_queue_len when assigning default qdisc
Date: Thu, 27 Aug 2015 21:21:37 +0200
Message-ID: <1440703299-21243-3-git-send-email-phil@nwl.cc>
References: <1440703299-21243-1-git-send-email-phil@nwl.cc>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, brouer@redhat.com,
	geert@linux-m68k.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:43022 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752242AbbH0TVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2015 15:21:41 -0400
In-Reply-To: <1440703299-21243-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since alloc_netdev_mqs() sets IFF_NO_QUEUE for drivers not initializing
tx_queue_len, it is safe to assume that if tx_queue_len is zero,
dev->priv flags always contains IFF_NO_QUEUE.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/sched/sch_generic.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 942fea8..f501b74 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -735,7 +735,7 @@ static void attach_one_default_qdisc(struct net_device *dev,
 {
 	struct Qdisc *qdisc = &noqueue_qdisc;
 
-	if (dev->tx_queue_len && !(dev->priv_flags & IFF_NO_QUEUE)) {
+	if (!(dev->priv_flags & IFF_NO_QUEUE)) {
 		qdisc = qdisc_create_dflt(dev_queue,
 					  default_qdisc_ops, TC_H_ROOT);
 		if (!qdisc) {
@@ -756,7 +756,6 @@ static void attach_default_qdiscs(struct net_device *dev)
 	txq = netdev_get_tx_queue(dev, 0);
 
 	if (!netif_is_multiqueue(dev) ||
-	    dev->tx_queue_len == 0 ||
 	    dev->priv_flags & IFF_NO_QUEUE) {
 		netdev_for_each_tx_queue(dev, attach_one_default_qdisc, NULL);
 		dev->qdisc = txq->qdisc_sleeping;
-- 
2.1.2

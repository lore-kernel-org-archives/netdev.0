From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 1/3] qdisc: adjustments for API allowing skb list
	xmits
Date: Tue, 02 Sep 2014 16:35:33 +0200
Message-ID: <20140902143524.1918.70967.stgit@dragon>
References: <20140902143254.1918.8419.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47150 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754061AbaIBOfl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 10:35:41 -0400
In-Reply-To: <20140902143254.1918.8419.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor adjustments for merge commit 53fda7f7f9e (Merge branch 'xmit_list')
that allows us to work with a list of SKBs.

Update code doc to function sch_direct_xmit().

In handle_dev_cpu_collision() use kfree_skb_list() in error handling.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/sched/sch_generic.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index a8bf9f9..5b261e9 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -93,7 +93,7 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
 		 * detect it by checking xmit owner and drop the packet when
 		 * deadloop is detected. Return OK to try the next skb.
 		 */
-		kfree_skb(skb);
+		kfree_skb_list(skb);
 		net_warn_ratelimited("Dead loop on netdevice %s, fix it urgently!\n",
 				     dev_queue->dev->name);
 		ret = qdisc_qlen(q);
@@ -110,9 +110,9 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
 }
 
 /*
- * Transmit one skb, and handle the return status as required. Holding the
- * __QDISC___STATE_RUNNING bit guarantees that only one CPU can execute this
- * function.
+ * Transmit possibly several skbs, and handle the return status as
+ * required. Holding the __QDISC___STATE_RUNNING bit guarantees that
+ * only one CPU can execute this function.
  *
  * Returns to the caller:
  *				0  - queue is empty or throttled.

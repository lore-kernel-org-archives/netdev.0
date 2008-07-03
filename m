From: David Miller <davem@davemloft.net>
Subject: [PATCH 10/39]: pkt_sched: Make netem queue agnostic.
Date: Thu, 03 Jul 2008 00:03:28 -0700 (PDT)
Message-ID: <20080703.000328.124016952.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com,
	Matheos.Worku@Sun.COM, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47502
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756927AbYGCHD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 03:03:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It just wants the root qdisc given an arbitrary qdisc,
and that is simply qdisc->dev_queue->qdisc

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_netem.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 4439aea..e882908 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -180,7 +180,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	 * skb will be queued.
 	 */
 	if (count > 1 && (skb2 = skb_clone(skb, GFP_ATOMIC)) != NULL) {
-		struct Qdisc *rootq = qdisc_dev(sch)->tx_queue.qdisc;
+		struct Qdisc *rootq = sch->dev_queue->qdisc;
 		u32 dupsave = q->duplicate; /* prevent duplicating a dup... */
 		q->duplicate = 0;
 
-- 
1.5.6


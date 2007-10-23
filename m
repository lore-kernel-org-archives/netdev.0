From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 11/12] NET: fix subqueue bugs
Date: Tue, 23 Oct 2007 18:36:46 -0400 (EDT)
Message-ID: <20071023223646.550241F81B7@havoc.gtf.org>
References: <tueoct232007613pm.likjasfdlkjdas987@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:49461 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755681AbXJWWgt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 18:36:49 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net/sched/sch_prio.c: In function =E2=80=98prio_dequeue=E2=80=99:
net/sched/sch_prio.c:139: warning: passing argument 2 of =E2=80=98netif=
_subqueue_stopped=E2=80=99 makes pointer from integer without a cast
net/sched/sch_prio.c: In function =E2=80=98rr_dequeue=E2=80=99:
net/sched/sch_prio.c:169: warning: passing argument 2 of =E2=80=98netif=
_subqueue_stopped=E2=80=99 makes pointer from integer without a cast

Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
---

diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index abd82fc..de89409 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -136,7 +136,7 @@ prio_dequeue(struct Qdisc* sch)
 		 * pulling an skb.  This way we avoid excessive requeues
 		 * for slower queues.
 		 */
-		if (!netif_subqueue_stopped(sch->dev, (q->mq ? prio : 0))) {
+		if (!__netif_subqueue_stopped(sch->dev, (q->mq ? prio : 0))) {
 			qdisc =3D q->queues[prio];
 			skb =3D qdisc->dequeue(qdisc);
 			if (skb) {
@@ -165,7 +165,7 @@ static struct sk_buff *rr_dequeue(struct Qdisc* sch=
)
 		 * for slower queues.  If the queue is stopped, try the
 		 * next queue.
 		 */
-		if (!netif_subqueue_stopped(sch->dev,
+		if (!__netif_subqueue_stopped(sch->dev,
 					    (q->mq ? q->curband : 0))) {
 			qdisc =3D q->queues[q->curband];
 			skb =3D qdisc->dequeue(qdisc);

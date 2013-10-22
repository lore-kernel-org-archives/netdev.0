From: Dave Taht <dave.taht@bufferbloat.net>
Subject: [PATCH 1/2] fq_codel: keep dropped statistic around
Date: Mon, 21 Oct 2013 18:19:56 -0700
Message-ID: <1382404797-17239-2-git-send-email-dave.taht@bufferbloat.net>
References: <1382404797-17239-1-git-send-email-dave.taht@bufferbloat.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dave Taht <dave.taht@bufferbloat.net>
To: netdev@vger.kernel.org,
	codel@lists.bufferbloat.net
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <1382404797-17239-1-git-send-email-dave.taht@bufferbloat.net>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

Having more accurate dropped information in this qdisc is useful.

Signed-off-by: Dave Taht <dave.taht@bufferbloat.net>
---
 net/sched/sch_fq_codel.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 5578628..437bc95 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -193,7 +193,6 @@ static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		list_add_tail(&flow->flowchain, &q->new_flows);
 		q->new_flow_count++;
 		flow->deficit = q->quantum;
-		flow->dropped = 0;
 	}
 	if (++sch->q.qlen <= sch->limit)
 		return NET_XMIT_SUCCESS;
-- 
1.7.9.5

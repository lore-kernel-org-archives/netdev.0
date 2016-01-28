From: Bernie Harris <bernie.harris@alliedtelesis.co.nz>
Subject: [PATCH] net_sched: drr: check for NULL pointer in drr_dequeue
Date: Thu, 28 Jan 2016 16:30:51 +1300
Message-ID: <1453951851-24501-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
References: <CAM_iQpX=x6gvuhxbN7zjbCa+zfyeh0nN86Ao_wVg6f9U3OEJew@mail.gmail.com>
Cc: davem@davemloft.net, jhs@mojatatu.com, stable@vger.kernel.org,
	bernie.harris@alliedtelesis.co.nz
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpX=x6gvuhxbN7zjbCa+zfyeh0nN86Ao_wVg6f9U3OEJew@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are cases where qdisc_dequeue_peeked can return NULL, and the result
is dereferenced later on in the function.

Similarly to the other qdisc dequeue functions, check whether the skb
pointer is NULL and if it is, goto out.

Signed-off-by: Bernie Harris <bernie.harris@alliedtelesis.co.nz>
---
 net/sched/sch_drr.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index f26bdea..a1cd778 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -403,6 +403,8 @@ static struct sk_buff *drr_dequeue(struct Qdisc *sch)
 		if (len <= cl->deficit) {
 			cl->deficit -= len;
 			skb = qdisc_dequeue_peeked(cl->qdisc);
+			if (unlikely(skb == NULL))
+				goto out;
 			if (cl->qdisc->q.qlen == 0)
 				list_del(&cl->alist);
 
-- 
2.7.0

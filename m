From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: Bug in netem reordering
Date: Thu,  5 Jan 2012 04:35:26 +0100
Message-ID: <1325734526-13428-1-git-send-email-hagen@jauu.net>
References: <CAGK4HS8YBBwPtPpQhi8gas=RBE6wao6KZ1dwbwo2rxn4qXggCQ@mail.gmail.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, shemminger@vyatta.com,
	Hagen Paul Pfeifer <hagen@jauu.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:60983 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752763Ab2AEDfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 22:35:37 -0500
In-Reply-To: <CAGK4HS8YBBwPtPpQhi8gas=RBE6wao6KZ1dwbwo2rxn4qXggCQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not now, but it looks you are correct. q->qdisc is NULL until another
additional qdisc is attached (beside tfifo). See 50612537e9ab2969312.
The following patch should work.

From: Hagen Paul Pfeifer <hagen@jauu.net>

netem: catch NULL pointer by updating the real qdisc statistic

Reported-by: Vijay Subramanian <subramanian.vijay@gmail.com>
Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/sched/sch_netem.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 06a5ceb..cc29d18 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -458,8 +458,8 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		q->counter = 0;
 
 		__skb_queue_head(&sch->q, skb);
-		q->qdisc->qstats.backlog += qdisc_pkt_len(skb);
-		q->qdisc->qstats.requeues++;
+		sch->qstats.backlog += qdisc_pkt_len(skb);
+		sch->qstats.requeues++;
 		ret = NET_XMIT_SUCCESS;
 	}
 
-- 
1.7.7.3

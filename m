From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH v2] pkt_sched: Remove smp_wmb() in qdisc_watchdog()
Date: Mon, 22 Dec 2008 07:57:05 +0000
Message-ID: <20081222075705.GA4419@ff.dom.local>
References: <20081219113047.GA17826@ff.dom.local> <20081219114125.GB17826@ff.dom.local> <20081219181851.7cda3fc1@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:30515 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752786AbYLVH5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 02:57:12 -0500
Received: by ey-out-2122.google.com with SMTP id 22so197126eye.37
        for <netdev@vger.kernel.org>; Sun, 21 Dec 2008 23:57:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081219181851.7cda3fc1@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 19, 2008 at 06:18:51PM -0800, Stephen Hemminger wrote:
...
> The barrier was copied from earlier version of tbf is unnecessary.

So I resend this patch with only a changelog updated

Thanks,
Jarek P.
---------->
While implementing a TCQ_F_THROTTLED flag there was used an smp_wmb()
in qdisc_watchdog(). Stephen Hemminger acknowledged the barrier was
copied from earlier version of tbf and is unnecessaray, so it's
removed here.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/sch_api.c   |    1 -
 net/sched/sch_netem.c |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 6bc29e8..0fc4a18 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -450,7 +450,6 @@ static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
 						 timer);
 
 	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
-	smp_wmb();
 	__netif_schedule(qdisc_root(wd->qdisc));
 
 	return HRTIMER_NORESTART;
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 7e78f1c..d876b87 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -266,7 +266,6 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 	struct netem_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 
-	smp_mb();
 	if (sch->flags & TCQ_F_THROTTLED)
 		return NULL;
 

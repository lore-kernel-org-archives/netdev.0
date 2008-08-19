From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Schedule correct qdisc in watchdog.
Date: Mon, 18 Aug 2008 20:51:53 -0700 (PDT)
Message-ID: <20080818.205153.07023796.davem@davemloft.net>
References: <20080818103559.GA6548@ff.dom.local>
	<20080818104355.GB6548@ff.dom.local>
	<20080818110625.GA6910@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, denys@visp.net.lb
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34903
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752770AbYHSDvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 23:51:53 -0400
In-Reply-To: <20080818110625.GA6910@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 18 Aug 2008 11:06:25 +0000

> On Mon, Aug 18, 2008 at 10:43:56AM +0000, Jarek Poplawski wrote:
> ...
> > Sooory!!! Forget this all: it looks like your patch is damn right!
> 
> So, I guess, you could merge this patch to net-2.6, so Denys could
> test this all later without additional patching?!

Here is the final patch I put into net-2.6, thanks.

pkt_sched: Never schedule non-root qdiscs.

Based upon initial discovery and patch by Jarek Poplawski.

The qdisc watchdogs can be attached to any qdisc, not just the root,
so make sure we schedule the correct one.

CBQ has a similar bug.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_api.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index c8dc72e..98c0084 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -426,7 +426,7 @@ static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
 
 	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
 	smp_wmb();
-	__netif_schedule(wd->qdisc);
+	__netif_schedule(qdisc_root(wd->qdisc));
 
 	return HRTIMER_NORESTART;
 }
-- 
1.5.6.5.GIT


From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Schedule correct qdisc in watchdog.
Date: Mon, 18 Aug 2008 01:39:54 -0700 (PDT)
Message-ID: <20080818.013954.187452037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33189
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751216AbYHRIjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 04:39:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jarek, I bet this is what was causing the crash you were trying to fix
yesterday.

But that's just my newbie hunch :-)

pkt_sched: Never scheduler non-root qdiscs.

The qdisc watchdogs can be attached to any qdisc,
not just the root, so make sure we schedule the
correct one.

Signed-off-by: David S. Miller <davem@davemloft.net>

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

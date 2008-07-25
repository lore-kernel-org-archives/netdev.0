From: David Miller <davem@davemloft.net>
Subject: Re: [lockdep warning] AOE / networking: aoenet_xmit:
 noop_qdisc.q.lock, INFO: inconsistent lock state at 0000000000000370
Date: Thu, 24 Jul 2008 23:25:21 -0700 (PDT)
Message-ID: <20080724.232521.193699299.davem@davemloft.net>
References: <20080721.134608.75595942.davem@davemloft.net>
	<20080725062009.GA6476@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ecashin@coraid.com, axboe@suse.de, mike.miller@hp.com,
	a.p.zijlstra@chello.nl, rjw@sisk.pl
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42140
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751477AbYGYGZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 02:25:22 -0400
In-Reply-To: <20080725062009.GA6476@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 25 Jul 2008 08:20:09 +0200

> not sure whether it got reported already, but -tip testing triggered 
> this new ATA over Ethernet lockdep warning on latest -git:

Thanks for the report, does this fix it?

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 4ac7e3a..43abd4d 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -736,9 +736,9 @@ static void shutdown_scheduler_queue(struct net_device *dev,
 		dev_queue->qdisc = qdisc_default;
 		dev_queue->qdisc_sleeping = qdisc_default;
 
-		spin_lock(root_lock);
+		spin_lock_bh(root_lock);
 		qdisc_destroy(qdisc);
-		spin_unlock(root_lock);
+		spin_unlock_bh(root_lock);
 	}
 }
 

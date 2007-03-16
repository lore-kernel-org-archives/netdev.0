From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET_SCHED 00/10]: ktime clocksource + hrtimer
Date: Fri, 16 Mar 2007 13:45:32 +0100
Message-ID: <45FA916C.2080501@trash.net>
References: <20070316053018.22744.76883.sendpatchset@localhost.localdomain> <20070316.023510.41635847.davem@davemloft.net> <45FA6682.10303@trash.net> <20070316124124.GK521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000201010908000401020104"
Cc: David Miller <davem@davemloft.net>, devik@cdi.cz,
	netdev@vger.kernel.org, shemminger@linux-foundation.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53084 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753490AbXCPMpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 08:45:39 -0400
In-Reply-To: <20070316124124.GK521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000201010908000401020104
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Thomas Graf wrote:
> * Patrick McHardy <kaber@trash.net> 2007-03-16 10:42
> 
>>David Miller wrote:
>>
>>>It would be nice to figure out why CBQ isn't working for
>>>you, I know at least some folks have used it successfully
>>>at some point.
>>
>>Probably my own incompetence, I'll see if I can find some
>>scripts that are known to work.
> 
> 
> I'll complain if it stops working, I'm still using CBQ to
> keep rsync and other bulk flows from interfering with ssh.
> HTB just doesn't have the same homy touch :-)

:)

I managed to find a working script in the meantime and discovered
a bug in my changes, with this patch on top it seems to works fine.


--------------000201010908000401020104
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET_SCHED]: sch_cbq: fix watchdog scheduled too late

q->now is increased during dequeue and doesn't contain the current time
afterwards, resulting in a too large timeout value for the qdisc watchdog.
Use "now" instead, which still contains the current time.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit b832b2f5f076cdd050b5b142dae10fcca874a4eb
tree 19b7dc63ace14cc4a5c0d6d6561487185aef8fdd
parent 9b85e807e5971a7ceff45ac450392909ea1c6954
author Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 13:12:17 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 13:12:17 +0100

 net/sched/sch_cbq.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 0491fad..d83414d 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1070,7 +1070,7 @@ cbq_dequeue(struct Qdisc *sch)
 		sch->qstats.overlimits++;
 		if (q->wd_expires)
 			qdisc_watchdog_schedule(&q->watchdog,
-						q->now + q->wd_expires);
+						now + q->wd_expires);
 	}
 	return NULL;
 }

--------------000201010908000401020104--

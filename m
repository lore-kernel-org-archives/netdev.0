From: "David S. Miller" <davem@redhat.com>
Subject: Re: assertion failure at net/sched/sch_generic.c(530)
Date: Tue, 23 Sep 2003 17:42:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030923174254.03218556.davem@redhat.com>
References: <3F70E12A.1090204@pacbell.net>
	<20030923170216.32eaff53.davem@redhat.com>
	<20030923170858.3c3b0b8e.davem@redhat.com>
	<3F70E8EE.9070606@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Brownell <david-b@pacbell.net>
In-Reply-To: <3F70E8EE.9070606@pacbell.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 23 Sep 2003 17:44:30 -0700
David Brownell <david-b@pacbell.net> wrote:

> > Qdiscs don't get unlinked in qdisc_destroy() unless that config
> > is enabled.  If you have it off, that explains the bug and the
> > fix is obvious.
> 
> Well, obvious to people who know that part of the stack ... :)

Honest, it's a pretty simple bug :)  Try this patch:

--- net/sched/sch_generic.c.~1~	Tue Sep 23 17:52:22 2003
+++ net/sched/sch_generic.c	Tue Sep 23 17:52:28 2003
@@ -416,7 +416,6 @@
 
 	dev = qdisc->dev;
 
-#ifdef CONFIG_NET_SCHED
 	if (dev) {
 		struct Qdisc *q, **qp;
 		for (qp = &qdisc->dev->qdisc_list; (q=*qp) != NULL; qp = &q->next) {
@@ -428,7 +427,6 @@
 	}
 #ifdef CONFIG_NET_ESTIMATOR
 	qdisc_kill_estimator(&qdisc->stats);
-#endif
 #endif
 	if (ops->reset)
 		ops->reset(qdisc);

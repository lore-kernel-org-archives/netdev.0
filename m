From: Thomas Graf <tgraf@suug.ch>
Subject: Re: assertion (dev->qdisc_list == NULL) failed at net/sched/sch_generic.c(530)
Date: Wed, 24 Sep 2003 21:49:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030924194916.GH21544@rei.reeler.org>
References: <20030924161152.GA8683@vana.vc.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Petr Vandrovec <vandrove@vc.cvut.cz>
Content-Disposition: inline
In-Reply-To: <20030924161152.GA8683@vana.vc.cvut.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi

> # insmod vmnet; netifup vmnet1; ifconfig vmnet1 1.2.3.4 up
> /dev/vmnet: open called by PID 7413 (vmnet-netifup)
> /dev/vmnet: port on hub 1 successfully opened
> # ifconfig vmnet1 down
> # rmmod vmnet
> KERNEL: assertion (dev->qdisc_list == NULL) failed at net/sched/sch_generic.c(530)

The following patch should solve the issue. I'm not sure yet
whetever it's a good idea to apply the patch to the tree, but
as every dev has a qdisc even if CONFIG_NET_SCHED is not set,
it would make sense.

	Thomas


Index: net/sched/sch_generic.c
===================================================================
RCS file: /cvs/tgr/linux-26/net/sched/sch_generic.c,v
retrieving revision 1.1.1.1.2.1
diff -u -r1.1.1.1.2.1 sch_generic.c
--- net/sched/sch_generic.c	21 Sep 2003 02:11:22 -0000	1.1.1.1.2.1
+++ net/sched/sch_generic.c	24 Sep 2003 19:36:19 -0000
@@ -398,7 +398,6 @@
 
 	dev = qdisc->dev;
 
-#ifdef CONFIG_NET_SCHED
 	if (dev) {
 		struct Qdisc *q, **qp;
 		for (qp = &qdisc->dev->qdisc_list; (q=*qp) != NULL; qp = &q->next) {
@@ -411,7 +410,6 @@
 #ifdef CONFIG_NET_ESTIMATOR
 	qdisc_kill_estimator(&qdisc->stats);
 #endif
-#endif
 	if (ops->reset)
 		ops->reset(qdisc);
 	if (ops->destroy)

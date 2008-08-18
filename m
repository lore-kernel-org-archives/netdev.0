From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Schedule correct qdisc in watchdog.
Date: Mon, 18 Aug 2008 03:10:03 -0700 (PDT)
Message-ID: <20080818.031003.115715822.davem@davemloft.net>
References: <20080818091011.GC5434@ff.dom.local>
	<20080818.023105.01989851.davem@davemloft.net>
	<20080818094727.GA6388@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57440
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751453AbYHRKKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 06:10:03 -0400
In-Reply-To: <20080818094727.GA6388@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 18 Aug 2008 09:47:27 +0000

> Maybe I wrote this wrong. wd->qdisc stores qdisc from the
> qdisc_watchdog_init() time, and this could be &noop_qdisc.
> So qdisc_root() would schedule wrong qdisc later. BTW, my
> version would probably do the same for root qdisc, but in
> these tests there was a problem with leafs.

qdisc_watchdog_init() is only invoked by:

net/sched/sch_cbq.c:	qdisc_watchdog_init(&q->watchdog, sch);
net/sched/sch_hfsc.c:	qdisc_watchdog_init(&q->watchdog, sch);
net/sched/sch_htb.c:	qdisc_watchdog_init(&q->watchdog, sch);
net/sched/sch_netem.c:	qdisc_watchdog_init(&q->watchdog, sch);
net/sched/sch_tbf.c:	qdisc_watchdog_init(&q->watchdog, sch);

These "q" things are the scheduler private structs, and 'sch' of the
qdisc type indicated by the source file the code in question resides
:-)

This watchdog is different from the TX timeout watchdog which is
implemented in net/sch/sch_generic.c, which you may be confusing this
qdisc_watchdog_init() one with.

The watchdog we are discussing here is purely for qdiscs where time
based events modify qdisc state (such as making new quotas available
for a flow, thus making certain packets eligible for scheduling that
were not beforehand)

So really, it cannot be &noop_qdisc as far as I can see.
:-)

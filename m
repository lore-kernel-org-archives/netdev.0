From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH]: Schedule correct qdisc in watchdog.
Date: Mon, 18 Aug 2008 10:43:56 +0000
Message-ID: <20080818104355.GB6548@ff.dom.local>
References: <20080818091011.GC5434@ff.dom.local> <20080818.023105.01989851.davem@davemloft.net> <20080818094727.GA6388@ff.dom.local> <20080818.031003.115715822.davem@davemloft.net> <20080818103559.GA6548@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:27423 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbYHRKoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 06:44:02 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1109748nfc.21
        for <netdev@vger.kernel.org>; Mon, 18 Aug 2008 03:44:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080818103559.GA6548@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 18, 2008 at 10:35:59AM +0000, Jarek Poplawski wrote:
> On Mon, Aug 18, 2008 at 03:10:03AM -0700, David Miller wrote:
> > From: Jarek Poplawski <jarkao2@gmail.com>
> > Date: Mon, 18 Aug 2008 09:47:27 +0000
> > 
> > > Maybe I wrote this wrong. wd->qdisc stores qdisc from the
> > > qdisc_watchdog_init() time, and this could be &noop_qdisc.
> > > So qdisc_root() would schedule wrong qdisc later. BTW, my
> > > version would probably do the same for root qdisc, but in
> > > these tests there was a problem with leafs.
> > 
> > qdisc_watchdog_init() is only invoked by:
> > 
> > net/sched/sch_cbq.c:	qdisc_watchdog_init(&q->watchdog, sch);
> > net/sched/sch_hfsc.c:	qdisc_watchdog_init(&q->watchdog, sch);
> > net/sched/sch_htb.c:	qdisc_watchdog_init(&q->watchdog, sch);
> > net/sched/sch_netem.c:	qdisc_watchdog_init(&q->watchdog, sch);
> > net/sched/sch_tbf.c:	qdisc_watchdog_init(&q->watchdog, sch);
> > 
> > These "q" things are the scheduler private structs, and 'sch' of the
> > qdisc type indicated by the source file the code in question resides
> > :-)
> > 
> > This watchdog is different from the TX timeout watchdog which is
> > implemented in net/sch/sch_generic.c, which you may be confusing this
> > qdisc_watchdog_init() one with.
> 
> I don't think I wrote anything which could suggest I confused these
> watchdogs.
> 
> > 
> > The watchdog we are discussing here is purely for qdiscs where time
> > based events modify qdisc state (such as making new quotas available
> > for a flow, thus making certain packets eligible for scheduling that
> > were not beforehand)
> > 
> > So really, it cannot be &noop_qdisc as far as I can see.
> > :-)
> 
> Sure, ->sch is never &noop_qdisc, but your qdisc_root(sch) most
> probably is at the moment of qdisc_watchdog_init(). My version
> can do the same if eg. htb is root qdisc because at the moment
> of qdisc_create() qdisc_sleeping could be &noop_qdisc as well.
> But, in case we have a qdisc_sleeping already, it should work.
> 
> So these patches will stop break things, but these qdisc_watchdog()
> calls would be sometimes/always useless.

Sooory!!! Forget this all: it looks like your patch is damn right!

Jarek P.

PS: I'm still sleeping...

From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: + gen_estimator-fix-locking-and-timer-related-bugs.patch added to -mm tree
Date: Mon, 9 Jul 2007 09:47:23 +0200
Message-ID: <20070709074722.GA1851@ff.dom.local>
References: <1183646029.4069.11.camel@ranko-fc2.spidernet.net> <1183651165.4069.26.camel@ranko-fc2.spidernet.net> <20070706061420.GA1846@ff.dom.local> <20070706062629.GC1846@ff.dom.local> <20070706064523.GA2144@ff.dom.local> <1183727654.6389.3.camel@ranko-fc2.spidernet.net> <468E4FD9.4060702@trash.net> <1183733732.6389.26.camel@ranko-fc2.spidernet.net> <1183794918.30237.69.camel@localhost.localdomain> <Pine.LNX.4.64.0707071704370.1808@x2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ranko Zivojnovic <ranko@spidernet.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:50068 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751124AbXGIHip (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jul 2007 03:38:45 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707071704370.1808@x2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 07, 2007 at 05:10:54PM +0200, Patrick McHardy wrote:
> On Sat, 7 Jul 2007, Ranko Zivojnovic wrote:
> 
> >>On Fri, 2007-07-06 at 16:21 +0200, Patrick McHardy wrote:
> >>>There is at least one ABBA deadlock, est_timer does:
> >>>
> >>>read_lock(&est_lock)
> >>>spin_lock(e->stats_lock) (which is dev->queue_lock)
> >>>
> >>>and qdisc_destroy calls htb_destroy under dev->queue_lock, which
> >>>calls htb_destroy_class, then gen_kill_estimator and this
> >>>write_locks est_lock.
> >>>
> >>>I can't see the problem above though, the qdisc_run path only takes
> >>>dev->queue_lock. Please enable lockdep and post the output if any.
> >>
> >
> >I've got both code paths this time. It shows exactly the ABBA deadlock
> >you describe above. The details are below.
> 
> 
> Thanks. I'm still wondering whats causing the other lockup
> you're seeing.
> 
> >Maybe the appropriate way to fix this would to call gen_kill_estimator,
> >with the appropriate lock order, before the call to qdisc_destroy, so
> >when dev->queue_lock is taken for qdisc_destroy - the structure is
> >already off the list.
> 
> 
> Probably easier to just kill est_lock and use rcu lists.
> I'm currently travelling, I'll look into it tomorrow.
> 

Congratulations to both of you!

Ranko, it looks like you have some licence to kill!
(I hope bugs only...)

Cheers,
Jarek P.

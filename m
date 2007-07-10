From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: + gen_estimator-fix-locking-and-timer-related-bugs.patch added to -mm tree
Date: Tue, 10 Jul 2007 15:10:34 +0200
Message-ID: <20070710131033.GC3130@ff.dom.local>
References: <1183733732.6389.26.camel@ranko-fc2.spidernet.net> <1183794918.30237.69.camel@localhost.localdomain> <Pine.LNX.4.64.0707071704370.1808@x2> <1183984861.18656.21.camel@ranko-fc2.spidernet.net> <46923DA8.9010208@trash.net> <1183999420.18656.54.camel@ranko-fc2.spidernet.net> <20070710073447.GA1870@ff.dom.local> <1184062147.11966.37.camel@localhost.localdomain> <20070710121756.GB3130@ff.dom.local> <4693797C.1020408@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ranko Zivojnovic <ranko@spidernet.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:41205 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751280AbXGJNB5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 09:01:57 -0400
Content-Disposition: inline
In-Reply-To: <4693797C.1020408@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 10, 2007 at 02:20:12PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
> > On Tue, Jul 10, 2007 at 01:09:07PM +0300, Ranko Zivojnovic wrote:
> > 
> >>However I decided not to use _rcu based iteration neither the
> >>rcu_read_lock() after going through the RCU documentation and a bunch of
> >>examples in kernel that iterate through the lists using non _rcu macros
> >>and do list_del_rcu() just fine.
> >>
> >>For readability, the reference to list_del_rcu as well as call_rcu, I
> >>believe, should be enough of the indication. Please do correct me if I
> >>am wrong here.
> > 
> > 
> > It's only my opinion, and it's probably not very popular at least
> > at net/ code, so it's more about general policy and not this
> > particular code. But:
> > - if somebody is looking after some rcu related problems, why can't
> > he/she spare some time by omitting lists without _rcu and not
> > analyzing why/how such lists are used and locked?
> 
> 
> RCU is used for the read-side, using it on the write-side just makes
> things *less* understandable IMO. It will look like the read-side
> but still do modifications.
> 

>From Documentation/RCU/checklist:

"9.      All RCU list-traversal primitives, which include
        list_for_each_rcu(), list_for_each_entry_rcu(),
        list_for_each_continue_rcu(), and list_for_each_safe_rcu(),
        must be within an RCU read-side critical section.  RCU
        read-side critical sections are delimited by rcu_read_lock()
        and rcu_read_unlock(), or by similar primitives such as
        rcu_read_lock_bh() and rcu_read_unlock_bh().

        Use of the _rcu() list-traversal primitives outside of an
        RCU read-side critical section causes no harm other than
        a slight performance degradation on Alpha CPUs.  It can
        also be quite helpful in reducing code bloat when common
        code is shared between readers and updaters."

So, it seems, it's a question of taste about what is this bloat.

I'd certainly agree with you if the write-side looks like in
examples from documentation: there is always a few lines of code
with some spinlocks. But here we see no locks and no comments,
so each time we have to guess which of the supposed here locks
is needed for RCU or maybe for the lists without "rcu".

Sorry, for messing here with my private opinions: I really
shouldn't start this theme.

Jarek P.

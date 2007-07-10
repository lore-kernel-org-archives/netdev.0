From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: + gen_estimator-fix-locking-and-timer-related-bugs.patch added to -mm tree
Date: Tue, 10 Jul 2007 15:51:52 +0200
Message-ID: <20070710135152.GD3130@ff.dom.local>
References: <1183794918.30237.69.camel@localhost.localdomain> <Pine.LNX.4.64.0707071704370.1808@x2> <1183984861.18656.21.camel@ranko-fc2.spidernet.net> <46923DA8.9010208@trash.net> <1183999420.18656.54.camel@ranko-fc2.spidernet.net> <20070710073447.GA1870@ff.dom.local> <1184062147.11966.37.camel@localhost.localdomain> <20070710121756.GB3130@ff.dom.local> <4693797C.1020408@trash.net> <20070710131033.GC3130@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ranko Zivojnovic <ranko@spidernet.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:54586 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753437AbXGJNnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 09:43:13 -0400
Content-Disposition: inline
In-Reply-To: <20070710131033.GC3130@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 10, 2007 at 03:10:34PM +0200, Jarek Poplawski wrote:
> On Tue, Jul 10, 2007 at 02:20:12PM +0200, Patrick McHardy wrote:
> > Jarek Poplawski wrote:
> > > On Tue, Jul 10, 2007 at 01:09:07PM +0300, Ranko Zivojnovic wrote:
> > > 
> > >>However I decided not to use _rcu based iteration neither the
> > >>rcu_read_lock() after going through the RCU documentation and a bunch of
> > >>examples in kernel that iterate through the lists using non _rcu macros
> > >>and do list_del_rcu() just fine.
> > >>
> > >>For readability, the reference to list_del_rcu as well as call_rcu, I
> > >>believe, should be enough of the indication. Please do correct me if I
> > >>am wrong here.
> > > 
> > > 
> > > It's only my opinion, and it's probably not very popular at least
> > > at net/ code, so it's more about general policy and not this
> > > particular code. But:
> > > - if somebody is looking after some rcu related problems, why can't
> > > he/she spare some time by omitting lists without _rcu and not
> > > analyzing why/how such lists are used and locked?
> > 
> > 
> > RCU is used for the read-side, using it on the write-side just makes
> > things *less* understandable IMO. It will look like the read-side
> > but still do modifications.
> > 
> 
> From Documentation/RCU/checklist:
> 
> "9.      All RCU list-traversal primitives, which include
>         list_for_each_rcu(), list_for_each_entry_rcu(),
>         list_for_each_continue_rcu(), and list_for_each_safe_rcu(),
>         must be within an RCU read-side critical section.  RCU
>         read-side critical sections are delimited by rcu_read_lock()
>         and rcu_read_unlock(), or by similar primitives such as
>         rcu_read_lock_bh() and rcu_read_unlock_bh().

...But, on the other hand, Ranko didn't use any of these primitives...
So, first I said he should use this, and than I asked why there was
no rcu_read_locks around... I really start to amaze with my consistency.

I hope some day you'll forgive me (no hurry, I can wait).

Cheers,
Jarek P. 

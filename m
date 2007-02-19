From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [Bugme-new] [Bug 7974] New: BUG: scheduling while atomic: swapper/0x10000100/0
Date: Mon, 19 Feb 2007 16:21:14 -0500
Message-ID: <20070219212113.GB3020@gospo.rdu.redhat.com>
References: <20070209133802.01286bbb.akpm@linux-foundation.org> <20070213202905.GA26818@gospo.rdu.redhat.com> <200702132226.l1DMQS22009230@death.nxdomain.ibm.com> <20070213.143243.78711492.davem@davemloft.net> <20070213230803.GB26818@gospo.rdu.redhat.com> <200702132333.l1DNX022012433@death.nxdomain.ibm.com> <20070214013130.GD26818@gospo.rdu.redhat.com> <200702140211.l1E2BF22031298@death.nxdomain.ibm.com> <20070215210019.GB30353@gospo.rdu.redhat.com> <200702152345.l1FNjN22000583@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	lpiccilli@gelre.com.br, bugme-daemon@bugzilla.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56374 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932664AbXBSVWM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 16:22:12 -0500
Content-Disposition: inline
In-Reply-To: <200702152345.l1FNjN22000583@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 15, 2007 at 03:45:23PM -0800, Jay Vosburgh wrote:
> 
> 	For the short term, yes, I don't have any disagreement with
> switching the timer based stuff over to workqueues.  Basically a one for
> one replacement to get the functions in a process context and tweak the
> locking.

I did some testing of mine last week and my patch definitely has some
issues.  I'm running into a problem that is similar to the thread
started last week titled "BUG] RTNL and flush_scheduled_work
deadlocks" but I think I can patch around that if needed.

> 
> 	I do think we're having a little confusion over details of
> terminology; if I'm not mistaken, you're thinking that workqueue means
> single threaded: even though each individual "monitor thingie" is a
> separate piece of work, they still can't collide.
> 
> 	That's true, but (unless I've missed a call somewhere) there
> isn't a "wq_pause_for_a_bit" type of call (that, e.g., waits for
> anything running to stop, then doesn't run any further work until we
> later tell it to), so suspending all of the periodic things running for
> the bond is more hassle than if there's just one schedulable work thing,
> which internally calls the right functions to do the various things.
> This is also single threaded, but easier to stop and start.  It seems to
> be simpler to have multiple link monitors running in such a system as
> well (without having them thrashing the link state as would happen now).
> 

I see by looking at your patch that you keep a list of timers and only
schedule work for the event that will happen next.  I've seen timer
implementations like this before and feel its reasonable.  It would be
good to account for skew, but other than that it seems like a reasonable
solution -- though it is too bad that workqueues and their behavior seem
like somewhat of a mystery to most and cause people to code around them
(I don't blame you one bit).

I also plan to start testing your patch later this week and will let you
know what I find.

-andy



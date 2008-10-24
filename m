From: David Miller <davem@davemloft.net>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Fri, 24 Oct 2008 16:31:11 -0700 (PDT)
Message-ID: <20081024.163111.244324800.davem@davemloft.net>
References: <20081010115518.GA3159@tservice.net.ru>
	<20081010115725.GD19487@elte.hu>
	<200810250025.35734.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, s0mbre@tservice.net.ru, a.p.zijlstra@chello.nl,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org, efault@gmx.de
To: rjw@sisk.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59044
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751295AbYJXXbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 19:31:34 -0400
In-Reply-To: <200810250025.35734.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Sat, 25 Oct 2008 00:25:34 +0200

> On Friday, 10 of October 2008, Ingo Molnar wrote:
> > 
> > * Evgeniy Polyakov <s0mbre@tservice.net.ru> wrote:
> > 
> > > On Fri, Oct 10, 2008 at 01:42:45PM +0200, Ingo Molnar (mingo@elte.hu) wrote:
> > > > > vanilla 27: 347.222
> > > > > no TSO/GSO: 357.331
> > > > > no hrticks: 382.983
> > > > > no balance: 389.802
> > > > 
> > > > okay. The target is 470 MB/sec, right? (Assuming the workload is sane 
> > > > and 'fixing' it does not mean we have to schedule worse.)
> > > 
> > > Well, that's where I started/stopped, so maybe we will even move
> > > further? :)
> > 
> > that's the right attitude ;)
> 
> Can anyone please tell me if there was any conclusion of this thread?

I made some more analysis in private with Ingo and Peter Z. and found
that the tbench decreases correlate pretty much directly with the
ongoing increasing cpu cost of wake_up() and friends in the fair
scheduler.

The largest increase in computational cost of wakeups came in 2.6.27
when the hrtimer bits got added, it more than tripled the cost of a wakeup.
In 2.6.28-rc1 the hrtimer feature has been disabled, but I think that
should be backports into the 2.6.27-stable branch.

So I think that should be backported, and meanwhile I'm spending some
time in the background trying to replace the fair schedulers RB tree
crud with something faster so maybe at some point we can recover all
of the regressions in this area caused by the CFS code.

From: Bodo Eggert <7eggert@gmx.de>
Subject: Re: GFP_ATOMIC page allocation failures.
Date: Fri, 4 Apr 2008 13:35:48 +0200 (CEST)
Message-ID: <Pine.LNX.4.58.0804041307500.9036@be10.lrz>
References: <adYyJ-20N-11@gated-at.bofh.it> <aeqF6-45P-29@gated-at.bofh.it>
 <E1Jhib4-0000md-FP@be1.7eggert.dyndns.org> <200804042159.54220.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: 7eggert@gmx.de, Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Chris Snook <csnook@redhat.com>,
	Dave Jones <davej@codemonkey.org.uk>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.177]:63306 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751652AbYDDLhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 07:37:00 -0400
In-Reply-To: <200804042159.54220.nickpiggin@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Apr 2008, Nick Piggin wrote:

> On Friday 04 April 2008 20:52, Bodo Eggert wrote:
> > Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> > > On Thursday 03 April 2008 05:18, Jeff Garzik wrote:
> > >> Turning to Nick's comment,
> > >>
> > >> > It's still actually nice to know how often it is happening even for
> > >> > these known good sites because too much can indicate a problem and
> > >> > that you could actually bring performance up by tuning some things.
> > >>
> > >> then create a counter or acculuation buffer somewhere.
> > >>
> > >> We don't need spew every time there is memory pressure of this
> > >> magnitude.
> > >
> > > Not a complete solution. Counter would be nice, but you need backtraces
> > > and want a way to more proactively warn the user/tester/developer.
> > >
> > > I agree that I don't exactly like adding nowarns around, and I don't
> > > think places like driver writers should have to know about this stuff.
> >
> > What about reverse ratelimiting: If the limit is reached, a backtrace will
> > be generated (and, off cause, positively ratelimited)?
> 
> I was thinking about that. I got as far as writing a simple patch to
> printk  so that it would not start to trigger until it gets a 2nd event
> within 'n' jiffies of the first.

I think there was a standalone ratelimit function. I'd use it like this:

static atomic_alloc_ratelimit; /* needs to be initialized ... */

{
	...
	if (success)
		return mem;
	if(!debug && ratelimit(atomic_alloc_ratelimit))
		return err_ptr(-ENOMEM);
	if (printk_ratelimit(first line) > 0) {
		printk(rest);
	}
}

> But actually developers do sometimes want see the event even if it is
> relatively infrequent...

You shouldn't frighten the users either. /proc/sys/vm/debug?

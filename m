From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: GFP_ATOMIC page allocation failures.
Date: Fri, 4 Apr 2008 21:59:53 +1100
Message-ID: <200804042159.54220.nickpiggin@yahoo.com.au>
References: <adYyJ-20N-11@gated-at.bofh.it> <aeqF6-45P-29@gated-at.bofh.it> <E1Jhib4-0000md-FP@be1.7eggert.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Chris Snook <csnook@redhat.com>,
	Dave Jones <davej@codemonkey.org.uk>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: 7eggert@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp118.mail.mud.yahoo.com ([209.191.84.167]:47468 "HELO
	smtp118.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755071AbYDDLAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 07:00:03 -0400
In-Reply-To: <E1Jhib4-0000md-FP@be1.7eggert.dyndns.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 04 April 2008 20:52, Bodo Eggert wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> > On Thursday 03 April 2008 05:18, Jeff Garzik wrote:
> >> Turning to Nick's comment,
> >>
> >> > It's still actually nice to know how often it is happening even for
> >> > these known good sites because too much can indicate a problem and
> >> > that you could actually bring performance up by tuning some things.
> >>
> >> then create a counter or acculuation buffer somewhere.
> >>
> >> We don't need spew every time there is memory pressure of this
> >> magnitude.
> >
> > Not a complete solution. Counter would be nice, but you need backtraces
> > and want a way to more proactively warn the user/tester/developer.
> >
> > I agree that I don't exactly like adding nowarns around, and I don't
> > think places like driver writers should have to know about this stuff.
>
> What about reverse ratelimiting: If the limit is reached, a backtrace will
> be generated (and, off cause, positively ratelimited)?

I was thinking about that. I got as far as writing a simple patch to
printk  so that it would not start to trigger until it gets a 2nd event
within 'n' jiffies of the first.

But actually developers do sometimes want see the event even if it is
relatively infrequent...

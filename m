From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: GFP_ATOMIC page allocation failures.
Date: Wed, 2 Apr 2008 08:54:37 -0700
Message-ID: <20080402085437.7d9abf1f.akpm@linux-foundation.org>
References: <20080401235609.GA6947@codemonkey.org.uk>
	<47F32789.2070703@redhat.com>
	<20080402005646.f8df1c1b.akpm@linux-foundation.org>
	<200804022012.58760.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Chris Snook <csnook@redhat.com>,
	Dave Jones <davej@codemonkey.org.uk>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41884 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754034AbYDBPzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 11:55:47 -0400
In-Reply-To: <200804022012.58760.nickpiggin@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Apr 2008 20:12:58 +1100 Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> On Wednesday 02 April 2008 18:56, Andrew Morton wrote:
> 
> > > Limiting this to once per boot should suffice for debugging purposes.
> > > Even if you manage to concoct a bug that always survives the first
> > > failure, you should be able to take the hint when you keep seeing this
> > > in dmesg.
> >
> > The appropriate thing to do here is to convert known-good drivers (such as
> > e1000[e]) to use __GFP_NOWARN.
> >
> > Unfortunately netdev_alloc_skb() went and assumed GFP_ATOMIC, but I guess
> > we can dive below the covers and use __netdev_alloc_skb():
> 
> It's still actually nice to know how often it is happening even for
> these known good sites because too much can indicate a problem and
> that you could actually bring performance up by tuning some things.

Yes, it's useful debugging.  It tells us when we mucked up the page
allocator.

It also tells us when we mucked up the net driver - I doubt if we (or at
least, I) would have discovered that e1000 does a 32k allocation for a 5k(?)
frame if this warning wasn't coming out.

> So I think that the messages should stay, and they should print out
> some header to say that it is only a warning and if not happening
> too often then it is not a problem, and if it is continually
> happening then please try X or Y or post a message to lkml...

Yes, I suppose so.

hm, tricky.

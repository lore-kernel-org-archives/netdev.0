From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: GFP_ATOMIC page allocation failures.
Date: Wed, 2 Apr 2008 10:33:55 -0700
Message-ID: <20080402103355.77ef22ff.akpm@linux-foundation.org>
References: <20080401235609.GA6947@codemonkey.org.uk>
	<200804021228.16875.nickpiggin@yahoo.com.au>
	<20080402013551.GA8361@codemonkey.org.uk>
	<47F32789.2070703@redhat.com>
	<20080402005646.f8df1c1b.akpm@linux-foundation.org>
	<47F3C0A8.9090300@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Chris Snook <csnook@redhat.com>,
	Dave Jones <davej@codemonkey.org.uk>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54288 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756072AbYDBRiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 13:38:08 -0400
In-Reply-To: <47F3C0A8.9090300@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 02 Apr 2008 13:21:44 -0400 Jeff Garzik <jeff@garzik.org> wrote:

> Andrew Morton wrote:
> > The appropriate thing to do here is to convert known-good drivers (such as
> > e1000[e]) to use __GFP_NOWARN.
> > 
> > Unfortunately netdev_alloc_skb() went and assumed GFP_ATOMIC, but I guess
> > we can dive below the covers and use __netdev_alloc_skb():
> > 
> > 
> > 
> > From: Andrew Morton <akpm@linux-foundation.org>
> > 
> > We get rather a lot of reports of page allocation warnings coming out of
> > e1000.  But this driver is know to handle them properly so let's suppress
> > them.
> 
> 
> Do you people hear what you're saying???
> 
> I respectfully but strongly disagree with this.
> 
> We do __not__ need a whitelist (__GFP_NOWARN) of drivers that handle 
> allocation failures properly.  That's a long list, a maintenance 
> nightmare, and it is punishing good behavior.
> 
> It has been true for over a decade that allocations should be checked 
> for NULL, and GFP_ATOMIC allocations MUST be checked for NULL.
> 
> Let's not crap all over good drivers, because a few bad apples don't 
> have the proper checks.
> 
> Or at the very least, this TOTALLY BOGUS spew from working drivers 
> should not be foisted upon users.  Every time a working driver complains 
> about this -- as in the examples here -- the value of the warning 
> decreases to noise.
> 
> And the solution to noise is not _more noise_ (adding 'nowarn' to every 
> damn driver in the kernel).
> 

After you've read Nick's comments (which I pray you have not), and after
you've convinced us and yourself of their wrongness, you might like to
consider adding a __GFP_NOWARN to netdev_alloc_skb().


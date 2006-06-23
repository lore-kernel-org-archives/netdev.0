From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [1/4] kevent: core files.
Date: Fri, 23 Jun 2006 16:31:14 -0400
Message-ID: <20060623203114.GD14126@kvack.org>
References: <20060623070933.GA20291@2ka.mipt.ru> <20060623184457.GA13617@kvack.org> <20060623192422.GA11508@2ka.mipt.ru> <20060623.131940.48806210.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johnpol@2ka.mipt.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:15791 "EHLO kanga.kvack.org")
	by vger.kernel.org with ESMTP id S1750752AbWFWUbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 16:31:34 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060623.131940.48806210.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 23, 2006 at 01:19:40PM -0700, David Miller wrote:
> I completely agree with Evgeniy here.
> 
> There is nothing in the kernel today that provides integrated event
> handling.  Nothing.  So when someone says to use the "existing" stuff,
> they need to have their head examined.

The existing AIO events are *events*, with the syscalls providing the 
reading of events.

> The existing AIO stuff stinks as a set of interfaces.  It was designed
> by a standards committee, not by people truly interested in a good
> performing event processing design.  It is especially poorly suited
> for networking, and any networking developer understands this.

I disagree.  Stuffing an event that a read or write is complete/ready is a 
good way of handling things, even more so with hardware that will perform 
the memory copies to/from user buffers.

> It is pretty much a foregone conclusion that we will need new
> APIs to get good networking performance.  Every existing interface
> has one limitation or another.

Eh?  Nobody has posted any numbers comparing the approaches yet, so this 
is pure handwaving, unless you have real concrete results?

> So we should be happy people like Evgeniy try to work on this stuff,
> instead of discouraging them.

I would like to encourage him, but at the same time I don't want to see 
creating APIs that essentially duplicate existing work and needlessly 
break compatibility.  I completely agree that the in-kernel APIs are not 
as encompassing as they should be, and within the kernel Evgeniy's work 
may well be the way to go.  What I do not agree is that we need new 
syscalls at this point.  I'm perfectly willing to accept proof that change 
is needed if we do a proper comparision between any new syscall API and the 
use of the existing syscall API, but the pain of introducing a new API is 
sufficiently large that I think it is worth looking at the numbers.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.

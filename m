From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: GFP_ATOMIC page allocation failures.
Date: Wed, 2 Apr 2008 22:32:54 -0700
Message-ID: <20080402223254.5ac50337.akpm@linux-foundation.org>
References: <20080401235609.GA6947@codemonkey.org.uk>
	<200804022012.58760.nickpiggin@yahoo.com.au>
	<20080402085437.7d9abf1f.akpm@linux-foundation.org>
	<200804031622.26973.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Chris Snook <csnook@redhat.com>,
	Dave Jones <davej@codemonkey.org.uk>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34175 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752664AbYDCFdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 01:33:42 -0400
In-Reply-To: <200804031622.26973.nickpiggin@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 3 Apr 2008 16:22:26 +1100 Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> > It also tells us when we mucked up the net driver - I doubt if we (or at
> > least, I) would have discovered that e1000 does a 32k allocation for a
> > 5k(?) frame if this warning wasn't coming out.
> 
> Is that right? If it is allocating for 9K MTU, then the slab allocator
> (slub in this case) will bump that up to the 16K kmalloc slab. If it is
> a 5K frame, then it would get the 8K kmalloc slab I think.
> 
> Oh, but SLUB's default MIN_OBJECTS is 4, so 4*8 is 32 indeed. So slub
> is probably deciding to round the kmalloc-8192 allocations up to order-3.
> I think. How did you know it was a 5k frame? :)

urgh, it was a while ago, and I don't know if e1000e retains the behaviour.

iirc the issue was with some errant versions of the hardware needing
exorbitant alignment and additional padding at the end because of
occasional DMA overruns.  Something like that.


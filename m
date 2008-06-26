From: Dave Jones <davej@redhat.com>
Subject: Re: GFP_ATOMIC page allocation failures.
Date: Thu, 26 Jun 2008 17:06:24 -0400
Message-ID: <20080626210624.GA11816@redhat.com>
References: <20080401235609.GA6947@codemonkey.org.uk> <200804022012.58760.nickpiggin@yahoo.com.au> <20080402085437.7d9abf1f.akpm@linux-foundation.org> <200804031622.26973.nickpiggin@yahoo.com.au> <20080402223254.5ac50337.akpm@linux-foundation.org> <20080403085922.GA10874@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Chris Snook <csnook@redhat.com>,
	Dave Jones <davej@codemonkey.org.uk>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50476 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753681AbYFZVNv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2008 17:13:51 -0400
Content-Disposition: inline
In-Reply-To: <20080403085922.GA10874@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This thread seemed to die out with no resolution..

On Thu, Apr 03, 2008 at 12:59:22PM +0400, Evgeniy Polyakov wrote:
 > On Wed, Apr 02, 2008 at 10:32:54PM -0700, Andrew Morton (akpm@linux-foundation.org) wrote:
 > > > > It also tells us when we mucked up the net driver - I doubt if we (or at
 > > > > least, I) would have discovered that e1000 does a 32k allocation for a
 > > > > 5k(?) frame if this warning wasn't coming out.
 > > > 
 > > > Is that right? If it is allocating for 9K MTU, then the slab allocator
 > > > (slub in this case) will bump that up to the 16K kmalloc slab. If it is
 > > > a 5K frame, then it would get the 8K kmalloc slab I think.
 > > > 
 > > > Oh, but SLUB's default MIN_OBJECTS is 4, so 4*8 is 32 indeed. So slub
 > > > is probably deciding to round the kmalloc-8192 allocations up to order-3.
 > > > I think. How did you know it was a 5k frame? :)
 > > 
 > > urgh, it was a while ago, and I don't know if e1000e retains the behaviour.
 > > 
 > > iirc the issue was with some errant versions of the hardware needing
 > > exorbitant alignment and additional padding at the end because of
 > > occasional DMA overruns.  Something like that.
 > 
 > e1000 hardware does require power-of-two alignment, network stack adds
 > additional structure at the end, so with e1000 it ends up with two
 > rounds to the higher power of two.
 > 5k ends up with 16k allocations, 9k - to 32k.
 > 
 > This problem is known for years already and number of fixes was
 > proposed, but the really good one is to rewrite e1000 allocation path to
 > use fragments, which I believe was done in the new e1000 driver.

So this morning, we got a fresh report from this in 2.6.25.6's e1000 driver
https://bugzilla.redhat.com/show_bug.cgi?id=453010
Pages and pages of spew, which make users freak out.
This stuff might be 'nice to know', but if it isn't getting fixed,
I can see why some distros have been shipping the 'silence GFP_ATOMIC failures'
patches for some time.

	Dave

 > And as a side note: shuting allocation failures is a very bad step,
 > since it hides allocation problems for drivers. if people do care about
 > it add __GFP_SMALL_WARN flag which will just print that allocation
 > failed, its order and function where it happend.



-- 
http://www.codemonkey.org.uk

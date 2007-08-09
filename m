From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Thu, 9 Aug 2007 08:00:41 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0708090751560.25146@woody.linux-foundation.org>
References: <8Q2Pg-8uV-23@gated-at.bofh.it> <8Q7Fa-7rJ-1@gated-at.bofh.it>
 <8Q8rD-hh-7@gated-at.bofh.it> <E1IJ424-0000d7-HK@be1.lrz>
 <20070809171832.1568864b.wjiang@resilience.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: 7eggert@gmx.de, Chris Snook <csnook@redhat.com>,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, schwidefsky@de.ibm.com,
	wensong@linux-vs.org, horms@verge.net.au, cfriesen@nortel.com,
	zlynx@acm.org
To: Jerry Jiang <wjiang@resilience.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54996 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754921AbXHIPCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 11:02:06 -0400
In-Reply-To: <20070809171832.1568864b.wjiang@resilience.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 9 Aug 2007, Jerry Jiang wrote:
> 
> and still not to said "Why the *volatile-accesses-in-code* is
> acceptable"

I don't think volatile is necessarily wonderful in code _either_. So I 
think the "atomic_read()" issue would be even better off if we just made 
sure everybody behaves well and has the right barriers.

So the difference between "volatile in code" and "volatile on data 
structures" is that the latter is *always* wrong (and wrong for very 
fundamental reasons). 

But "volatile in code" can be perfectly fine. If you hide the volatile in 
an accessor function, and just specify that the rules for that function is 
that it always loads from memory but doesn't imply any memory barriers, 
than that is fine. And I think those kinds of semantics may well be 
perfectly sane for "atomic_read()".

So I think a volatile access inside "atomic_read()" at least has 
well-defined semantics. Are they the best possible semantics? I dunno. I 
can imagine that it's perfectly fine, but on the other hand, it would be 
interesting to see any code for which it matters - it's entirely possible 
that the code itself is the problem, and should instead have a 
"cpu_relax()" or similar that implies a barrier.

			Linus

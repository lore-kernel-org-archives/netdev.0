From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Sat, 18 Aug 2007 05:21:42 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708180512300.3666@enigma.security.iitk.ac.in>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <46C32618.2080108@redhat.com>
 <20070815234021.GA28775@gondor.apana.org.au> <3694fb2e4ed1e4d9bf873c0d050c911e@kernel.crashing.org>
 <46C3B50E.7010702@yahoo.com.au> <194369f4c96ea0e24decf8f9197d5bad@kernel.crashing.org>
 <46C505B2.6030704@yahoo.com.au> <18117.4848.695269.72976@cargo.ozlabs.ibm.com>
 <alpine.LFD.0.999.0708162033400.30176@woody.linux-foundation.org>
 <alpine.LFD.0.999.0708171016160.3666@enigma.security.iitk.ac.in>
 <f5796b5aa38ae6305c65ffa0340ba295@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>, heiko.carstens@de.ibm.com,
	horms@verge.net.au,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	rpjday@mindspring.com, ak@suse.de, netdev@vger.kernel.org,
	cfriesen@nortel.com, Nick Piggin <nickpiggin@yahoo.com.au>,
	linux-arch@vger.kernel.org, jesper.juhl@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>, zlynx@acm.org,
	clameter@sgi.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert.xu@redhat.com>, davem@davemloft.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: Segher Boessenkool <segher@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:46455 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348AbXHQXjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 19:39:08 -0400
In-Reply-To: <f5796b5aa38ae6305c65ffa0340ba295@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sat, 18 Aug 2007, Segher Boessenkool wrote:

> > #define forget(a)	__asm__ __volatile__ ("" :"=m" (a) :"m" (a))
> > 
> > [ This is exactly equivalent to using "+m" in the constraints, as recently
> >   explained on a GCC list somewhere, in response to the patch in my bitops
> >   series a few weeks back where I thought "+m" was bogus. ]
> 
> [It wasn't explained on a GCC list in response to your patch, as
> far as I can see -- if I missed it, please point me to an archived
> version of it].

http://gcc.gnu.org/ml/gcc-patches/2007-07/msg01758.html

is a follow-up in the thread on the gcc-patches@gcc.gnu.org mailing list,
which began with:

http://gcc.gnu.org/ml/gcc-patches/2007-07/msg01677.html

that was posted by Jan Kubicka, as he quotes in that initial posting,
after I had submitted:

http://lkml.org/lkml/2007/7/23/252

which was a (wrong) patch to "rectify" what I thought was the "bogus"
"+m" constraint, as per the quoted extract from gcc docs (that was
given in that (wrong) patch's changelog).

That's when _I_ came to know how GCC interprets "+m", but probably
this has been explained on those lists multiple times. Who cares,
anyway?


> One last time: it isn't equivalent on older (but still supported
> by Linux) versions of GCC.  Current versions of GCC allow it, but
> it has no documented behaviour at all, so use it at your own risk.

True.

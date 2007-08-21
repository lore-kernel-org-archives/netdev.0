From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Tue, 21 Aug 2007 16:59:08 +0200
Message-ID: <e1aed5ce66e392cd290f82637b2176f2@kernel.crashing.org>
References: <alpine.LFD.0.999.0708170929580.30176@woody.linux-foundation.org>	<46C993DF.4080400@redhat.com>	<alpine.LFD.0.999.0708202244520.30176@woody.linux-foundation.org> <20070821.000404.39159401.davem@davemloft.net> <46CAED8B.9030006@redhat.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, heiko.carstens@de.ibm.com,
	ilpo.jarvinen@helsinki.fi, horms@verge.net.au,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	rpjday@mindspring.com, netdev@vger.kernel.org, ak@suse.de,
	piggin@cyberone.com.au, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, cfriesen@nortel.com,
	jesper.juhl@gmail.com, linux-arch@vger.kernel.org,
	paulus@samba.org, herbert@gondor.apana.org.au,
	satyam@infradead.org, clameter@sgi.com, stefanr@s5r6.in-berlin.de,
	schwidefsky@de.ibm.com, zlynx@acm.org, wensong@linux-vs.org,
	wjiang@resilience.com
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:39064 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760733AbXHUPNZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2007 11:13:25 -0400
In-Reply-To: <46CAED8B.9030006@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> At some point in the future, barrier() will be universally regarded as 
> a hammer too big for most purposes.  Whether or not removing it now

You can't just remove it, it is needed in some places; you want to
replace it in most places with a more fine-grained "compiler barrier",
I presume?

> constitutes premature optimization is arguable, but I think we should 
> allow such optimization to happen (or not happen) in 
> architecture-dependent code, and provide a consistent API that doesn't 
> require the use of such things in arch-independent code where it might 
> turn into a totally superfluous performance killer depending on what 
> hardware it gets compiled for.

Explicit barrier()s won't be too hard to replace -- but what to do
about the implicit barrier()s in rmb() etc. etc. -- *those* will be
hard to get rid of, if only because it is hard enough to teach driver
authors about how to use those primitives *already*.  It is far from
clear what a good interface like that would look like, anyway.

Probably we should first start experimenting with a forget()-style
micro-barrier (but please, find a better name), and see if a nice
usage pattern shows up that can be turned into an API.


Segher


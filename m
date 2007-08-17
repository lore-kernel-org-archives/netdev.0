From: Nick Piggin <piggin@cyberone.com.au>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 19:31:11 +1000
Message-ID: <46C56ADF.8010501@cyberone.com.au>
References: <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au> <Pine.LNX.4.64.0708161743500.13267@kivilampi-30.cs.helsinki.fi> <46C4ABA5.9010804@redhat.com> <Pine.LNX.4.64.0708161319000.17777@schroedinger.engr.sgi.com> <18117.1287.779351.836552@cargo.ozlabs.ibm.com> <alpine.LFD.0.999.0708161953310.30176@woody.linux-foundation.org> <18117.6495.397597.582736@cargo.ozlabs.ibm.com> <20070817035342.GA14744@gondor.apana.org.au> <alpine.LFD.0.999.0708171142550.3666@enigma.security.iitk.ac.in> <46C55E90.7010407@yahoo.com.au> <alpine.LFD.0.999.0708171431150.3666@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Mackerras <paulus@samba.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, ak@suse.de,
	heiko.carstens@de.ibm.com, David Miller <davem@davemloft.net>,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.icp-qv1-irony2.iinet.net.au ([203.59.1.107]:4839 "EHLO
	webmail.icp-qv1-irony2.iinet.net.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750991AbXHQJbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 05:31:19 -0400
In-Reply-To: <alpine.LFD.0.999.0708171431150.3666@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Satyam Sharma wrote:
> 
> On Fri, 17 Aug 2007, Nick Piggin wrote:
> 
> 
>>Satyam Sharma wrote:
>>[...]
>>
>>>Granted, the above IS buggy code. But, the stated objective is to avoid
>>>heisenbugs.
> 
>     ^^^^^^^^^^
> 
> 
>>Anyway, why are you making up code snippets that are buggy in other
>>ways in order to support this assertion being made that lots of kernel
>>code supposedly depends on volatile semantics. Just reference the
>>actual code.
> 
> 
> Because the point is *not* about existing bugs in kernel code. At some
> point Chris Snook (who started this thread) did write that "If I knew
> of the existing bugs in the kernel, I would be sending patches for them,
> not this series" or something to that effect.
> 
> The point is about *author expecations*. If people do expect atomic_read()
> (or a variant thereof) to have volatile semantics, why not give them such
> a variant?

Because they should be thinking about them in terms of barriers, over
which the compiler / CPU is not to reorder accesses or cache memory
operations, rather than "special" "volatile" accesses. Linux's whole
memory ordering and locking model is completely geared around the
former.


> And by the way, the point is *also* about the fact that cpu_relax(), as
> of today, implies a full memory clobber, which is not what a lot of such
> loops want. (due to stuff mentioned elsewhere, summarized in that summary)

That's not the point, because as I also mentioned, the logical extention
to Linux's barrier API to handle this is the order(x) macro. Again, not
special volatile accessors.

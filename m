From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 17:26:12 +1000
Message-ID: <46C54D94.5080803@yahoo.com.au>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <46C32618.2080108@redhat.com> <20070815234021.GA28775@gondor.apana.org.au> <3694fb2e4ed1e4d9bf873c0d050c911e@kernel.crashing.org> <46C3B50E.7010702@yahoo.com.au> <194369f4c96ea0e24decf8f9197d5bad@kernel.crashing.org> <46C505B2.6030704@yahoo.com.au> <18117.4848.695269.72976@cargo.ozlabs.ibm.com> <alpine.LFD.0.999.0708162033400.30176@woody.linux-foundation.org> <alpine.LFD.0.999.0708171016160.3666@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Mackerras <paulus@samba.org>,
	Segher Boessenkool <segher@kernel.crashing.org>,
	heiko.carstens@de.ibm.com, horms@verge.net.au,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	rpjday@mindspring.com, ak@suse.de, netdev@vger.kernel.org,
	cfriesen@nortel.com, Andrew Morton <akpm@linux-foundation.org>,
	jesper.juhl@gmail.com, linux-arch@vger.kernel.org, zlynx@acm.org,
	clameter@sgi.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert.xu@redhat.com>, davem@davemloft.net,
	wensong@linux-vs.org, wjiang@resilience.com
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.mail.mud.yahoo.com ([209.191.85.214]:33903 "HELO
	smtp104.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751239AbXHQH00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 03:26:26 -0400
In-Reply-To: <alpine.LFD.0.999.0708171016160.3666@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Satyam Sharma wrote:

> #define atomic_read_volatile(v)				\
> 	({						\
> 		forget((v)->counter);			\
> 		((v)->counter);				\
> 	})
> 
> where:

*vomit* :)

Not only do I hate the keyword volatile, but the barrier is only a
one-sided affair so its probable this is going to have slightly
different allowed reorderings than a real volatile access.

Also, why would you want to make these insane accessors for atomic_t
types? Just make sure everybody knows the basics of barriers, and they
can apply that knowledge to atomic_t and all other lockless memory
accesses as well.


> #define forget(a)	__asm__ __volatile__ ("" :"=m" (a) :"m" (a))

I like order(x) better, but it's not the most perfect name either.

-- 
SUSE Labs, Novell Inc.

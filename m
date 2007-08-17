From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Sat, 18 Aug 2007 00:29:30 +0200
Message-ID: <036b785bc30ad3faa872171d8630542f@kernel.crashing.org>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <46C32618.2080108@redhat.com> <20070815234021.GA28775@gondor.apana.org.au> <3694fb2e4ed1e4d9bf873c0d050c911e@kernel.crashing.org> <46C3B50E.7010702@yahoo.com.au> <194369f4c96ea0e24decf8f9197d5bad@kernel.crashing.org> <46C505B2.6030704@yahoo.com.au> <18117.4848.695269.72976@cargo.ozlabs.ibm.com> <alpine.LFD.0.999.0708162033400.30176@woody.linux-foundation.org>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Mackerras <paulus@samba.org>, heiko.carstens@de.ibm.com,
	horms@verge.net.au, linux-kernel@vger.kernel.org,
	rpjday@mindspring.com, ak@suse.de, netdev@vger.kernel.org,
	cfriesen@nortel.com, akpm@linux-foundation.org,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	linux-arch@vger.kernel.org, jesper.juhl@gmail.com,
	satyam@infradead.org, zlynx@acm.org, clameter@sgi.com,
	schwidefsky@de.ibm.com, Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert.xu@redhat.com>, davem@davemloft.net,
	wensong@linux-vs.org, wjiang@resilience.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:53034 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752951AbXHQWaj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2007 18:30:39 -0400
In-Reply-To: <alpine.LFD.0.999.0708162033400.30176@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> In a reasonable world, gcc should just make that be (on x86)
>
> 	addl $1,i(%rip)
>
> on x86-64, which is indeed what it does without the volatile. But with 
> the
> volatile, the compiler gets really nervous, and doesn't dare do it in 
> one
> instruction, and thus generates crap like
>
>         movl    i(%rip), %eax
>         addl    $1, %eax
>         movl    %eax, i(%rip)
>
> instead. For no good reason, except that "volatile" just doesn't have 
> any
> good/clear semantics for the compiler, so most compilers will just 
> make it
> be "I will not touch this access in any way, shape, or form". Including
> even trivially correct instruction optimization/combination.

It's just a (target-specific, perhaps) missed-optimisation kind
of bug in GCC.  Care to file a bug report?

> but is
> (again) something that gcc doesn't dare do, since "i" is volatile.

Just nobody taught it it can do this; perhaps no one wanted to
add optimisations like that, maybe with a reasoning like "people
who hit the go-slow-in-unspecified-ways button should get what
they deserve" ;-)


Segher


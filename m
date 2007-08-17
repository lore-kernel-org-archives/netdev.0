From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Fri, 17 Aug 2007 16:59:12 -0700
Message-ID: <20070817235912.GA24314@linux.vnet.ibm.com>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <46C32618.2080108@redhat.com> <20070815234021.GA28775@gondor.apana.org.au> <3694fb2e4ed1e4d9bf873c0d050c911e@kernel.crashing.org> <46C3B50E.7010702@yahoo.com.au> <194369f4c96ea0e24decf8f9197d5bad@kernel.crashing.org> <46C505B2.6030704@yahoo.com.au> <18117.4848.695269.72976@cargo.ozlabs.ibm.com> <46C516BA.60700@yahoo.com.au> <alpine.LFD.0.999.0708162045150.30176@woody.linux-foundation.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nick Piggin <nickpiggin@yahoo.com.au>,
	Paul Mackerras <paulus@samba.org>,
	Segher Boessenkool <segher@kernel.crashing.org>,
	heiko.carstens@de.ibm.com, horms@verge.net.au,
	linux-kernel@vger.kernel.org, rpjday@mindspring.com, ak@suse.de,
	netdev@vger.kernel.org, cfriesen@nortel.com,
	akpm@linux-foundation.org, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org, zlynx@acm.org, satyam@infradead.org,
	clameter@sgi.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert.xu@redhat.com>, davem@davemloft.net,
	wensong@linux-vs.org, wjiang@resilience.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:49523 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753292AbXHQX7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2007 19:59:16 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0708162045150.30176@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 08:50:30PM -0700, Linus Torvalds wrote:
> Just try it yourself:
> 
> 	volatile int i;
> 	int j;
> 
> 	int testme(void)
> 	{
> 	        return i <= 1;
> 	}
> 
> 	int testme2(void)
> 	{
> 	        return j <= 1;
> 	}
> 
> and compile with all the optimizations you can.
> 
> I get:
> 
> 	testme:
> 	        movl    i(%rip), %eax
> 	        subl    $1, %eax
> 	        setle   %al
> 	        movzbl  %al, %eax
> 	        ret
> 
> vs
> 
> 	testme2:
> 	        xorl    %eax, %eax
> 	        cmpl    $1, j(%rip)
> 	        setle   %al
> 	        ret
> 
> (now, whether that "xorl + setle" is better than "setle + movzbl", I don't 
> really know - maybe it is. But that's not thepoint. The point is the 
> difference between
> 
>                 movl    i(%rip), %eax
>                 subl    $1, %eax
> 
> and
> 
>                 cmpl    $1, j(%rip)

gcc bugzilla bug #33102, for whatever that ends up being worth.  ;-)

							Thanx, Paul

From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 12:19:30 +1000
Message-ID: <46C505B2.6030704@yahoo.com.au>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <46C32618.2080108@redhat.com> <20070815234021.GA28775@gondor.apana.org.au> <3694fb2e4ed1e4d9bf873c0d050c911e@kernel.crashing.org> <46C3B50E.7010702@yahoo.com.au> <194369f4c96ea0e24decf8f9197d5bad@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: heiko.carstens@de.ibm.com, horms@verge.net.au,
	linux-kernel@vger.kernel.org, rpjday@mindspring.com, ak@suse.de,
	netdev@vger.kernel.org, cfriesen@nortel.com,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	jesper.juhl@gmail.com, linux-arch@vger.kernel.org, zlynx@acm.org,
	satyam@infradead.org, clameter@sgi.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert.xu@redhat.com>, davem@davemloft.net,
	wensong@linux-vs.org, wjiang@resilience.com
To: Segher Boessenkool <segher@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp108.mail.mud.yahoo.com ([209.191.85.218]:37714 "HELO
	smtp108.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1761005AbXHQCTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 22:19:48 -0400
In-Reply-To: <194369f4c96ea0e24decf8f9197d5bad@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Segher Boessenkool wrote:
>>>>> Part of the motivation here is to fix heisenbugs.  If I knew where 
>>>>> they
>>>>
>>>>
>>>>
>>>> By the same token we should probably disable optimisations
>>>> altogether since that too can create heisenbugs.
>>>
>>> Almost everything is a tradeoff; and so is this.  I don't
>>> believe most people would find disabling all compiler
>>> optimisations an acceptable price to pay for some peace
>>> of mind.
>>
>>
>> So why is this a good tradeoff?
> 
> 
> It certainly is better than disabling all compiler optimisations!

It's easy to be better than something really stupid :)

So i386 and x86-64 don't have volatiles there, and it saves them a
few K of kernel text. What you need to justify is why it is a good
tradeoff to make them volatile (which btw, is much harder to go
the other way after we let people make those assumptions).


>> I also think that just adding things to APIs in the hope it might fix
>> up some bugs isn't really a good road to go down. Where do you stop?
> 
> 
> I look at it the other way: keeping the "volatile" semantics in
> atomic_XXX() (or adding them to it, whatever) helps _prevent_ bugs;

Yeah, but we could add lots of things to help prevent bugs and
would never be included. I would also contend that it helps _hide_
bugs and encourages people to be lazy when thinking about these
things.

Also, you dismiss the fact that we'd actually be *adding* volatile
semantics back to the 2 most widely tested architectures (in terms
of test time, number of testers, variety of configurations, and
coverage of driver code). This is a very important different from
just keeping volatile semantics because it is basically a one-way
API change.


> certainly most people expect that behaviour, and also that behaviour
> is *needed* in some places and no other interface provides that
> functionality.

I don't know that most people would expect that behaviour. Is there
any documentation anywhere that would suggest this?

Also, barrier() most definitely provides the required functionality.
It is overkill in some situations, but volatile is overkill in _most_
situations. If that's what you're worried about, we should add a new
ordering primitive.


> [some confusion about barriers wrt atomics snipped]

What were you confused about?

-- 
SUSE Labs, Novell Inc.

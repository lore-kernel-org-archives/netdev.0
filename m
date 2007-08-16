From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Thu, 16 Aug 2007 03:30:44 +0200
Message-ID: <0de0c3d833b6f543bd75f74bb17a124b@kernel.crashing.org>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <46C32618.2080108@redhat.com> <20070815234021.GA28775@gondor.apana.org.au> <20070815235125.GT9645@linux.vnet.ibm.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
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
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:38087 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751712AbXHPBcw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 21:32:52 -0400
In-Reply-To: <20070815235125.GT9645@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> Part of the motivation here is to fix heisenbugs.  If I knew where 
>>> they
>>
>> By the same token we should probably disable optimisations
>> altogether since that too can create heisenbugs.
>
> Precisely the point -- use of volatile (whether in casts or on asms)
> in these cases are intended to disable those optimizations likely to
> result in heisenbugs.

The only thing volatile on an asm does is create a side effect
on the asm statement; in effect, it tells the compiler "do not
remove this asm even if you don't need any of its outputs".

It's not disabling optimisation likely to result in bugs,
heisen- or otherwise; _not_ putting the volatile on an asm
that needs it simply _is_ a bug :-)


Segher


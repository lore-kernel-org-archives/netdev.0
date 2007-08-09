From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 1/24] make atomic_read() behave consistently on alpha
Date: Thu, 09 Aug 2007 15:30:12 -0400
Message-ID: <46BB6B44.90009@redhat.com>
References: <20070809132442.GA13042@shell.boston.redhat.com> <20070809143255.GA8424@linux.vnet.ibm.com> <46BB2A5A.5090006@redhat.com> <20070809150445.GB8424@linux.vnet.ibm.com> <46BB31A6.4080507@redhat.com> <20070809161024.GC8424@linux.vnet.ibm.com> <46BB4281.7010803@redhat.com> <06d22e947a5357cd53adb070225bc7c1@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wjiang@resilience.com, rpjday@mindspring.com, wensong@linux-vs.org,
	heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org,
	ak@suse.de, netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	horms@verge.net.au, akpm@linux-foundation.org,
	linux-arch@vger.kernel.org, jesper.juhl@gmail.com,
	torvalds@linux-foundation.org, schwidefsky@de.ibm.com,
	davem@davemloft.net, cfriesen@nortel.com, zlynx@acm.org
To: Segher Boessenkool <segher@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46749 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751474AbXHITgK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 15:36:10 -0400
In-Reply-To: <06d22e947a5357cd53adb070225bc7c1@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Segher Boessenkool wrote:
>>> The compiler is within its rights to read a 32-bit quantity 16 bits at
>>> at time, even on a 32-bit machine.  I would be glad to help pummel any
>>> compiler writer that pulls such a dirty trick, but the C standard really
>>> does permit this.
>>
>> Yes, but we don't write code for these compilers.  There are countless 
>> pieces of kernel code which would break in this condition, and there 
>> doesn't seem to be any interest in fixing this.
> 
> "Other things are broken too".  Great argument :-)

We make plenty of practical assumptions in the kernel, and declare incorrect 
things which violate them, even in cases where there's no commandment from the 
heavens forbidding them.  Since the whole point of this exercise is to prevent 
badness with *optimizing* compilers, it's quite reasonable to declare broken any 
so-called optimizer which violates these trivial assumptions.

>>> In short, please retain atomic_set()'s volatility, especially on those
>>> architectures that declared the atomic_t's counter to be volatile.
>>
>> Like i386 and x86_64?  These used to have volatile in the atomic_t 
>> declaration.  We removed it, and the sky did not fall.
> 
> And this proves what?  Lots of stuff "works" by accident.

If something breaks because of this, it was already broken, but hidden a lot 
better.  I don't see much of a downside to exposing and fixing those bugs.

	-- Chris

From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 1/24] make atomic_read() behave consistently on alpha
Date: Thu, 09 Aug 2007 15:47:49 -0400
Message-ID: <46BB6F65.8040204@redhat.com>
References: <20070809132442.GA13042@shell.boston.redhat.com> <20070809143255.GA8424@linux.vnet.ibm.com> <46BB2A5A.5090006@redhat.com> <20070809150445.GB8424@linux.vnet.ibm.com> <46BB31A6.4080507@redhat.com> <3bfabd7472d6f019aa1880b14013f7a1@kernel.crashing.org> <46BB3ECF.2070100@redhat.com> <1abc2c621d6b62b3ac9f489d4d18806a@kernel.crashing.org> <46BB656D.6090408@redhat.com> <Pine.LNX.4.64.0708092123270.22584@anakin>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Segher Boessenkool <segher@kernel.crashing.org>,
	wjiang@resilience.com, cfriesen@nortel.com, wensong@linux-vs.org,
	heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org,
	ak@suse.de, netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	horms@verge.net.au, akpm@linux-foundation.org,
	linux-arch@vger.kernel.org, jesper.juhl@gmail.com,
	torvalds@linux-foundation.org, zlynx@acm.org,
	rpjday@mindspring.com, schwidefsky@de.ibm.com, davem@davemloft.net
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57641 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755559AbXHITzp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 15:55:45 -0400
In-Reply-To: <Pine.LNX.4.64.0708092123270.22584@anakin>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Geert Uytterhoeven wrote:
> On Thu, 9 Aug 2007, Chris Snook wrote:
>> Segher Boessenkool wrote:
>>>>> The only safe way to get atomic accesses is to write
>>>>> assembler code.  Are there any downsides to that?  I don't
>>>>> see any.
>>>> The assumption that aligned word reads and writes are atomic, and that
>>>> words are aligned unless explicitly packed otherwise, is endemic in the
>>>> kernel.  No sane compiler violates this assumption.  It's true that we're
>>>> not portable to insane compilers after this patch, but we never were in
>>>> the first place.
>>> You didn't answer my question: are there any downsides to using
>>> explicit coded-in-assembler accesses for atomic accesses?  You
>>> can handwave all you want that it should "just work" with
>>> volatile accesses, but volatility != atomicity, volatile in C
>>> is really badly defined, GCC never officially gave stronger
>>> guarantees, and we have a bugzilla full of PRs to show what a
>>> minefield it is.
>>>
>>> So, why not use the well-defined alternative?
>> Because we don't need to, and it hurts performance.
> 
> It hurts performance by implementing 32-bit atomic reads in assembler?

No, I misunderstood the question.  Implementing 32-bit atomic reads in assembler 
is redundant, because any sane compiler, *particularly* and optimizing compiler 
(and we're only in this mess because of optimizing compilers) will give us that 
automatically without the assembler.  Yes, it is legal for a compiler to violate 
this assumption.  It is also legal for us to refuse to maintain compatibility 
with compilers that suck this badly.  That decision was made a very long time 
ago, and I consider it the correct decision.

	-- Chris

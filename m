From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Thu, 09 Aug 2007 03:31:10 -0400
Message-ID: <46BAC2BE.1090106@redhat.com>
References: <20070808230733.GA17270@shell.boston.redhat.com> <alpine.LFD.0.999.0708082116060.25146@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, schwidefsky@de.ibm.com,
	wensong@linux-vs.org, horms@verge.net.au, wjiang@resilience.com,
	cfriesen@nortel.com, zlynx@acm.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35706 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764889AbXHIHiQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 03:38:16 -0400
In-Reply-To: <alpine.LFD.0.999.0708082116060.25146@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:
> 
> On Wed, 8 Aug 2007, Chris Snook wrote:
>> Some architectures currently do not declare the contents of an atomic_t to be
>> volatile.  This causes confusion since atomic_read() might not actually read
>> anything if an optimizing compiler re-uses a value stored in a register, which
>> can break code that loops until something external changes the value of an
>> atomic_t.
> 
> I'd be *much* happier with "atomic_read()" doing the "volatile" instead.
> 
> The fact is, volatile on data structures is a bug. It's a wart in the C 
> language. It shouldn't be used. 
> 
> Volatile accesses in *code* can be ok, and if we have "atomic_read()" 
> expand to a "*(volatile int *)&(x)->value", then I'd be ok with that.
> 
> But marking data structures volatile just makes the compiler screw up 
> totally, and makes code for initialization sequences etc much worse.
> 
> 		Linus

Fair enough.  Casting to (volatile int *) will give us the behavior people 
expect when using atomic_t without needing to use inefficient barriers.

While we have the hood up, should we convert all the atomic_t's to non-volatile 
and put volatile casts in all the atomic_reads?  I don't know enough about the 
various arches to say with confidence that those changes alone will preserve 
existing behavior.  We might need some arch-specific tweaking of the atomic 
operations.

	-- Chris

From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 1/24] make atomic_read() behave consistently on alpha
Date: Thu, 09 Aug 2007 14:13:52 -0400
Message-ID: <46BB5960.9040009@redhat.com>
References: <20070809132442.GA13042@shell.boston.redhat.com> <20070809143255.GA8424@linux.vnet.ibm.com> <46BB2A5A.5090006@redhat.com> <20070809150445.GB8424@linux.vnet.ibm.com> <46BB31A6.4080507@redhat.com> <20070809161024.GC8424@linux.vnet.ibm.com> <46BB4281.7010803@redhat.com> <20070809165853.GD8424@linux.vnet.ibm.com> <46BB4B7B.4070007@redhat.com> <20070809174150.GE8424@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43900 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757558AbXHISTx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 14:19:53 -0400
In-Reply-To: <20070809174150.GE8424@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul E. McKenney wrote:
> On Thu, Aug 09, 2007 at 01:14:35PM -0400, Chris Snook wrote:
>>                                 If you're depending on volatile writes 
>> being visible to other CPUs, you're screwed either way, because the CPU can 
>> hold that data in cache as long as it wants before it writes it to memory.  
>> When this finally does happen, it will happen atomically, which is all that 
>> atomic_set guarantees.  If you need to guarantee that the value is written 
>> to memory at a particular time in your execution sequence, you either have 
>> to read it from memory to force the compiler to store it first (and a 
>> volatile cast in atomic_read will suffice for this) or you have to use 
>> LOCK_PREFIX instructions which will invalidate remote cache lines 
>> containing the same variable.  This patch doesn't change either of these 
>> cases.
> 
> The case that it -can- change is interactions with interrupt handlers.
> And NMI/SMI handlers, for that matter.

You have a point here, but only if you can guarantee that the interrupt handler 
is running on a processor sharing the cache that has the not-yet-written 
volatile value.  That implies a strictly non-SMP architecture.  At the moment, 
none of those have volatile in their declaration of atomic_t, so this patch 
can't break any of them.

	-- Chris

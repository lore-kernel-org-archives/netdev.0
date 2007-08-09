From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 1/24] make atomic_read() behave consistently on alpha
Date: Thu, 9 Aug 2007 20:51:31 +0200
Message-ID: <06d22e947a5357cd53adb070225bc7c1@kernel.crashing.org>
References: <20070809132442.GA13042@shell.boston.redhat.com> <20070809143255.GA8424@linux.vnet.ibm.com> <46BB2A5A.5090006@redhat.com> <20070809150445.GB8424@linux.vnet.ibm.com> <46BB31A6.4080507@redhat.com> <20070809161024.GC8424@linux.vnet.ibm.com> <46BB4281.7010803@redhat.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wjiang@resilience.com, rpjday@mindspring.com, wensong@linux-vs.org,
	heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org,
	ak@suse.de, netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	horms@verge.net.au, akpm@linux-foundation.org,
	linux-arch@vger.kernel.org, jesper.juhl@gmail.com,
	torvalds@linux-foundation.org, schwidefsky@de.ibm.com,
	davem@davemloft.net, cfriesen@nortel.com, zlynx@acm.org
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:58184 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753203AbXHIS5p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 14:57:45 -0400
In-Reply-To: <46BB4281.7010803@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> The compiler is within its rights to read a 32-bit quantity 16 bits at
>> at time, even on a 32-bit machine.  I would be glad to help pummel any
>> compiler writer that pulls such a dirty trick, but the C standard 
>> really
>> does permit this.
>
> Yes, but we don't write code for these compilers.  There are countless 
> pieces of kernel code which would break in this condition, and there 
> doesn't seem to be any interest in fixing this.

"Other things are broken too".  Great argument :-)

> Sequence points enforce read-after-write ordering, not 
> write-after-write.

Sequence points order *all* side effects; sequence points exist in the
domain of the abstract sequential model of the C language only.  The
compiler translates that to machine code that is equivalent to that C
code under the "as-if" rule; but this is still in that abstract model,
which doesn't include things such as SMP, visibility by I/O devices,
store queues, etc. etc.

> We flush writes with reads for MMIO because of this effect as well as 
> the CPU/bus effects.

You cannot flush all MMIO writes with reads; this is a PCI-specific
thing.  And even then, you need more than just the read itself: you
have to make sure the read completed and returned data.

>> In short, please retain atomic_set()'s volatility, especially on those
>> architectures that declared the atomic_t's counter to be volatile.
>
> Like i386 and x86_64?  These used to have volatile in the atomic_t 
> declaration.  We removed it, and the sky did not fall.

And this proves what?  Lots of stuff "works" by accident.


Segher


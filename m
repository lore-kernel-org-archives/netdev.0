From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 1/24] make atomic_read() behave consistently on alpha
Date: Thu, 9 Aug 2007 21:17:12 +0200
Message-ID: <b6f6588ccebe3e91a03fb2f76febbe34@kernel.crashing.org>
References: <20070809132442.GA13042@shell.boston.redhat.com> <20070809143255.GA8424@linux.vnet.ibm.com> <46BB2A5A.5090006@redhat.com> <20070809150445.GB8424@linux.vnet.ibm.com> <46BB31A6.4080507@redhat.com> <20070809161024.GC8424@linux.vnet.ibm.com> <46BB4281.7010803@redhat.com> <20070809165853.GD8424@linux.vnet.ibm.com> <46BB4B7B.4070007@redhat.com>
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
Received: from gate.crashing.org ([63.228.1.57]:59495 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759107AbXHITZy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 15:25:54 -0400
In-Reply-To: <46BB4B7B.4070007@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> If you need to guarantee that the value is written to memory at a 
> particular time in your execution sequence, you either have to read it 
> from memory to force the compiler to store it first

That isn't enough.  The CPU will happily read the datum back from
its own store queue before it ever hit memory or cache or any
external bus.  If you need the value to be globally visible before
another store, you use wmb(); if you need it before some read,
you use mb().

These concepts are completely separate from both atomicity and
volatility (which aren't the same themselves).

> No, but I can reason about it and be confident that this won't break 
> anything that isn't already broken.  At worst, this patch will make 
> any existing subtly incorrect uses of atomic_t much more obvious and 
> easier to track down.

PR22278, PR29753 -- both P2 bugs, and both about basic *(volatile *)
usage.  Yeah, it's definitely not problematic, esp. not if you want
to support older compilers than 4.2 too.</sarcasm>


Segher


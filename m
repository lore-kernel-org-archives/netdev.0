From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 24/24] document volatile atomic_read() behavior
Date: Fri, 10 Aug 2007 00:23:47 +0200
Message-ID: <9452870655b1844283961f8e9e406464@kernel.crashing.org>
References: <20070809142430.GA19817@shell.boston.redhat.com> <8f6bb8a9e4f2819a161d732bdb6c70c0@kernel.crashing.org> <46BB403D.10202@redhat.com> <0a08872e608cf5f7a3d9c0fc746a1051@kernel.crashing.org> <46BB74B9.4070702@nortel.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wjiang@resilience.com, rpjday@mindspring.com, wensong@linux-vs.org,
	heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org,
	ak@suse.de, netdev@vger.kernel.org, horms@verge.net.au,
	akpm@linux-foundation.org, linux-arch@vger.kernel.org,
	jesper.juhl@gmail.com, torvalds@linux-foundation.org,
	schwidefsky@de.ibm.com, davem@davemloft.net, zlynx@acm.org,
	Chris Snook <csnook@redhat.com>
To: "Chris Friesen" <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:39499 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753453AbXHIWYw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 18:24:52 -0400
In-Reply-To: <46BB74B9.4070702@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Anyway, what's the supposed advantage of *(volatile *) vs. using
>> a real volatile object?  That you can access that same object in
>> a non-volatile way?
>
> That's my understanding.  That way accesses where you don't care about 
> volatility may be optimised.

But those accesses might be done non-atomically then (for example,
if the compiler knows it only needs to write one byte, it might not
bother writing the rest), so that's no good if you want to read the
thing atomically too.

> For instance, in cases where there are already other things 
> controlling visibility (as are needed for atomic increment, for 
> example) you don't need to make the access itself volatile.

Hrm, you mean within a lock or similar?  You'll get the same semantics
as volatile anyway there.


Segher


From: David VomLehn <dvomlehn@cisco.com>
Subject: Re: [Patch 1/1][RFC] NETDEV: Find network bugs by validating the
	sk_buff state
Date: Thu, 30 Apr 2009 09:32:00 -0700
Message-ID: <20090430163200.GC15170@cuplxvomd02.corp.sa.net>
References: <20090429151440.GA14266@cuplxvomd02.corp.sa.net> <20090429.145338.149717676.davem@davemloft.net> <20090429222809.GA1949@cuplxvomd02.corp.sa.net> <20090429.154406.231161665.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:33770 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755653AbZD3QcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 12:32:00 -0400
Content-Disposition: inline
In-Reply-To: <20090429.154406.231161665.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 29, 2009 at 03:44:06PM -0700, David Miller wrote:
> From: David VomLehn <dvomlehn@cisco.com>
> Date: Wed, 29 Apr 2009 15:28:09 -0700
> 
> > Still, let us back up to technical specifics.
> 
> The specifics are that if you showed me something that
> added a "u16", at most, I'd go to bat for you and support
> your work going upstream.
> 
> We could find a way to squeeze that into the existing
> structure with little or even no size increase.

I think the size is very doable. Only two bits are needed to encode the state
so the ability to check the state isn't an issue. The other piece, though,
is recording enough information to be able to pinpoint the problem. 

This initial patch uses two void * to record the addresses where the sk_buff
allocation and freeing is done. So, the question is how to compress these.
Since there are only a limited of places where sk_buffs are allocated and
freed, we can, use an index. As long the two indices use a total of no more
than 14 bits, the sk_buff growth will only be 16 bits.

Converting from call location index to the call location is only done when
an error is detected; the performance is not that important. Converting from
a call location to an index is performance critical and I'm thinking of a
couple of approaches. As seems to usually be the case, the better performing
solution is more complex.

David VomLehn

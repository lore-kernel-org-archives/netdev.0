From: David Miller <davem@davemloft.net>
Subject: Re: small RPS cache for fragments?
Date: Tue, 17 May 2011 17:26:30 -0400 (EDT)
Message-ID: <20110517.172630.1789843473242620898.davem@davemloft.net>
References: <1305666050.2691.4.camel@edumazet-laptop>
	<20110517.171000.1166144155994185790.davem@davemloft.net>
	<1305666822.2848.51.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37073 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932296Ab1EQV0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 17:26:36 -0400
In-Reply-To: <1305666822.2848.51.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 17 May 2011 22:13:42 +0100

> On Tue, 2011-05-17 at 17:10 -0400, David Miller wrote:
>> That's true, but one could also argue that in the existing code at least
>> one of the packets (the one with the UDP header) would make it to the
>> proper flow cpu.
> 
> No, we ignore the layer-4 header when either MF or OFFSET is non-zero.

That's right and I now remember we had quite a discussion about this
in the past.

So IP/saddr/daddr keying is out of the question due to reordering
concerns.

The idea to do RFS post fragmentation is interesting, it's sort of
another form of GRO.  We would need to re-fragment (like GRO does)
in the forwarding case.

But it would be nice since it would reduce the number of calls into
the stack (and thus route lookups, etc.) per fragmented frame.

There is of course the issue of fragmentation queue timeouts, and
what semantics of that means when we are not the final destination
and those fragments would have been forwarded rather than consumed
by us.


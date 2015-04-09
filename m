From: David Miller <davem@davemloft.net>
Subject: Re: [FYI] xfrm: Don't lookup sk_policy for timewait sockets
Date: Thu, 09 Apr 2015 17:07:20 -0400 (EDT)
Message-ID: <20150409.170720.1374561715105253435.davem@davemloft.net>
References: <1428570461.25985.240.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150409.143727.1391401196320839634.davem@davemloft.net>
	<20150409191441.GE20653@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, sebastian.poehn@gmail.com,
	netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50912 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754151AbbDIVHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 17:07:23 -0400
In-Reply-To: <20150409191441.GE20653@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu, 9 Apr 2015 21:14:41 +0200

> I re-introduced this in fd158d79d33d3c under the assumption
> that the input path handles skb->sk timewait sockets correctly
> after all the early demux changes, afaics tcp edemux can also
> assign skb->sk timewait sockets.
> 
> Also, reporter mentions 3.8 as affected which should not assign
> tw sockets to skb->sk.
> 
> Even more strange, the reporters backtrace seems to indicate
> crash at end of forward path.
> 
> Sebastian, can you disable tw assignment via TPROXY in 3.12 just
> to see if it makes a difference?
> 
> [ not doing the assignment is safe provided you still set tproxy mark
>   on the skb; policy routing will ensure local delivery ].

My assumption in my analysis is that TPROXY writes the socket to
skb->sk, and it is also being forwarded.  And yes this is based
upon his backtrace.

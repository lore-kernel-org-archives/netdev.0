From: Florian Westphal <fw@strlen.de>
Subject: Re: [FYI] xfrm: Don't lookup sk_policy for timewait sockets
Date: Thu, 9 Apr 2015 23:21:44 +0200
Message-ID: <20150409212144.GH20653@breakpoint.cc>
References: <1428570461.25985.240.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150409.143727.1391401196320839634.davem@davemloft.net>
 <20150409191441.GE20653@breakpoint.cc>
 <20150409.170720.1374561715105253435.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, eric.dumazet@gmail.com, sebastian.poehn@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:56596 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750785AbbDIVVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 17:21:48 -0400
Content-Disposition: inline
In-Reply-To: <20150409.170720.1374561715105253435.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Thu, 9 Apr 2015 21:14:41 +0200
> 
> > I re-introduced this in fd158d79d33d3c under the assumption
> > that the input path handles skb->sk timewait sockets correctly
> > after all the early demux changes, afaics tcp edemux can also
> > assign skb->sk timewait sockets.
> > 
> > Also, reporter mentions 3.8 as affected which should not assign
> > tw sockets to skb->sk.
> > 
> > Even more strange, the reporters backtrace seems to indicate
> > crash at end of forward path.
> > 
> > Sebastian, can you disable tw assignment via TPROXY in 3.12 just
> > to see if it makes a difference?
> > 
> > [ not doing the assignment is safe provided you still set tproxy mark
> >   on the skb; policy routing will ensure local delivery ].
> 
> My assumption in my analysis is that TPROXY writes the socket to
> skb->sk, and it is also being forwarded.  And yes this is based
> upon his backtrace.

Right.  However, I think we might have to make more changes than just tproxy.

If we have sockets bound to non-local addresses then why would tcp edemux
not cause same issue?

From: Sebastian Poehn <sebastian.poehn@gmail.com>
Subject: Re: [FYI] xfrm: Don't lookup sk_policy for timewait sockets
Date: Fri, 10 Apr 2015 13:14:14 +0200
Message-ID: <1428664454.10242.19.camel@googlemail.com>
References: <1428570461.25985.240.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150409.143727.1391401196320839634.davem@davemloft.net>
	 <20150409191441.GE20653@breakpoint.cc>
	 <20150409.170720.1374561715105253435.davem@davemloft.net>
	 <20150409212144.GH20653@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	sebastian.poehn@gmail.com, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:33107 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbbDJLOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 07:14:17 -0400
Received: by wiax7 with SMTP id x7so13833454wia.0
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 04:14:15 -0700 (PDT)
In-Reply-To: <20150409212144.GH20653@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-09 at 23:21 +0200, Florian Westphal wrote:
> David Miller <davem@davemloft.net> wrote:
> > From: Florian Westphal <fw@strlen.de>
> > Date: Thu, 9 Apr 2015 21:14:41 +0200
> > 
> > > I re-introduced this in fd158d79d33d3c under the assumption
> > > that the input path handles skb->sk timewait sockets correctly
> > > after all the early demux changes, afaics tcp edemux can also
> > > assign skb->sk timewait sockets.
> > > 
> > > Also, reporter mentions 3.8 as affected which should not assign
> > > tw sockets to skb->sk.
> > > 
> > > Even more strange, the reporters backtrace seems to indicate
> > > crash at end of forward path.
> > > 
> > > Sebastian, can you disable tw assignment via TPROXY in 3.12 just
> > > to see if it makes a difference?
> > > 
> > > [ not doing the assignment is safe provided you still set tproxy mark
> > >   on the skb; policy routing will ensure local delivery ].
> > 
> > My assumption in my analysis is that TPROXY writes the socket to
> > skb->sk, and it is also being forwarded.  And yes this is based
> > upon his backtrace.
> 
> Right.  However, I think we might have to make more changes than just tproxy.
> 
> If we have sockets bound to non-local addresses then why would tcp edemux
> not cause same issue?

Thanks for all the helpful inputs. I will try to provide some more information
and try a bit around with TPROXY not assigning tw sockets.

I will provide you with an update the next days.

Unfortunately this is a very rare event and (yet) impossible to reproduce in-house.

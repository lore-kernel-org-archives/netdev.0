From: Willy Tarreau <w@1wt.eu>
Subject: Re: Stable regression with 'tcp: allow splice() to build full TSO packets'
Date: Thu, 17 May 2012 19:22:46 +0200
Message-ID: <20120517172246.GM14498@1wt.eu>
References: <20120517121800.GA18052@1wt.eu> <20120517150157.GA19274@1wt.eu> <1337269380.3403.10.camel@edumazet-glaptop> <20120517155621.GK14498@1wt.eu> <1337272404.3403.18.camel@edumazet-glaptop> <20120517164016.GL14498@1wt.eu> <1337273387.3403.24.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2333 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754138Ab2EQRWt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 13:22:49 -0400
Content-Disposition: inline
In-Reply-To: <1337273387.3403.24.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 17, 2012 at 06:49:47PM +0200, Eric Dumazet wrote:
> On Thu, 2012-05-17 at 18:40 +0200, Willy Tarreau wrote:
> >  try to port your patch (8d4057 tg3: provide frags as skb head) to
> > mv643xx_eth as an exercise. If I succeed and notice an improvement, I'll
> > send a patch :-)
> 
> 
> tg3 uses build_skb(), thats an API that allocates the skb after frame is
> filled by the device, to have less cache misses in RX path.
> 
> But for most devices, netdev_alloc_skb() would be more than enough.

OK, so that's out of reach for me right now.

> I'll send a patch once tested.

I'll happily give it a try.

BTW, net-next gave me around 13-14% improvement over 3.0/3.2+splice
patches ! Now I'm seeing splice() being 75% faster than recv/send, while
it used to be slower on this hardware not that long ago! That's really
impressive, great work!

Willy

From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Thu, 17 May 2012 19:45:51 +0200
Message-ID: <20120517174551.GN14498@1wt.eu>
References: <20120517121800.GA18052@1wt.eu> <20120517150157.GA19274@1wt.eu> <1337269380.3403.10.camel@edumazet-glaptop> <20120517155621.GK14498@1wt.eu> <1337272404.3403.18.camel@edumazet-glaptop> <20120517164016.GL14498@1wt.eu> <1337273387.3403.24.camel@edumazet-glaptop> <1337276056.3403.37.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2336 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756323Ab2EQRp4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 13:45:56 -0400
Content-Disposition: inline
In-Reply-To: <1337276056.3403.37.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 17, 2012 at 07:34:16PM +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Please note I havent tested yet this patch, lacking hardware for this.
> 
> (tg3/bnx2/bnx2x use build_skb, r8169 does a copy of incoming frames,
> ixgbe uses fragments...)
> 
> Any volunteer ?
> 
> Thanks
> 
> [PATCH net-next] net: netdev_alloc_skb() use build_skb()
> 
> netdev_alloc_skb() is used by networks driver in their RX path to
> allocate an skb to receive an incoming frame.
> 
> With recent skb->head_frag infrastructure, it makes sense to change
> netdev_alloc_skb() to use build_skb() and a frag allocator.
> 
> This permits a zero copy splice(socket->pipe), and better GRO or TCP
> coalescing.

Impressed !

For the first time I could proxy HTTP traffic at gigabit speed on this
little box powered by USB ! I've long believed that proper splicing
would make this possible and now I'm seeing it is. Congrats Eric !

I'm still observing some stalls on medium-sized files (eg: 100k,
smaller than the pipe size, don't know yet if there is any relation).
I'll check closer and try to report something more exploitable.

Cheers,
Willy

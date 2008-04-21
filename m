From: David Miller <davem@davemloft.net>
Subject: Re: poor network loopback performance and scalability
Date: Sun, 20 Apr 2008 20:38:10 -0700 (PDT)
Message-ID: <20080420.203810.183610437.davem@davemloft.net>
References: <20080331113602.GA13526@elte.hu>
	<E1JnmdQ-0001qO-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, dada1@cosmosbay.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, a.p.zijlstra@chello.nl
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54967
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754694AbYDUDiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 23:38:09 -0400
In-Reply-To: <E1JnmdQ-0001qO-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 21 Apr 2008 11:24:04 +0800

> Ingo Molnar <mingo@elte.hu> wrote:
> > 
> >   # ifconfig lo mtu 1048576
> 
> Chiming in late here, but 1048576 can't possibly work with IP
> which uses a 16-bit quantity as the length header.  In fact a
> quick test seems to indicate that an 1048576 mtu doesn't generate
> anything bigger than the default 16K mtu.

Right.

To move things forward, we should look into doing something
similar to what Al Viro suggested, which would be to return
an SKB pointer from the transmit path and call back into
netif_receive_skb() using that.

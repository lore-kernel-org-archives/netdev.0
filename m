From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: poor network loopback performance and scalability
Date: Mon, 21 Apr 2008 18:19:08 +0800
Message-ID: <20080421101908.GC9295@gondor.apana.org.au>
References: <E1JnmdQ-0001qO-00@gondolin.me.apana.org.au> <20080420.203810.183610437.davem@davemloft.net> <20080421081103.GA31328@elte.hu> <20080421.011623.67335122.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mingo@elte.hu, dada1@cosmosbay.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, a.p.zijlstra@chello.nl
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753041AbYDUKTf@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080421.011623.67335122.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 21, 2008 at 01:16:23AM -0700, David Miller wrote:
>
> What's being discussed is having the top of the transmit call path
> getting a socket "buffer" pointer, that it can feed back into the
> packet input path directly.  Loopback would return buffer pointers
> from ->hard_start_xmit() instead of passing them netif_rx().  The top
> of the transmit call path, upon getting a non-NULL buffer returned,
> would pass it to netif_receive_skb().

Yes this will definitely reduce the per-packet cost.  The other
low-hanging fruit is to raise the loopback MTU to just below 64K.
I belive the current value is a legacy from the days when we didn't
support skb page frags so everything had to be physically contiguous.

Longer term we could look at generating packets > 64K on lo, for
IPv6 anyway.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: issue with new TCP TSO stuff
Date: Fri, 13 May 2005 07:47:44 +1000
Message-ID: <20050512214744.GA21958@gondor.apana.org.au>
References: <20050511.223036.39664020.davem@davemloft.net> <E1DWAZg-0006aD-00@gondolin.me.apana.org.au> <20050512.131349.32715242.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050512.131349.32715242.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 12, 2005 at 01:13:49PM -0700, David S. Miller wrote:
> 
> But this still has the early free problem, I think.  If an ACK
> comes in which releases an SKB on the chain, while the driver
> is still working with that chain, we cannot free the SKB.  We
> have to do it some time later.

This is fine because we have to skb_clone the packet.  Otherwise
the next pointer for the frag/xmit list will be messed up.

> One way to prevent that would be to do an skb_get() on every
> SKB in the chain, but then we're back to the original problem
> of all the extra atomic operations.

You're being frugal Dave :) I was happy with one skb_clone per
skb and you're having problems with skb_get? :)

Seriously, we already do one skb_clone for every packet sent
so we won't be incurring any extra overhead with this.

> A secondary point is that I'd like to use a name other than
> NETIF_F_FRAGLIST because people are super confused as to what this
> device flag even means.  Some people confuse it with NETIF_F_SG,
> others thing it takes a huge UDP frame and fragments it into MTU sized
> IP frames and checksums the whole thing.  None of which are true.

Fine by me.  But you know I'm not good with names :)

> Loopback is the only driver which supports this properly, by
> simply doing nothing with the packet :-)

If we implement these in the TSO-capable drivers, IPsec could benefit
as well.  Two inbound IPsec fragments that are reassembled are currently
linearised in dev_queue_xmit.  With this it can be sent directly to
the driver.

> So back to the main point, we are in quite a conundrum.  The whole
> point of TSO is to offload the segmentation overhead, but we're in
> fact making the TCP output engine more expensive for the TSO path.

I'll need to finish reading the entire patch before I can respond to
this.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

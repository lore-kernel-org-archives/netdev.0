From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: IPsec and Path MTU
Date: Thu, 17 Jun 2004 00:23:41 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040616202341.GD29781@ms2.inr.ac.ru>
References: <20040615124334.GA25164@gondor.apana.org.au> <20040616121026.GA1169@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20040616121026.GA1169@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> > So unless I'm missing something, we should get rid of dst->path and
> > store the MTU in the xfrm dst's directly.

Yes, this is absolutely true. BTW we talked about this already.

The problem here is pure technical. In any case pmtu on path
going through tunnel is _lower_ than dst_path() and has to be
recalculated when dst_path() changes. Because we do not hold
any back references for dst's using dst->path, we cannot do this
actively. dst_path() is enough to do this.

But it is definitely not enough when pmtu is lowered on some
policies by another reasons.

So, holding pmtu at all the dst's is necessary and we have to sync
those mtus with dst_path instead using it directly.


> Now the problem with all this is that it looks pretty complicated.

I am afraid I still did not understand your troubles completely.

Actually, the last time when we discussed this we had only one
but _damn_ ugly problem. We have to remember original packet content
to reply with ICMP correctly, when encapsulating. Is it possible
that you are confused with this? We do send invalid ICMP_FRAG_NEEDED
from ip_fragment. PMTU discovery will work only if we reply to original,
not transofrmed packet. See?


Alexey

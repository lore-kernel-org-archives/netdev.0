From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] NETLINK_UESTABLISHED notifier event
Date: Wed, 6 Apr 2005 16:03:43 +1000
Message-ID: <20050406060343.GA14059@gondor.apana.org.au>
References: <E1DJ0YI-0003PR-00@gondolin.me.apana.org.au> <1112766901.7488.16.camel@mylaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Dmitry Yusupov <dmitry_yus@yahoo.com>
Content-Disposition: inline
In-Reply-To: <1112766901.7488.16.camel@mylaptop>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Apr 05, 2005 at 10:55:01PM -0700, Dmitry Yusupov wrote:
> 
> main reason for this is to have clear way to notify netlink user that
> new socket created and bound.

Why do you want to exclude sockets that listen to multicast
messages? They can still do unicast transactions.
 
> one reason is for consistency with sock interface. sk_allocation is
> equal to GFP_KERNEL by default, so nothing changed. but. in some cases
> application might require non-blocking kmalloc behavior. one real life
> example is networking block device used for swap partition. this way any
> GFP_KERENL allocation on recovery path might lead to deadlock condition.

Setting of sk_allocation is controlled by the protocol itself.  In this
case this is af_netlink.c.  As you can see, we never set this to anything
other than GFP_KERNEL.

Using sk_allocation will only confuse those who are not familiar with
netlink into thinking that this can be atomic.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Mon, 4 Apr 2005 07:45:21 +1000
Message-ID: <20050403214521.GB15901@gondor.apana.org.au>
References: <E1DHdsP-0003Lr-00@gondolin.me.apana.org.au> <424E641A.1020609@cosmosbay.com> <16974.41648.568927.54429@robur.slu.se> <20050402193224.GA25157@gondor.apana.org.au> <20050402115528.11f71a3c.davem@davemloft.net> <20050403074337.GA8083@gondor.apana.org.au> <16976.19092.562006.246545@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, dada1@cosmosbay.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <16976.19092.562006.246545@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Apr 03, 2005 at 09:57:08PM +0200, Robert Olsson wrote:
> 
> Herbert Xu writes:
> 
>  > We could also move rt_cache_flush into a kernel thread.  When the
>  > number of chains is large this function is really expensive for a
>  > softirq handler.
> 
>  It can also be done via /proc and left to administrators to find 
>  suitable policy. Kernel just provides the mechanism to rehash.

The reason I'm suggesting the move to a kernel thread is because
softirq context is not preemptible.

So doing a large amount of work in it when your table is big means
that a UP machine will freeze for a while.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

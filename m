From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Get rid of rt_check_expire and rt_garbage_collect
Date: Sun, 3 Apr 2005 17:41:25 +1000
Message-ID: <20050403074125.GB8105@gondor.apana.org.au>
References: <E1DHdsP-0003Lr-00@gondolin.me.apana.org.au> <424E641A.1020609@cosmosbay.com> <20050402112304.GA11321@gondor.apana.org.au> <1112475955.1088.294.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>,
        Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112475955.1088.294.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Apr 02, 2005 at 04:05:55PM -0500, jamal wrote:
>
> > Here is how it can be done: Every time a routing entry is inserted into
> > a hash chain, we perform GC on that chain unconditionally.
> 
> May not be a good idea to do it unconditionally - in particular on SMP
> where another CPU maybe spinning waiting for you to let go of bucket
> lock. In particular if a burst of packets accessing the same bucket show
> up on different processors, this would be aggravated.
> You may wanna kick in this algorithm only when things start going past a
> certain threshold.

This isn't too bad because:

1. The fast path is lockless using RCU.
2. The number of locks exceeds the number of CPUs by some insane amount.
3. The cost of performing GC is really cheap, it's just a matter of
calling rt_may_expire.

Anyway, I agree that all of these ideas are simply fantasy until
we have some code.  So let me work on that and then we can let the
benchmarks do the talking :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Mon, 4 Apr 2005 20:48:57 +1000
Message-ID: <20050404104857.GA32359@gondor.apana.org.au>
References: <E1DHdsP-0003Lr-00@gondolin.me.apana.org.au> <424E641A.1020609@cosmosbay.com> <16974.41648.568927.54429@robur.slu.se> <20050402193224.GA25157@gondor.apana.org.au> <16976.17876.832677.945878@robur.slu.se> <20050403214358.GA15901@gondor.apana.org.au> <16977.6411.415326.988754@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <16977.6411.415326.988754@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Apr 04, 2005 at 12:38:03PM +0200, Robert Olsson wrote:
> 
>  This is likely to happen in rt_intern_hash? I don't see how this can
>  get along with chain-pruning there?

What I'm trying to catch is the case when you've got x number of
entries in the table and a large fraction of them are all in one
chain.

This does not conflict with the goal of keeping the chains short.

Even if you strictly allow only 8 entries per chain, it's trivial
to exceed 8 times the average chain length.

Remember the average chain length can be fractions like 0.1.  Of
course we need to set a minimum value that the chain needs to
grow beyond before this check kicks in.

>  IMO the thoughts of extending in-flow GC etc are interesting and can
>  hopefully give us more robust performance.

Indeed, it looks like Alexey has already put the code there.  It just
needs to be made more strict :) It needs to free entries even if they
are in use.

After all, freeing an entry in use can't be much worse than not having
a cache at all.  OTOH, having a very long chain is definitely much worse
than not having a cache :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Mon, 4 Apr 2005 07:43:58 +1000
Message-ID: <20050403214358.GA15901@gondor.apana.org.au>
References: <E1DHdsP-0003Lr-00@gondolin.me.apana.org.au> <424E641A.1020609@cosmosbay.com> <16974.41648.568927.54429@robur.slu.se> <20050402193224.GA25157@gondor.apana.org.au> <16976.17876.832677.945878@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <16976.17876.832677.945878@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Apr 03, 2005 at 09:36:52PM +0200, Robert Olsson wrote:
> 
>  Well I don't see how we detect the need for rehash just be looking
>  at the hash chains. How does the the "lengthening" look like that
>  are allowed to trigger a rehash?

The only way to attack a hash is by exploiting collisions and
create one or more excessively long chains.

This can be detected as follows at each rt hash insertion.  If

(total number of entries in cache >> (hash length - user defined length)) <
current bucket length

is true, then we schedule a rehash/flush.

Hash length is the number of bits in the hash, i.e.,

1 << hash length == number of buckets

I'd suggest a default shift length of 3.  That is, if any individual
chain is growing beyond 8 times the average chain length then we've
got a problem.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

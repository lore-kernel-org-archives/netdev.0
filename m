From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [6/6]: jenkins hash for neigh
Date: Tue, 28 Sep 2004 08:00:15 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CC3Xb-0001yY-00@gondolin.me.apana.org.au>
References: <E1CC3FW-0001wo-00@gondolin.me.apana.org.au>
Cc: davem@davemloft.net, herbert@gondor.apana.org.au, laforge@gnumonks.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au (Herbert Xu)
In-Reply-To: <E1CC3FW-0001wo-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> Please at least do something like this:
> 
> size = tbl->hash_mask + 1;
> if (tbl->entries > size) {
>        write_lock_bh(&tbl->lock);
>        neigh_hash_grow(tbl, size << 1);
>        write_unlock_bh(&tbl->lock);
> }
> 
> That'll at least kill the first race.  You can kill the race of
> growing into the same size by doing the if check again inside the
> locks.

Never mind.  Unless you do the check again inside the lock this
may actually shrink :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

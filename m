From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.4] Bugfix in neigh_create
Date: Sat, 08 Jan 2005 21:36:57 +1100
Message-ID: <E1CnDxp-00015B-00@gondolin.me.apana.org.au>
References: <200501071452.29006.raivis@mt.lv>
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: raivis@mt.lv (Raivis Bucis)
In-Reply-To: <200501071452.29006.raivis@mt.lv>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Raivis Bucis <raivis@mt.lv> wrote:
> 
> I believe that there is a bug in neigh_create in linux-2.4.28 introduced by 
> neighbor cache backport from v2.6.9.

Yes you're right.  Unfortunately your patch's been broken by your
mailer.  Can you please resend it to davem as an attachment?

Thanks,
 
> diff -uNr linux-2.4.28.org/net/core/neighbour.c 
> linux-2.4.28/net/core/neighbour.c
> --- linux-2.4.28.org/net/core/neighbour.c 2004-11-17 13:54:22.000000000 +0200
> +++ linux-2.4.28/net/core/neighbour.c 2005-01-07 14:11:57.000000000 +0200
> @@ -427,11 +427,12 @@
> 
>  n->confirmed = jiffies - (n->parms->base_reachable_time<<1);
> 
> - hash_val = tbl->hash(pkey, dev) & tbl->hash_mask;
> -
>  write_lock_bh(&tbl->lock);
>  if (atomic_read(&tbl->entries) > (tbl->hash_mask + 1))
>   neigh_hash_grow(tbl, (tbl->hash_mask + 1) << 1);
> +
> + hash_val = tbl->hash(pkey, dev) & tbl->hash_mask;
> +
>  for (n1 = tbl->hash_buckets[hash_val]; n1; n1 = n1->next) {
>   if (dev == n1->dev &&
>       memcmp(n1->primary_key, pkey, key_len) == 0) {
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

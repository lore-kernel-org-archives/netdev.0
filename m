From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [6/6]: jenkins hash for neigh
Date: Mon, 27 Sep 2004 21:48:33 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CBtzd-0000zI-00@gondolin.me.apana.org.au>
References: <20040925005623.2faf8faf.davem@davemloft.net>
Cc: laforge@gnumonks.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20040925005623.2faf8faf.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:
> 
> 3) Fix locking and GFP_* bugs.
>
> @@ -400,8 +400,11 @@
>  		goto out;
>  	}
>  
> -	if (tbl->entries > (tbl->hash_mask + 1))
> +	if (tbl->entries > (tbl->hash_mask + 1)) {
> +		write_lock_bh(&tbl->lock);
>  		neigh_hash_grow(tbl, (tbl->hash_mask + 1) << 1);
> +		write_unlock_bh(&tbl->lock);
> +	}

The locking should be outside the if block as otherwise you may grow
unnecessarily or grow into the same size :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

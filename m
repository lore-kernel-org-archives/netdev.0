From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [6/6]: jenkins hash for neigh
Date: Mon, 27 Sep 2004 21:56:10 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CBu70-00010X-00@gondolin.me.apana.org.au>
References: <20040925005623.2faf8faf.davem@davemloft.net>
Cc: laforge@gnumonks.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20040925005623.2faf8faf.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:
> 
> 4) The controversial/RFC patch, dorking with neigh_forced_gc()
>
> +			if (n->nud_state -= NUD_INCOMPLETE &&
> +			    reap_incomplete == 0 &&
> +			    time_after(jiffies,
> +				       n->used + n->parms->retrans_time)) {
> +				num_incomplete++;
> +				goto next_ent;

That should either be time_before, or you need to swap the arguments.

@@ -261,7 +277,9 @@
 	if (tbl->entries > tbl->gc_thresh3 ||
 	    (tbl->entries > tbl->gc_thresh2 &&
 	     time_after(now, tbl->last_flush + 5 * HZ))) {
-		if (!neigh_forced_gc(tbl) &&
+		int goal = tbl->entries - tbl->gc_thresh3;

This could be negative but I suppose it's harmless...

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

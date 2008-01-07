From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPV4] ROUTE: Avoid sparse warnings
Date: Mon, 07 Jan 2008 23:11:53 +1100
Message-ID: <E1JBqpd-0006vB-00@gondolin.me.apana.org.au>
References: <20080107120117.aeebd0c8.dada1@cosmosbay.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	viro@ZenIV.linux.org.uk
To: dada1@cosmosbay.com (Eric Dumazet)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1358 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754135AbYAGMMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 07:12:13 -0500
In-Reply-To: <20080107120117.aeebd0c8.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <dada1@cosmosbay.com> wrote:
>  CHECK   net/ipv4/route.c
> net/ipv4/route.c:298:2: warning: context imbalance in 'rt_cache_get_first' - wrong count at exit
> net/ipv4/route.c:307:3: warning: context imbalance in 'rt_cache_get_next' - unexpected unlock
> net/ipv4/route.c:346:3: warning: context imbalance in 'rt_cache_seq_stop' - unexpected unlock
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 10915bb..fec0571 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -289,11 +289,11 @@ static struct rtable *rt_cache_get_first(struct seq_file *seq)
>        struct rt_cache_iter_state *st = seq->private;
> 
>        for (st->bucket = rt_hash_mask; st->bucket >= 0; --st->bucket) {
> -               rcu_read_lock_bh();
>                r = rt_hash_table[st->bucket].chain;
>                if (r)
>                        break;
>                rcu_read_unlock_bh();
> +               rcu_read_lock_bh();

If we have to change perfectly working code to silence sparse then
either sparse or we are doing something wrong.

This is not the only spot where we conditionally hold the lock.
There's got to be a better fix than changing all of them to hold
locks unconditionally.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

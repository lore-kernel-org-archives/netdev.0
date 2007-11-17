From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] IPV4 : Move ip route cache flush (secret_rebuild) from softirq to workqueue
Date: Sat, 17 Nov 2007 22:36:22 +0800
Message-ID: <20071117143622.GA20813@gondor.apana.org.au>
References: <20071116174027.726e6eca.dada1@cosmosbay.com> <20071116.165445.172804063.davem@davemloft.net> <473EB75B.7000607@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3589 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752123AbXKQOgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2007 09:36:33 -0500
Content-Disposition: inline
In-Reply-To: <473EB75B.7000607@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 17, 2007 at 09:41:47AM +0000, Eric Dumazet wrote:
>
> [PATCH] IPV4 : Move ip route cache flush (secret_rebuild) from softirq to 
> workqueue

Thanks for your work on this Eric! It's very much needed.

> @@ -667,7 +697,7 @@ void rt_cache_flush(int delay)
>  
>  	if (delay <= 0) {
>  		spin_unlock_bh(&rt_flush_lock);
> -		rt_run_flush(0);
> +		rt_run_flush(user_mode);
>  		return;
>  	}

This seems to be the only potentially softirq caller of rt_run_flush.
However, I just checked the callers of it and most of them seem to
hold the RTNL which would indicate that they're in process context.

So do you know if you we have any real softirq callers left?
If we do perhaps we can look at either moving them out or see
if they can cope with the flush occuring after the call returns.

If not we can get rid of the softirq special case.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

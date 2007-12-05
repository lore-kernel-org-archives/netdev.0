From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] NET: ASSERT_RTNL in __dev_set_promiscuity makes debug warning
Date: Wed, 5 Dec 2007 16:36:07 +1100
Message-ID: <20071205053607.GA10589@gondor.apana.org.au>
References: <000001c8365a$e0e500c0$9c94fea9@jason> <E1IzgPL-0006HB-00@gondolin.me.apana.org.au> <006001c836ff$f0d59a30$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	'David Miller' <davem@davemloft.net>
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3451 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751081AbXLEFgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 00:36:12 -0500
Content-Disposition: inline
In-Reply-To: <006001c836ff$f0d59a30$9c94fea9@jason>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 05, 2007 at 02:30:10PM +0900, Joonwoo Park wrote:
>
> @@ -140,9 +147,11 @@ int dev_mc_sync(struct net_device *to, struct net_device *from)
>  		da = next;
>  	}
>  	if (!err)
> -		__dev_set_rx_mode(to);
> +		pending = __dev_set_rx_mode(to);
>  	netif_tx_unlock_bh(to);
>  
> +	if (pending)
> +		__dev_set_rx_mode_fini(to);

The idea is to not touch the unicast stuff at all on the multicast path.

Anyway, this was discussed on netdev so please check the archives because
there is more to this than just changing the multicast handling.  We also
talked about consolidating the driver interface so that all these calls
have the same environment rather than the mix-and-match that we have now.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

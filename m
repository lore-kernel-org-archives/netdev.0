From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pppoe: Add missing sock_put() in pppoe_rcv()
Date: Fri, 31 Oct 2008 12:29:20 +0800
Message-ID: <20081031042920.GA6101@gondor.apana.org.au>
References: <20081030085725.GA15289@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46624 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751926AbYJaE31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 00:29:27 -0400
Content-Disposition: inline
In-Reply-To: <20081030085725.GA15289@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 30, 2008 at 08:57:25AM +0000, Jarek Poplawski wrote:
>
> diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
> index fc6f4b8..c074276 100644
> --- a/drivers/net/pppoe.c
> +++ b/drivers/net/pppoe.c
> @@ -403,8 +403,10 @@ static int pppoe_rcv(struct sk_buff *skb,
>  	if (!po)
>  		goto drop;
>  
> -	if (pskb_trim_rcsum(skb, len))
> +	if (pskb_trim_rcsum(skb, len)) {
> +		sock_put(sk_pppox(po));
>  		goto drop;
> +	}

Actually we might be better off moving the trim before the get_item
call.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

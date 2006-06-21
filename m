From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: + myri10ge-build-fix.patch added to -mm tree
Date: Wed, 21 Jun 2006 14:41:07 +1000
Message-ID: <20060621044107.GB899@gondor.apana.org.au>
References: <200606210433.k5L4XgmP008626@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mm-commits@vger.kernel.org, bgoglin@myri.com, davem@davemloft.net,
	jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:20241 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932283AbWFUElj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 00:41:39 -0400
To: akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <200606210433.k5L4XgmP008626@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 20, 2006 at 09:33:42PM -0700, akpm@osdl.org wrote:
>
> diff -puN drivers/net/myri10ge/myri10ge.c~myri10ge-build-fix drivers/net/myri10ge/myri10ge.c
> --- a/drivers/net/myri10ge/myri10ge.c~myri10ge-build-fix
> +++ a/drivers/net/myri10ge/myri10ge.c
> @@ -2120,7 +2120,7 @@ abort_linearize:
>  		goto drop;
>  	}
>  
> -	if (skb_linearize(skb, GFP_ATOMIC))
> +	if (skb_linearize(skb))
>  		goto drop;

Actually I think this driver (in conjunction with TSO) is buggy.
It has a maximum segment count of 12.  However TSO can send 13 pages
or more of data on i386.  If this happens it looks like this driver
will go into an infinite loop forever trying to linearize the skb.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

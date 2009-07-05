From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ipv6: Keep index within tab_unreach[]
Date: Sun, 5 Jul 2009 11:46:55 +0800
Message-ID: <20090705034655.GA7635@gondor.apana.org.au>
References: <4A37E715.4060504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50506 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753482AbZGEDq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jul 2009 23:46:56 -0400
Content-Disposition: inline
In-Reply-To: <4A37E715.4060504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roel Kluin <roel.kluin@gmail.com> wrote:
> Ensure that index `code' remains within array tab_unreach[]
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
> index 36dff88..8f850de 100644
> --- a/net/ipv6/icmp.c
> +++ b/net/ipv6/icmp.c
> @@ -923,7 +923,7 @@ int icmpv6_err_convert(int type, int code, int *err)
>        switch (type) {
>        case ICMPV6_DEST_UNREACH:
>                fatal = 1;
> -               if (code <= ICMPV6_PORT_UNREACH) {
> +               if (code <= ICMPV6_PORT_UNREACH && code >= 0) {

Why not make code unsigned?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

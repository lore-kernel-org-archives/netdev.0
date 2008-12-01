From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCHv2] xfrm: Fix kernel panic when flush and dump SPD
	entries
Date: Mon, 1 Dec 2008 13:00:46 +0800
Message-ID: <20081201050046.GB18292@gondor.apana.org.au>
References: <49334542.3070502@cn.fujitsu.com> <49334788.4030409@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60970 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750850AbYLAFAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 00:00:54 -0500
Content-Disposition: inline
In-Reply-To: <49334788.4030409@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 01, 2008 at 10:10:16AM +0800, Wei Yongjun wrote:
>
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index 058f04f..fb216c9 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -817,6 +817,7 @@ int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info)
>  				continue;
>  			hlist_del(&pol->bydst);
>  			hlist_del(&pol->byidx);
> +			list_del(&pol->walk.all);

Good catch.  In fact there so man occurrences of these three calls
that perhaps we should put them (and any other relevant code) in a
helper.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

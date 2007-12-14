From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 2/4] net: use mutex_is_locked() for ASSERT_RTNL()
Date: Fri, 14 Dec 2007 16:10:44 +0800
Message-ID: <E1J35d6-00041l-00@gondolin.me.apana.org.au>
References: <200712140002.lBE02aGO025491@imap1.linux-foundation.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4135 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754101AbXLNIKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 03:10:54 -0500
In-Reply-To: <200712140002.lBE02aGO025491@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
>
> diff -puN drivers/net/cxgb3/cxgb3_main.c~net-use-mutex_is_locked-for-assert_rtnl drivers/net/cxgb3/cxgb3_main.c
> --- a/drivers/net/cxgb3/cxgb3_main.c~net-use-mutex_is_locked-for-assert_rtnl
> +++ a/drivers/net/cxgb3/cxgb3_main.c
> @@ -2191,7 +2191,7 @@ static void check_t3b2_mac(struct adapte
> {
>        int i;
> 
> -       if (!rtnl_trylock())    /* synchronize with ifdown */
> +       if (rtnl_is_locked())   /* synchronize with ifdown */
>                return;
> 
>        for_each_port(adapter, i) {
> @@ -2219,7 +2219,6 @@ static void check_t3b2_mac(struct adapte
>                        p->mac.stats.num_resets++;
>                }
>        }
> -       rtnl_unlock();

This doesn't look right.  It seems that they really want trylock
here so we should just fix it by removing the bang.

Also, does ASSERT_RTNL still warn when someone calls it from an
atomic context? We definitely don't want to lose that check.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

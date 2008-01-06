From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/4] [XFRM]: Kill some bloat
Date: Sun, 06 Jan 2008 11:29:35 +1100
Message-ID: <E1JBJOR-0000jO-00@gondolin.me.apana.org.au>
References: <1199540349385-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: davem@davemloft.net, netdev@vger.kernel.org, acme@redhat.com,
	ilpo.jarvinen@helsinki.fi, paul.moore@hp.com, latten@us.ibm.com
To: ilpo.jarvinen@helsinki.fi (Ilpo J??rvinen)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2637 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753862AbYAFA3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 19:29:48 -0500
In-Reply-To: <1199540349385-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi> wrote:
>
> Signed-off-by: Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

> #ifdef CONFIG_AUDITSYSCALL
> -static inline void xfrm_audit_helper_sainfo(struct xfrm_state *x,
> -                                           struct audit_buffer *audit_buf)
> +static void xfrm_audit_helper_sainfo(struct xfrm_state *x,
> +                                    struct audit_buffer *audit_buf)

We should never use inline except when it's on the fast path and this
is definitely not a fast path.  If a function ends up being called
just once the compiler will most likely inline it anyway, making the
use of the keyword inline redundant.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Thu, 01 Apr 2010 15:05:20 +0200
Message-ID: <1270127120.2229.93.camel@edumazet-laptop>
References: <1270126340-30181-1-git-send-email-timo.teras@iki.fi>
	 <1270126340-30181-2-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:54902 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993Ab0DANFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 09:05:25 -0400
Received: by bwz1 with SMTP id 1so822054bwz.21
        for <netdev@vger.kernel.org>; Thu, 01 Apr 2010 06:05:23 -0700 (PDT)
In-Reply-To: <1270126340-30181-2-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 avril 2010 =C3=A0 15:52 +0300, Timo Teras a =C3=A9crit :
> This allows to validate the cached object before returning it.
> It also allows to destruct object properly, if the last reference
> was held in flow cache. This is also a prepartion for caching
> bundles in the flow cache.
>=20
> In return for virtualizing the methods, we save on:
> - not having to regenerate the whole flow cache on policy removal:
>   each flow matching a killed policy gets refreshed as the getter
>   function notices it smartly.
> - we do not have to call flow_cache_flush from policy gc, since the
>   flow cache now properly deletes the object if it had any references
>=20
> Signed-off-by: Timo Teras <timo.teras@iki.fi>
> ---

=2E..

> @@ -481,6 +482,7 @@ struct xfrm_policy {
>  	atomic_t		refcnt;
>  	struct timer_list	timer;
> =20
> +	struct flow_cache_entry_ops *fc_ops;
>  	u32			priority;
>  	u32			index;
>  	struct xfrm_mark	mark;
=2E..

> +static struct flow_cache_entry_ops xfrm_policy_fc_ops __read_mostly =
=3D {
> +	.get =3D xfrm_policy_get_fce,
> +	.check =3D xfrm_policy_check_fce,
> +	.delete =3D xfrm_policy_delete_fce,
> +};
> =20

Any particular reason these flow_cache_entry_ops are not const ?



From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: ipv6: mcast: Removing invalid check
Date: Sat, 14 May 2011 16:33:30 +0200
Message-ID: <1305383610.3120.62.camel@edumazet-laptop>
References: <20110514134307.GA3603@maxin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net, yoshfuji@linux-ipv6.org, jmorris@namei.org,
	pekkas@netcore.fi, kuznet@ms2.inr.ac.ru, davem@davemloft.net
To: Maxin B John <maxin.john@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46945 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755813Ab1ENOdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2011 10:33:38 -0400
In-Reply-To: <20110514134307.GA3603@maxin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 14 mai 2011 =C3=A0 16:43 +0300, Maxin B John a =C3=A9crit :
> Since the variable 'first' is assigned to 1, the check
> "if (truncate && !first)" will always be false.
>=20
> Thanks to Coverity for spotting this issue.
>=20
> Signed-off-by: Maxin B. John <maxin.john@gmail.com>
> ---
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index 76b8937..441c1a4 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -1536,8 +1536,6 @@ static struct sk_buff *add_grec(struct sk_buff =
*skb, struct ifmcaddr6 *pmc,
> =20
>  		if (AVAILABLE(skb) < sizeof(*psrc) +
>  		    first*sizeof(struct mld2_grec)) {
> -			if (truncate && !first)
> -				break;	 /* truncate these */
>  			if (pgr)
>  				pgr->grec_nsrcs =3D htons(scount);
>  			if (skb)

At a first glance, I would say Coverity is wrong, unless you can explai=
n
why it's right ;)

first can be 0 at this point, we are in a loop.

BTW "Removing invalid check" is a really wrong patch title.

Once you can prove your point, you should use "Remove useless check"

Thanks



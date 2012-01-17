From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: fix NULL-deref in WARN() in skb_gso_segment()
Date: Tue, 17 Jan 2012 20:23:05 +0000
Message-ID: <1326831785.2478.22.camel@bwh-desktop>
References: <a9312f6addc77e2af43ef4e1cceb91676944ae3d.1326829994.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Joe Perches <joe@perches.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:22321 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755642Ab2AQUXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 15:23:09 -0500
In-Reply-To: <a9312f6addc77e2af43ef4e1cceb91676944ae3d.1326829994.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-01-17 at 21:00 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> Bug was introduced in commit c8f44affb7244f2ac3e703cab13d55ede27621bb=
=2E

Sorry, this conflicts with changes I've just submitted, the first of
which has already been applied.

Ben.

> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
>  net/core/dev.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
>=20
> [against net tree]
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index f494675..634a70a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1961,6 +1961,7 @@ struct sk_buff *skb_gso_segment(struct sk_buff =
*skb,
>  	__skb_pull(skb, skb->mac_len);
> =20
>  	if (unlikely(skb->ip_summed !=3D CHECKSUM_PARTIAL)) {
> +		static const netdev_features_t null_features =3D 0;
>  		struct net_device *dev =3D skb->dev;
>  		struct ethtool_drvinfo info =3D {};
> =20
> @@ -1968,8 +1969,8 @@ struct sk_buff *skb_gso_segment(struct sk_buff =
*skb,
>  			dev->ethtool_ops->get_drvinfo(dev, &info);
> =20
>  		WARN(1, "%s: caps=3D(%pNF, %pNF) len=3D%d data_len=3D%d ip_summed=3D=
%d\n",
> -		     info.driver, dev ? &dev->features : NULL,
> -		     skb->sk ? &skb->sk->sk_route_caps : NULL,
> +		     info.driver, dev ? &dev->features : &null_features,
> +		     skb->sk ? &skb->sk->sk_route_caps : &null_features,
>  		     skb->len, skb->data_len, skb->ip_summed);
> =20
>  		if (skb_header_cloned(skb) &&

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

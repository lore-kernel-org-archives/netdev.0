From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] net: fix hw_features ethtool_ops->set_flags
 compatibility
Date: Fri, 22 Apr 2011 07:16:42 +0200
Message-ID: <1303449402.13893.6.camel@edumazet-laptop>
References: <20110421231232.BF22613909@rere.qmqm.pl>
	 <1303426342.3464.184.camel@localhost> <20110421221548.GA7888@rere.qmqm.pl>
	 <20110412144940.GA26043@rere.qmqm.pl>
	 <20110411202630.C079D13909@rere.qmqm.pl>
	 <1302610228.32697.298.camel@lb-tlvb-vladz>
	 <20110412140708.GA21835@rere.qmqm.pl>
	 <1302619012.6750.8.camel@lb-tlvb-vladz>
	 <20110412193823.0823213A65@rere.qmqm.pl>
	 <1303397531.3685.16.camel@edumazet-laptop>
	 <1303411750.19212.123.camel@lb-tlvb-vladz>
	 <1303413559.3165.55.camel@bwh-desktop> <20110421221548.GA7888@rere.qmqm.pl>
	 <20110421235921.89D1D13909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	Vladislav Zolotarov <vladz@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34054 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006Ab1DVFQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 01:16:47 -0400
Received: by wwa36 with SMTP id 36so383160wwa.1
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 22:16:46 -0700 (PDT)
In-Reply-To: <20110421235921.89D1D13909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 22 avril 2011 =C3=A0 01:59 +0200, Micha=C5=82 Miros=C5=82aw=
 a =C3=A9crit :
> __ethtool_set_flags() was not taking into account features set but no=
t
> user-toggleable.
>=20
> Since GFLAGS returns masked dev->features, EINVAL is returned when
> passed flags differ to it, and not to wanted_features.
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
> This should be the simpler way Ben was talking about.
>=20
>  net/core/ethtool.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 13d79f5..d8b1a8d 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -546,12 +546,12 @@ int __ethtool_set_flags(struct net_device *dev,=
 u32 data)
>  	}
> =20
>  	/* allow changing only bits set in hw_features */
> -	changed =3D (data ^ dev->wanted_features) & flags_dup_features;
> +	changed =3D (data ^ dev->features) & flags_dup_features;
>  	if (changed & ~dev->hw_features)
>  		return (changed & dev->hw_features) ? -EINVAL : -EOPNOTSUPP;
> =20
>  	dev->wanted_features =3D
> -		(dev->wanted_features & ~changed) | data;
> +		(dev->wanted_features & ~changed) | (data & dev->hw_features);
> =20
>  	__netdev_update_features(dev);
> =20

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Tested-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks, this solves the bnx2x problem !



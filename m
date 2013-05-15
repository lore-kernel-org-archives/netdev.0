From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH] bonding: allow TSO being set on bonding master
Date: Thu, 16 May 2013 00:55:40 +0200
Message-ID: <CAHXqBF+r3wnWY+hveYjVBNwbVYdiDF4mOj1UmbKeH3OYo6kz6Q@mail.gmail.com>
References: <1368654065.4519.53.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:46836 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754323Ab3EOW4B convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 18:56:01 -0400
Received: by mail-ie0-f171.google.com with SMTP id e11so5024610iej.2
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 15:56:01 -0700 (PDT)
In-Reply-To: <1368654065.4519.53.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/5/15 Eric Dumazet <eric.dumazet@gmail.com>:
> From: Eric Dumazet <edumazet@google.com>
>
> In some situations, we need to disable TSO on bonding slaves.
>
> bonding device automatically unset TSO in bond_fix_features(), and
> performance is not good because :
>
> 1) We consume more cpu cycles.
>
> 2) GSO segmentation has some bugs leading to out of order TCP packets
> if this segmentation is done before virtual device. This particular
> problem will be addressed in a separate patch.
>
> This patch allows TSO being set/unset on the bonding master,
> so that GSO segmentation is done after bonding layer.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jay Vosburgh <fubar@us.ibm.com>
> Cc: Andy Gospodarek <andy@greyhouse.net>
> Cc: Maciej =C5=BBenczykowski <maze@google.com>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> ---
>  drivers/net/bonding/bond_main.c |    5 +++++
>  1 file changed, 5 insertions(+)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index d0aade0..b429bb8 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1362,6 +1362,11 @@ static netdev_features_t bond_fix_features(str=
uct net_device *dev,
>                                                      slave->dev->feat=
ures,
>                                                      mask);
>         }
> +       /* Allow TSO being used on bonding device :
> +        * Performing the GSO segmentation after bonding transmit
> +        * is a performance improvement.
> +        */
> +       features |=3D mask & NETIF_F_ALL_TSO;
>
>  out:
>         read_unlock(&bond->lock);

Have you tried adding it to NETIF_F_ONE_FOR_ALL set? 'Team' and bridge
could then also use it.

Best Regards,
Micha=C5=82 Miros=C5=82aw

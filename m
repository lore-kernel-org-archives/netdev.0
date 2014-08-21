From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH net-next v3 3/3] enic: Add tunable_ops support for rx_copybreak
Date: Fri, 22 Aug 2014 00:12:03 +0200
Message-ID: <CAHXqBFKS+LOPWW+CjuSc3sNDMvBGL100qwLL3L9jeyKgGD0ZgQ@mail.gmail.com>
References: <1408008560-1067-1-git-send-email-_govind@gmx.com> <1408008560-1067-4-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, ben@decadent.org.uk,
	stephen@networkplumber.org, ssujith@cisco.com, benve@cisco.com
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:35122 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755396AbaHUWMY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 18:12:24 -0400
Received: by mail-ie0-f169.google.com with SMTP id rd18so5540415iec.0
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2014 15:12:23 -0700 (PDT)
In-Reply-To: <1408008560-1067-4-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-08-14 11:29 GMT+02:00 Govindarajulu Varadarajan <_govind@gmx.com>:
> This patch adds support for setting/getting rx_copybreak using
> tunable_ops.
>
> Defines enic_get_rx_copybreak() & enic_set_rx_copybreak() tunable_ops=
=2E
>
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
> ---
>  drivers/net/ethernet/cisco/enic/enic_ethtool.c | 30 ++++++++++++++++=
++++++++++
>  1 file changed, 30 insertions(+)
>
> diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers=
/net/ethernet/cisco/enic/enic_ethtool.c
> index 523c9ce..9bf53fc 100644
> --- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
> +++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
> @@ -379,6 +379,30 @@ static int enic_get_rxnfc(struct net_device *dev=
, struct ethtool_rxnfc *cmd,
>         return ret;
>  }
>
> +static int enic_get_rx_copybreak(struct net_device *dev,
> +                                struct ethtool_tunable *tuna)
> +{
> +       struct enic *enic =3D netdev_priv(dev);
> +
> +       if (tuna->len < sizeof(tuna->data.rx_copybreak))
> +               return -ENOSPC;
> +       tuna->data.rx_copybreak =3D enic->rx_copybreak;
> +
> +       return 0;
> +}
> +
> +static int enic_set_rx_copybreak(struct net_device *dev,
> +                                struct ethtool_tunable *tuna)
> +{
> +       struct enic *enic =3D netdev_priv(dev);
> +
> +       if (tuna->len !=3D sizeof(tuna->data.rx_copybreak))
> +               return -EINVAL;
> +       enic->rx_copybreak =3D tuna->data.rx_copybreak;
> +
> +       return 0;
> +}
> +
>  static const struct ethtool_ops enic_ethtool_ops =3D {
>         .get_settings =3D enic_get_settings,
>         .get_drvinfo =3D enic_get_drvinfo,
> @@ -391,6 +415,12 @@ static const struct ethtool_ops enic_ethtool_ops=
 =3D {
>         .get_coalesce =3D enic_get_coalesce,
>         .set_coalesce =3D enic_set_coalesce,
>         .get_rxnfc =3D enic_get_rxnfc,
> +       .tunable_ops =3D {
> +               [ETHTOOL_RX_COPYBREAK] =3D {
> +                       .set =3D enic_set_rx_copybreak,
> +                       .get =3D enic_get_rx_copybreak,
> +               },
> +       },
>  };
>
>  void enic_set_ethtool_ops(struct net_device *netdev)

This is a lot of boilerplate code to write for such a simple variable.

BTW, there are a lot of drivers that use rx_copybreak idea. Some time
ago, I tried to unify rx packet handling, but got into too many leafs
of the theme.You could google up 'rx_copybreak handling' if you'd like
to revive the idea.

Best Regards,
Micha=C5=82 Miros=C5=82aw

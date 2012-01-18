From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 3/6] mlx4_en: eth statistics modification
Date: Wed, 18 Jan 2012 20:54:17 +0100
Message-ID: <1326916457.2742.0.camel@edumazet-laptop>
References: <4F17204D.6030109@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, eugenia@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:49823 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757601Ab2ARTyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 14:54:21 -0500
Received: by wibhm6 with SMTP id hm6so2508585wib.19
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 11:54:20 -0800 (PST)
In-Reply-To: <4F17204D.6030109@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 janvier 2012 =C3=A0 21:41 +0200, Yevgeny Petrilin a =C3=A9=
crit :
> From: Eugenia Emantayev <eugenia@mellanox.co.il>
>=20
> In native mode display all available statistics.
> In SRIOV mode on VF display only SW counters statistics,
> in SRIOV mode on hypervisor display SW counters and errors (got from =
=46W)
> statistics.
>=20
> Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
> Reviewed-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |   72 +++++++++++++=
+++++-----
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |    2 +
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    1 +
>  drivers/net/ethernet/mellanox/mlx4/port.c       |   21 +++++++
>  include/linux/mlx4/device.h                     |    1 +
>  5 files changed, 81 insertions(+), 16 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/driver=
s/net/ethernet/mellanox/mlx4/en_ethtool.c
> index 53c6686..0e5f275 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> @@ -183,10 +183,17 @@ static int mlx4_en_set_wol(struct net_device *n=
etdev,
>  static int mlx4_en_get_sset_count(struct net_device *dev, int sset)
>  {
>  	struct mlx4_en_priv *priv =3D netdev_priv(dev);
> +	u64 bm =3D priv->stats_bitmap;
> +	int bit_count =3D 0;
> =20
>  	switch (sset) {
>  	case ETH_SS_STATS:
> -		return NUM_ALL_STATS +
> +		while (bm) {
> +			if (bm & 1)
> +				bit_count++;
> +			bm >>=3D 1;
> +		}

hweight64(bm) ?

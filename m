From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH 2/2] net: ethernet: nb8800: use phy_ethtool_{get|set}_link_ksettings
Date: Sun, 19 Jun 2016 12:32:00 +0100
Message-ID: <yw1xk2hlwh1r.fsf@unicorn.mansr.com>
References: <1466284615-7045-1-git-send-email-tremyfr@gmail.com>
	<1466284615-7045-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, sf84@laposte.net, arnd@arndb.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466284615-7045-2-git-send-email-tremyfr@gmail.com> (Philippe
	Reynes's message of "Sat, 18 Jun 2016 23:16:55 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Philippe Reynes <tremyfr@gmail.com> writes:

> There are two generics functions phy_ethtool_{get|set}_link_ksettings=
,
> so we can use them instead of defining the same code in the driver.
>
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Acked-by: Mans Rullgard <mans@mansr.com>

> ---
>  drivers/net/ethernet/aurora/nb8800.c |   24 ++----------------------
>  1 files changed, 2 insertions(+), 22 deletions(-)
>
> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ether=
net/aurora/nb8800.c
> index 4989d31..dc2c35d 100644
> --- a/drivers/net/ethernet/aurora/nb8800.c
> +++ b/drivers/net/ethernet/aurora/nb8800.c
> @@ -1035,26 +1035,6 @@ static const struct net_device_ops nb8800_netd=
ev_ops =3D {
>  	.ndo_validate_addr	=3D eth_validate_addr,
>  };
>
> -static int nb8800_get_settings(struct net_device *dev, struct ethtoo=
l_cmd *cmd)
> -{
> -	struct phy_device *phydev =3D dev->phydev;
> -
> -	if (!phydev)
> -		return -ENODEV;
> -
> -	return phy_ethtool_gset(phydev, cmd);
> -}
> -
> -static int nb8800_set_settings(struct net_device *dev, struct ethtoo=
l_cmd *cmd)
> -{
> -	struct phy_device *phydev =3D dev->phydev;
> -
> -	if (!phydev)
> -		return -ENODEV;
> -
> -	return phy_ethtool_sset(phydev, cmd);
> -}
> -
>  static int nb8800_nway_reset(struct net_device *dev)
>  {
>  	struct phy_device *phydev =3D dev->phydev;
> @@ -1183,8 +1163,6 @@ static void nb8800_get_ethtool_stats(struct net=
_device *dev,
>  }
>
>  static const struct ethtool_ops nb8800_ethtool_ops =3D {
> -	.get_settings		=3D nb8800_get_settings,
> -	.set_settings		=3D nb8800_set_settings,
>  	.nway_reset		=3D nb8800_nway_reset,
>  	.get_link		=3D ethtool_op_get_link,
>  	.get_pauseparam		=3D nb8800_get_pauseparam,
> @@ -1192,6 +1170,8 @@ static const struct ethtool_ops nb8800_ethtool_=
ops =3D {
>  	.get_sset_count		=3D nb8800_get_sset_count,
>  	.get_strings		=3D nb8800_get_strings,
>  	.get_ethtool_stats	=3D nb8800_get_ethtool_stats,
> +	.get_link_ksettings	=3D phy_ethtool_get_link_ksettings,
> +	.set_link_ksettings	=3D phy_ethtool_set_link_ksettings,
>  };
>
>  static int nb8800_hw_init(struct net_device *dev)
> --=20
> 1.7.4.4
>

--=20
M=E5ns Rullg=E5rd

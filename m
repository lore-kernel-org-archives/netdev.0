From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] sh: sh_eth: Add support ethtool
Date: Tue, 11 Jan 2011 13:19:03 +0100
Message-ID: <1294748343.2927.57.camel@edumazet-laptop>
References: <1294747109-11511-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	yoshihiro.shimoda.uh@renesas.com, bhutchings@solarflare.com
To: nobuhiro.iwamatsu.yj@renesas.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1294747109-11511-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 11 janvier 2011 =C3=A0 20:58 +0900, nobuhiro.iwamatsu.yj@renes=
as.com
a =C3=A9crit :
> From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
>=20
> This commit supports following functions.
>  - get_drvinfo
>  - get_settings
>  - set_settings
>  - nway_reset
>  - get_msglevel
>  - set_msglevel
>  - get_link
>  - get_strings
>  - get_ethtool_stats
>  - get_sset_count
>=20
> About other function, the device does not support.
>=20
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> ---

> +static const char sh_eth_gstrings_stats[][ETH_GSTRING_LEN] =3D {
> +	"rx_packets", "tx_packets", "rx_bytes", "tx_bytes", "rx_errors",
> +	"tx_errors", "rx_dropped", "tx_dropped", "multicast", "collisions",
> +	"rx_length_errors", "rx_over_errors", "rx_crc_errors",
> +	"rx_frame_errors", "rx_fifo_errors", "rx_missed_errors",
> +	"tx_aborted_errors", "tx_carrier_errors", "tx_fifo_errors",
> +	"tx_heartbeat_errors", "tx_window_errors",
> +	/* device-specific stats */
> +	"rx_current", "tx_current",
> +	"rx_dirty", "tx_dirty",
> +};
> +#define SH_ETH_NET_STATS_LEN  21
> +#define SH_ETH_STATS_LEN  ARRAY_SIZE(sh_eth_gstrings_stats)

Why is it needed to report standard device stats ?


> +
> +static int sh_eth_get_sset_count(struct net_device *netdev, int sset=
)
> +{
> +	switch (sset) {
> +	case ETH_SS_STATS:
> +		return SH_ETH_STATS_LEN;
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +}
> +
> +static void sh_eth_get_ethtool_stats(struct net_device *ndev,
> +			struct ethtool_stats *stats, u64 *data)
> +{
> +	struct sh_eth_private *mdp =3D netdev_priv(ndev);
> +	int i =3D SH_ETH_NET_STATS_LEN;
> +
> +	memcpy(data, (unsigned long *)&ndev->stats,
> +				SH_ETH_NET_STATS_LEN * sizeof(unsigned long));

This is wrong on 32bit arches.
ndev->stats is an array of "long" values, not u64 ones.

> +
> +	/* device-specific stats */
> +	data[i++] =3D mdp->cur_rx;
> +	data[i++] =3D mdp->cur_tx;
> +	data[i++] =3D mdp->dirty_rx;
> +	data[i++] =3D mdp->dirty_tx;
> +}
> +




From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next] sundance: Add initial ethtool stats support
Date: Sat, 09 Oct 2010 14:33:33 +0200
Message-ID: <1286627613.2692.26.camel@edumazet-laptop>
References: <20101009095346.GA12951@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Denis Kirjanov <dkirjanov@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58544 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754845Ab0JIMdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Oct 2010 08:33:54 -0400
Received: by wwj40 with SMTP id 40so2144788wwj.1
        for <netdev@vger.kernel.org>; Sat, 09 Oct 2010 05:33:53 -0700 (PDT)
In-Reply-To: <20101009095346.GA12951@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 09 octobre 2010 =C3=A0 09:53 +0000, Denis Kirjanov a =C3=A9cr=
it :
> Add initial ethtool statistics support=20
>=20
> Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
> ---
>  drivers/net/sundance.c |   46 ++++++++++++++++++++++++++++++++++++++=
++++++++
>  1 files changed, 46 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
> index 27d69aa..685845b 100644
> --- a/drivers/net/sundance.c
> +++ b/drivers/net/sundance.c
> @@ -1564,6 +1564,18 @@ static int __set_mac_addr(struct net_device *d=
ev)
>  	return 0;
>  }
> =20
> +static const struct {
> +	const char name[ETH_GSTRING_LEN];
> +} sundance_stats[] =3D {
> +	{ "tx_packets" },
> +	{ "tx_bytes" },
> +	{ "rx_packets" },
> +	{ "rx_bytes" },
> +	{ "tx_errors" },
> +	{ "tx_dropped" },
> +	{ "rx_errors" },
> +};
> +
>  static int check_if_running(struct net_device *dev)
>  {
>  	if (!netif_running(dev))
> @@ -1622,6 +1634,37 @@ static void set_msglevel(struct net_device *de=
v, u32 val)
>  	np->msg_enable =3D val;
>  }
> =20
> +static void get_strings(struct net_device *dev, u32 stringset,
> +		u8 *data)
> +{

	if (stringset !=3D ETH_SS_STATS)
		return;

> +	memcpy(data, sundance_stats, sizeof(sundance_stats));
> +}
> +
> +static int get_sset_count(struct net_device *dev, int sset)
> +{
> +	switch (sset) {
> +	case ETH_SS_STATS:
> +		return ARRAY_SIZE(sundance_stats);
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +}
> +
> +static void get_ethtool_stats(struct net_device *dev,
> +		struct ethtool_stats *stats, u64 *data)
> +{
> +	struct net_device_stats *netdev_stats =3D get_stats(dev);
> +	int i =3D 0;
> +
> +	data[i++] =3D netdev_stats->tx_packets;
> +	data[i++] =3D netdev_stats->tx_bytes;
> +	data[i++] =3D netdev_stats->rx_packets;
> +	data[i++] =3D netdev_stats->rx_bytes;
> +	data[i++] =3D netdev_stats->tx_errors;
> +	data[i++] =3D netdev_stats->tx_dropped;
> +	data[i++] =3D netdev_stats->rx_errors;
> +}
> +
>  static const struct ethtool_ops ethtool_ops =3D {
>  	.begin =3D check_if_running,
>  	.get_drvinfo =3D get_drvinfo,
> @@ -1631,6 +1674,9 @@ static const struct ethtool_ops ethtool_ops =3D=
 {
>  	.get_link =3D get_link,
>  	.get_msglevel =3D get_msglevel,
>  	.set_msglevel =3D set_msglevel,
> +	.get_strings =3D get_strings,
> +	.get_sset_count =3D get_sset_count,
> +	.get_ethtool_stats =3D get_ethtool_stats,
>  };
> =20
>  static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, in=
t cmd)



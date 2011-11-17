From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] net: verify GSO flag bits against netdev features
Date: Thu, 17 Nov 2011 00:09:56 +0000
Message-ID: <1321488596.2709.68.camel@bwh-desktop>
References: <2ec988cd27c6eb5162ea2e41416edcaae207bb5e.1321488025.git.mirq-linux@rere.qmqm.pl>
	 <d4513ed885d62d13873f9b7310fc20cbfa55f634.1321488025.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:41204 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754159Ab1KQAKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 19:10:02 -0500
In-Reply-To: <d4513ed885d62d13873f9b7310fc20cbfa55f634.1321488025.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-11-17 at 01:05 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
>  include/linux/netdevice.h |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
>=20
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index b35ffd7..31da3bb 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2492,6 +2492,15 @@ netdev_features_t netif_skb_features(struct sk=
_buff *skb);
>  static inline int net_gso_ok(netdev_features_t features, int gso_typ=
e)
>  {
>  	netdev_features_t feature =3D gso_type << NETIF_F_GSO_SHIFT;
> +
> +	/* check flags correspondence */
> +	BUILD_BUG_ON(SKB_GSO_TCPV4   !=3D (NETIF_F_TSO >> NETIF_F_GSO_SHIFT=
));
> +	BUILD_BUG_ON(SKB_GSO_UDP     !=3D (NETIF_F_UFO >> NETIF_F_GSO_SHIFT=
));
> +	BUILD_BUG_ON(SKB_GSO_DODGY   !=3D (NETIF_F_GSO_ROBUST >> NETIF_F_GS=
O_SHIFT));
> +	BUILD_BUG_ON(SKB_GSO_TCP_ECN !=3D (NETIF_F_TSO_ECN >> NETIF_F_GSO_S=
HIFT));
> +	BUILD_BUG_ON(SKB_GSO_TCPV6   !=3D (NETIF_F_TSO6 >> NETIF_F_GSO_SHIF=
T));
> +	BUILD_BUG_ON(SKB_GSO_FCOE    !=3D (NETIF_F_FSO >> NETIF_F_GSO_SHIFT=
));
> +
>  	return (features & feature) =3D=3D feature;
>  }

This is fine but should still be done at the same time as changing the
definitions.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

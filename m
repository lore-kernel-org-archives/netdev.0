From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sit: fix regression: do not release skb->dst before xmit
Date: Sat, 11 Jul 2009 15:24:15 +0200
Message-ID: <4A58927F.7040405@gmail.com>
References: <1247317289-27867-1-git-send-email-contact@saschahlusiak.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, berni@birkenwald.de
To: Sascha Hlusiak <contact@saschahlusiak.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37764 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124AbZGKNYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2009 09:24:46 -0400
In-Reply-To: <1247317289-27867-1-git-send-email-contact@saschahlusiak.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sascha Hlusiak a =E9crit :
> The sit module makes use of skb->dst in it's xmit function,
> so since 93f154b594fe47 sit tunnels are broken, because the
> flag IFF_XMIT_DST_RELEASE is not unset.
>=20
> This patch unsets that flag for sit devices to fix this
> regression.
>=20
> Signed-off-by: Sascha Hlusiak <contact@saschahlusiak.de>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

> ---
>  net/ipv6/sit.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
> index 68e5230..98b7327 100644
> --- a/net/ipv6/sit.c
> +++ b/net/ipv6/sit.c
> @@ -1018,6 +1018,7 @@ static void ipip6_tunnel_setup(struct net_devic=
e *dev)
>  	dev->hard_header_len 	=3D LL_MAX_HEADER + sizeof(struct iphdr);
>  	dev->mtu		=3D ETH_DATA_LEN - sizeof(struct iphdr);
>  	dev->flags		=3D IFF_NOARP;
> +	dev->priv_flags	       &=3D ~IFF_XMIT_DST_RELEASE;
>  	dev->iflink		=3D 0;
>  	dev->addr_len		=3D 4;
>  	dev->features		|=3D NETIF_F_NETNS_LOCAL;


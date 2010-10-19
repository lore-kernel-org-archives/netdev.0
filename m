From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip6_tunnel dont update the mtu on the route.
Date: Tue, 19 Oct 2010 16:32:08 +0200
Message-ID: <1287498728.2676.110.camel@edumazet-laptop>
References: <1287496247-24127-1-git-send-email-Anders.Franzen@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Anders.Franzen@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52077 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077Ab0JSOcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 10:32:13 -0400
Received: by wwe15 with SMTP id 15so56035wwe.1
        for <netdev@vger.kernel.org>; Tue, 19 Oct 2010 07:32:12 -0700 (PDT)
In-Reply-To: <1287496247-24127-1-git-send-email-Anders.Franzen@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 19 octobre 2010 =C3=A0 15:50 +0200, Anders.Franzen@ericsson.co=
m a
=C3=A9crit :
> From: Anders Franzen <anders.franzen@ericsson.com>
>=20
> The ip6_tunnel device did not unset the flag,
> IFF_XMIT_DST_RELEASE. This will make the dev layer
> to release the dst before calling the tunnel.
> The tunnel will not update any mtu/pmtu info, since
> it does not have a dst on the skb.
> ---
>  net/ipv6/ip6_tunnel.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> index c2c0f89..38b9a56 100644
> --- a/net/ipv6/ip6_tunnel.c
> +++ b/net/ipv6/ip6_tunnel.c
> @@ -1371,6 +1371,7 @@ static void ip6_tnl_dev_setup(struct net_device=
 *dev)
>  	dev->flags |=3D IFF_NOARP;
>  	dev->addr_len =3D sizeof(struct in6_addr);
>  	dev->features |=3D NETIF_F_NETNS_LOCAL;
> +	dev->priv_flags &=3D ~IFF_XMIT_DST_RELEASE;
>  }
> =20
>=20

Thanks for catching this Anders

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>




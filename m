From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipip: Fix bug added to ipip_tunnel_xmit().
Date: Wed, 25 Jan 2012 00:21:35 +0100
Message-ID: <1327447295.14373.3.camel@edumazet-laptop>
References: <20120124.181838.1470195215432711102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55774 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753002Ab2AXXVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 18:21:39 -0500
Received: by wgbed3 with SMTP id ed3so4593491wgb.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2012 15:21:38 -0800 (PST)
In-Reply-To: <20120124.181838.1470195215432711102.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 24 janvier 2012 =C3=A0 18:18 -0500, David Miller a =C3=A9crit =
:
> We can remove the rt_gateway =3D=3D 0 check but we shouldn't
> remove the 'dst' initialization too.
>=20
> Noticed by Eric Dumazet.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/ipv4/ipip.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
> index 87c63b6..f84ebff 100644
> --- a/net/ipv4/ipip.c
> +++ b/net/ipv4/ipip.c
> @@ -454,6 +454,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buf=
f *skb, struct net_device *dev)
>  			dev->stats.tx_fifo_errors++;
>  			goto tx_error;
>  		}
> +		dst =3D rt->rt_gateway;
>  	}
> =20
>  	rt =3D ip_route_output_ports(dev_net(dev), &fl4, NULL,


Well, a similar fix is needed for net/ipv4/ip_gre.c :)

(Its a bit late here, time for a sleep for me)

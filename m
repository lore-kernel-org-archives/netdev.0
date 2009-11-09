From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] IPv6: use ipv6_addr_v4mapped()
Date: Mon, 09 Nov 2009 23:59:53 +0100
Message-ID: <4AF89EE9.1090109@gmail.com>
References: <4AF89241.7060203@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34048 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755080AbZKIW7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 17:59:52 -0500
In-Reply-To: <4AF89241.7060203@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley a =E9crit :
> Change udp6_portaddr_hash() to use ipv6_addr_v4mapped()
> inline instead of ipv6_addr_type().
>=20
> Signed-off-by: Brian Haley <brian.haley@hp.com>
> ---
>=20
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 2915e1d..0ed1637 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -89,7 +89,7 @@ static unsigned int udp6_portaddr_hash(struct net *=
net,
> =20
>  	if (ipv6_addr_any(addr6))
>  		hash =3D jhash_1word(0, mix);
> -	else if (ipv6_addr_type(addr6) =3D=3D IPV6_ADDR_MAPPED)
> +	else if (ipv6_addr_v4mapped(addr6))
>  		hash =3D jhash_1word(addr6->s6_addr32[3], mix);
>  	else
>  		hash =3D jhash2(addr6->s6_addr32, 4, mix);

Indeed, its a bit faster ;)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks Brian


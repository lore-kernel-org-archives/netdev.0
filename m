From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RESEND PATCH net-next-2.6 3/3] ipv6 sit: Set relay to 0.0.0.0
 directly if relay_prefixlen == 0.
Date: Mon, 12 Oct 2009 09:32:41 +0200
Message-ID: <4AD2DB99.3070208@gmail.com>
References: <4AD1E169.6090705@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46538 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753696AbZJLHdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 03:33:24 -0400
In-Reply-To: <4AD1E169.6090705@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki a =C3=A9crit :
> ipv6 sit: Set relay to 0.0.0.0 directly if relay_prefixlen =3D=3D 0.
>=20
> Do not use bit-shift if relay_prefixlen =3D=3D 0;
> relay_prefix << 32 does not result in 0.
>=20
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  net/ipv6/sit.c |    9 ++++++---
>  1 files changed, 6 insertions(+), 3 deletions(-)
>=20
> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
> index 193d0c6..510d31f 100644
> --- a/net/ipv6/sit.c
> +++ b/net/ipv6/sit.c
> @@ -1014,9 +1014,12 @@ ipip6_tunnel_ioctl (struct net_device *dev, st=
ruct ifreq *ifr, int cmd)
>  					 ip6rd.prefixlen);
>  			if (!ipv6_addr_equal(&prefix, &ip6rd.prefix))
>  				goto done;
> -			relay_prefix =3D ip6rd.relay_prefix &
> -				       htonl(0xffffffffUL <<
> -					     (32 - ip6rd.relay_prefixlen));
> +			if (ip6rd.relay_prefixlen)
> +				relay_prefix =3D ip6rd.relay_prefix &
> +					       htonl(0xffffffffUL <<
> +						     (32 - ip6rd.relay_prefixlen));
> +			else
> +				relay_prefix =3D 0;
>  			if (relay_prefix !=3D ip6rd.relay_prefix)
>  				goto done;
> =20


Sorry I dont get it

u32 val =3D any_value ;
u32 relay_prefix =3D val & htonl(0xffffffffUL << 32) should give 0

If not, something is broken and should be fixed.


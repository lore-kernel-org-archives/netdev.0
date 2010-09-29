From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip_gre: CONFIG_IPV6_MODULE support
Date: Wed, 29 Sep 2010 08:47:28 +0200
Message-ID: <1285742848.22570.53.camel@edumazet-laptop>
References: <1285734295.22570.25.camel@edumazet-laptop>
	 <20100929043642.GA3660@gondor.apana.org.au>
	 <20100928.214132.226782961.davem@davemloft.net>
	 <20100928.223850.104051485.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37522 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231Ab0I2Grd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 02:47:33 -0400
Received: by fxm14 with SMTP id 14so268800fxm.19
        for <netdev@vger.kernel.org>; Tue, 28 Sep 2010 23:47:32 -0700 (PDT)
In-Reply-To: <20100928.223850.104051485.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 28 septembre 2010 =C3=A0 22:38 -0700, David Miller a =C3=A9cri=
t :
> From: David Miller <davem@davemloft.net>
> Date: Tue, 28 Sep 2010 21:41:32 -0700 (PDT)
>=20
> > Eric, please cook up a patch which does this, I think the
> > magic Kconfig dependency formula for this is:
> >=20
> > 	depends on IPV6 || IPV6=3Dn
> >=20
> > Thanks!
>=20
> Nevermind, I took care of it :-)
>=20
> --------------------
> ip_gre: Fix dependencies wrt. ipv6.
>=20
> The GRE tunnel driver needs to invoke icmpv6 helpers in the
> ipv6 stack when ipv6 support is enabled.
>=20
> Therefore if IPV6 is enabled, we have to enforce that GRE's
> enabling (modular or static) matches that of ipv6.
>=20
> Reported-by: Patrick McHardy <kaber@trash.net>
> Reported-by: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/ipv4/Kconfig |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> index 571f895..72380a3 100644
> --- a/net/ipv4/Kconfig
> +++ b/net/ipv4/Kconfig
> @@ -217,6 +217,7 @@ config NET_IPIP
> =20
>  config NET_IPGRE
>  	tristate "IP: GRE tunnels over IP"
> +	depends on IPV6 || IPV6=3Dn
>  	help
>  	  Tunneling means encapsulating data of one protocol type within
>  	  another protocol and sending it over a channel that understands t=
he


Still, this does not solve the problem for people wanting to disable
ipv6 module load or disable it ?

install ipv6 /bin/true

or

options ipv6 disable=3D1

I tried both ways with my patch and could load ip_gre module. But in
both ways, register_icmpv6_send() was not called so ip_gre could not tr=
y
to use icmpv6_send()






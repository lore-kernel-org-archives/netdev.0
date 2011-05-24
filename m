From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] ipv6: xfrm6: fix dubious code
Date: Tue, 24 May 2011 07:02:42 +0200
Message-ID: <20110524050242.GD8013@secunet.com>
References: <1306140167.2869.8.camel@edumazet-laptop>
 <1306164960.3456.42.camel@localhost>
 <20110523.163302.1123967560115611293.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53874 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751935Ab1EXFAQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2011 01:00:16 -0400
Content-Disposition: inline
In-Reply-To: <20110523.163302.1123967560115611293.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 23, 2011 at 04:33:02PM -0400, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Mon, 23 May 2011 08:36:00 -0700
>=20
> > On Mon, 2011-05-23 at 10:42 +0200, Eric Dumazet wrote:
> >> net/ipv6/xfrm6_tunnel.c: In function =E2=80=98xfrm6_tunnel_rcv=E2=80=
=99:
> >> net/ipv6/xfrm6_tunnel.c:244:53: warning: the omitted middle operan=
d
> >> in ?: will always be =E2=80=98true=E2=80=99, suggest explicit midd=
le operand
> >>=20
> >> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> >> ---
> >>  net/ipv6/xfrm6_tunnel.c |    2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>=20
> >> diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
> >> index a6770a0..fb9b0c3 100644
> >> --- a/net/ipv6/xfrm6_tunnel.c
> >> +++ b/net/ipv6/xfrm6_tunnel.c
> >> @@ -241,7 +241,7 @@ static int xfrm6_tunnel_rcv(struct sk_buff *sk=
b)
> >>  	__be32 spi;
> >> =20
> >>  	spi =3D xfrm6_tunnel_spi_lookup(net, (const xfrm_address_t *)&ip=
h->saddr);
> >> -	return xfrm6_rcv_spi(skb, IPPROTO_IPV6, spi) > 0 ? : 0;
> >> +	return xfrm6_rcv_spi(skb, IPPROTO_IPV6, spi) > 0 ? 1 : 0;
> >>  }
> >> =20
> >>  static int xfrm6_tunnel_err(struct sk_buff *skb, struct inet6_skb=
_parm *opt,
> >=20
> > I suspect that this was intended to return the result of xfrm6_rcv_=
spi()
> > if > 0.
>=20
> I also suspect this was the intent, but I'm not sure why it matters
> at all.
>=20
> The equivalent code implementing the same operations on the ipv4
> side return xfrm4_rcv_spi()'s return value directly.
>=20
> So we need to either decide that we can do the same thing here on the
> ipv6 side, or document exactly why we can't.

I think we can return the value directly like ipv4 does it. xfrm6_rcv_s=
pi()
returns the return value of xfrm_input() which returns 0 in any case.

From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH]  ipv6: xfrm6: fix dubious code
Date: Mon, 23 May 2011 08:36:00 -0700
Message-ID: <1306164960.3456.42.camel@localhost>
References: <1306140167.2869.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:1128 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754725Ab1EWPgD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 11:36:03 -0400
In-Reply-To: <1306140167.2869.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-05-23 at 10:42 +0200, Eric Dumazet wrote:
> net/ipv6/xfrm6_tunnel.c: In function =E2=80=98xfrm6_tunnel_rcv=E2=80=99=
:
> net/ipv6/xfrm6_tunnel.c:244:53: warning: the omitted middle operand
> in ?: will always be =E2=80=98true=E2=80=99, suggest explicit middle =
operand
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/ipv6/xfrm6_tunnel.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
> index a6770a0..fb9b0c3 100644
> --- a/net/ipv6/xfrm6_tunnel.c
> +++ b/net/ipv6/xfrm6_tunnel.c
> @@ -241,7 +241,7 @@ static int xfrm6_tunnel_rcv(struct sk_buff *skb)
>  	__be32 spi;
> =20
>  	spi =3D xfrm6_tunnel_spi_lookup(net, (const xfrm_address_t *)&iph->=
saddr);
> -	return xfrm6_rcv_spi(skb, IPPROTO_IPV6, spi) > 0 ? : 0;
> +	return xfrm6_rcv_spi(skb, IPPROTO_IPV6, spi) > 0 ? 1 : 0;
>  }
> =20
>  static int xfrm6_tunnel_err(struct sk_buff *skb, struct inet6_skb_pa=
rm *opt,

I suspect that this was intended to return the result of xfrm6_rcv_spi(=
)
if > 0.  But if it really is intended to return the result of the
inequality, then the '?:' operation is not needed at all.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


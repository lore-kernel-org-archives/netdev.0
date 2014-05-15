From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [PATCH] ipv4: ip_tunnels: disable dst cache for nbma gre
 tunnels
Date: Thu, 15 May 2014 20:35:35 +0300
Message-ID: <20140515203535.33ad90fd@vostro>
References: <20140424151647.2a917ff1@vostro>
	<1400142917-1849-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Timo =?UTF-8?B?VGVyw6Rz?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:49297 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753106AbaEORfX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 13:35:23 -0400
Received: by mail-la0-f54.google.com with SMTP id pv20so1081420lab.27
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 10:35:22 -0700 (PDT)
In-Reply-To: <1400142917-1849-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 May 2014 11:35:17 +0300
Timo Ter=C3=A4s <timo.teras@iki.fi> wrote:

> The connected check fails to check for ip_gre nbma mode tunnels
> properly. ip_gre creates temporary tnl_params with daddr specified
> to pass-in the actual target on per-packet basis from neighbor
> layer. Detect these tunnels by inspecting the actual tunnel
> configuration instead.
>=20
> Fixes: 7d442fab0a67 ("ipv4: Cache dst in tunnels")
> Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> ---
> Should go to 3.14-stable too.
>=20
> (This does not fix all NBMA GRE regressions in 3.14.
>  I'm also getting weird oopses from GRO; will post soon more info.)
>=20
>  net/ipv4/ip_tunnel.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index e77381d..100caf5 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -538,9 +538,10 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct
> net_device *dev, unsigned int max_headroom;	/* The extra
> header space needed */ __be32 dst;
>  	int err;
> -	bool connected =3D true;
> +	bool connected;
> =20
>  	inner_iph =3D (const struct iphdr *)skb_inner_network_header(skb);
> +	connected =3D (tunnel->daddr !=3D 0);
> =20
>  	dst =3D tnl_params->daddr;
>  	if (dst =3D=3D 0) {

I meant tunnel->parms.iph.daddr here.  tunnel->daddr does not even
exist. I wonder which tree I was testing. I'll retry tests and send new
patch.

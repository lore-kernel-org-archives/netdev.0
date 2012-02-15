From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] l2tp/ipv6: support for L2TPv2 over UDP over IPv6
Date: Wed, 15 Feb 2012 06:06:50 +0100
Message-ID: <1329282410.2555.31.camel@edumazet-laptop>
References: <20120214223112.GB6806@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:51472 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041Ab2BOFGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 00:06:54 -0500
Received: by werb13 with SMTP id b13so371671wer.19
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 21:06:53 -0800 (PST)
In-Reply-To: <20120214223112.GB6806@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 14 f=C3=A9vrier 2012 =C3=A0 17:31 -0500, Benjamin LaHaise a =C3=
=A9crit :
> Hello folks,
>=20
> Below is a patch that adds support for L2TPv2 over UDP over IPv6.  It=
's an=20
> RFC at present due to 2 outstanding issues: the first is that struct=20
> pppol2tp_addr and pppol2tpv3_addr have an embedded struct sockaddr_in=
, and=20
> these changes have not implemented a replacement of those socket addr=
esses. =20
> Since the existing pppol2tp{,v3}_addr structures did not place the so=
ckaddr_in=20
> at the end of the structure, IPv6 addresses cannot be embedded withou=
t=20
> changing the ABI.  The question becomes one of how: just add a versio=
n of the=20
> pppol2tp_addr structure with a sockaddr_in6 embedded in it (easily do=
ne, as=20
> the different in address structures can be detected via sin_family in=
 the=20
> embedded address), or replace it wholesale with a new pppol2tp_addr t=
hat has=20
> the embedded address at the end of the structure?  That is:
>=20
> 	struct pppol2tp_addr_in6 {
> 		int			pid;
> 		int			fd;
> 		struct sockaddr_in6	addr;
> 		u16			s_tunnel, s_session;
> 		u16			d_tunnel, d_session;
> 	};
>=20
> or
>=20
> 	struct new_pppol2tp_addr {
> 		int			pid;
> 		int			fd;
> 		u32			s_tunnel, s_session;
> 		u32			d_tunnel, d_session;
> 		struct sockaddr_in6	addr;
> 	};
>=20
My personal choice would be the latter .



> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> +	if (sk->sk_family =3D=3D PF_INET6) {
> +		psum =3D csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
> +				       &ipv6_hdr(skb)->daddr, ulen,
> +				       IPPROTO_UDP, 0);
> +	} else
> +#endif
> +	{


Please use the modern :

#if IS_ENABLED(CONFIG_IPV6)

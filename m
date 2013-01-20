From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: add anti-spoofing checks for 6to4 and 6rd
Date: Sun, 20 Jan 2013 04:37:11 +0100
Message-ID: <20130120033711.GA19482@order.stressinduktion.org>
References: <20130118200416.GB4795@order.stressinduktion.org> <50F9F875.30302@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39189 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440Ab3ATDhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2013 22:37:13 -0500
Content-Disposition: inline
In-Reply-To: <50F9F875.30302@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 19, 2013 at 10:35:49AM +0900, YOSHIFUJI Hideaki wrote:
> (2013=E5=B9=B401=E6=9C=8819=E6=97=A5 05:04), Hannes Frederic Sowa wro=
te:
> > This patch adds anti-spoofing checks in sit.c as specified in RFC39=
64
> > section 5.2 for 6to4 and RFC5969 section 12 for 6rd. I left out the
> > checks which could easily be implemented with netfilter.
> >=20
> > Specifically this patch adds following logic (based loosely on the
> > pseudocode in RFC3964 section 5.2):
> >=20
> > if prefix (inner_src_v6) =3D=3D rd6_prefix (2002::/16 is the defaul=
t)
> >         and outer_src_v4 !=3D embedded_ipv4 (inner_src_v6)
> >                 drop
> > if prefix (inner_dst_v6) =3D=3D rd6_prefix (or 2002::/16 is the def=
ault)
> >         and outer_dst_v4 !=3D embedded_ipv4 (inner_dst_v6)
> >                 drop
> > accept
> >=20
> > To accomplish the specified security checks proposed by above RFCs,
> > it is still necessary to employ uRPF filters with netfilter. These =
new
> > checks only kick in if the employed addresses are within the 2002::=
/16 or
> > another range specified by the 6rd-prefix (which defaults to 2002::=
/16).
>=20
> It seems this breaks 6rd receiving rules:
>=20
> BR:
> 	if (outer src ip4 !=3D embedded src ip4)
> 		drop();
> CE:
> 	if (outer src ip4 !=3D embedded src ip4 ||
> 	    inner dest ip6 !=3D configured ip6 prefix)
> 		drop();
>=20
> No?

Could you give me a concrete example? I have tested this patch on BR
and CE with different 6rd prefixes (and lengths) and have not seen
any breakage. Perhaps I am missing something.

Thanks,

  Hannes

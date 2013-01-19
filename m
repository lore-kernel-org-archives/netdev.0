From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] ipv6: add anti-spoofing checks for 6to4 and 6rd
Date: Sat, 19 Jan 2013 10:35:49 +0900
Message-ID: <50F9F875.30302@linux-ipv6.org>
References: <20130118200416.GB4795@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org, davem@davemloft.net,
	hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:46430 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751745Ab3ASBfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 20:35:51 -0500
In-Reply-To: <20130118200416.GB4795@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2013=E5=B9=B401=E6=9C=8819=E6=97=A5 05:04), Hannes Frederic Sowa wrote=
:
> This patch adds anti-spoofing checks in sit.c as specified in RFC3964
> section 5.2 for 6to4 and RFC5969 section 12 for 6rd. I left out the
> checks which could easily be implemented with netfilter.
>=20
> Specifically this patch adds following logic (based loosely on the
> pseudocode in RFC3964 section 5.2):
>=20
> if prefix (inner_src_v6) =3D=3D rd6_prefix (2002::/16 is the default)
>         and outer_src_v4 !=3D embedded_ipv4 (inner_src_v6)
>                 drop
> if prefix (inner_dst_v6) =3D=3D rd6_prefix (or 2002::/16 is the defau=
lt)
>         and outer_dst_v4 !=3D embedded_ipv4 (inner_dst_v6)
>                 drop
> accept
>=20
> To accomplish the specified security checks proposed by above RFCs,
> it is still necessary to employ uRPF filters with netfilter. These ne=
w
> checks only kick in if the employed addresses are within the 2002::/1=
6 or
> another range specified by the 6rd-prefix (which defaults to 2002::/1=
6).

It seems this breaks 6rd receiving rules:

BR:
	if (outer src ip4 !=3D embedded src ip4)
		drop();
CE:
	if (outer src ip4 !=3D embedded src ip4 ||
	    inner dest ip6 !=3D configured ip6 prefix)
		drop();

No?

--yoshfuji

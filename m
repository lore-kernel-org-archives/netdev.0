From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipsec tunnel with different inner and outer ip families
Date: Wed, 18 Jan 2012 17:30:49 +1100
Message-ID: <20120118063049.GA23795@gondor.apana.org.au>
References: <B97B134FACB2024DB45F524AB0A7B7F2058AF99D@XMB-BGL-419.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Prashant Batra prbatra <prbatra@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:56842 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754303Ab2ARGax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 01:30:53 -0500
Content-Disposition: inline
In-Reply-To: <B97B134FACB2024DB45F524AB0A7B7F2058AF99D@XMB-BGL-419.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prashant Batra prbatra <prbatra@cisco.com> wrote:
> Hello,
>=20
> Does linux 2.6.* support an IPSec tunnel with different family of inn=
er and outer addresses , like v4 in v6 or v6 in v4.
> After trying ip xfrm * from user space, the utility doesn't seem to a=
ccept two different families in a single command.
>=20
> #ip xfrm policy add dir out src 172.168.68.1/32 dst 172.168.68.2/32 t=
mpl src 2001:db8:0:242::36/128 dst 2001:db8:0:242::37/128 proto esp=A0 =
mode tunnel
> Error: an inet prefix is expected rather than "2001:db8:0:242::36/128=
".
>=20
> So, I tried sending a NETLINK SPD add message) from user space with, =
selector as v4 addresses and tmpl as v6 address.
> Policy got added but kernel doesn't seem to be interpreting the addre=
sses correctly.
>=20
> src 172.16.80.1/32 dst 0.0.0.0/0
> =A0=A0=A0=A0=A0=A0=A0 dir out priority 1024
> =A0=A0=A0=A0=A0=A0=A0 tmpl=A0=A0=A0 src 32.1.13.184 dst 32.1.13.184=A0=
=A0 /* I gave ipv6 addresses here*/
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 proto esp spi 0x0000000=
0 reqid 0 mode tunnel
>=20
> Can someone help me with this?

The kernel is certainly supposed to support inter-family SAs
and policies.  However, I wouldn't be surprised if it's buggy
as very few people use it.

Cheers,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

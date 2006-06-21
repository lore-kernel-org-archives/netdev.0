From: Lukasz Stelmach <stlman@poczta.fm>
Subject: Re: ipv6 source address selection in addrconf.c (2.6.17)
Date: Thu, 22 Jun 2006 00:57:56 +0200
Message-ID: <4499CEF4.2050308@poczta.fm>
References: <44986AE6.6090102@poczta.fm> <44994CB3.6070302@poczta.fm>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig4F837EFEF1695AAF358B681C"
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.poczta.interia.pl ([80.48.65.8]:25108 "EHLO
	smtp.poczta.interia.pl") by vger.kernel.org with ESMTP
	id S1751509AbWFUW56 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 18:57:58 -0400
Received: from poczta.interia.pl (mi01.poczta.interia.pl [10.217.12.1])
	by smtp.poczta.interia.pl (INTERIA.PL) with ESMTP id F1C3027145E
	for <netdev@vger.kernel.org>; Thu, 22 Jun 2006 00:57:56 +0200 (CEST)
Received: from [10.0.0.2] (coh145.neoplus.adsl.tpnet.pl [83.31.187.145])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by www.poczta.fm (INTERIA.PL) with ESMTP id 54C0326F866
	for <netdev@vger.kernel.org>; Thu, 22 Jun 2006 00:57:55 +0200 (CEST)
To: netdev@vger.kernel.org
In-Reply-To: <44994CB3.6070302@poczta.fm>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig4F837EFEF1695AAF358B681C
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Lukasz Stelmach wrote:
> Lukasz Stelmach wrote:
>=20
>> [...] when trying to connect to
>>
>> 2001:200:0:8002:203:47ff:fea5:3085 (www.kame.net)
>>
>> with two global addresses assigned to the ethernet card
>>
>> fd24:6f44:46bd:face::254
>> 2002:531f:d667:face::254
>>
>> rule 8 does not work and the first address is chosen.
>=20
> The answer is that fc00::/7 matches 2001:: better because it gets the s=
ame
> label (ipv6_saddr_label()). Although fc00::/7 addresses are defined as =
global
> unicast IMHO they should be treated *slightly* different. This is the p=
atch.
> Since 6to4 has its own label I have decided to assign one to Teredo too=
=2E

There still, however, remains one issue. Aditional labels prevent kernel =
from
selecting fc00::/7 prematurly. But there is no way to stop it from select=
ing
it in rule 7. A wrong assumption has been taken that there is only one
"private" address per interface and it is always the best choice. If ther=
e are
four addresses on the interface:

fd24:6f44:46bd:face:EUI64 fd24:6f44:46bd:face:RANDOM
and
2002:531f:d667:face:EUI64 2002:531f:d667:face::RANDOM

there seem to be no way to prefere 2002:: over fc00:: in rule 7 and it wi=
ll be
selected as long as it is before 2002:: on the list. I can see here that =
an
implicit assumption has been made that an interface either is multihomed =
or
"private". The seventh rule should not IMHO break the whole process of
selection but rather mark as selectable all "private" (random) addresses.=
 And
it should rather be done before rule 6.

Yet another issue with privacy enhancement is how not to choose "private"=

address (let's even forget for a moment about fc00::/7) when connecting t=
o
certain hosts or networks. For example I would like to hide MAC adresses =
of my
client machines when connecting to some foreign servers but I want to see=

permanent addresses in the logfiles of my servers. Maybe even use them to=

create som ACLs. This is an interesting case.


Kind regards,
--=20
By=C5=82o mi bardzo mi=C5=82o.                    Czwarta pospolita kl=C4=
=99ska, [...]
>=C5=81ukasz<                      Ju=C5=BC nie katolicka lecz z=C5=82odz=
iejska.  (c)PP


--------------enig4F837EFEF1695AAF358B681C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFEmc75NdzY8sm9K9wRAr3+AKCbSSr2VMmh49y7S7wB6DcQZevsawCdEQ/z
elXgiIoRjqJYgHi1oykGrA0=
=1PoY
-----END PGP SIGNATURE-----

--------------enig4F837EFEF1695AAF358B681C--

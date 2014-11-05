From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH] net: mv643xx_eth: reclaim TX skbs only when released
 by the HW
Date: Wed, 05 Nov 2014 11:46:16 -0300
Message-ID: <545A3838.3090606@free-electrons.com>
References: <1415197979-1702-1-git-send-email-karl.beldan@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="G22cq1UIeA00SHG4nxN9LdmFKfuT0k5TE"
Cc: Karl Beldan <karl.beldan@rivierawaves.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Karl Beldan <karl.beldan@gmail.com>,
	David Miller <davem@davemloft.net>,
	Ian Campbell <ijc@hellion.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:42114 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754112AbaKEOsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 09:48:07 -0500
In-Reply-To: <1415197979-1702-1-git-send-email-karl.beldan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--G22cq1UIeA00SHG4nxN9LdmFKfuT0k5TE
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Karl,

On 11/05/2014 11:32 AM, Karl Beldan wrote:> From: Karl Beldan <karl.belda=
n@rivierawaves.com>
>=20
> ATM, txq_reclaim will dequeue and free an skb for each tx desc released=

> by the hw that has TX_LAST_DESC set. However, in case of TSO, each
> hw desc embedding the last part of a segment has TX_LAST_DESC set,
> losing the one-to-one 'last skb frag'/'TX_LAST_DESC set' correspondance=
,
> which causes data corruption.
>=20
> Fix this by checking TX_ENABLE_INTERRUPT instead of TX_LAST_DESC, and
> warn when trying to dequeue from an empty txq (which can be symptomatic=

> of releasing skbs prematurely).
>=20
> Fixes: 3ae8f4e0b98 ('net: mv643xx_eth: Implement software TSO')

Although your change makes sense, this isn't fixing the issue for me,
neither did the previous one.

Ian: Can you double check that you have corruption *without* the patch,
and that the patch fixes the issue?

--=20
Ezequiel Garc=C3=ADa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com


--G22cq1UIeA00SHG4nxN9LdmFKfuT0k5TE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUWjhGAAoJEIOKbhOEIHKizRQP/jDJ3P6dSI4xYyYpyStHRgTa
0utiDvmHSzY0tOMR67TnHitc6qAwE7UuSX6Mh3q84ArGeWRqWUPc5tXORKheXtCI
quRWOA8/1RRvDbD/zNuhwFelvLTfWrlhagDCQ36ylzPo6Z3PuVvl3+4CMxdPG7Mp
Y8X8lEWyiFDLvkEx3twYupO4bmp2bkoZyonZy49H13Ibfnb+1hjhPdVIQF3L2XfJ
tU43b6RVlNr16bRPJI5Y7RoH8A2JGHrUDXFcPmZmqX1IR9eHzBEBi8abZMDFfaxl
/FpJdB+R6GwXhKkekJiXSd/g6k7ZhUJ9NyCG1eCZhVj10MJtlKA0U/n2YUMLHzN5
5KuqID8+ICcxOx/jT+36KqlRbBWwElx7T1jOVDz7pd030Ec0zn7N21AB5KDZWFtg
OCjJ/4YNgZiTgwB7otfs7vX737NDva12lOaATNNdUw7QNcgnK2mcY0uuJ0gY+qTK
rBM9xJptVobzV1N6OjP7ycxmqlL/5TuXIfU9bhz3RFQnCCvHKMlPneHWSt7hTZzh
zHg0hKoyZL9roJ74T7B9eO16s5yFSSn/mlrI6WIfBbLYmOxLys/KNfklKOgCGB5J
Vt6YFJIPspsI1PvsP8o9l20W+b7enUmJ6QRI+mSuo1m8hPQAd5i6Dpk2z72xCHHN
XIG5USR0LLqRynH/r7yC
=pHTZ
-----END PGP SIGNATURE-----

--G22cq1UIeA00SHG4nxN9LdmFKfuT0k5TE--

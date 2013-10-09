From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH 10/16] batman-adv: use CRC32C instead of CRC16 in TT code
Date: Wed, 9 Oct 2013 18:10:28 +0200
Message-ID: <20131009161028.GI3544@neomailbox.net>
References: <1381322418-1349-1-git-send-email-antonio@meshcoding.com>
 <1381322418-1349-11-git-send-email-antonio@meshcoding.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7384@saturn3.aculab.com>
 <20131009143500.GH3544@neomailbox.net>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7385@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="Qf1oXS95uex85X0R"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:41682 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751921Ab3JIQLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 12:11:04 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7385@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Qf1oXS95uex85X0R
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 09, 2013 at 04:49:53PM +0100, David Laight wrote:
> > > Are you really generating CRC32 of a pile of ethernet MAC addresses
> > > and the XORing the CRC together?
> > > That gives the same answer as XORing together the MAC addresses and
> > > then doing a CRC of the final value.
> >=20
> > I was not sure about this since the CRC32 is not a linear operation. Ho=
wever
> > this routine is not on the fast path, so we can also live with this ord=
er.
>=20
> All CRC are linear.
> Because '(a + b) mod c' is the same as '((a mod c) + (b mod c)) mod c'.
>=20
> The CRC of a buffer is the XOR of the CRCs generated for each '1' bit.
> The CRC for each bit depends on how far it is from the end of the buffer.

In our tables we cannot make any assumption about the order of the entries:=
 the
node whom generated the table may store the entries in a different order fr=
om
what we have got.
This is why I did not implemented it as a simple CRC of the
whole the GlobalTable/buffer but I CRC'd each MAC+VID on its own.


> Presetting the CRC to all-ones generates a value that is dependent on
> the length of the buffer - otherwise missing/extra leading zeros are
> not detected.


Assuming what I said above (that we cannot make assumptions on the order of=
 the
entries), what is your suggestion?


Regards,

--=20
Antonio Quartulli

--Qf1oXS95uex85X0R
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSVX/zAAoJEADl0hg6qKeOoMYP/0y28d9Nj+F/IQm/eSwWtZ7s
SS46Q8FxHzeGtaqW/eYQP2GKOL4/CSs4pTcyugusmZov/U4oaa74qkVO4O+qzVMz
VP+6eHL14P5HS+sK2/k65mc3hujMn9p7wXWPxXvwKm8CFrLAYlClq5LJoUStXhAn
ZAcIkSEvK6hqvmRj/8hCA4U+dnaDV2fLJlS79bKlk+93Wun+1TiVit2m0q+33Vx5
e8kgEBA1H3QYEdYnCZbVO7MmZ/eBYM2Fy5yifW7b6vtCzLEFS0sb556+d6ztGKDr
1wOXKrrVUcAHeG8y8CYv423eMNq+aQ+tdJJ7kXLqXkL3+xO7AHMcec0DkyUybVE7
9cFZvRDJGF3LJkBH1tmN/yjIlKSqZlUpY/eSJ/1Tf3185SPcEBzOB7Kps2NXGht1
DBz1ySPMV/TkZhGL2omtuC/lC8y53kPLqLspuaY18aUWZfSdDaSyNk0DzDqvHuWs
/yIGSdikEnXhbzAnBHAnpte9Zopr/FJX/DHk7u/c60GjAMSD+UzIaxpsynWpESdp
CHuU/Tno8j3twSIBjrikVulGLraXSNqB1WR7hml9vwht2Xpw2RBJE/HKrUfyMJCG
cbDuLAUgJwjL9wfNLjvUsPCVp4cfxMWmJqnlCXRo4ioSNT1jrqvbTBGu/dHx0D6F
LUImhcJzbWDzOSEh/UuM
=78ve
-----END PGP SIGNATURE-----

--Qf1oXS95uex85X0R--

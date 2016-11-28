From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net PATCH 0/2] Don't use lco_csum to compute IPv4 checksum
Date: Mon, 28 Nov 2016 14:26:02 -0800
Message-ID: <1480371962.2402.36.camel@intel.com>
References: <20161128153927.15466.99193.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-XTOq6R28/WTO9WngQ8bU"
Cc: Alexander Duyck <alexander.h.duyck@intel.com>, davem@davemloft.net
To: sfr@canb.auug.org.au, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:58294 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755156AbcK1W0K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 17:26:10 -0500
In-Reply-To: <20161128153927.15466.99193.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-XTOq6R28/WTO9WngQ8bU
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-11-28 at 10:42 -0500, Alexander Duyck wrote:
> When I implemented the GSO partial support in the Intel drivers I was
> using
> lco_csum to compute the checksum that we needed to plug into the IPv4
> checksum field in order to cancel out the data that was not a part of the
> IPv4 header.=C2=A0 However this didn't take into account that the transpo=
rt
> offset might be pointing to the inner transport header.
>=20
> Instead of using lco_csum I have just coded around it so that we can use
> the outer IP header plus the IP header length to determine where we need
> to
> start our checksum and then just call csum_partial ourselves.
>=20
> This should fix the SIT issue reported on igb interfaces as well as
> simliar
> issues that would pop up on other Intel NICs.
>=20
> ---
>=20
> Alexander Duyck (2):
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 igb/igbvf: Don't use lco_csum to compute I=
Pv4 checksum
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ixgbe/ixgbevf: Don't use lco_csum to compu=
te IPv4 checksum

Stephen, I have applied Alex's patches to my net-queue tree. =C2=A0Can you
confirm they resolve the bug seen?
--=-XTOq6R28/WTO9WngQ8bU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJYPK76AAoJEOVv75VaS+3OQpQP/1Y4Sz1XRrrVgGSOGVktznII
HLO61br6UeYcvVOYnpyGwk/5z97ndjUa6dLdfW0iPfc7Cw9UilMe/34G5X9Htu2J
XkG3JJy3Xe1iVhLe/IcHiYkGLy771pZO/OIQLUSKbt+jpSuu2Z7XxPfIy+yVE/Ij
/fH+EiuoAaToCB0DBCf8dwt32JrdYxxXJvOmD4gaYtJAdcyOanZmTqtke9i7pjLE
fgvq8CpijQjALAgO6uFGk+uuyt1ZDN7vXpzJIJ9rIrI1TmsflKHEO9ULJJEKT0mZ
QDfbaPBdUAoAa4ECweoVQ6B9rCOcEEitvWWxpx5KLzh0+vMRYYK2zRhtbtLp53uz
E70mr8eRAxdZi5C5u4V3659m8E6g3WXhbZJAEHIpUEWFNJHgzBtC/XP+Kpy9YXQV
7tJzPQTLy562+UnQcJdc34W8ulIhbgX+lfHlPIj9NrZXrBl3WJn824adyDiSPz5K
GPkJbWU64/2hehyEIvni7HwB0HVqk+iXCGpkW1mrCFXx3Ir70tP+w50dqBijg9O+
e6HlRrM5ifihduM6K8pAqYDLGfmxC7qmp+FeNMtaMuykHWtBE9kTjHRxVokSYEJt
3sZoWOEd8KI2bEOcexjlIeIhScoiGScYdM2Bs8Wh5WNQFz3844dO73GW1+R2V6XA
0SFH98S3BmjbAWagScj3
=Qr03
-----END PGP SIGNATURE-----

--=-XTOq6R28/WTO9WngQ8bU--

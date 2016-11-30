From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net PATCH 0/2] Don't use lco_csum to compute IPv4 checksum
Date: Wed, 30 Nov 2016 13:15:22 -0800
Message-ID: <1480540522.2377.18.camel@intel.com>
References: <20161128153927.15466.99193.stgit@ahduyck-blue-test.jf.intel.com>
         <20161130.094746.724735454244491985.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-0TKh2kz0viFz9lRPEFOD"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        sfr@canb.auug.org.au
To: David Miller <davem@davemloft.net>, alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:61086 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755389AbcK3VPc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 16:15:32 -0500
In-Reply-To: <20161130.094746.724735454244491985.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-0TKh2kz0viFz9lRPEFOD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-11-30 at 09:47 -0500, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Mon, 28 Nov 2016 10:42:18 -0500
>=20
> > When I implemented the GSO partial support in the Intel drivers I was
> using
> > lco_csum to compute the checksum that we needed to plug into the IPv4
> > checksum field in order to cancel out the data that was not a part of
> the
> > IPv4 header.=C2=A0 However this didn't take into account that the trans=
port
> > offset might be pointing to the inner transport header.
> >=C2=A0
> > Instead of using lco_csum I have just coded around it so that we can
> use
> > the outer IP header plus the IP header length to determine where we
> need to
> > start our checksum and then just call csum_partial ourselves.
> >=C2=A0
> > This should fix the SIT issue reported on igb interfaces as well as
> simliar
> > issues that would pop up on other Intel NICs.
>=20
> Jeff, are you going to send me a pull request with this stuff or would
> you be OK with my applying these directly to 'net'?

Go ahead and apply those to your net tree, I do not want to hold this up.
--=-0TKh2kz0viFz9lRPEFOD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJYP0FqAAoJEOVv75VaS+3O05kQAKN76t01FAXL/3UpOMmO4F/A
qcv93jHHPiVcQ1zLWpVfi8jN3Nbe3alSYtkD+JjTEyxtIwyY/hcjQeynEkZUuuSG
7GYXigzYh0eCVEYGZi+s+mNQLSyOv6U3TzbDDU3pAlYXQacFjrc1BgTUDMPkPmdd
MUc3JARTzgOYYXOKhV8TtfXMwk/XvIcq00bEJNOOKodA04zBA/5fWlwWRuSOhBNL
jMd4L2Mq++Gp+8sBPjoQdtzU0VpgumbbeljX5es04yQUVY5V+AN8//Aa3otPyTr4
LGUSJhmIqimejDMMHxX0V/s+AEebVjmEEF6S5uuC39s2FmK7qVqILuvQ5uP40+UM
kSmm/tNXdnzxhnllujDggvrGs7lLrTMKmgwFYaJazlU6yEanEji6Or+aR5fVcNQb
55mj4DtjbiMGT1ipQkRawei8GfncqCvfGNedW3HiM1uP8yaUxTFqmDKwM1Gt0XlL
OhJ/zgjMm2vx946n12Q/SmVtv5MPoRxdm4mI9o1rPCq/HJPNZtmTyhGtVlLdBu1r
4TkPCccAJvQJpRxNNoJAz+BZ5kKUAfQx3u+IMGZGYs9eAocgPjOBLrPg+xe42z1F
E8xHvS4HD0dfzgSJvmyBTuoL6z+wZVTgpFUrnPDTzIT2NtzeU1z//BCvb2wnDRly
GyvPlCyAipPRNYrRVaLf
=wjUQ
-----END PGP SIGNATURE-----

--=-0TKh2kz0viFz9lRPEFOD--

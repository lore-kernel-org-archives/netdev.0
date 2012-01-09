From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: Intel ixgbe: uninitialized variable use in
 ixgbe_non_sfp_link_config()
Date: Sun, 08 Jan 2012 21:07:28 -0800
Message-ID: <1326085648.2641.9.camel@jtkirshe-mobl>
References: <alpine.LNX.2.00.1201082215310.24030@swampdragon.chaosbits.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-9veVLnPKVsg9w+SqNptp"
Cc: e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Jesper Juhl <jj@chaosbits.net>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:43570 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750744Ab2AIFHa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jan 2012 00:07:30 -0500
In-Reply-To: <alpine.LNX.2.00.1201082215310.24030@swampdragon.chaosbits.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-9veVLnPKVsg9w+SqNptp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2012-01-08 at 22:21 +0100, Jesper Juhl wrote:
> Hi
>=20
> In ixgbe_non_sfp_link_config(), the variable 'negotiation' is declared
> without initializer and unless we take the true branch in the 'if
> ((!autoneg) && (hw->mac.ops.get_link_capabilities))' statement it will
> remain uninitialized when it is subsequently read in the 'ret =3D
> hw->mac.ops.setup_link(hw, autoneg, negotiation, link_up)' statement.
>=20
> The test of 'ret' after the 'if ((!autoneg) &&
> (hw->mac.ops.get_link_capabilities))' statement also looks fairly
> pointless if we do not take the true branch, since then 'ret' will not
> have been changed since the previous identical test.
>=20
> The correct fix escapes me since I don't really know this code (and don't=
=20
> plan to spend the time to get to know it), but I thought I'd just report=
=20
> what I had noticed and then someone else can hopefully come up with a goo=
d=20
> fix :-)
>=20
>=20
> PS. Please CC me on replies.
>=20

Adding netdev mailing list and Don Skidmore (ixgbe maintainer)
Removed Bruce Allan (e1000e maintainer)

I see the potential issue you are referring to, I will defer to Don to
either explain the reasoning in the logic or suggest a fix.

--=-9veVLnPKVsg9w+SqNptp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPCnYQAAoJEOVv75VaS+3OC1kQAI0f5SPOnzVwzibX+fLGyu6P
C6tJzRdW/cBm/KTtdKhqZif4KPKprBMZuqgp/IRqh4v5RL9y69MRqncxN0LrtqwU
0h2z8BKr0gk9lnTIyMN9i4RVOLzLTuYxDZutR0G/p4iRk0ER2I1dUSTaZhbcKT80
AnOxuZjp+wmc/+/R6nnqmqK+UJkXtZ5Uj9Zi7BU98HSvjVCe7jOktC25fgHUMvjo
dr1M8fkUHJxmfvNeEAM6B51xashiTCogV7IMA1sOxch/bFUCmU+TXdnUQ0MAx6yr
DIFwkaOApc0XDYC1ElitFeAXBk/3hSGy2kxsmnKHyq/Yy+ZQlP+tKqDyh2WgJm+Y
bXpNOuVH6OuYS3IrK40nvOsrE8wRMaVib/VWsUEfSevx2g2+7L4cHGgBzQbD169V
7Jks0mkjz9Xz51UHon+XflbSwHy304u/K45iv/jxa+/N3BglzsTpNzRnoHJ+vwJo
tKqbMiaRVMx+h4PsGpScX/X6V03ZYuD1Wl0auGUmKXsjMPtzT/uE8KcxxMOoZPOM
9woWLD/TLKAOoZtaVWx7GSObOqoh4jGUvpyuAHzh3dYpFR5JK/gJFjvMgWa5K15q
Hbdb6im1du2OlwfszgCD7ykfORHI/Lq0Kx+pDfEyyHkc4N4wUrvMe74gd/Ny6QiN
piJDh5VPYZ/M7OIT6uTZ
=PGNl
-----END PGP SIGNATURE-----

--=-9veVLnPKVsg9w+SqNptp--

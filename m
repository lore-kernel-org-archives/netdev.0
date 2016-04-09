From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [next-queue PATCH 2/3] ixgbe/ixgbevf: Add support for GSO
 partial
Date: Fri, 08 Apr 2016 23:53:01 -0700
Message-ID: <1460184781.2982.2.camel@intel.com>
References: <20160408210103.13096.77973.stgit@ahduyck-xeon-server>
	 <20160408210647.13096.55323.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-VS2YcFoUzB3V2WG5Bv5+"
To: Alexander Duyck <aduyck@mirantis.com>, herbert@gondor.apana.org.au,
	tom@herbertland.com, jesse@kernel.org, alexander.duyck@gmail.com,
	edumazet@google.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:63571 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751987AbcDIGxD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Apr 2016 02:53:03 -0400
In-Reply-To: <20160408210647.13096.55323.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-VS2YcFoUzB3V2WG5Bv5+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-04-08 at 17:06 -0400, Alexander Duyck wrote:
> This patch adds support for partial GSO segmentation in the case of
> tunnels.=C2=A0 Specifically with this change the driver an perform
> segmenation
> as long as the frame either has IPv6 inner headers, or we are allowed
> to
> mangle the IP IDs on the inner header.=C2=A0 This is needed because we
> will not
> be modifying any fields from the start of the start of the outer
> transport
> header to the start of the inner transport header as we are treating
> them
> like they are just a block of IP options.
>=20
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---
> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe_main.c=C2=A0=C2=A0=C2=A0=C2=
=A0 |=C2=A0 105
> +++++++++++++-----
> =C2=A0drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |=C2=A0 123
> ++++++++++++++++-----
> =C2=A02 files changed, 172 insertions(+), 56 deletions(-)

Dropping this patch (and now the series) because this does not
compile...

[23:51:49 @jtkirshe-linux:next-queue]$ make -j 77 -s
Makefile:679: Cannot use CONFIG_KCOV: -fsanitize-coverage=3Dtrace-pc is
not supported by compiler
=C2=A0 DESCEND=C2=A0=C2=A0objtool
drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c: In function
=E2=80=98ixgbevf_set_features=E2=80=99:
drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c:3892:17: error:
=E2=80=98NETIF_F_TSO_MANGLEID=E2=80=99 undeclared (first use in this functi=
on)
=C2=A0 if (features & NETIF_F_TSO_MANGLEID)
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0^
drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c:3892:17: note: each
undeclared identifier is reported only once for each function it
appears in
drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c: In function
=E2=80=98ixgbevf_probe=E2=80=99:
drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c:4062:8: error:
=E2=80=98struct net_device=E2=80=99 has no member named =E2=80=98gso_partia=
l_features=E2=80=99
=C2=A0 netdev->gso_partial_features =3D IXGBEVF_GSO_PARTIAL_FEATURES;
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^
drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c:4063:25: error:
=E2=80=98NETIF_F_GSO_PARTIAL=E2=80=99 undeclared (first use in this functio=
n)
=C2=A0 netdev->hw_features |=3D NETIF_F_GSO_PARTIAL |
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
^
drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c:4073:6: error:
=E2=80=98NETIF_F_TSO_MANGLEID=E2=80=99 undeclared (first use in this functi=
on)
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0NETIF_F_TSO_MANGLEID |
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^
scripts/Makefile.build:291: recipe for target
'drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.o' failed
make[5]: *** [drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.o] Error
1
scripts/Makefile.build:440: recipe for target
'drivers/net/ethernet/intel/ixgbevf' failed
make[4]: *** [drivers/net/ethernet/intel/ixgbevf] Error 2
make[4]: *** Waiting for unfinished jobs....
drivers/net/ethernet/intel/ixgbe/ixgbe_main.c: In function
=E2=80=98ixgbe_set_features=E2=80=99:
drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:8635:17: error:
=E2=80=98NETIF_F_TSO_MANGLEID=E2=80=99 undeclared (first use in this functi=
on)
=C2=A0 if (features & NETIF_F_TSO_MANGLEID)
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0^
drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:8635:17: note: each
undeclared identifier is reported only once for each function it
appears in
drivers/net/ethernet/intel/ixgbe/ixgbe_main.c: In function
=E2=80=98ixgbe_probe=E2=80=99:
drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:9350:8: error: =E2=80=98struc=
t
net_device=E2=80=99 has no member named =E2=80=98gso_partial_features=E2=80=
=99
=C2=A0 netdev->gso_partial_features =3D IXGBE_GSO_PARTIAL_FEATURES;
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^
drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:9351:22: error:
=E2=80=98NETIF_F_GSO_PARTIAL=E2=80=99 undeclared (first use in this functio=
n)
=C2=A0 netdev->features |=3D NETIF_F_GSO_PARTIAL |
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^
drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:9368:6: error:
=E2=80=98NETIF_F_TSO_MANGLEID=E2=80=99 undeclared (first use in this functi=
on)
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0NETIF_F_TSO_MANGLEID |
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^
scripts/Makefile.build:291: recipe for target
'drivers/net/ethernet/intel/ixgbe/ixgbe_main.o' failed
make[5]: *** [drivers/net/ethernet/intel/ixgbe/ixgbe_main.o] Error 1
scripts/Makefile.build:440: recipe for target
'drivers/net/ethernet/intel/ixgbe' failed
make[4]: *** [drivers/net/ethernet/intel/ixgbe] Error 2
scripts/Makefile.build:440: recipe for target
'drivers/net/ethernet/intel' failed
make[3]: *** [drivers/net/ethernet/intel] Error 2
scripts/Makefile.build:440: recipe for target 'drivers/net/ethernet'
failed
make[2]: *** [drivers/net/ethernet] Error 2
scripts/Makefile.build:440: recipe for target 'drivers/net' failed
make[1]: *** [drivers/net] Error 2
Makefile:962: recipe for target 'drivers' failed
make: *** [drivers] Error 2
--=-VS2YcFoUzB3V2WG5Bv5+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXCKbNAAoJEOVv75VaS+3OX7kP/iBJj6F8IO5qWdsik0Cci4t/
5fCdUlBvlB5f85liEaLggX/77QezgjwkVeVmJvstfrBF/vxmzZ3RQ8724/CYZeBP
3emF2rO2uxZKI2SoIDblD9b1mUBSFhyGlj85nKCk53rF99J1pvikAbKmUd1DqR7b
NfnV0qF0MH9xgF4U98N7YNzjSiIA83lhnEyXHoGYi4Qw3HPjL7GaLALEoesZWsHU
mleFpawjDW1rCQDPlsZ3x3Qb6ixr/sW1HjQK9dKMz2GTrkl17K6/X4aMepEqjAcH
kXKP1ofFjLCmbIQ2LqS/JVaqld8cyrllBNtZ7dRbK4NKv4K9IQhTOl51tkeEWFEE
T5/4yhv88bEYPVlYDeOCx/Gq4FZCU68+Sd/SjcXsmdey8jr1RFH5OBq5ccpsvTXr
oZK3wPYCwqAzqygmsuNguzcENYcmmjCfrMWkcWeaqTZ8kw+fTll6U10bvm9UOfD3
CuDUdpbS+wSFbk/1SrS9gg0CpP90NqGU4gA8r5XZOP5x7mIe7twj05vuIuKlKn4Z
u7xUD75/jjkNOeLrAVVRGhGIUaNhz+NC425WqcmJZN4OnKGACSjbHFcUQGTWfeaH
BpfDhp5QHJPMpVWew2I+LGhsDrag7lYpRf246dWv+17fNXjXcrrfp9jiy5miTyZk
Gcg4Uy8aDPAkzxK1BsZ0
=prpX
-----END PGP SIGNATURE-----

--=-VS2YcFoUzB3V2WG5Bv5+--

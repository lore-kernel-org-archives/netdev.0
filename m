From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the arm-soc tree with the net-next tree
Date: Mon, 1 Jul 2013 16:28:12 +1000
Message-ID: <20130701162812.def47813e7d94c27950f3e82@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__1_Jul_2013_16_28_12_+1000_10y7cHq3JZwQniMw"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Olof Johansson <olof@lixom.net>, Arnd Bergmann <arnd@arndb.de>,
	<linux-arm-kernel@lists.infradead.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__1_Jul_2013_16_28_12_+1000_10y7cHq3JZwQniMw
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the arm-soc tree got a conflict in
arch/arm/mach-mxs/mach-mxs.c between commit b7c4114b07bb ("can: flexcan:
Use a regulator to control the CAN transceiver") from the net-next tree
and commit 2046338dcbc6 ("ARM: mxs: Use soc bus infrastructure") from the
arm-soc tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc arch/arm/mach-mxs/mach-mxs.c
index 97b8a44,7fa611c..0000000
--- a/arch/arm/mach-mxs/mach-mxs.c
+++ b/arch/arm/mach-mxs/mach-mxs.c
@@@ -323,13 -477,14 +432,14 @@@ static void __init mxs_machine_init(voi
  		imx28_evk_init();
  	else if (of_machine_is_compatible("bluegiga,apx4devkit"))
  		apx4devkit_init();
- 	else if (of_machine_is_compatible("crystalfontz,cfa10037"))
- 		cfa10037_init();
- 	else if (of_machine_is_compatible("crystalfontz,cfa10049"))
- 		cfa10049_init();
+ 	else if (of_machine_is_compatible("crystalfontz,cfa10037") ||
+ 		 of_machine_is_compatible("crystalfontz,cfa10049") ||
+ 		 of_machine_is_compatible("crystalfontz,cfa10055") ||
+ 		 of_machine_is_compatible("crystalfontz,cfa10057"))
+ 		crystalfontz_init();
 =20
  	of_platform_populate(NULL, of_default_bus_match_table,
- 			     NULL, NULL);
 -			     mxs_auxdata_lookup, parent);
++			     NULL, parent);
 =20
  	if (of_machine_is_compatible("karo,tx28"))
  		tx28_post_init();

--Signature=_Mon__1_Jul_2013_16_28_12_+1000_10y7cHq3JZwQniMw
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJR0SGAAAoJEECxmPOUX5FEicoQAJPhfyf4CDOKlF/5dKx4r4XG
YeV9oMhwNrg8dngVXdvK9kvvz+XrW0//PvldT1CyqgAsGRRv8qLn4p3sOWxCCRPx
s40NkhPKmo0Ya8nMKs7OIzCwKdbB9a4myUwdcB0+Plc4+jc69432gVapeSn2Ef8G
EgQ0wqyZJ8H2AdOWGtFq8d8z6i0UwZzoARrRgruhB7vu7r9XkIwIt7fNruoWrkVj
NhYRj4pbnP9Ju+/6xdHk7gJsXfg1JnrEk5AU0wZym6DBZdI9SY7ZLBUUq60WjY3/
sihCf3q70nLizg2wepJrm39M4WAfHBfV3z7/VfYTZPEFMN8BwujItc36yp/vnjc4
9j3PAV6u1N3/hEmSShi7nFTwo6fCwwSrFFEcwHpLZiNTLHR/oMydBm+ideeYo9AB
4xDPDYD9LDBnODdBHkNJIbbTC1l2cYi4AGx0dM+37a6UnT5QcZl47Jiz0z+PJ1Vb
N19TZM6/ioi8pik2+pZF0KeYubJW8TAU6Fh+4CWce3Xa4VUfnTGGrio+/WJVPCqS
gqlao7nZaZVpjWNkwyr7EfQIBWwJsEw3/Zekz5R2kf8TDADKICrObEeQMAaA7AhA
D+6DquaAxiu/eL0GCexbNRaESntwbMYpYNEkdU8kREdTcqvAIVSZRsEyGgRhVLDy
h1SoSclMhAiPkbTatcEu
=JBkZ
-----END PGP SIGNATURE-----

--Signature=_Mon__1_Jul_2013_16_28_12_+1000_10y7cHq3JZwQniMw--

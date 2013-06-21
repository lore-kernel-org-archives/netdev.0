From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 21 Jun 2013 12:33:21 +1000
Message-ID: <20130621123321.a6b54d66ef1a9f708caae452@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__21_Jun_2013_12_33_21_+1000_1uwrfcQZwFdyVLeM"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>,
	Chris Healy <cphealy@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__21_Jun_2013_12_33_21_+1000_1uwrfcQZwFdyVLeM
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/freescale/fec_main.c between commit d13919301d9a
("net: fec: Fix build for MCF5272") from the net tree and commit
32bc9b46d840 ("fec: Add support to restart autonegotiate") from the
net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/freescale/fec_main.c
index d48099f,46f2544..0000000
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@@ -1444,13 -1435,20 +1443,24 @@@ static int fec_enet_set_pauseparam(stru
  	return 0;
  }
 =20
 +#endif /* !defined(CONFIG_M5272) */
 +
+ static int fec_enet_nway_reset(struct net_device *dev)
+ {
+ 	struct fec_enet_private *fep =3D netdev_priv(dev);
+ 	struct phy_device *phydev =3D fep->phy_dev;
+=20
+ 	if (!phydev)
+ 		return -ENODEV;
+=20
+ 	return genphy_restart_aneg(phydev);
+ }
+=20
  static const struct ethtool_ops fec_enet_ethtool_ops =3D {
 +#if !defined(CONFIG_M5272)
  	.get_pauseparam		=3D fec_enet_get_pauseparam,
  	.set_pauseparam		=3D fec_enet_set_pauseparam,
 +#endif
  	.get_settings		=3D fec_enet_get_settings,
  	.set_settings		=3D fec_enet_set_settings,
  	.get_drvinfo		=3D fec_enet_get_drvinfo,
@@@ -1891,9 -1887,13 +1900,14 @@@ fec_probe(struct platform_device *pdev
  	if (pdev->id_entry &&
  	    (pdev->id_entry->driver_data & FEC_QUIRK_HAS_GBIT))
  		fep->pause_flag |=3D FEC_PAUSE_FLAG_AUTONEG;
 +#endif
 =20
- 	fep->hwp =3D devm_request_and_ioremap(&pdev->dev, r);
+ 	fep->hwp =3D devm_ioremap_resource(&pdev->dev, r);
+ 	if (IS_ERR(fep->hwp)) {
+ 		ret =3D PTR_ERR(fep->hwp);
+ 		goto failed_ioremap;
+ 	}
+=20
  	fep->pdev =3D pdev;
  	fep->dev_id =3D dev_id++;
 =20

--Signature=_Fri__21_Jun_2013_12_33_21_+1000_1uwrfcQZwFdyVLeM
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRw7t2AAoJEECxmPOUX5FEJnQP/18a3XuLiEllZnES9ToH36Zv
6ANFOWlhKIYnpITBQ6PJGbvulx6kgXLTqjh/FoYoqVmTlUpBzdW1yVjFn+wlKokn
M9njhNHioHixHPKa/qYUK5BXJKms7uy52F4KjSI2wlrEtU0oZbJRNJcZ2X9/xr+Z
7HYHl3n0gg0P0vGFPfUJdYlvJSIWJnx8PhnmuJnSKY84cDPJbvRTaxPjoF+w/krG
OTvHZrL6wkT253VlT7uGK9uIawuaoLdXHoxWH30l5ZJF+gC8ip1hRITLcnVLrXAI
NgynkE/Ts+JNVZzDn4Ivd1WczYVEWHLcFHyW8jZ5r1OWesMEWOQPMgksCn7gDM7z
AwMsj2daZVBcocgb5ncQjNDYJaGZ52aUd5p2N5AKHDldYNDzCcO0Lgy/Z6r2j+1g
S5EdDs2UuwiTWBJM5GODo6aCYbtZwHNy2mC9FFkmM2nwi663r3WCa5yd4ykPqrH8
1TVsbt6WiLPMpl+sQtGytY0BKDo5JCX+gbMsDr3dUb2E+iPIqrC5b2otywyuhGMo
kGWcx1JIWaUuolFCYxxX9/PrkPv5w8bR23nr2ItrTpAPcixIZ5bCIAIrwAIK3FTr
QReqnIJc6EGM+yZ4cT4iCxBSMG+l7bIE0ha1jPcFi6kX6+QsOsIFfWvLFZ8HKhCV
Azy40VikB/osCwNm8olQ
=JfTM
-----END PGP SIGNATURE-----

--Signature=_Fri__21_Jun_2013_12_33_21_+1000_1uwrfcQZwFdyVLeM--

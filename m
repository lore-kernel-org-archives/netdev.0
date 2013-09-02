From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Mon, 2 Sep 2013 13:12:12 +1000
Message-ID: <20130902131212.4cd51e16f04732b01c58df34@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__2_Sep_2013_13_12_12_+1000_8oIN2pp.lMwK7C0J"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Byungho An <bh74.an@samsung.com>,
	Sonic Zhang <sonic.zhang@analog.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__2_Sep_2013_13_12_12_+1000_8oIN2pp.lMwK7C0J
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c between commit
64c3b252e9fc ("net: stmmac: fixed the pbl setting with DT") from the
tree and commit e2a240c7d3bc ("driver:net:stmmac: Disable DMA store and
forward mode if platform data force_thresh_dma_mode is set") from the
net-next tree.

I fixed it up (I think - see below) and can carry the fix as necessary (no
action is required).


--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 1c83a44,623ebc5..0000000
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@@ -71,18 -71,19 +71,23 @@@ static int stmmac_probe_config_dt(struc
  		plat->force_sf_dma_mode =3D 1;
  	}
 =20
 -	dma_cfg =3D devm_kzalloc(&pdev->dev, sizeof(*dma_cfg), GFP_KERNEL);
 -	if (!dma_cfg)
 -		return -ENOMEM;
 -
 -	plat->dma_cfg =3D dma_cfg;
 -	of_property_read_u32(np, "snps,pbl", &dma_cfg->pbl);
 -	dma_cfg->fixed_burst =3D of_property_read_bool(np, "snps,fixed-burst");
 -	dma_cfg->mixed_burst =3D of_property_read_bool(np, "snps,mixed-burst");
 +	if (of_find_property(np, "snps,pbl", NULL)) {
 +		dma_cfg =3D devm_kzalloc(&pdev->dev, sizeof(*dma_cfg),
 +				       GFP_KERNEL);
 +		if (!dma_cfg)
 +			return -ENOMEM;
 +		plat->dma_cfg =3D dma_cfg;
 +		of_property_read_u32(np, "snps,pbl", &dma_cfg->pbl);
 +		dma_cfg->fixed_burst =3D
 +			of_property_read_bool(np, "snps,fixed-burst");
 +		dma_cfg->mixed_burst =3D
 +			of_property_read_bool(np, "snps,mixed-burst");
 +	}
+ 	plat->force_thresh_dma_mode =3D of_property_read_bool(np, "snps,force_th=
resh_dma_mode");
+ 	if (plat->force_thresh_dma_mode) {
+ 		plat->force_sf_dma_mode =3D 0;
+ 		pr_warn("force_sf_dma_mode is ignored if force_thresh_dma_mode is set."=
);
+ 	}
 =20
  	return 0;
  }

--Signature=_Mon__2_Sep_2013_13_12_12_+1000_8oIN2pp.lMwK7C0J
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJSJAIQAAoJEECxmPOUX5FEPwIP/2sohm21ZbYNlvdJfHKjWgGW
Qqjh1jtq/zZdNsRX//I4BS82Oj+JT8OVPB8WtSRrur1RpcPPr45i8JzRy42/PV8K
uk0YV+mO3595Lhg0p9LIn+Lqx1ei6wShsP8JVLuU2edqpWMaXzooJ7aRuTfezaSD
XBJM7VrswUADWRDblOgF+fEFPjxUitiircUB05C8KwzaKKtkVJoaC0sqrSr4DyQ8
kJeRcst7/AqIYbkJiVeZ2lg8rsjaXOTM5ZSUVfYwoycBQQyBIuy94pSGzmL1uH9u
FV47rI6QWc8LiwDtFNzyZSbYHtCbTr2Nwv9A5danIsPMX7e+DyJi8gRJWF6w4T0G
fEw6XmH2MYWvjil5+KOP+qUsGbaxm4JN/w7Qd/gfB3yZ1ZLT5dlQd3c0P5X+gnAa
LDUP70Z4HladEVuBjwjuAGzKIwhpCznAxX7wuN7OOmJvup4HpjRqgjYmSFIeoeTZ
CigUQR6O7vnKXR/2G7Xon+iFiiCiDb41eSygu3zUflnMb4r3NyZHv4OeAs5MZ6fU
SHnNz762CV8tQ9GYs7ll02Ugt5sK/NnEOTWmEyLmpaw6KibHosg5u8vGmlrhefin
oq8lrN03TGZ6yVNgLqIdjrI+QdcXt6Lplx2kNsi2H/RzaQBnlSp17Y2u218qkS4Z
uful+Zz6igaJIM+WORLB
=O7OQ
-----END PGP SIGNATURE-----

--Signature=_Mon__2_Sep_2013_13_12_12_+1000_8oIN2pp.lMwK7C0J--

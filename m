From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless-next tree with the
 net-next tree
Date: Mon, 11 Feb 2013 13:33:50 +1100
Message-ID: <20130211133350.5f510bbb28759960a19a98af@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__11_Feb_2013_13_33_50_+1100_+V/rPl72J2L7N9fL"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>, Luciano Coelho <coelho@ti.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__11_Feb_2013_13_33_50_+1100_+V/rPl72J2L7N9fL
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

Today's linux-next merge of the wireless-next tree got conflicts in
drivers/net/wireless/ti/wlcore/sdio.c and
drivers/net/wireless/ti/wlcore/spi.c between commit 0d2e7a5c6080
("wireless: Remove unnecessary alloc/OOM messages, alloc cleanups") from
the net-next tree and commit afb43e6d88e5 ("wlcore: remove if_ops from
platform_data") from the wireless-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
diff --cc drivers/net/wireless/ti/wlcore/sdio.c
index 75622f6,198028d..0000000
--- a/drivers/net/wireless/ti/wlcore/sdio.c
+++ b/drivers/net/wireless/ti/wlcore/sdio.c
@@@ -228,9 -228,19 +228,17 @@@ static int wl1271_probe(struct sdio_fun
  	if (func->num !=3D 0x02)
  		return -ENODEV;
 =20
+ 	pdev_data =3D kzalloc(sizeof(*pdev_data), GFP_KERNEL);
+ 	if (!pdev_data) {
+ 		dev_err(&func->dev, "can't allocate platdev_data\n");
+ 		goto out;
+ 	}
+=20
+ 	pdev_data->if_ops =3D &sdio_ops;
+=20
  	glue =3D kzalloc(sizeof(*glue), GFP_KERNEL);
 -	if (!glue) {
 -		dev_err(&func->dev, "can't allocate glue\n");
 +	if (!glue)
- 		goto out;
+ 		goto out_free_pdev_data;
 -	}
 =20
  	glue->dev =3D &func->dev;
 =20
diff --cc drivers/net/wireless/ti/wlcore/spi.c
index 53790d1,5ad2e10..0000000
--- a/drivers/net/wireless/ti/wlcore/spi.c
+++ b/drivers/net/wireless/ti/wlcore/spi.c
@@@ -325,17 -331,26 +325,24 @@@ static int wl1271_probe(struct spi_devi
  	struct resource res[1];
  	int ret =3D -ENOMEM;
 =20
- 	pdata =3D spi->dev.platform_data;
- 	if (!pdata) {
+ 	pdev_data =3D kzalloc(sizeof(*pdev_data), GFP_KERNEL);
+ 	if (!pdev_data) {
+ 		dev_err(&spi->dev, "can't allocate platdev_data\n");
+ 		goto out;
+ 	}
+=20
+ 	pdev_data->pdata =3D spi->dev.platform_data;
+ 	if (!pdev_data->pdata) {
  		dev_err(&spi->dev, "no platform data\n");
- 		return -ENODEV;
+ 		ret =3D -ENODEV;
+ 		goto out_free_pdev_data;
  	}
 =20
- 	pdata->ops =3D &spi_ops;
+ 	pdev_data->if_ops =3D &spi_ops;
 =20
  	glue =3D kzalloc(sizeof(*glue), GFP_KERNEL);
 -	if (!glue) {
 -		dev_err(&spi->dev, "can't allocate glue\n");
 +	if (!glue)
- 		goto out;
+ 		goto out_free_pdev_data;
 -	}
 =20
  	glue->dev =3D &spi->dev;
 =20

--Signature=_Mon__11_Feb_2013_13_33_50_+1100_+V/rPl72J2L7N9fL
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRGFiOAAoJEECxmPOUX5FENrIP/0V0ySPeeW4i6C8ZA0uTvrew
fyccgOriJfmv5KhC+N/tPfJLOtKtqAl2m18YLCTEk4B6la11eCMI7ZvQamY8xJkZ
gKbcPkzqPSMUE3qycvEFR2eOxzoNKI8nm2oVnGxM8hIza7ZGbW4o0ilHufZuSRSY
U+dnx+0r1ZE9Qa1HjvdHO+jXcya0VT3Qm1M+3M9JNUDPOi6xbwXf6Bxew9vSXbxG
64mGfLzUEwrUw3d+pZ08As3kwSdRfXHPX/qv7EhFNNKGIX/sTgB/wDJpie3qsRwo
V8PGToq1zK4HoIbGwnfqFRoi89bGrbuL9UXYCtWbdhxywFD7e09aKIxt8Qb8rPOy
852QPkyfXN9P0BHCbHSY5Y8BWxRNhV2adODCKyzSB9rEw0H7W+uC2tFsQD2S+Zx1
JLFPef5PiHoHRXDpgYYR5IzE4XjyZAsL2Ulqq7PhCJ3Lh+aTZhDFBzIWCrgoZ8dk
ZagpTt2UxC8VCHJRZE2Q65si/VlcTcyGVs7Xb2F7op6JFnYbs4RkxchiYvhy20Fg
9pQ4vevOUX4P6D6QJSau4SxuNttBcyxu4RYQDlz039w6lqKVw7Hu12IRwN/3n0PR
z+moy+j4iSMGXTEgBGc9h6Uz12RLEqfkK5O3VnUi9qoSpqyB7Yoqbcodt9bsyu/v
pOhBDpORG2c2Drgt86B1
=ELL8
-----END PGP SIGNATURE-----

--Signature=_Mon__11_Feb_2013_13_33_50_+1100_+V/rPl72J2L7N9fL--

From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 12 May 2015 11:49:59 +1000
Message-ID: <20150512114959.35139289@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/_fpatKuVHZ6w1PP+OrX70ca"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stefan Wahren <stefan.wahren@i2se.com>,
	Varka Bhadram <varkabhadram@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/_fpatKuVHZ6w1PP+OrX70ca
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/qualcomm/qca_spi.c between commit 268be0f7a7d9
("net: qca_spi: Fix possible race during probe") from the net tree and
commit cf9d0dcc5a46 ("ethernet: qualcomm: use spi instead of
spi_device") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/qualcomm/qca_spi.c
index 6af028d5f9bc,c6b749880e46..000000000000
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@@ -909,12 -909,10 +909,12 @@@ qca_spi_probe(struct spi_device *spi
  		return -ENOMEM;
  	}
  	qca->net_dev =3D qcaspi_devs;
- 	qca->spi_dev =3D spi_device;
+ 	qca->spi_dev =3D spi;
  	qca->legacy_mode =3D legacy_mode;
 =20
- 	spi_set_drvdata(spi_device, qcaspi_devs);
++	spi_set_drvdata(spi, qcaspi_devs);
 +
- 	mac =3D of_get_mac_address(spi_device->dev.of_node);
+ 	mac =3D of_get_mac_address(spi->dev.of_node);
 =20
  	if (mac)
  		ether_addr_copy(qca->net_dev->dev_addr, mac);

--Sig_/_fpatKuVHZ6w1PP+OrX70ca
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVUVxHAAoJEMDTa8Ir7ZwVEnIP/2Wggs2Ux9MTQIMbz278ZRDW
Bm3+0ctNvzvUP5qsJiTtJM2JwbROHowpYEClnRBkC01WLViUiBcTpFhEylcSakTU
lo2VAkKZMQf8Isx4VGFo32LY7NVV7H2Qwehs1XEdoLN1nCNpP+HDZksoK23o7jyM
L0xdF9lFXyLJuWuFRC2mTj01pwEQEe2pO8MrlYKunp0NQMWoSAZdYF1B/ZPncAPh
cJq1xY09FiOvqJ0Hvi2PtKo0gIuVRwjKjYOVL6Cc1cy+GFMeB9eY3z2Qa9oNafmm
KQRDAgT+KiLoMA8tSdxuKDvzX7LpFULD1HvMlASlF5s45lmB7By/YVocnYE6NuVD
nMpKe2ub5bh8u4TDBb6CF/aOL+5LqCGLO+8YiNvnuPZ0F2OhhXD+tzuvcSteQvOW
FOkmyV72oroRRP6PRvTcwcYNU3QOFYKruQQIDjvahrw1XiXBahvMMzA0mjiT60aF
xFrZooWLQWCFumEsLRSdmDfEPFqpCFJnzKSAo5POWKR1YwytCUN2ve8iC2dTG7TH
tp/zZs1Bwiq9EX/dRkE9RpOcfT0Hm93fQUyCo9RO9xk4f09YOLgN0UlryMzH2d+Y
NgPMLD8Dczf27YL9KVPExRN8A9dBPrOIghCU210odSCQFfXYdg9gcE68S2sU/aGP
7tcB1smDZA1uJI3owMxX
=TEr6
-----END PGP SIGNATURE-----

--Sig_/_fpatKuVHZ6w1PP+OrX70ca--

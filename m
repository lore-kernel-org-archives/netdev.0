From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the akpm tree with the net-next tree
Date: Fri, 8 Jun 2012 13:56:23 +1000
Message-ID: <20120608135623.0771d422608209264d4c3ef5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__8_Jun_2012_13_56_23_+1000_.QQKrYWL2EHZtje/"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	AnilKumar Ch <anilkumar@ti.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Viresh Kumar <viresh.kumar@st.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:60498 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758241Ab2FHD4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 23:56:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Fri__8_Jun_2012_13_56_23_+1000_.QQKrYWL2EHZtje/
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

Today's linux-next merge of the akpm tree got a conflict in
drivers/net/can/c_can/c_can_platform.c between commit 33f810097769 ("can:
c_can: Move overlay structure to array with offset as index") from the
net-next tree and commit "net/c_can: remove conditional compilation of
clk code" from the akpm tree.

Just context changes.  I fixed it up (see below) and can carry the fix as
necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/can/c_can/c_can_platform.c
index f0921d1,7ec9316..0000000
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@@ -71,10 -71,8 +71,9 @@@ static int __devinit c_can_plat_probe(s
  	void __iomem *addr;
  	struct net_device *dev;
  	struct c_can_priv *priv;
 +	const struct platform_device_id *id;
  	struct resource *mem;
  	int irq;
- #ifdef CONFIG_HAVE_CLK
  	struct clk *clk;
 =20
  	/* get the appropriate clk */
@@@ -138,18 -129,8 +136,16 @@@
  		priv->read_reg =3D c_can_plat_read_reg_aligned_to_16bit;
  		priv->write_reg =3D c_can_plat_write_reg_aligned_to_16bit;
  		break;
 +	default:
 +		ret =3D -EINVAL;
 +		goto exit_free_device;
  	}
 =20
 +	dev->irq =3D irq;
 +	priv->base =3D addr;
- #ifdef CONFIG_HAVE_CLK
 +	priv->can.clock.freq =3D clk_get_rate(clk);
 +	priv->priv =3D clk;
- #endif
 +
  	platform_set_drvdata(pdev, dev);
  	SET_NETDEV_DEV(dev, &pdev->dev);
 =20

--Signature=_Fri__8_Jun_2012_13_56_23_+1000_.QQKrYWL2EHZtje/
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJP0XfnAAoJEECxmPOUX5FEh1cP/j32krsuzCEAsWMTcZt6P/JD
L93AAMdNomyrL+islkawj5WxoI26OxbQuIRvQAyTfDmPToBjFqF/N3MTRrpXYk4t
e6ZM1qqUiSd9tIsC314u9H0oBWNw9Af6Hbt9dUIY8Fani2L492KHk3WsFpK7lsFS
UK8p2Iv65xPSWSNSZUK++djs8mpbBVTj97XhgucnFcA0iKD3AsiWkHPJA25DEPeM
aRLg5CzesyZ2UrpKX7f8+O//c8ZQDnNoFW7FRZel1rwJqNOhVxJZxp+KEDaZhA+c
QcQ5cQKwi7uK6iV7VgexPFg1ytywN2Qc0s0yhiqLvXcALKLw4QN+n+iya7mp+lvr
O1FxAD9ieRk4dhZUjCIscIHeAXjMqVAcPiPLfJsKMk3NL2r2OIpitNzRoGkiYT3I
uOtVLUJ2d+4v6r2RC4jCQwpJD3WJ6sYlOM5r7bAmP4EYyJWwdowAWp/l2pPE837p
vEV0s06Buvdgs2CXMCg4IvDK3OX7ikllR3gfZR9h3RS2EznqTyIWJfjgcDNChpbA
29nhXELnCnZH4EQUTAyEjjnPrPMoyZkNdMWHJJIQ5VoQ07VI7JG6O13KwTQn3X+q
SwbVCNYDaWrl16bfE42Otw5bzaOJ6DZV/izXxUvE+qAuh5P7tnj3h2S3rz6N+Qws
zvf9zRz8RWIHV73yGAF0
=p5Hn
-----END PGP SIGNATURE-----

--Signature=_Fri__8_Jun_2012_13_56_23_+1000_.QQKrYWL2EHZtje/--

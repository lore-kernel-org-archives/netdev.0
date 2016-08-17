From: Leon Romanovsky <leon@kernel.org>
Subject: Re: next-20160816 build: 1 failures 2 warnings (next-20160816)
Date: Wed, 17 Aug 2016 08:44:03 +0300
Message-ID: <20160817054403.GD5489@leon.nu>
References: <E1bZaoA-0004xE-Oj@optimist>
 <20160816163841.GU9347@sirena.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="k4f25fnPtRuIRUb3"
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	kernel-build-reports@lists.linaro.org,
	linaro-kernel@lists.linaro.org, linux-next@vger.kernel.org,
	netdev@vger.kernel.org
To: Mark Brown <broonie@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:33746 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750903AbcHQFoJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2016 01:44:09 -0400
Content-Disposition: inline
In-Reply-To: <20160816163841.GU9347@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--k4f25fnPtRuIRUb3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 16, 2016 at 05:38:41PM +0100, Mark Brown wrote:
> On Tue, Aug 16, 2016 at 10:37:20AM +0100, Build bot for Mark Brown wrote:
>=20
> Today's -next fails to build an ARM allmodconfig due to:
>=20
> > 	arm-allmodconfig
> > ../drivers/net/ethernet/mellanox/mlx5/core/debugfs.c:300:61: error: 'ou=
tb' undeclared (first use in this function)
>=20
> which appears to be caused by 535e20f083e6 ({net,IB}/mlx5: QP/XRCD
> commands via mlx5 ifc).  outb() just isn't available as standard on ARM,
> it's not something that's meaningful for the hardware.

Thanks Mark for catching it.

It puzzles me how it passed all other compilations (internals and
externals) without failures. On my machine (x86-64), old and new
versions compile without errors.

This failure isn't related to OUT assembly instruction, but to typo in
pointer name declaration. It was declared as "u32 *out", but "outb" was
used.

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c b/drivers/ne=
t/ethernet/mellanox/mlx5/core/debugfs.c
index e587911..e94a953 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
@@ -297,7 +297,7 @@ static u64 qp_read_field(struct mlx5_core_dev *dev, str=
uct mlx5_core_qp *qp,
 	*is_str =3D 0;
=20
 	/* FIXME: use MLX5_GET rather than mlx5_qp_context manual struct */
-	ctx =3D (struct mlx5_qp_context *)MLX5_ADDR_OF(query_qp_out, outb, qpc);
+	ctx =3D (struct mlx5_qp_context *)MLX5_ADDR_OF(query_qp_out, out, qpc);
=20
 	switch (index) {
 	case QP_PID:

--k4f25fnPtRuIRUb3
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXs/mjAAoJEORje4g2clin3kkQAMCWygm5vF/N4pCYBHDaDAQ4
hNXgM9mpzHG6OZspclVo9+eyk1jSWy+37dc5TvvJgwXJuNYwexKmJ3TevuxRmtf/
fXehsncQOeLF8BnGtIouFYSUTir59d35t+qcwFwnmwiHPdYBNm8q000iqTtrF4S5
pnJwlV5kOlcBblcXfBYgE0h7J6Lw/kS/9h+TCmV0+wTuSyICp4IIBb1BVuuNwJvj
MsGc0JGYEb7j37n9HicdDTe9QEGndXci2hbF3cC3t26uoBrurElgest5ARrh/Tbz
DLBhcnPJl6Gbm9Dce+63l2pNFcfDuCVoWdcebI5meJaJkETgxeJdUzCp0e4UB/G/
2cICT1I+KysPA13u3GhuMwdCVN0TD4GH++A/jcM787czJ5/PKPxdYCAsoqUzyBEs
wKSGd1RJJjHFw5kJ05z6G42ZdhB2apncdeHo1OAjkwQt0DVoiHUZbpY6ZxttwJHR
TPwbphdg1CS56D+s9IqGPCK/xjCBwjW34ifvCqFc2qQuOcRrFKqfa7Hjyk8yO31w
Nth6Dy/+xZTj+axuIyBsj3DVuti00VOM3CKFg2SSlPdycsbSDnIw7teYDoFOH6Sj
9Tx1rRwpQ/Goa4+d5SB2Kys6qGdp4tVQIfz3p9u7pw0c9YLl9g5JatyEoOh/3tAR
75gwlS/YKnedP5GBNP1D
=u4ml
-----END PGP SIGNATURE-----

--k4f25fnPtRuIRUb3--

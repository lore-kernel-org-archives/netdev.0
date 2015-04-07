From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 7 Apr 2015 13:18:19 +1000
Message-ID: <20150407131819.269e593a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/_FerJuvGdzg_r12/tcltcR5"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Ido Shamay <idos@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/_FerJuvGdzg_r12/tcltcR5
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/mellanox/mlx4/cmd.c between commit fde913e25496
("net/mlx4_core: Fix error message deprecation for ConnectX-2 cards")
from the net tree and commit a130b5905732 ("net/mlx4: Add SET_PORT
opcode modifiers enumeration") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/mellanox/mlx4/cmd.c
index 546ca4226916,06993ea9e6ba..000000000000
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@@ -724,9 -725,9 +725,10 @@@ static int mlx4_cmd_wait(struct mlx4_de
  		 * on the host, we deprecate the error message for this
  		 * specific command/input_mod/opcode_mod/fw-status to be debug.
  		 */
 -		if (op =3D=3D MLX4_CMD_SET_PORT && in_modifier =3D=3D 1 &&
 +		if (op =3D=3D MLX4_CMD_SET_PORT &&
 +		    (in_modifier =3D=3D 1 || in_modifier =3D=3D 2) &&
- 		    op_modifier =3D=3D 0 && context->fw_status =3D=3D CMD_STAT_BAD_SIZE)
+ 		    op_modifier =3D=3D MLX4_SET_PORT_IB_OPCODE &&
+ 		    context->fw_status =3D=3D CMD_STAT_BAD_SIZE)
  			mlx4_dbg(dev, "command 0x%x failed: fw status =3D 0x%x\n",
  				 op, context->fw_status);
  		else

--Sig_/_FerJuvGdzg_r12/tcltcR5
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVI0yAAAoJEMDTa8Ir7ZwVYkgP/j2RxZZcSHu3BoTQFzCDiSPl
jDSWlP9cdsXi8zKJer73Uw2o8NpDZVmWx9eiBoNFdCTWsxx21i5sIcNzvaQDp1PD
4vgxs1PRyyeacFm2jKZiBizoHyBR1Tji7xyKb8xwvF/fOLPVK63iHT/pPUs354xv
wCrlHk8rQb9VHKJDdpdAGmN8bSbQjIW7h8WBvNo5WeVm+XgsY3F4KErLfTQDzecq
/OOMJ2kBvWlnAFxuj85HMX8TbUn6dJyIYhRKXAx3zcPnmmzecHqKItHDkqkfa3h5
tDttgvS3UiZILp9wxmi/vlWMxdWWq2ir9boZPl1zu5FJjcVEbGL2av7ZxHSzZkT8
IIOx0DDZlVbaUqD1cAWZ3XZ4HXb4/Pg7b/VsHYeI8YdmJZqDHl9mTyJdwrlAA1i7
dm07y18VOn1AeAbe2qBBM3YSLqRGePHNSY/gC3fErvxerwx44vGmrsq7VjRioonc
0d24cVtWKVcHQCEpRAc/nVAz9iu7FcM0+YuWhZL9LE46PUHo100bt/A8WOt9UubV
gJhOEIEmNd+xi/fg0UnHEsATxSKt31YiUzPB/ozylOUQbnOajD6+xW22h+xf0m3w
Ln+C/fNhaHWOGAD3mxkUuDm10vz0+1h+Ha4ZD28xZBzPeIJNO8OS6v8UWZb9+egc
Xv659o8Yc+1rVyO3ux2Y
=zi/u
-----END PGP SIGNATURE-----

--Sig_/_FerJuvGdzg_r12/tcltcR5--

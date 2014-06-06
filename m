From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Fri, 6 Jun 2014 14:06:51 +1000
Message-ID: <20140606140651.1c393d7a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/LpwfM8eg+rXoae73mu8hekU"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/LpwfM8eg+rXoae73mu8hekU
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (powerpc
ppc64_defconfig) failed like this:

net/core/filter.c: In function 'convert_bpf_extensions':
net/core/filter.c:696:17: error: 'A_REG' undeclared (first use in this func=
tion)
   insn->a_reg =3D A_REG;
                 ^

Caused by my bad merge resolution :-(

I applied this in the hope that it is correct (at least it builds):

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 6 Jun 2014 14:00:07 +1000
Subject: [PATCH] net: filter: merge fix up

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/core/filter.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 7b46e4553c17..74dd87596257 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -691,10 +691,7 @@ static bool convert_bpf_extensions(struct sock_filter =
*fp,
 		*insn =3D BPF_ALU32_IMM(BPF_AND, BPF_REG_A, PKT_TYPE_MAX);
 #ifdef __BIG_ENDIAN_BITFIELD
 		insn++;
-
-		insn->code =3D BPF_ALU | BPF_RSH | BPF_K;
-		insn->a_reg =3D A_REG;
-		insn->imm =3D 5;
+		*insn =3D BPF_ALU32_IMM(BPF_RSH, BPF_REG_A, 5);
 #endif
 		break;
=20
--=20
2.0.0

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/LpwfM8eg+rXoae73mu8hekU
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTkT5hAAoJEMDTa8Ir7ZwVXkAP/jLiWO660gmEvDVpMHDYhg9J
2naxz+DC8Nb4ZuUVIpdFJsQtLQuY6U+rVPGeeHALalHzs/WmGD35HDtaekIrxyuK
VQPSdPea7RSNiUI5AMfHl6QHpXc1q2N1A0F0Q/pVmFfxG5DkyJ3oQLreDEPabIPe
xctesY/hluDrfOaODpTdvB8SUCyV39QLKu4/xkHEv+N5DNPigGxaeniNbCMYkn/+
wC61979gsJfufNrk2itLc8D/c9dsz0HCQ1H2dqZZblxVpgCJEN2oyyS+A3vRIn18
iM1TG7liLukYrMCp/KGQ57XjGMxeDGVzqnc547VOlazmA9sqdeNHmoIV5mVhOfmK
kYiU7kk2vDSKB1UXn435qee5rNdqCo0IfljyD80zBcKS90daTD+EovBqY5FcEU/V
QaAXqJ9Y36qooQc4jWnrx8jhy/c+papSmOCZfzOsP4fQyAwElNu7Rfh+FIVRNNBp
cy+kVsY2regdad3NDDFrUGh9tvx163ILmeSBWHM11CKocfBCBU6uWXq5cSarNFlj
A/pXpJKdhdpD04m6VIqVE5VjFMvxe8ss7YQJcBsbyTV6S4fmWvCK5i4IuzYtrSdt
ePI4IZwcClpBnkHG3ts9t+bXfpm1Xzz5NnWoiID4mwDFz0HYxl9IhF/n/5lmEr6u
nFs7bAVnAfMCWl3ulXum
=1poB
-----END PGP SIGNATURE-----

--Sig_/LpwfM8eg+rXoae73mu8hekU--

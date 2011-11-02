From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net tree
 related)
Date: Wed, 2 Nov 2011 16:37:08 +1100
Message-ID: <20111102163708.75d719e765dea20e0c4c5a04@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__2_Nov_2011_16_37_08_+1100_Nt6k6I4h11x20WA5"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__2_Nov_2011_16_37_08_+1100_Nt6k6I4h11x20WA5
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

[I thought I had reported this, but it was a similar problem in another
driver.]

After merging the final tree, today's linux-next build (powerpc
allyesconfig) failed like this:

drivers/net/ethernet/xilinx/ll_temac_main.c: In function 'temac_start_xmit':
drivers/net/ethernet/xilinx/ll_temac_main.c:717:3: error: implicit declarat=
ion of function 'frag_size' [-Werror=3Dimplicit-function-declaration]

Caused by commit 9e903e085262 ("net: add skb frag size accessors").

I have added this patch for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 2 Nov 2011 16:31:37 +1100
Subject: [PATCH] net: fix typo in drivers/net/ethernet/xilinx/ll_temac_main=
.c

Commit 9e903e085262 ("net: add skb frag size accessors") used frag_size
instead of skb_frag_size in this file.

Fixes this build error:

drivers/net/ethernet/xilinx/ll_temac_main.c: In function 'temac_start_xmit':
drivers/net/ethernet/xilinx/ll_temac_main.c:717:3: error: implicit declarat=
ion of function 'frag_size' [-Werror=3Dimplicit-function-declaration]

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ethernet/xilinx/ll_temac_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethe=
rnet/xilinx/ll_temac_main.c
index 4d1658e..caf3659 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -716,8 +716,8 @@ static int temac_start_xmit(struct sk_buff *skb, struct=
 net_device *ndev)
 		cur_p =3D &lp->tx_bd_v[lp->tx_bd_tail];
 		cur_p->phys =3D dma_map_single(ndev->dev.parent,
 					     skb_frag_address(frag),
-					     frag_size(frag), DMA_TO_DEVICE);
-		cur_p->len =3D frag_size(frag);
+					     skb_frag_size(frag), DMA_TO_DEVICE);
+		cur_p->len =3D skb_frag_size(frag);
 		cur_p->app0 =3D 0;
 		frag++;
 	}
--=20
1.7.7

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__2_Nov_2011_16_37_08_+1100_Nt6k6I4h11x20WA5
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJOsNcEAAoJEECxmPOUX5FE5ewP/2ro6ZAHBloRr9LCWHqoMLPC
AcAArTryTXhV6PspAFwR2YCdUmNEX2grAJV9dN0IQ7FweTaYX6+Y6tG/iB0k4iYk
lD4EzSpmO61S5GOPRBpxTBFR/onGDXj6+9bE8/tdUwpVO4HPMvECf2EwaJpGvyxZ
QEVw0JoSmNRlFKv+/JHRmnESx4qCrLTCs2Er63IQo5+ssSCC7ueQZDlOKsPAjJ5H
24ojHAjZKxqvWCoJPRCb/9fybGqQcFQKZmoOr4NvP8florYX8YTvO61IlORqULry
kkQFCFyq6zbLlRxCkfDruR6bj4/1fJIdE46syfrR00peZoiad4cElFpHnMXRNGfq
IfQhRyCxlrxHNYbuSTW5He2Z1m2SgSCAYkNFR6Y6YVFCPNup9FNiZvmO6HSx+njz
DYo72+UFCzplfab4SkkiNUCnuU5nGhoDrREjDydLySdH3Z3/M3CdQY+sqfZvoTM9
MXWBczRgg2ecWh/9yZQxI+/whi/XmoNtL2d79/VsTJCp6NmBMCI83cwKnaQOfH69
2Xaz8UhucdJthTZZrMLFkRwV0Fc5OE4pm+JakFXJPHWHv5o8ElE2j8gV5HXZVmlQ
OMI+Le29iOEZNWKhX7bsYU5oPF1l6suE7Vp9PEjipWCOD9X79xio30zq4P86KM3/
xK9VmeTpzrCE11rI52uF
=ReYY
-----END PGP SIGNATURE-----

--Signature=_Wed__2_Nov_2011_16_37_08_+1100_Nt6k6I4h11x20WA5--

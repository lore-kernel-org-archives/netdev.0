From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 11 Mar 2015 08:48:30 +1100
Message-ID: <20150311084830.0bc6dffd@canb.auug.org.au>
References: <20150310120842.6dfa6c2b@canb.auug.org.au>
	<20150309.234329.425011226766680524.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/sZKR5hR0S+47EvJiWxb8nCi"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, joshc@ni.com,
	boris.brezillon@free-electrons.com, cyrille.pitchen@atmel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20150309.234329.425011226766680524.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/sZKR5hR0S+47EvJiWxb8nCi
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Mon, 09 Mar 2015 23:43:29 -0400 (EDT) David Miller <davem@davemloft.net>=
 wrote:
>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Tue, 10 Mar 2015 12:08:42 +1100
>=20
> > Today's linux-next merge of the net-next tree got a conflict in
> > drivers/net/ethernet/cadence/macb.c between commit 0b2eb3e9bc73 ("net:
> > macb: constify macb configuration data") from the net tree and commits
> > a848748959d5 ("net: macb: remove #if defined(CONFIG_ARCH_AT91)
> > sections") and 421d9df0628b ("net/macb: merge at91_ether driver into
> > macb driver") from the net-next tree.
> >=20
> > I fixed it up (I think - see below) and can carry the fix as necessary
> > (no action is required).
>=20
> Thanks Stephen, I'm merging net into net-next right now and will resolve
> this similarly.

Just wondering if you got that merge right?  Here is the diff from what
I did yesterday to what you have in net-next:

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cad=
ence/macb.c
index f032e2a245b0..f00be585f661 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2131,24 +2131,8 @@ static const struct net_device_ops macb_netdev_ops =
=3D {
  */
 static void macb_configure_caps(struct macb *bp)
 {
-	const struct of_device_id *match;
-	const struct macb_config *config;
 	u32 dcfg;
=20
-	if (bp->pdev->dev.of_node) {
-		match =3D of_match_node(macb_dt_ids, bp->pdev->dev.of_node);
-		if (match && match->data) {
-			config =3D match->data;
-
-			bp->caps =3D config->caps;
-			/*
-			 * As we have access to the matching node, configure
-			 * DMA burst length as well
-			 */
-			bp->dma_burst_length =3D config->dma_burst_length;
-		}
-	}
-
 	if (MACB_BFEXT(IDNUM, macb_readl(bp, MID)) =3D=3D 0x2)
 		bp->caps |=3D MACB_CAPS_MACB_IS_GEM;
=20
That section was removed by commit 421d9df0628b ("net/macb: merge
at91_ether driver into macb driver") and I presumed its effect was
moved into macb_probe().

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/sZKR5hR0S+47EvJiWxb8nCi
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJU/2a2AAoJEMDTa8Ir7ZwVX+sP/AiwzNKD3rs5YpOvNF5I1cBL
SH3NzInggrdCzelVcKdPWIshZUXvcvPFk/adbF6jYfmG0YuXagWNwOzhELYzHgiN
CdwqmZlWUxnoC7NAPdxQH0QmSVpd5x8Kje5fI9C7UZSvVkWzaRyldLBDpaDgVrPf
TswaVS31UkeZwTcRg748DVDq/7RSCH5VC7/1fTYfivcrZG2fhrl4aDVuvMwxhFo8
bGlm9+QPyHMxfFoMN0P3VuaRiH64DqUVkMzTN/ioccGOmMgyf0pRbPM3rQHgVDiY
jt7xUJA04vwDin2elDe9M7AQ8y/uuAqrI4nng7z3q6oA29eBsqaEl+q3rJEUvTEt
tEiWM6wA8oI8sAvURrHFPY1aLwJq1qGWhq3guzZvuPQmNVGYRDkLiu+lQqKu/u5g
TXEeq4OnMrWglXKcnMO+XfjDL2HjQrOpCVqgeAAHiu0BQ9C13TNwaLjNTQrmeeAM
R6ykD8L/0JhDzGAfF4MiCnMV3HxW8+ajtvtf75U5gKknClJwPlRzLKiK43UBctpi
986wqVgaiS/NZa4IiHIRC5mbOafuWPEJE23PPPFr0V2vEEYYscg7iVrr4rn9Whkl
ZJX4lxAoSD+ebhClwee/gdCgyRdASL9Nz+pPwgtiEgPVxsQTdAbepORAeyBeS7qs
AuLMr4ACJn5HwqxtvYIw
=eVCj
-----END PGP SIGNATURE-----

--Sig_/sZKR5hR0S+47EvJiWxb8nCi--

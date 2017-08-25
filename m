From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH] net: stmmac: dwmac-sun8i: Use reset exclusive
Date: Fri, 25 Aug 2017 19:12:33 +0200
Message-ID: <20170825171233.4xoihzakca3mqscd@flea.lan>
References: <20170825143805.21733-1-clabbe.montjoie@gmail.com>
 <20170825144832.3w6izhri5vstbndp@flea.lan>
 <20170825151733.GB9475@Red>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="d5x6nwykedhdh2iw"
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com, wens@csie.org,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170825151733.GB9475@Red>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--d5x6nwykedhdh2iw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 25, 2017 at 05:17:33PM +0200, Corentin Labbe wrote:
> On Fri, Aug 25, 2017 at 04:48:32PM +0200, Maxime Ripard wrote:
> > On Fri, Aug 25, 2017 at 04:38:05PM +0200, Corentin Labbe wrote:
> > > The current dwmac_sun8i module cannot be rmmod/modprobe due to that
> > > the reset controller was not released when removed.
> > >=20
> > > This patch remove ambiguity, by using of_reset_control_get_exclusive =
and
> > > add the missing reset_control_put().
> > >=20
> > > Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> > > ---
> > >  drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c | 3 ++-
> > >  1 file changed, 2 insertions(+), 1 deletion(-)
> > >=20
> > > diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c b/driv=
ers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
> > > index fffd6d5fc907..675a09629d85 100644
> > > --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
> > > +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
> > > @@ -782,6 +782,7 @@ static int sun8i_dwmac_unpower_internal_phy(struc=
t sunxi_priv_data *gmac)
> > > =20
> > >  	clk_disable_unprepare(gmac->ephy_clk);
> > >  	reset_control_assert(gmac->rst_ephy);
> > > +	reset_control_put(gmac->rst_ephy);
> > >  	return 0;
> > >  }
> > > =20
> > > @@ -942,7 +943,7 @@ static int sun8i_dwmac_probe(struct platform_devi=
ce *pdev)
> > >  			return -EINVAL;
> > >  		}
> > > =20
> > > -		gmac->rst_ephy =3D of_reset_control_get(plat_dat->phy_node, NULL);
> > > +		gmac->rst_ephy =3D of_reset_control_get_exclusive(plat_dat->phy_no=
de, NULL);
> >=20
> > Why not just use devm_reset_control_get?
> >=20
>=20
> Because there no devm_ functions with of_

devm_reset_control_get uses of_reset_control_get internally.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--d5x6nwykedhdh2iw
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZoFqBAAoJEBx+YmzsjxAgcaYQAKceKvfrxXOK84X9VyHNURo8
vjYRlHxUp4kddpBI5AQzoh0OU3JY9+IovsQ7DcMiRMcIApSw/g2k7ssYCH+PHUTx
eINuyaC7wDlMMrjmNGTGJgTLL1wo7hYVqws5nA+Zd4B1G4R7uuVSj+aeIiq4/xN+
SAf/3qvWjFpGgRA8bRujmRuv4vqfFUxRR3Nd85HICccqzpaBx+Ox7h5jOzTaLEDZ
CiODgXahTuV9eRFqueWeEcrcOuEZhQgLTfbWt0wDh+iF6PNYZhuPCg0oujElM2TW
XvRRAg+vFa/tz4+206FS85FyIVCsf/p4D6R6EZJfwQeUlSLiP+cQxuZh4ouXbyKe
jhXUXcGqALuAt8DeCMH2EfwMx1O94pc1Gh4eo+zoXCVE1I1Wya+JrIfb4O4OJlto
hmxpNTYCFHiKjGY3v01ramMmUaz7X6CAyEw/D3MT+kQmDxSniPu8RQOF9ONZPIyv
QR1CaYQec6qzzJjyeQXnyGCOC/heXZTElyaPNowQhwx+/akqq+01GZbzwtQd6B70
teZDbSfyIdrR9X95x4BVHHSFY9C6nMR+ebOM9yYN/zX3q9am35jeiE1ulymsIhfD
U0gD74LZV6Beb3TVGLkD7zW3Jc7DZUStoLcbL4nStpaTLsqbfTFWl6djq3nh/IM1
pZsssT/oRc09EmDKpo+V
=dm+a
-----END PGP SIGNATURE-----

--d5x6nwykedhdh2iw--

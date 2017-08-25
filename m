From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH] net: stmmac: dwmac-sun8i: Use reset exclusive
Date: Fri, 25 Aug 2017 16:48:32 +0200
Message-ID: <20170825144832.3w6izhri5vstbndp@flea.lan>
References: <20170825143805.21733-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="7wgxoaddpuvmahyd"
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com, wens@csie.org,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170825143805.21733-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--7wgxoaddpuvmahyd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 25, 2017 at 04:38:05PM +0200, Corentin Labbe wrote:
> The current dwmac_sun8i module cannot be rmmod/modprobe due to that
> the reset controller was not released when removed.
>=20
> This patch remove ambiguity, by using of_reset_control_get_exclusive and
> add the missing reset_control_put().
>=20
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c b/drivers/=
net/ethernet/stmicro/stmmac/dwmac-sun8i.c
> index fffd6d5fc907..675a09629d85 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
> @@ -782,6 +782,7 @@ static int sun8i_dwmac_unpower_internal_phy(struct su=
nxi_priv_data *gmac)
> =20
>  	clk_disable_unprepare(gmac->ephy_clk);
>  	reset_control_assert(gmac->rst_ephy);
> +	reset_control_put(gmac->rst_ephy);
>  	return 0;
>  }
> =20
> @@ -942,7 +943,7 @@ static int sun8i_dwmac_probe(struct platform_device *=
pdev)
>  			return -EINVAL;
>  		}
> =20
> -		gmac->rst_ephy =3D of_reset_control_get(plat_dat->phy_node, NULL);
> +		gmac->rst_ephy =3D of_reset_control_get_exclusive(plat_dat->phy_node, =
NULL);

Why not just use devm_reset_control_get?

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--7wgxoaddpuvmahyd
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZoDjAAAoJEBx+YmzsjxAgzpsP/RqMjFs19QijQiAU3z7L9WJy
zZJfZnaZMxN93eAtBIDuaYh3D0WN76cvaXcH2tfBhiz2YdUFR02eZY5WUH6xx9Cb
oRkvYVsv/A2O3UfRZTGrZZie/E+7YlOsjVAjKXtZ094PAFdMbQ/m4RfYktiuRYMR
sa/g5b3hjkwO1KdkHXsmBn1Ir5jrFKlY+tdTd7zkA8xgu4eUKwbkYZmPliU8Ty7W
Ol/D32JxReH44jnrL4k3N7XlC+hTMwCrV/Y/sDO0lDrcBdM9v8uWlTqw3S5dtdak
apLb//DW/p67ZaZWZRcUvXhLQ+2ia8Wmy6io3wVfrYPj7Ge+VlzA6scQdfZbT6H0
uHMp+H0y15+OB/aHKQum1tgwiwmIPhgcp0UpdtDhqK4xcRgSLtrsSkZDqHbR/wfL
cyfuZ/kU3OuFA7Vfa6r0WwfxC1NxWrGgY3C2bSEcIJvOmbfeY3gjgNbpymOtnEj1
uS45itDm4Ej/FW4MxtjpLhUVOQZrXuTpgCICP9ty7yEclkrm/4iXWyxtCKxcvjeh
D54eqQP68zI6xRrkcOd4S5/sAAOykPrs2dEAh5yzPyTuuZ4AGG8b6Rc6EpAJVgai
SF+qGIwEN/vA6JryQlHxrFbRrZHUXGAvmwvQ+XdEVZUg0gdOfhTnye5cOnLk5z9r
EiDvSLklPP5lDrTmY4k3
=p8Ab
-----END PGP SIGNATURE-----

--7wgxoaddpuvmahyd--

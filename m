From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH v2] net: stmmac: dwmac-sun8i: Use reset exclusive
Date: Tue, 19 Sep 2017 10:45:25 +0200
Message-ID: <20170919084525.vdbjrqx5qvhhxmor@flea.lan>
References: <20170918183043.8028-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="7mqomjgivpyllpcv"
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com, wens@csie.org,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170918183043.8028-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--7mqomjgivpyllpcv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Sep 18, 2017 at 08:30:43PM +0200, Corentin Labbe wrote:
> The current dwmac_sun8i module cannot be rmmod/modprobe due to that
> the reset controller was not released when removed.
>=20
> This patch remove ambiguity, by using of_reset_control_get_exclusive and
> add the missing reset_control_put().
>=20
> Note that we cannot use devm_reset_control_get, since the reset is not
> in the device node.
>=20
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---
> Changes since v1:
> - added a note about devm_reset_control_get in commit message

That comment would be better if it was in the code.

>=20
>  drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c b/drivers/=
net/ethernet/stmicro/stmmac/dwmac-sun8i.c
> index 57bb6dd7b401..1736d7cb0d96 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
> @@ -854,6 +854,7 @@ static int sun8i_dwmac_unpower_internal_phy(struct su=
nxi_priv_data *gmac)
> =20
>  	clk_disable_unprepare(gmac->ephy_clk);
>  	reset_control_assert(gmac->rst_ephy);
> +	reset_control_put(gmac->rst_ephy);

Putting it here is weird.

What would happen if power_phy / unpower_phy is called several times?

Can't we just make it symetric and undo in remove what we do in probe?

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--7mqomjgivpyllpcv
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZwNklAAoJEBx+YmzsjxAgc1sQALqO1I3/P84NAW9+qGwxSTxI
ba/GiF/zhUPXY7yHr525XqpS0Jw4W7UeUdFeUvLIO2egKbsWF1gkDw6s1+vr2Mmz
5Ontv4Dcsl3gtGufu02QGmLfscfdwsru7xAC6zZaKi95pNxnrtlxFxcBRkibgRYa
qqquX92ejLAwuhnm7W2YdP/GafdoDVvbXlEQ3e3wmNEXJ+6u/a6KkEwUmrzlWf8N
SF7SpXXcORLK8MFwAoqnQeI+HASyEQMWk8kxwM73YKiRl9eHx8Xa8dVSJ70G3tK4
FZN/Cm191I1WH+E9tJlvE4lrfoJBdWYIQBWPnNcmq5WrsLBmexn30NVp/72Jlibf
9G+6rY0vbvI4SQKjxWrEKtb2XU577vfg2tC9OFhGULA6hHp2qshw2G2eHDIklVra
b8919uhgLLtHUC5HRh23x1XsKBtuQ972RyAEiz1lfSiThPawbwYbRf9JrDeV9l02
SnuAmEGNvK72NHET+JRmmb4TqhGhMISasTF7XLUcrCYqfGjel54LApvSXirDeQ1H
BnLyyC+IZ5iCtSI9RFbAdbw6eEnzWW1SLcHK+yIc4+U2Bw+GxYvICmFMg7ad85Fz
NAZxSmRgrd9m5GZltoZZH9H1pGv/qhIdQ3X5kW6LeScmvdz5crjy1STQCXAlY1St
U9Cavy0g78jKumyev0PA
=Xp24
-----END PGP SIGNATURE-----

--7mqomjgivpyllpcv--

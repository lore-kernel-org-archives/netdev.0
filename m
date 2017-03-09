From: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/7] net: stmmac: Balance PTP reference clock
 enable/disable
Date: Thu, 9 Mar 2017 20:30:12 +0100
Message-ID: <20170309193012.GB5554@ulmo.ba.sec>
References: <20170223172438.14770-1-thierry.reding@gmail.com>
 <20170223172438.14770-3-thierry.reding@gmail.com>
 <53f18077-6a4d-339f-192e-287a1f889fb7@kapsi.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="p4qYPpj5QlsIQJ0K"
Cc: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
        Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Jon Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mikko Perttunen <cyndis-/1wQRMveznE@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <53f18077-6a4d-339f-192e-287a1f889fb7-/1wQRMveznE@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--p4qYPpj5QlsIQJ0K
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 27, 2017 at 11:31:39AM +0200, Mikko Perttunen wrote:
> On 23.02.2017 19:24, Thierry Reding wrote:
> > From: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
> >=20
> > clk_prepare_enable() and clk_disable_unprepare() for this clock aren't
> > properly balanced, which can trigger a WARN_ON() in the common clock
> > framework.
> >=20
> > Signed-off-by: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
> > ---
> >  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     | 4 ++++
> >  drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 1 -
> >  2 files changed, 4 insertions(+), 1 deletion(-)
> >=20
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/driver=
s/net/ethernet/stmicro/stmmac/stmmac_main.c
> > index 3cbe09682afe..6b7a5ce19589 100644
> > --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> > +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> > @@ -1711,6 +1711,10 @@ static int stmmac_hw_setup(struct net_device *de=
v, bool init_ptp)
> >  	stmmac_mmc_setup(priv);
> >=20
> >  	if (init_ptp) {
> > +		ret =3D clk_prepare_enable(priv->plat->clk_ptp_ref);
> > +		if (ret < 0)
> > +			netdev_warn(priv->dev, "failed to enable PTP reference clock: %d\n"=
, ret);
> > +
>=20
> Should we return an error code if the clock enable fails?

Yeah, that's probably a good idea.

> >  		ret =3D stmmac_init_ptp(priv);
> >  		if (ret =3D=3D -EOPNOTSUPP)
> >  			netdev_warn(priv->dev, "PTP not supported by HW\n");
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/dr=
ivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> > index 5b18355c0d2b..d285d6cfbd0d 100644
> > --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> > +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> > @@ -365,7 +365,6 @@ stmmac_probe_config_dt(struct platform_device *pdev=
, const char **mac)
> >  		plat->clk_ptp_ref =3D NULL;
> >  		dev_warn(&pdev->dev, "PTP uses main clock\n");
> >  	} else {
> > -		clk_prepare_enable(plat->clk_ptp_ref);
> >  		plat->clk_ptp_rate =3D clk_get_rate(plat->clk_ptp_ref);
> >  		dev_dbg(&pdev->dev, "PTP rate %d\n", plat->clk_ptp_rate);
> >  	}
> >=20
>=20
> It seems like there will still be a refcount mismatch for the clock if any
> of the request_irqs that are after stmmac_hw_setup in stmmac_open fail.

Looks like there's a few more things that could be cleaned up on failure
to request those interrupts. I've added another patch to the series that
will attempt to do this.

Thierry

--p4qYPpj5QlsIQJ0K
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIyBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljBrUQACgkQ3SOs138+
s6HKdg/452olRbI3ZQXVCtnn/Zlw9rzOaGMA19mcDhHTOdwP+c1PkJpxpTOvSEMw
4mkq3fs3U6IanszokGNI7lA2/ZV3N2hb2yEN9ysX6qwSEAbBJ/IxeYuOjheF8Qtc
sPjpWqgjXjraCZjtEE9rtd83EK1RzYRR8lLOq13vgAdpybSDivZBlLj5NXVjav/v
90yLlXF7HmwbuYiSs18Agt8AYcLU5oP1ORh+MpumAvHcTGbdBlgD0YP9fgDIebOH
ocvWv1WSZqv7e0wV9wflL98upnZ0qWC2NvGwjKfm00keso0ir0s8Qx7MhLPRH/AS
IgUl30c5LwVVxkiBE0W3w64TWOxw/tC9QXR8L4+gf9o05cONquoChjAbTznueOGV
6PHN6rNL1GK5HBxMvWO9nhfJ0wkY47EupzIJDiU+ZuKWZyarOv23qzoo/L+iEVst
F0j3LjFx4+rCxgWx+WQg3+w9+esHH7B0HR5/Jd8LbiAuKLv4YifhJou2FBIwMbdo
/FG7m5wubfCruJxDhMZMmNnQtGB7vsVLA4ezSzVW6UdVAp2y8uEGE9fxfGRap0/s
TJS0IkZ7Q9AgQK4VMOzIIqCX5AslTlERFDNe/WpOyeFGeVzeAyTIq7KyFgWRXtOc
tAoeBKXYv1g9BNsqOzFY4M510RdmixxLOOhX2hkjgqasIt7Dxw==
=UQBB
-----END PGP SIGNATURE-----

--p4qYPpj5QlsIQJ0K--

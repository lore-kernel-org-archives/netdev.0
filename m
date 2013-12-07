From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 04/10] net: stmmac: sunxi platfrom
 extensions for GMAC in Allwinner A20 SoC's
Date: Sat, 7 Dec 2013 12:46:16 +0100
Message-ID: <20131207114616.GM24519@lukather>
References: <1386350983-13281-1-git-send-email-wens@csie.org>
 <1386350983-13281-5-git-send-email-wens@csie.org>
 <20131207102710.GK24519@lukather>
 <2030454.PFLhh6xOPI@flatron>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Nj4mAaUCx+wbOcQD"
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, Mike Turquette <mturquette-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Srinivas Kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>
To: Tomasz Figa <tomasz.figa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBD2ZNBF5VYJRBDMXRSKQKGQE64J32XQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <2030454.PFLhh6xOPI@flatron>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


--Nj4mAaUCx+wbOcQD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Dec 07, 2013 at 12:12:26PM +0100, Tomasz Figa wrote:
> On Saturday 07 of December 2013 11:27:10 Maxime Ripard wrote:
> > Chen-Yu, Mike,
> >=20
> > On Sat, Dec 07, 2013 at 01:29:37AM +0800, Chen-Yu Tsai wrote:
> > > The Allwinner A20 has an ethernet controller that seems to be
> > > an early version of Synopsys DesignWare MAC 10/100/1000 Universal,
> > > which is supported by the stmmac driver.
> > >=20
> > > Allwinner's GMAC requires setting additional registers in the SoC's
> > > clock control unit.
> > >=20
> > > The exact version of the DWMAC IP that Allwinner uses is unknown,
> > > thus the exact feature set is unknown.
> > >=20
> > > Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
> > > ---
> > >  .../bindings/net/allwinner,sun7i-gmac.txt          | 22 +++++++
> > >  drivers/net/ethernet/stmicro/stmmac/Kconfig        | 12 ++++
> > >  drivers/net/ethernet/stmicro/stmmac/Makefile       |  1 +
> > >  drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c  | 76 ++++++++++++=
++++++++++
> > >  drivers/net/ethernet/stmicro/stmmac/stmmac.h       |  3 +
> > >  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  3 +
> > >  6 files changed, 117 insertions(+)
> > >=20
> > > diff --git a/Documentation/devicetree/bindings/net/allwinner,sun7i-gm=
ac.txt b/Documentation/devicetree/bindings/net/allwinner,sun7i-gmac.txt
> > > new file mode 100644
> > > index 0000000..271554a
> > > --- /dev/null
> > > +++ b/Documentation/devicetree/bindings/net/allwinner,sun7i-gmac.txt
> > > @@ -0,0 +1,22 @@
> > > +* Allwinner GMAC ethernet controller
> > > +
> > > +This device is a platform glue layer for stmmac.
> > > +Please see stmmac.txt for the other unchanged properties.
> > > +
> > > +Required properties:
> > > + - compatible:  Should be "allwinner,sun7i-gmac"
> >=20
> > Please use sun7i-a20-gmac here.
> >=20
> > > + - reg: Address and length of register set for the device and corres=
ponding
> > > +   clock control
> > >
> > > +Examples:
> > > +
> > > +	gmac: ethernet@01c50000 {
> > > +		compatible =3D "allwinner,sun7i-gmac";
> > > +		reg =3D <0x01c50000 0x10000>,
> > > +		      <0x01c20164 0x4>;
> >=20
> > This is actually a clock, and should probably be registered in the
> > common clock framework.
> >=20
> > Mike: This small register actually is a regular muxer/divider, except
> > that it has some bits that are of interest to the ethernet controller
> > (for example to set wether it's using GMII or RGMII to communicate
> > with the phy), that, as far as I'm aware of, aren't really fitting
> > into the CCF.
> >=20
> > Do you have some recommendation on how to proceed?
> >=20
> > Maybe make a thin "real" clock driver in this hardware glue, that
> > provides !exported function to set this *GMII thing.
>=20
> Is this register part of a bigger IP block that manages clocks for other
> IP blocks than stmmac as well? If not, I don't see a point of exporting
> a clock from inside of the GMAC "domain" just to feed it back into it
> as the only user.

This register is actually part of the SoC clock controller. So it sits
right beside the other clocks registers controlling the clocks of the
other devices, and is not part of the GMAC IP itself.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--Nj4mAaUCx+wbOcQD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSowqHAAoJEBx+YmzsjxAgjZ4P/Ahc9ly8rsz058FrSITAIsOi
8LhTZ8APxfaed9n5GaenDT1tjwuSzBVVUrUrjtb8UvreFgX8r1c8FionF2fuQi3a
Ywj6Cfc2Wz2QCKPOJAqNM+SJh5vTAmgVwFm+UK1dMw1ZhsTJzX0tSrT2Xr6TFVBd
bG1+l7GObEVopkGHuEx9bOAkWq0T1XFEHy1r0X9LAFV4ZN5h8sl30E6/vbaJM8qb
khYtwWQ9ROnvqQFyBpq7SPb7Hq4t1wLx1m3d/Jx+S3XlrbXJq4lDnEFHoJHJrZrk
+u9OHp1vqojesD010TKOk2n06LjKbqOwSqxzpg71Ne4JSIukfnwDpDsTagpRMII6
ft6clTqU1PCNwf+qEJpaxcKSnzbjmD6vKfnE1nMZU9wR1koga9HgE7WMvSAYuZtS
XhDRhEt+8pdL0alRVeczNfJWQ03c3a2JMBKYmpkIcbAy0sdwc54AxxEKHQUlz8+G
cszxxVlrKfj2WqPTpE1yRk1lEmL43zHGle1hBcSvh8Y+LOHVwBWuVH/87WreWoaj
1NQzqfoq/zi90LPhjsGtE8zlWQ6A5Bu1E59Yithnn84uPiNBUMy77h/kpEDBClCs
oSOkpoupNyWpRJmwSYhdeEMtM6LvxzBvqOGVChvlibdH7MwYZFK0qpQeO6td6PW+
d3Au/JRyy6ptoWJe6/UB
=qqDB
-----END PGP SIGNATURE-----

--Nj4mAaUCx+wbOcQD--

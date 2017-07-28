From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v2 05/11] net: stmmac: dwmac-rk: Add internal phy support
Date: Fri, 28 Jul 2017 09:39:36 +0200
Message-ID: <20170728073936.jwgrq2z2nd3dqrti@flea.home>
References: <1501160156-30328-1-git-send-email-david.wu@rock-chips.com>
 <1501160540-30662-1-git-send-email-david.wu@rock-chips.com>
 <20170727134834.GD18666@lunn.ch>
 <65ae1747-4dff-b1d8-8aa3-684fc8c7809a@gmail.com>
 <20170727173152.GA16362@Red>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="mb5t67vs5o3drojx"
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, hwg-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
        huangtao-TNX95d0MmH7DzftRWevZcw@public.gmane.org, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        olof-nZhT3qVonbNeoWH0uzbU5w@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org
To: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170727173152.GA16362@Red>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--mb5t67vs5o3drojx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 27, 2017 at 07:31:52PM +0200, Corentin Labbe wrote:
> On Thu, Jul 27, 2017 at 09:54:01AM -0700, Florian Fainelli wrote:
> > On 07/27/2017 06:48 AM, Andrew Lunn wrote:
> > > On Thu, Jul 27, 2017 at 09:02:16PM +0800, David Wu wrote:
> > >> To make internal phy work, need to configure the phy_clock,
> > >> phy cru_reset and related registers.
> > >>
> > >> Signed-off-by: David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
> > >> ---
> > >> changes in v2:
> > >>  - Use the standard "phy-mode" property for internal phy. (Florian)
> > >=20
> > > I think we need to discuss this. This PHY appears to be on an MDIO
> > > bus, it uses a standard PHY driver, and it appears to be using an RMII
> > > interface. So it is just an ordinary PHY.
> >=20
> > First, the fact that the internal PHY also appears through MDIO is
> > orthogonal to the fact that it is internal or external. Plenty of
> > designs have internal PHYs exposed through MDIO because that is
> > convenient. What matters though is how the data/clock lines are wired
> > internally, which is what "phy-mode" describes.
> >=20
> > >=20
> > > Internal is supposed to be something which is not ordinary, does not
> > > use one of the standard phy modes, needs something special to make it
> > > work.
> > >=20
> > > Florain, it appears to be your suggestion to use internal. What do you
> > > say?
> >=20
> > phy-mode =3D "internal" really means that it is not a standard MII vari=
ant
> > to connect the data/clock lines between the Ethernet MAC and the PHY,
> > and this can happen in some designs (although quite unlikely). So from
> > there we could do several things depending on the requirements:
> >=20
> > - if you can have your Ethernet MAC driver perform the necessary
> > configuration *after* you have been able to bind the PHY device with its
> > PHY driver, then the PHY driver should have PHY_IS_INTERNAL in its
> > flags, and you can use phy_is_internal() from PHYLIB to tell you that
> > and we could imagine using: phy-mode =3D "rmii" because that would not =
too
> > much of a stretch
> >=20
> > - if you need knowledge about this PHY connection type prior to binding
> > the PHY device and its driver (that is, before of_phy_connect()) we
> > could add a boolean property e.g: "phy-is-internal" that allows us to
> > know that, or we can have a new phy-mode value, e.g: "internal-rmii"
> > which describes that, either way would probably be fine, but the former
> > scales better
>=20
> We have the same problem on Allwinner SoCs for dwmac-sun8i, we need
> to set a syscon for chossing between internal/external PHY.
>
> Having this phy-is-internal would be very helpfull. (adding
> internal-xmii will add too many flags in our case)

In our case, we'll always have a phy node, so we can have a compatible
that will give you the same information.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--mb5t67vs5o3drojx
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZeuo3AAoJEBx+YmzsjxAght0P/AuvCotYX0025UWZZda9LYAD
HveAFwH6Q2WjDt8iNE9nVW9OUGX30FrPCYnSHSoLha2RQKisFIrjbDUFmFWV/eWZ
HqujLkqWoXJvW8cOaoCqBPHW9FiZFe09Q9dkVpR0JHL8gmhVeCD43T24YMavVlx9
fgkGZy/XKbLUmYHG/iFwIqrHjwOGghaeuit2XuMW4vcfH1xzjp0LCkpfVJ7u4a7l
QJZAY6AVidJ2wFiS8pPtkjHyAnG/z1S4CEaiSmXgf2v859j7ZMshr4PeYEE16qMd
mY/jjuYDNV7XjbeL3J8kmDugNRMLFgAs340qeDbnES0OSPQ+oSwdhAN7TzM5hYk7
/x+xZ+tEcCjgZE6vqkOTlIZvRxIJpyIntBJsPc+7nHENTaJ28doBE3XvBxJsh75u
dsiFxGyDZLbz/KHC8m6jidtNWrmwWeGdSIp3oQdIPdpaxhvGxHAyDaMKs7qE9MFh
sxSoVJEpxawQunapseMeMUooENn9uAFTHRPkD+DyZaeJ0lGsXOBIELFCxOcvrrKZ
dXvio4bxSJeqwgcN3cUqGn+WF2dP2zUo63PIi6h7vgrBlD0fEf3DNtcQBW5BQHs9
JBXAQo4eGAvCJbi1+ACllwuF6mGJWLCH6CQ+siQX2iTP4l/Xm45ZmmbGqlm8m0zt
IJzVAkOHq7WrCO7borhp
=T/3W
-----END PGP SIGNATURE-----

--mb5t67vs5o3drojx--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH v2 0/5] Generic PHY Framework
Date: Tue, 19 Feb 2013 15:12:58 +0200
Message-ID: <20130219131258.GV23197@arwen.pp.htv.fi>
References: <1361253198-7401-1-git-send-email-kishon@ti.com>
 <201302191044.28653.arnd@arndb.de>
 <512361F0.1070500@ti.com>
 <201302191233.54677.arnd@arndb.de>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fCmRXBY78W5odcVA"
Cc: kishon <kishon@ti.com>, <rob@landley.net>, <tony@atomide.com>,
	<linux@arm.linux.org.uk>, <eballetbo@gmail.com>,
	<javier@dowhile0.org>, <balbi@ti.com>,
	<gregkh@linuxfoundation.org>, <akpm@linux-foundation.org>,
	<mchehab@redhat.com>, <cesarb@cesarb.net>, <davem@davemloft.net>,
	<santosh.shilimkar@ti.com>, <broonie@opensource.wolfsonmicro.com>,
	<swarren@nvidia.com>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201302191233.54677.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--fCmRXBY78W5odcVA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Tue, Feb 19, 2013 at 12:33:54PM +0000, Arnd Bergmann wrote:
> On Tuesday 19 February 2013, kishon wrote:
> > On Tuesday 19 February 2013 04:14 PM, Arnd Bergmann wrote:
> > > On Tuesday 19 February 2013, Kishon Vijay Abraham I wrote:
> > >> Added a generic PHY framework that provides a set of APIs for the PH=
Y drivers
> > >> to create/destroy a PHY and APIs for the PHY users to obtain a refer=
ence to
> > >> the PHY with or without using phandle. To obtain a reference to the =
PHY
> > >> without using phandle, the platform specfic intialization code (say =
=66rom board
> > >> file) should have already called phy_bind with the binding informati=
on. The
> > >> binding information consists of phy's device name, phy user device n=
ame and an
> > >> index. The index is used when the same phy user binds to mulitple ph=
ys.
> > >>
> > >> This framework will be of use only to devices that uses external PHY=
 (PHY
> > >> functionality is not embedded within the controller).
> > >>
> > >> The intention of creating this framework is to bring the phy drivers=
 spread
> > >> all over the Linux kernel to drivers/phy to increase code re-use and=
 to
> > >> increase code maintainability.
> > >>
> > >> Comments to make PHY as bus wasn't done because PHY devices can be p=
art of
> > >> other bus and making a same device attached to multiple bus leads to=
 bad
> > >> design.
> > >
> > > How does this relate to the generic PHY interfaces in drivers/net/phy?
> >=20
> > Currently drivers/phy and drivers/net/phy are independent and are not=
=20
> > related to each other. There are some fundamental differences on how=20
> > these frameworks work. IIUC, the *net* uses bus layer (MDIO bus) to=20
> > match a PHY device with a PHY driver and the Ethernet device uses the=
=20
> > bus layer to get the PHY.
> > The Generic PHY Framework however doesn't have any bus layer. The PHY=
=20
> > should be like any other Platform Devices and Drivers and the framework=
=20
> > will provide some APIs to register with the framework. And there are=20
> > other APIs which any controller can use to get the PHY (for e.g., in th=
e=20
> > case of dt boot, it can use phandle to get a reference to the PHY).
>=20
> Hmm, I think the use of a bus_type for a PHY actually sounds quite
> appropriate. The actual PHY device would then be a child of the

really ? I'm not so sure, the *bus* used by the PHY is ULPI, UTMI,
UTMI+, PIP3, I2C, etc... adding another 'fake' bus representation is a
bit overkill IMO.

Imagine an I2C-controlled PHY driver like isp1301, that driver will have
to register i2c_driver and phy_driver, which looks weird to me. If the
only substitute for class is a bus, we can't drop classes just yet, I'm
afraid.

Imagine a regulator bus, a pwm bus, an LED bus etc. They don't make
sense IMHO.

> platform_device (or something else) that gets probed by its parent
> bus or the DT. The operations that you define for the PHY
> actually mirror some of the things that we have for a 'struct device',
> so I think it would be quite logical to do it the same way.
>=20
> Note that MDIO has both a 'bus' and a 'class', and what we want here is m=
ore
> like what the 'class' was meant for, except that for new classes, we
> should actually use a 'bus', since the long-term plan is to kill off
> the concept of a 'class'. I hope that was not too confusing. :)

:)

--=20
balbi

--fCmRXBY78W5odcVA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRI3pZAAoJEIaOsuA1yqRERKkP/RH8Q7YwqdCtERF9W5S1lWTY
EqTvOOCto0Ijdyg203y384O2ECY9U57KZrCFdN/j+e3PDKc99FDpa5MC03xNa18R
0QxZdyDotPNq5tGdH6uJEqsS2iDixVjSGb0O/vnie1F+VMNhoDELXJB8NQGG1UjN
Gec7eY6kc47HKSJrNSRybueYqLWSUIEUj0DscA2J+fT2LBH5vUfcjPutCz4Aa2aS
Gi9jUUJ7M7bVdpHMP4PvcKu9svRmbAyztyZTGpjcoDdbod1q0DnMO5SkXnlo/eRt
LXvK5RApTnRmvLyvS+CRjzvW+yo1/bh/xPxHfe6Gn24WqxoNCeWCq0Uq2CrWMeME
K2XMMcVineXpIGaj1B76NkLVF8q/j0Y0bLmibjyeilFxaubZKzPCc2Aw7BbZEe1H
5W7vizCMtYcEy0jeAKrEkKszS465y6326lf0UUtBlce1hDw7CoAFQklgWwvluelT
NIuEb2iuBSk4F4zNH1teDpSLwDD+P14/ugLyFAN3OIQMGQYsczXCKiHdPQJf09mD
mzXOYalYNEZEJEV9ZHX0mNmb4YFqhAgLsf3g4qrc06JMbTJvqAUrg5SSOYIXEAWz
xs0E5lP93HV9+8G84HUyk/10e5Huq0x3mIeuMV3hwgHSK4HMQIAIMeUHomnK83ry
XwpUKLLRfYvFguzidRsY
=UZg3
-----END PGP SIGNATURE-----

--fCmRXBY78W5odcVA--

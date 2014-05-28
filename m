From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH v2 1/4] devicetree: bindings: Properly document micrel
 ks8851 SPI chips
Date: Wed, 28 May 2014 18:12:19 +0100
Message-ID: <20140528171219.GD5099@sirena.org.uk>
References: <1400875040-13269-1-git-send-email-sboyd@codeaurora.org>
 <1400875040-13269-2-git-send-email-sboyd@codeaurora.org>
 <20140524124858.GR22111@sirena.org.uk>
 <5385063F.30407@codeaurora.org>
 <20140528151646.GU20155@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="uxuisgdDHaNETlh8"
Cc: Stephen Boyd <sboyd@codeaurora.org>,
	"David S . Miller" <davem@davemloft.net>,
	Nishanth Menon <nm@ti.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	linux-arm-msm@vger.kernel.org, Kumar Gala <galak@codeaurora.org>,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	Rob Herring <robh+dt@kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140528151646.GU20155@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--uxuisgdDHaNETlh8
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, May 28, 2014 at 05:16:46PM +0200, Uwe Kleine-K=F6nig wrote:
> On Tue, May 27, 2014 at 02:40:15PM -0700, Stephen Boyd wrote:
> > On 05/24/14 05:48, Mark Brown wrote:

> > > So, according to the datasheet I managed to find this device has a
> > > supply VDD_IO (so normally written vdd-io-supply here), some other
> > > supplies which are tied to VDD_IO (so can probably be omitted) and a
> > > supply VDD_A3.3 none of which are optional.  There is an internal
> > > regulator which can be used to drop a higher voltage VDD_IO down for
> > > some of the supplies tied to it but that's essentially a noop from
> > > software as far as I can tell.  None of these supplies are obviously
> > > optional, though I've not read the datasheet in detail so I may have
> > > missed something here.

> There is a difference between the supply being optional for the hardware
> to work and the need to specify it in the device tree, isn't it? My
> expectation is that when it's not specified there is just nothing the
> the software needs to care for.=20

If the supply must always be physically present the bindings should be
specified as it being mandatory and the code written in that fashion; as
an extension Linux will put a dummy in but this is attempting to handle
incorrect DTs.  This means we have functional error handling in cases
where there is something to worry about and simplifies the code using
the regulator.

regulator_get_optional() should *only* be used if the supply may be
omitted from the physical design and should generally always be
accompanied by code which does something substantially different such as
using an internal regulator or changing the source for a reference
voltage instead.

> > > That said it looks like this is intended to be a supply for an extern=
al
> > > PHY rather than the device itself, but even so my original question
> > > about it being able to operate without power still applies.  Looking =
at
> > > the code it's certainly not doing any of the handling of a missing
> > > supply that I would associate with using _optional().

> > I agree, both supplies don't look optional. Unfortunately
> > efm32gg-dk3750.dts doesn't look to be listing any supply, and this
> > driver only recently got support for the VDD_A3.3 supply that the omap
> > board uses (adding Uwe for any comments on efm setup). I presume on

> If I read the schematic correctly there is nothing to regulate on the
> efm32 dev board. If you want to take a look on the schematic yourself,
> it's contained in the documentation package available at
> http://www.silabs.com/products/mcu/lowpower/pages/efm32gg-dk3750.aspx .
> BDR3201A_A02_sch.pdf, page 3 of 22.

That shows all the supplies connected to fixed voltage regulators
(including the internal 1.8V LDO); the device tree should represent this
accurately though the internal 1.8V regulator could be omitted for
simplicity.  It would be a remarkable device that was able to operate
without power.

--uxuisgdDHaNETlh8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJThhjwAAoJELSic+t+oim9UZMP+gIUErotQjc3rwuMwlYzLDNs
lKkRj1LfCKyl1tzmLxhNwf/cJw2OA1p8/3mLYn8yPx4lamm3iMZzsURDVCE98U0H
uZVv7pzwweBMfi1qX9zp3DsSUycbGliSkKWG9QdB+TRYQNd92IKYuhWemVmcKzxF
xTQ36t2xsGC9dpb+9WWapnx2EOg7j4fifECax1c4WJFUsihlntRV/dAHCUWDpE3X
ppfxkstYJcfnL/xqwNM7GOAvJFKg/fTneCEzuKJ2s/fo/MbdmRHWt4X53it974Y0
WpmUCR6as6al0ZHshda4qvzhs8ElAdL6C7KUbRW4WvvpVSu6h2bRtvKMm/6fMuSd
awUIslyqU9ObPY8nh/8I5SuTvYlvy4iO9C5HVlxLtfSB0T26Ei7MaT3PitEe7d2C
L/Nj19MEkoahWgW2pu7M9yGpw1iUFPI6vxFDqaeA/omb7LF4E34QhB/AwbtNXK9o
/FqeD+UrsTgXeoh2vnV6S7RvH4tTcyIX4xryr6g3xtjxji0wa3me02G3zvjLYLcp
MQUF4oCElBrchGU6/urKxtWPLUi2X2PiXBOlJ8PBsbdgO/TGUTPRplHM1BebTADm
DWgPisiq9DEm/gVPmkwW9L6QLBgVx6SShNNSPz6lbjhWr8oZi7Gzbnh6PwWjAQ7Y
LciNhsSYfhqHf0gfN/dp
=TSUP
-----END PGP SIGNATURE-----

--uxuisgdDHaNETlh8--

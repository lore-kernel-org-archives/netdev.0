From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v2 1/4] devicetree: bindings: Properly document micrel
 ks8851 SPI chips
Date: Wed, 28 May 2014 17:16:46 +0200
Message-ID: <20140528151646.GU20155@pengutronix.de>
References: <1400875040-13269-1-git-send-email-sboyd@codeaurora.org>
 <1400875040-13269-2-git-send-email-sboyd@codeaurora.org>
 <20140524124858.GR22111@sirena.org.uk>
 <5385063F.30407@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mark Brown <broonie@kernel.org>,
	"David S . Miller" <davem@davemloft.net>,
	Nishanth Menon <nm@ti.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	linux-arm-msm@vger.kernel.org, Kumar Gala <galak@codeaurora.org>,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	Rob Herring <robh+dt@kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Stephen Boyd <sboyd@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5385063F.30407@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Stephen,

On Tue, May 27, 2014 at 02:40:15PM -0700, Stephen Boyd wrote:
> On 05/24/14 05:48, Mark Brown wrote:
> > On Fri, May 23, 2014 at 12:57:17PM -0700, Stephen Boyd wrote:
> >
> >>  Optional properties:
> >> -- vdd-supply:	supply for Ethernet mac
> >> +- vdd-supply: analog 3.3V supply for Ethernet mac
> >> +- vdd-io-supply: digital 1.8V IO supply for Ethernet mac
> > So, according to the datasheet I managed to find this device has a
> > supply VDD_IO (so normally written vdd-io-supply here), some other
> > supplies which are tied to VDD_IO (so can probably be omitted) and =
a
> > supply VDD_A3.3 none of which are optional.  There is an internal
> > regulator which can be used to drop a higher voltage VDD_IO down fo=
r
> > some of the supplies tied to it but that's essentially a noop from
> > software as far as I can tell.  None of these supplies are obviousl=
y
> > optional, though I've not read the datasheet in detail so I may hav=
e
> > missed something here.
There is a difference between the supply being optional for the hardwar=
e
to work and the need to specify it in the device tree, isn't it? My
expectation is that when it's not specified there is just nothing the
the software needs to care for.=20

> > That said it looks like this is intended to be a supply for an exte=
rnal
> > PHY rather than the device itself, but even so my original question
> > about it being able to operate without power still applies.  Lookin=
g at
> > the code it's certainly not doing any of the handling of a missing
> > supply that I would associate with using _optional().
>=20
> I agree, both supplies don't look optional. Unfortunately
> efm32gg-dk3750.dts doesn't look to be listing any supply, and this
> driver only recently got support for the VDD_A3.3 supply that the oma=
p
> board uses (adding Uwe for any comments on efm setup). I presume on
If I read the schematic correctly there is nothing to regulate on the
efm32 dev board. If you want to take a look on the schematic yourself,
it's contained in the documentation package available at
http://www.silabs.com/products/mcu/lowpower/pages/efm32gg-dk3750.aspx .
BDR3201A_A02_sch.pdf, page 3 of 22.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |

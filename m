From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 02/13] net: mvneta: enable IP checksum with jumbo frames for Armada 38x on Port0
Date: Sun, 22 Nov 2015 22:32:33 +0100
Message-ID: <5578695.0ahxvoVWDX@wuerfel>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com> <4040597.3hXVb3XDMS@wuerfel> <CAPv3WKdOVf4kXHfrawgybggHggAEJ9wJh=8gyp_mEhWp2i=YFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Marcin Wojtas <mw@semihalf.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	Simon Guinot <simon.guinot@sequanux.org>,
	linux-kernel@vger.kernel.org, Evan Wang <xswang@marvell.com>,
	nadavh@marvell.com, nitroshift@yahoo.com,
	Lior Amsalem <alior@marvell.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	Grzegorz Jaszczyk <jaz@semihalf.com>,
	Gregory =?ISO-8859-1?Q?Cl=E9ment?=
	<gregory.clement@free-electrons.com>,
	Tomasz Nowicki <tn@semihalf.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Yair Mahalalel <myair@marvell.com>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPv3WKdOVf4kXHfrawgybggHggAEJ9wJh=8gyp_mEhWp2i=YFw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 22 November 2015 22:04:38 Marcin Wojtas wrote:
> 2015-11-22 21:00 GMT+01:00 Arnd Bergmann <arnd@arndb.de>:
> > On Sunday 22 November 2015 08:53:48 Marcin Wojtas wrote:
> >> The Ethernet controller found in the Armada 38x SoC's family support
> >> TCP/IP checksumming with frame sizes larger than 1600 bytes, however
> >> only on port 0.
> >>
> >> This commit enables this feature by using 'marvell,armada-xp-neta' in
> >> 'ethernet@70000' node.
> >>
> >> Signed-off-by: Marcin Wojtas <mw@semihalf.com>
> >> Cc: <stable@vger.kernel.org> # v3.18+
> >> ---
> >>  arch/arm/boot/dts/armada-38x.dtsi | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/arch/arm/boot/dts/armada-38x.dtsi b/arch/arm/boot/dts/armada-38x.dtsi
> >> index c6a0e9d..b7868b2 100644
> >> --- a/arch/arm/boot/dts/armada-38x.dtsi
> >> +++ b/arch/arm/boot/dts/armada-38x.dtsi
> >> @@ -494,7 +494,7 @@
> >>                         };
> >>
> >>                         eth0: ethernet@70000 {
> >> -                               compatible = "marvell,armada-370-neta";
> >> +                               compatible = "marvell,armada-xp-neta";
> >>                                 reg = <0x70000 0x4000>;
> >>                                 interrupts-extended = <&mpic 8>;
> >>                                 clocks = <&gateclk 4>;
> >>
> >
> > As it's clear that they are not 100% backwards compatible, please
> > add a SoC specific compatible string here as well, like
> >
> >         compatible = "marvell,armada-380-neta", "marvell,armada-xp-neta";
> >
> 
> Wouldn't be one sufficient ("marvell,armada-380-neta")?

If they are basically compatible, you want to the original one in,
to make sure it keeps running on operating systems that only know
about the older string.

> > Maybe also leave the 370 string in place.
> >
> 
> Now 370 string disables ip checksum for jumbo frames, so I don't think
> it's appropriate to keep it for port 0.

Ok, I see. We should probably have done it the other way round and
kept the default as checksum-disabled and only override it when
the newer compatible string is also present. Basically the device
*is* compatible to an Armada 370, it just has additional features that
work correctly.

If the feature set depends on the port number, we should think about
the way it gets handled again, as this is probably better not described
as something that depends (just) on the SoC, but on the way it gets
integrated. Maybe we can introduce an additional property for the
checksums on jumbo frames and use that if present but fall back to
identifying by compatible string otherwise.

	Arnd

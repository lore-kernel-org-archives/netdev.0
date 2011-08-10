From: U Bhaskar-B22300 <B22300@freescale.com>
Subject: RE: [PATCH v10 5/5] [powerpc] Fix up fsl-flexcan device tree
 binding.
Date: Wed, 10 Aug 2011 14:36:20 +0000
Message-ID: <9C64B7751C3BCA41B64A68E23005A7BE1C6A21@039-SN1MPN1-002.039d.mgd.msft.net>
References: <1312945564-6626-1-git-send-email-holt@sgi.com>
 <1312945564-6626-6-git-send-email-holt@sgi.com>
 <4E428BFF.7060402@grandegger.com> <20110810141550.GQ4926@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Wood Scott-B07421 <B07421@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kumar Gala <galak@kernel.crashing.org>,
	"socketcan-core@lists.berlios.de" <socketcan-core@lists.berlios.de>,
	PPC list <linuxppc-dev@lists.ozlabs.org>
To: Robin Holt <holt@sgi.com>, Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:57975 "EHLO
	TX2EHSOBE007.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922Ab1HJOgZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2011 10:36:25 -0400
In-Reply-To: <20110810141550.GQ4926@sgi.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Robin Holt [mailto:holt@sgi.com]
> Sent: Wednesday, August 10, 2011 7:46 PM
> To: Wolfgang Grandegger
> Cc: Robin Holt; Marc Kleine-Budde; U Bhaskar-B22300; Wood Scott-B07421;
> netdev@vger.kernel.org; Kumar Gala; socketcan-core@lists.berlios.de; PPC
> list
> Subject: Re: [PATCH v10 5/5] [powerpc] Fix up fsl-flexcan device tree
> binding.
> 
> On Wed, Aug 10, 2011 at 03:47:43PM +0200, Wolfgang Grandegger wrote:
> > Hi Robin,
> >
> > On 08/10/2011 05:06 AM, Robin Holt wrote:
> > > In working with the socketcan developers, we have come to the
> > > conclusion the Documentation...fsl-flexcan.txt device tree
> > > documentation needs to be cleaned up.  The driver does not depend
> > > upon any properties other
> >
> > Your first sentence could be misleading. Please just describe what the
> > patch does and why, something like:
> >
> > "This patch cleans up the documentation of the device-tree binding for
> > the Flexcan devices on Freescale's PowerPC and ARM cores. Extra
> > properties are not needed as the frequency of the source clock is
> > fixed..." and so on.
> 
> I borrowed heavily from your message. ;)
> 
> > > than the required properties so we are removing the file.
> > > Additionally, the p1010*dts* files are not following the standard
> > > for node naming in that they have a trailing -v1.0.
> >
> > > Signed-off-by: Robin Holt <holt@sgi.com>
> > > To: Marc Kleine-Budde <mkl@pengutronix.de>,
> > > To: Wolfgang Grandegger <wg@grandegger.com>,
> > > To: U Bhaskar-B22300 <B22300@freescale.com>
> > > To: Scott Wood <scottwood@freescale.com>
> > > Cc: socketcan-core@lists.berlios.de,
> > > Cc: netdev@vger.kernel.org,
> > > Cc: PPC list <linuxppc-dev@lists.ozlabs.org>
> > > Cc: Kumar Gala <galak@kernel.crashing.org>
> > > ---
> > >  .../devicetree/bindings/net/can/fsl-flexcan.txt    |   61 ----------
> ----------
> > >  arch/powerpc/boot/dts/p1010rdb.dts                 |    8 ---
> > >  arch/powerpc/boot/dts/p1010si.dtsi                 |    8 +-
> > >  3 files changed, 4 insertions(+), 73 deletions(-)  delete mode
> > > 100644 Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
> > >
> > > diff --git
> > > a/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
> > > b/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
> > > deleted file mode 100644
> > > index 1a729f0..0000000
> > > --- a/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
> > > +++ /dev/null
> > > @@ -1,61 +0,0 @@
> > > -CAN Device Tree Bindings
> > > -------------------------
> > > -2011 Freescale Semiconductor, Inc.
> > > -
> > > -fsl,flexcan-v1.0 nodes
> > > ------------------------
> > > -In addition to the required compatible-, reg- and
> > > interrupt-properties, you can -also specify which clock source shall
> be used for the controller.
> > > -
> > > -CPI Clock- Can Protocol Interface Clock
> > > -	This CLK_SRC bit of CTRL(control register) selects the clock source
> to
> > > -	the CAN Protocol Interface(CPI) to be either the peripheral clock
> > > -	(driven by the PLL) or the crystal oscillator clock. The selected
> clock
> > > -	is the one fed to the prescaler to generate the Serial Clock
> (Sclock).
> > > -	The PRESDIV field of CTRL(control register) controls a prescaler
> that
> > > -	generates the Serial Clock (Sclock), whose period defines the
> > > -	time quantum used to compose the CAN waveform.
> > > -
> > > -Can Engine Clock Source
> > > -	There are two sources for CAN clock
> > > -	- Platform Clock  It represents the bus clock
> > > -	- Oscillator Clock
> > > -
> > > -	Peripheral Clock (PLL)
> > > -	--------------
> > > -		     |
> > > -		    ---------		      -------------
> > > -		    |       |CPI Clock	      | Prescaler |       Sclock
> > > -		    |       |---------------->| (1.. 256) |------------>
> > > -		    ---------		      -------------
> > > -                     |  |
> > > -	--------------  ---------------------CLK_SRC
> > > -	Oscillator Clock
> > > -
> > > -- fsl,flexcan-clock-source : CAN Engine Clock Source.This property
> selects
> > > -			     the peripheral clock. PLL clock is fed to the
> > > -			     prescaler to generate the Serial Clock (Sclock).
> > > -			     Valid values are "oscillator" and "platform"
> > > -			     "oscillator": CAN engine clock source is
> oscillator clock.
> > > -			     "platform" The CAN engine clock source is the bus
> clock
> > > -		             (platform clock).
> > > -
> > > -- fsl,flexcan-clock-divider : for the reference and system clock, an
> additional
> > > -			      clock divider can be specified.
> > > -- clock-frequency: frequency required to calculate the bitrate for
> FlexCAN.
> > > -
> > > -Note:
> > > -	- v1.0 of flexcan-v1.0 represent the IP block version for P1010
> SOC.
> > > -	- P1010 does not have oscillator as the Clock Source.So the default
> > > -	  Clock Source is platform clock.
> > > -Examples:
> > > -
> > > -	can0@1c000 {
> > > -		compatible = "fsl,flexcan-v1.0";
> > > -		reg = <0x1c000 0x1000>;
> > > -		interrupts = <48 0x2>;
> > > -		interrupt-parent = <&mpic>;
> > > -		fsl,flexcan-clock-source = "platform";
> > > -		fsl,flexcan-clock-divqider = <2>;
> > > -		clock-frequency = <fixed by u-boot>;
> > > -	};
> >
> > Do we really want to drop the documentation for that binding. I think
> > something like the following text would be still useful:
> >
> > ------------------------
> > Flexcan CAN contoller on Freescale's ARM and PowerPC processors
> >
> > Required properties:
> >
> > - compatible : Should be "fsl,flexcan" and optionally
> >                "fsl,flexcan-<processor>"
> > - reg : Offset and length of the register set for this device
> > - interrupts : Interrupt tuple for this device
> >
> > Example:
> >
> >   can@1c000 {
> >           compatible = "fsl,p1010-flexcan", "fsl,flexcan";
> >           reg = <0x1c000 0x1000>;
> >           interrupts = <48 0x2>;
> >           interrupt-parent = <&mpic>;
> >   };
> > -------------------------
> 
> Done, except the
> >           compatible = "fsl,p1010-flexcan", "fsl,flexcan";
> 
> line is
> 	compatible = "fsl,flexcan", "fsl,flexcan-p1010";
> 
> >
> > What do you think?
> >
> > > diff --git a/arch/powerpc/boot/dts/p1010rdb.dts
> > > b/arch/powerpc/boot/dts/p1010rdb.dts
> > > index 6b33b73..d6a0bb2 100644
> > > --- a/arch/powerpc/boot/dts/p1010rdb.dts
> > > +++ b/arch/powerpc/boot/dts/p1010rdb.dts
> > > @@ -169,14 +169,6 @@
> > >  			};
> > >  		};
> > >
> > > -		can0@1c000 {
> > > -			fsl,flexcan-clock-source = "platform";
> > > -		};
> > > -
> > > -		can1@1d000 {
> > > -			fsl,flexcan-clock-source = "platform";
> > > -		};
> > > -
> > >  		usb@22000 {
> > >  			phy_type = "utmi";
> > >  		};
> > > diff --git a/arch/powerpc/boot/dts/p1010si.dtsi
> > > b/arch/powerpc/boot/dts/p1010si.dtsi
> > > index 7f51104..20c396d 100644
> > > --- a/arch/powerpc/boot/dts/p1010si.dtsi
> > > +++ b/arch/powerpc/boot/dts/p1010si.dtsi
> > > @@ -141,19 +141,19 @@
> > >  		};
> > >
> > >  		can0@1c000 {
> > > -			compatible = "fsl,flexcan-v1.0";
> > > +			compatible = "fsl,p1010-flexcan",
> > > +					"fsl,flexcan";
> >
> > Does fit on one line.
> >
> > >  			reg = <0x1c000 0x1000>;
> > >  			interrupts = <48 0x2>;
> > >  			interrupt-parent = <&mpic>;
> > > -			fsl,flexcan-clock-divider = <2>;
> > >  		};
> > >
> > >  		can1@1d000 {
> > > -			compatible = "fsl,flexcan-v1.0";
> > > +			compatible = "fsl,p1010-flexcan",
> > > +					"fsl,flexcan";
> >
> > Ditto
> >
> > >  			reg = <0x1d000 0x1000>;
> > >  			interrupts = <61 0x2>;
> > >  			interrupt-parent = <&mpic>;
> > > -			fsl,flexcan-clock-divider = <2>;
> > >  		};
> > >
> > >  		L2: l2-cache-controller@20000 {
> >
> > Please also correct the node names (not using the number suffix).
> 
> So the node names should be
> 		can@1c000 {
> 		can@1d000 {
> correct?
> 
[Bhaskar] As there are two CAN controllers on P1010,So won't it be better
	    to distinguish it by can0 and can1 instead by simple "can" ?
> Robin



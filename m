From: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [PATCH v11 3/6] flexcan: Fix up fsl-flexcan device tree binding.
Date: Fri, 12 Aug 2011 03:28:24 -0500
Message-ID: <20110812082824.GH4926@sgi.com>
References: <1313078831-2511-1-git-send-email-holt@sgi.com>
	<1313078831-2511-4-git-send-email-holt@sgi.com>
	<CACxGe6vA8K7fhrSvBpKC+9aKftUc2+1EAUQ=A0SmmwzJ2Le=9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CACxGe6vA8K7fhrSvBpKC+9aKftUc2+1EAUQ=A0SmmwzJ2Le=9A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 11, 2011 at 10:53:43AM -0600, Grant Likely wrote:
> On Thu, Aug 11, 2011 at 10:07 AM, Robin Holt <holt-sJ/iWh9BUns@public.gmane.org> wrote:
> > +- compatible : Should be "fsl,<processor>-flexcan" and "fsl,flexcan"
> =

> Don't do this.  "fsl,flexcan" is far too generic.  Be specific to the
> soc part number or the ip core implementation version.

I don't have any crumbs to go with here.  There is nothing in the
documentation I have found to indicate what this is or should be.
I looked at the documentation for the P1010 processor and there is nothing
in there which I noticed that indicates what I could possibly use other
than flexcan.  They don't even indicate the registers are equivalent or
identical to their i.MX implementations for i.MX25 and i.MX35.  The only
thing they call it is flexcan.  I have asked our local freescale rep and
he said "There is no 'chip', it is just flexcan.  flexcan is flexcan."
His tone was such that I got the feeling he thought the question was
crazy as flexcan is flexcan.

> > -Can Engine Clock Source
> > - =A0 =A0 =A0 There are two sources for CAN clock
> > - =A0 =A0 =A0 - Platform Clock =A0It represents the bus clock
> > - =A0 =A0 =A0 - Oscillator Clock
> > + =A0An implementation should also claim any of the following compatibl=
es
> > + =A0that it is fully backwards compatible with:
> >
> > - =A0 =A0 =A0 Peripheral Clock (PLL)
> > - =A0 =A0 =A0 --------------
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 --------- =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 -------------
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 |CPI Clock =A0 =A0 =
=A0 =A0| Prescaler | =A0 =A0 =A0 Sclock
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 |---------------->|=
 (1.. 256) |------------>
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 --------- =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 -------------
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0|
> > - =A0 =A0 =A0 -------------- =A0---------------------CLK_SRC
> > - =A0 =A0 =A0 Oscillator Clock
> > + =A0- fsl,p1010-flexcan
> >
> > -- fsl,flexcan-clock-source : CAN Engine Clock Source.This property sel=
ects
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0the peripheral=
 clock. PLL clock is fed to the
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0prescaler to g=
enerate the Serial Clock (Sclock).
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Valid values a=
re "oscillator" and "platform"
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"oscillator": =
CAN engine clock source is oscillator clock.
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"platform" The=
 CAN engine clock source is the bus clock
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(platform cloc=
k).
> > +- reg : Offset and length of the register set for this device
> > +- interrupts : Interrupt tuple for this device
> >
> > -- fsl,flexcan-clock-divider : for the reference and system clock, an a=
dditional
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 clock divider=
 can be specified.
> > -- clock-frequency: frequency required to calculate the bitrate for Fle=
xCAN.
> > +Example:
> >
> > -Note:
> > - =A0 =A0 =A0 - v1.0 of flexcan-v1.0 represent the IP block version for=
 P1010 SOC.
> > - =A0 =A0 =A0 - P1010 does not have oscillator as the Clock Source.So t=
he default
> > - =A0 =A0 =A0 =A0 Clock Source is platform clock.
> > -Examples:
> > -
> > - =A0 =A0 =A0 can0@1c000 {
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 compatible =3D "fsl,flexcan-v1.0";
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 reg =3D <0x1c000 0x1000>;
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 interrupts =3D <48 0x2>;
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 interrupt-parent =3D <&mpic>;
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 fsl,flexcan-clock-source =3D "platform";
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 fsl,flexcan-clock-divider =3D <2>;
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 clock-frequency =3D <fixed by u-boot>;
> > - =A0 =A0 =A0 };
> > + =A0can@1c000 {
> > + =A0 =A0 =A0 =A0 =A0compatible =3D "fsl,p1010-flexcan", "fsl,flexcan";
> > + =A0 =A0 =A0 =A0 =A0reg =3D <0x1c000 0x1000>;
> > + =A0 =A0 =A0 =A0 =A0interrupts =3D <48 0x2>;
> > + =A0 =A0 =A0 =A0 =A0interrupt-parent =3D <&mpic>;
> > + =A0};
> =

> The diffstat for this patch looks too big because the whitespace has
> changed.  Try to restrict whitespace changes so that the patch is
> friendly to reviewers.

Reworked the best I can.  That reduced the diffstat by 3 lines.

Robin

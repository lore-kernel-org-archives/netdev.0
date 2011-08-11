From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH v11 3/6] flexcan: Fix up fsl-flexcan device tree binding.
Date: Thu, 11 Aug 2011 10:53:43 -0600
Message-ID: <CACxGe6vA8K7fhrSvBpKC+9aKftUc2+1EAUQ=A0SmmwzJ2Le=9A@mail.gmail.com>
References: <1313078831-2511-1-git-send-email-holt@sgi.com> <1313078831-2511-4-git-send-email-holt@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kumar Gala <galak@kernel.crashing.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	U Bhaskar-B22300 <B22300@freescale.com>,
	Scott Wood <scottwood@freescale.com>,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	PPC list <linuxppc-dev@lists.ozlabs.org>,
	devicetree-discuss@lists.ozlabs.org
To: Robin Holt <holt@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:50355 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560Ab1HKQyL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 12:54:11 -0400
Received: by vxi9 with SMTP id 9so1760362vxi.19
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2011 09:54:10 -0700 (PDT)
In-Reply-To: <1313078831-2511-4-git-send-email-holt@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 11, 2011 at 10:07 AM, Robin Holt <holt@sgi.com> wrote:
> This patch cleans up the documentation of the device-tree binding for
> the Flexcan devices on Freescale's PowerPC and ARM cores. Extra
> properties are not used by the driver so we are removing them.
>
> Signed-off-by: Robin Holt <holt@sgi.com>
> To: Marc Kleine-Budde <mkl@pengutronix.de>,
> To: Wolfgang Grandegger <wg@grandegger.com>,
> To: U Bhaskar-B22300 <B22300@freescale.com>
> To: Scott Wood <scottwood@freescale.com>
> To: Grant Likely <grant.likely@secretlab.ca>
> To: Kumar Gala <galak@kernel.crashing.org>
> Cc: socketcan-core@lists.berlios.de,
> Cc: netdev@vger.kernel.org,
> Cc: PPC list <linuxppc-dev@lists.ozlabs.org>
> Cc: devicetree-discuss@lists.ozlabs.org
> ---
> =A0.../devicetree/bindings/net/can/fsl-flexcan.txt =A0 =A0| =A0 69 ++=
++---------------
> =A0arch/powerpc/boot/dts/p1010rdb.dts =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 | =A0 10 +--
> =A0arch/powerpc/boot/dts/p1010si.dtsi =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 | =A0 10 +--
> =A03 files changed, 21 insertions(+), 68 deletions(-)
>
> diff --git a/Documentation/devicetree/bindings/net/can/fsl-flexcan.tx=
t b/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
> index 1a729f0..c78dcbb 100644
> --- a/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
> +++ b/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
> @@ -1,61 +1,22 @@
> -CAN Device Tree Bindings
> -------------------------
> -2011 Freescale Semiconductor, Inc.
> +Flexcan CAN contoller on Freescale's ARM and PowerPC processors
>
> -fsl,flexcan-v1.0 nodes
> ------------------------
> -In addition to the required compatible-, reg- and interrupt-properti=
es, you can
> -also specify which clock source shall be used for the controller.
> +Required properties:
>
> -CPI Clock- Can Protocol Interface Clock
> - =A0 =A0 =A0 This CLK_SRC bit of CTRL(control register) selects the =
clock source to
> - =A0 =A0 =A0 the CAN Protocol Interface(CPI) to be either the periph=
eral clock
> - =A0 =A0 =A0 (driven by the PLL) or the crystal oscillator clock. Th=
e selected clock
> - =A0 =A0 =A0 is the one fed to the prescaler to generate the Serial =
Clock (Sclock).
> - =A0 =A0 =A0 The PRESDIV field of CTRL(control register) controls a =
prescaler that
> - =A0 =A0 =A0 generates the Serial Clock (Sclock), whose period defin=
es the
> - =A0 =A0 =A0 time quantum used to compose the CAN waveform.
> +- compatible : Should be "fsl,<processor>-flexcan" and "fsl,flexcan"

Don't do this.  "fsl,flexcan" is far too generic.  Be specific to the
soc part number or the ip core implementation version.

>
> -Can Engine Clock Source
> - =A0 =A0 =A0 There are two sources for CAN clock
> - =A0 =A0 =A0 - Platform Clock =A0It represents the bus clock
> - =A0 =A0 =A0 - Oscillator Clock
> + =A0An implementation should also claim any of the following compati=
bles
> + =A0that it is fully backwards compatible with:
>
> - =A0 =A0 =A0 Peripheral Clock (PLL)
> - =A0 =A0 =A0 --------------
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 --------- =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 -------------
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 |CPI Clock =A0 =A0=
 =A0 =A0| Prescaler | =A0 =A0 =A0 Sclock
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 |----------------=
>| (1.. 256) |------------>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 --------- =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 -------------
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0|
> - =A0 =A0 =A0 -------------- =A0---------------------CLK_SRC
> - =A0 =A0 =A0 Oscillator Clock
> + =A0- fsl,p1010-flexcan
>
> -- fsl,flexcan-clock-source : CAN Engine Clock Source.This property s=
elects
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0the peripher=
al clock. PLL clock is fed to the
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0prescaler to=
 generate the Serial Clock (Sclock).
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Valid values=
 are "oscillator" and "platform"
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"oscillator"=
: CAN engine clock source is oscillator clock.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"platform" T=
he CAN engine clock source is the bus clock
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(platform cl=
ock).
> +- reg : Offset and length of the register set for this device
> +- interrupts : Interrupt tuple for this device
>
> -- fsl,flexcan-clock-divider : for the reference and system clock, an=
 additional
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 clock divid=
er can be specified.
> -- clock-frequency: frequency required to calculate the bitrate for F=
lexCAN.
> +Example:
>
> -Note:
> - =A0 =A0 =A0 - v1.0 of flexcan-v1.0 represent the IP block version f=
or P1010 SOC.
> - =A0 =A0 =A0 - P1010 does not have oscillator as the Clock Source.So=
 the default
> - =A0 =A0 =A0 =A0 Clock Source is platform clock.
> -Examples:
> -
> - =A0 =A0 =A0 can0@1c000 {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 compatible =3D "fsl,flexcan-v1.0";
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 reg =3D <0x1c000 0x1000>;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 interrupts =3D <48 0x2>;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 interrupt-parent =3D <&mpic>;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 fsl,flexcan-clock-source =3D "platform"=
;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 fsl,flexcan-clock-divider =3D <2>;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 clock-frequency =3D <fixed by u-boot>;
> - =A0 =A0 =A0 };
> + =A0can@1c000 {
> + =A0 =A0 =A0 =A0 =A0compatible =3D "fsl,p1010-flexcan", "fsl,flexcan=
";
> + =A0 =A0 =A0 =A0 =A0reg =3D <0x1c000 0x1000>;
> + =A0 =A0 =A0 =A0 =A0interrupts =3D <48 0x2>;
> + =A0 =A0 =A0 =A0 =A0interrupt-parent =3D <&mpic>;
> + =A0};

The diffstat for this patch looks too big because the whitespace has
changed.  Try to restrict whitespace changes so that the patch is
friendly to reviewers.

g.

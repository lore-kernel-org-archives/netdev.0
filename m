From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH v10 5/5] [powerpc] Fix up fsl-flexcan device tree
 binding.
Date: Wed, 10 Aug 2011 05:09:22 -0500
Message-ID: <20110810100922.GM4926@sgi.com>
References: <1312945564-6626-1-git-send-email-holt@sgi.com>
 <1312945564-6626-6-git-send-email-holt@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	PPC list <linuxppc-dev@lists.ozlabs.org>,
	Kumar Gala <galak@kernel.crashing.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>,
	U Bhaskar-B22300 <B22300@freescale.com>,
	Scott Wood <scottwood@freescale.com>
To: Grant Likely <grant.likely@secretlab.ca>,
	devicetree-discuss@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:36069 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751016Ab1HJKJX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2011 06:09:23 -0400
Content-Disposition: inline
In-Reply-To: <1312945564-6626-6-git-send-email-holt@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant,

Do you need this patch resent with you on the Cc: list or can you pick
up the discussion from here?  I am just trying to minimize noise on
the mailing lists if it is not needed.

The essence of the discussion to this point is:

1) Freescale built a board support package for a new processor and eval
   board (p1010) based upon some older boards.

2) As part of that effort, they made changes as they saw fit to get it
   working without submitting those changes to the community.

3) In the case of the flexcan device, that included defining a device
   tree node for the integrated Controller Area Network device and set
   .compatible="fsl,flexcan-v1.0".  Apparently this was copied from
   another device, possibly mscan.

4) In an effort to get my p1010rdb eval board working with a community
   kernel, I started submitting patches for flexcan which have evolved
   to the point of nearly being accepted with the exception of we need
   to settle on the node's .compatible= strings and whether it should
   be documented.

5) To this point, I believe the concensus has settled on
   "fsl,p1010-flexcan" and "fsl,flexcan" as the compatible strings.
   This leaves the most flexibility for segragating future specific
   revisions of the flexcan interface if needed.

6) I failed to Cc: you or the device tree list when I submitted version
   10 of the patches.  I have added both to the patch header so they
   will be included in the next pass.

Thanks,
Robin Holt

On Tue, Aug 09, 2011 at 10:06:04PM -0500, Robin Holt wrote:
> In working with the socketcan developers, we have come to the conclusion
> the Documentation...fsl-flexcan.txt device tree documentation needs to
> be cleaned up.  The driver does not depend upon any properties other
> than the required properties so we are removing the file.  Additionally,
> the p1010*dts* files are not following the standard for node naming in
> that they have a trailing -v1.0.
> 
> Signed-off-by: Robin Holt <holt@sgi.com>
> To: Marc Kleine-Budde <mkl@pengutronix.de>,
> To: Wolfgang Grandegger <wg@grandegger.com>,
> To: U Bhaskar-B22300 <B22300@freescale.com>
> To: Scott Wood <scottwood@freescale.com>
> Cc: socketcan-core@lists.berlios.de,
> Cc: netdev@vger.kernel.org,
> Cc: PPC list <linuxppc-dev@lists.ozlabs.org>
> Cc: Kumar Gala <galak@kernel.crashing.org>
> ---
>  .../devicetree/bindings/net/can/fsl-flexcan.txt    |   61 --------------------
>  arch/powerpc/boot/dts/p1010rdb.dts                 |    8 ---
>  arch/powerpc/boot/dts/p1010si.dtsi                 |    8 +-
>  3 files changed, 4 insertions(+), 73 deletions(-)
>  delete mode 100644 Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt b/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
> deleted file mode 100644
> index 1a729f0..0000000
> --- a/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
> +++ /dev/null
> @@ -1,61 +0,0 @@
> -CAN Device Tree Bindings
> -------------------------
> -2011 Freescale Semiconductor, Inc.
> -
> -fsl,flexcan-v1.0 nodes
> ------------------------
> -In addition to the required compatible-, reg- and interrupt-properties, you can
> -also specify which clock source shall be used for the controller.
> -
> -CPI Clock- Can Protocol Interface Clock
> -	This CLK_SRC bit of CTRL(control register) selects the clock source to
> -	the CAN Protocol Interface(CPI) to be either the peripheral clock
> -	(driven by the PLL) or the crystal oscillator clock. The selected clock
> -	is the one fed to the prescaler to generate the Serial Clock (Sclock).
> -	The PRESDIV field of CTRL(control register) controls a prescaler that
> -	generates the Serial Clock (Sclock), whose period defines the
> -	time quantum used to compose the CAN waveform.
> -
> -Can Engine Clock Source
> -	There are two sources for CAN clock
> -	- Platform Clock  It represents the bus clock
> -	- Oscillator Clock
> -
> -	Peripheral Clock (PLL)
> -	--------------
> -		     |
> -		    ---------		      -------------
> -		    |       |CPI Clock	      | Prescaler |       Sclock
> -		    |       |---------------->| (1.. 256) |------------>
> -		    ---------		      -------------
> -                     |  |
> -	--------------  ---------------------CLK_SRC
> -	Oscillator Clock
> -
> -- fsl,flexcan-clock-source : CAN Engine Clock Source.This property selects
> -			     the peripheral clock. PLL clock is fed to the
> -			     prescaler to generate the Serial Clock (Sclock).
> -			     Valid values are "oscillator" and "platform"
> -			     "oscillator": CAN engine clock source is oscillator clock.
> -			     "platform" The CAN engine clock source is the bus clock
> -		             (platform clock).
> -
> -- fsl,flexcan-clock-divider : for the reference and system clock, an additional
> -			      clock divider can be specified.
> -- clock-frequency: frequency required to calculate the bitrate for FlexCAN.
> -
> -Note:
> -	- v1.0 of flexcan-v1.0 represent the IP block version for P1010 SOC.
> -	- P1010 does not have oscillator as the Clock Source.So the default
> -	  Clock Source is platform clock.
> -Examples:
> -
> -	can0@1c000 {
> -		compatible = "fsl,flexcan-v1.0";
> -		reg = <0x1c000 0x1000>;
> -		interrupts = <48 0x2>;
> -		interrupt-parent = <&mpic>;
> -		fsl,flexcan-clock-source = "platform";
> -		fsl,flexcan-clock-divider = <2>;
> -		clock-frequency = <fixed by u-boot>;
> -	};
> diff --git a/arch/powerpc/boot/dts/p1010rdb.dts b/arch/powerpc/boot/dts/p1010rdb.dts
> index 6b33b73..d6a0bb2 100644
> --- a/arch/powerpc/boot/dts/p1010rdb.dts
> +++ b/arch/powerpc/boot/dts/p1010rdb.dts
> @@ -169,14 +169,6 @@
>  			};
>  		};
>  
> -		can0@1c000 {
> -			fsl,flexcan-clock-source = "platform";
> -		};
> -
> -		can1@1d000 {
> -			fsl,flexcan-clock-source = "platform";
> -		};
> -
>  		usb@22000 {
>  			phy_type = "utmi";
>  		};
> diff --git a/arch/powerpc/boot/dts/p1010si.dtsi b/arch/powerpc/boot/dts/p1010si.dtsi
> index 7f51104..20c396d 100644
> --- a/arch/powerpc/boot/dts/p1010si.dtsi
> +++ b/arch/powerpc/boot/dts/p1010si.dtsi
> @@ -141,19 +141,19 @@
>  		};
>  
>  		can0@1c000 {
> -			compatible = "fsl,flexcan-v1.0";
> +			compatible = "fsl,p1010-flexcan",
> +					"fsl,flexcan";
>  			reg = <0x1c000 0x1000>;
>  			interrupts = <48 0x2>;
>  			interrupt-parent = <&mpic>;
> -			fsl,flexcan-clock-divider = <2>;
>  		};
>  
>  		can1@1d000 {
> -			compatible = "fsl,flexcan-v1.0";
> +			compatible = "fsl,p1010-flexcan",
> +					"fsl,flexcan";
>  			reg = <0x1d000 0x1000>;
>  			interrupts = <61 0x2>;
>  			interrupt-parent = <&mpic>;
> -			fsl,flexcan-clock-divider = <2>;
>  		};
>  
>  		L2: l2-cache-controller@20000 {
> -- 
> 1.7.2.1

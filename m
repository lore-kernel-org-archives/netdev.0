From: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [PATCH v11 5/5] powerpc: Fix up fsl-flexcan device tree binding.
Date: Wed, 10 Aug 2011 13:30:16 -0500
Message-ID: <20110810183016.GY4926@sgi.com>
References: <1312993670-23999-1-git-send-email-holt@sgi.com>
	<1312993670-23999-6-git-send-email-holt@sgi.com>
	<4E42B83C.2040705@freescale.com> <20110810171933.GW4926@sgi.com>
	<4E42C196.7030708@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4E42C196.7030708-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
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

On Wed, Aug 10, 2011 at 12:36:22PM -0500, Scott Wood wrote:
> On 08/10/2011 12:19 PM, Robin Holt wrote:
> > On Wed, Aug 10, 2011 at 11:56:28AM -0500, Scott Wood wrote:
> >> On 08/10/2011 11:27 AM, Robin Holt wrote:
> >>> -CPI Clock- Can Protocol Interface Clock
> >>> -	This CLK_SRC bit of CTRL(control register) selects the clock source to
> >>> -	the CAN Protocol Interface(CPI) to be either the peripheral clock
> >>> -	(driven by the PLL) or the crystal oscillator clock. The selected clock
> >>> -	is the one fed to the prescaler to generate the Serial Clock (Sclock).
> >>> -	The PRESDIV field of CTRL(control register) controls a prescaler that
> >>> -	generates the Serial Clock (Sclock), whose period defines the
> >>> -	time quantum used to compose the CAN waveform.
> >>> +- compatible : Should be "fsl,flexcan" and optionally
> >>> +               "fsl,flexcan-<processor>"
> >>
> >> fsl,<processor>-flexcan, and it should not be optional, and should come
> >> before "fsl,flexcan".
> >>
> >> Also may want to list fsl,p1010-rdb as a "canonical compatible" for
> >> anything which is backwards compatible with p1010's implementation.
> > 
> > How do I specify 'canonical compatible'?
> 
> Something like:
> 
>   compatible: Should be "fsl,<processor>-flexcan" and "fsl,flexcan".
> 
>   An implementation should also claim any of the following compatibles
>   that it is fully backwards compatible with:
> 
>   - fsl,p1010-rdb

I am so confused.  fsl,p1010-flexcan refers, in my mind at least, to
a particular chiplet on the p1010 freescale processor.  fsl,p1010-rdb
would mean nothing to me as that is a p1010 processor with two flexcan
chiplets wired to a pair of DB-9 jacks.  For the driver, what additional
information is being conveyed?

Let's cut to the chase.  Here is what I have after incorporating your
earlier comment about the compatible line.  Please mark this up to
exactly what you are asking for.

Thanks,
Robin
------------------------------------------------------------------------
Flexcan CAN contoller on Freescale's ARM and PowerPC processors

Required properties:

- compatible : Should be "fsl,<processor>-flexcan" and "fsl,flexcan"
- reg : Offset and length of the register set for this device
- interrupts : Interrupt tuple for this device

Example:

  can@1c000 {
          compatible = "fsl,p1010-flexcan", "fsl,flexcan";
          reg = <0x1c000 0x1000>;
          interrupts = <48 0x2>;
          interrupt-parent = <&mpic>;
  };

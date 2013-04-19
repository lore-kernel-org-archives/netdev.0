From: Steffen Trumtrar <s.trumtrar@pengutronix.de>
Subject: Re: net/macb: clear tx/rx completion flags in ISR
Date: Fri, 19 Apr 2013 09:30:58 +0200
Message-ID: <20130419073058.GA660@pengutronix.de>
References: <5170D276.6070208@yahoo.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Ludovic Desroches <ludovic.desroches@atmel.com>
To: Hein Tibosch <hein_tibosch@yahoo.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49772 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754241Ab3DSHbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 03:31:03 -0400
Content-Disposition: inline
In-Reply-To: <5170D276.6070208@yahoo.es>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hein,

On Fri, Apr 19, 2013 at 01:13:26PM +0800, Hein Tibosch wrote:
> Hi Steffen,
> 
> > At least in the cadence IP core on the Xilinx Zynq SoC the TCOMP/RCOMP flags
> > are not auto-cleaned. As these flags are evaluated, they need to be cleaned.
> 
> This patch does not work for at least the AVR32 platform. Both RCOMP/RCOMP
> are cleared by *reading* the ISR and writing them would be fatal.
> 

:-(

> Could you tell me the version of the macb of Xilinx Zynq?
> 
>     u32 version = (macb_readl(bp, MID) & ((1 << MACB_REV_SIZE) - 1))
>             | MACB_GREGS_VERSION;
> 
> On an AP7000 it reads as 0x0000010D
> 

This gives me 0x00000119. The TRM says it is version r1p23.

> I am thinking of making a patch like:
> 
>     if (bp->version >= xxx)
>         macb_writel(bp, ISR, MACB_BIT(TCOMP));
> 
>     if (bp->version >= xxx)
>         macb_writel(bp, ISR, MACB_BIT(RCOMP));
> 
> which would make it work on both platforms.
> 

The documentation I have is a little bit confusing in that regard.
The cadence datasheet says, this register is R/W, the Xilinx datasheet says,
it is "normaly RO", but the programming guide explicitely mentions clearing
the bit by writing to it.
It seems, that something like your patch is inevitable.

Regards,
Steffen

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |

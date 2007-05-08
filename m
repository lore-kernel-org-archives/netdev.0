From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Tue, 8 May 2007 13:37:35 +0200
Message-ID: <20070508113735.GB32055@xi.wantstofly.org>
References: <m3abwhcy74.fsf@maximus.localdomain> <m3vef5biob.fsf@maximus.localdomain> <5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk> <m3hcqoa772.fsf@maximus.localdomain> <86D26EBE-5899-468F-9C79-23E83E0DE04B@cam.ac.uk> <m33b289zku.fsf@maximus.localdomain> <m3zm4g3yed.fsf_-_@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael-Luke Jones <mlj28@cam.ac.uk>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Russell King <rmk@arm.linux.org.uk>,
	ARM Linux Mailing List
	<linux-arm-kernel@lists.arm.linux.org.uk>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S967344AbXEHLhm@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m3zm4g3yed.fsf_-_@maximus.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 08, 2007 at 03:19:22AM +0200, Krzysztof Halasa wrote:

> diff --git a/arch/arm/mach-ixp4xx/ixdp425-setup.c b/arch/arm/mach-ixp4xx/ixdp425-setup.c
> index ec4f079..f20d39d 100644
> --- a/arch/arm/mach-ixp4xx/ixdp425-setup.c
> +++ b/arch/arm/mach-ixp4xx/ixdp425-setup.c
> @@ -101,10 +101,35 @@ static struct platform_device ixdp425_uart = {
>  	.resource		= ixdp425_uart_resources
>  };
>  
> +/* Built-in 10/100 Ethernet MAC interfaces */
> +static struct mac_plat_info ixdp425_plat_mac[] = {
> +	{
> +		.phy		= 0,
> +		.rxq		= 3,
> +	}, {
> +		.phy		= 1,
> +		.rxq		= 4,
> +	}
> +};

As with Christian's driver (I'm feeling like a bit of a broken record
here :-), putting knowledge of which queue to use (which is firmware-
specific) in the _board_ support file is almost certainly wrong.

I would just put the port number in there, and let the ethernet
driver map the port number to the hardware queue number.  After all,
the ethernet driver knows which queues the firmware uses, while the
board support code doesn't.


> +#ifndef __ARMEB__
> +#warning Little endian mode not supported
> +#endif

Yay. :-)  /me hides


> +static inline void set_regbits(u32 bits, u32 __iomem *reg)
> +{
> +	__raw_writel(__raw_readl(reg) | bits, reg);
> +}
> +static inline void clr_regbits(u32 bits, u32 __iomem *reg)
> +{
> +	__raw_writel(__raw_readl(reg) & ~bits, reg);
> +}

I generally discourage the use of such wrappers, as it often makes
people forget that the set and clear operations are not atomic, and
it ignores the fact that some of the other bits in the register you
are modifying might have side-effects.

Didn't review the rest -- not sure whether I'm looking at the latest
version.

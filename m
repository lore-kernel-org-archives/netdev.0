From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [patch nacked? 3/4] Update smc91x driver with ARM Versatile board info
Date: Wed, 30 Jul 2008 23:42:55 +0100
Message-ID: <20080730224255.GB12409@flint.arm.linux.org.uk>
References: <200807301940.m6UJemPm012683@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, dsaxena@plexity.net,
	nico@cam.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:50231 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350AbYG3Wnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 18:43:51 -0400
Content-Disposition: inline
In-Reply-To: <200807301940.m6UJemPm012683@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Are you aware that smc91x.h _already_ contains a CONFIG_ARCH_VERSATILE
section?

On Wed, Jul 30, 2008 at 12:40:48PM -0700, akpm@linux-foundation.org wrote:
> From: Deepak Saxena <dsaxena@plexity.net>
> 
> We need to specify a Versatile-specific SMC_IRQ_FLAGS value or the new
> generic IRQ layer will complain thusly:
> 
> No IRQF_TRIGGER set_type function for IRQ 25 (<NULL>)
> 
> Signed-off-by: Deepak Saxena <dsaxena@plexity.net>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Russell King <rmk@arm.linux.org.uk>
> Cc: Nicolas Pitre <nico@cam.org>
> 
> On Fri, 20 Oct 2006 22:50:40 +0100
> Russell King <rmk@arm.linux.org.uk> wrote:
> 
> > On Fri, Oct 20, 2006 at 02:42:04PM -0700, akpm@linux-foundation.org wrote:
> > > We need to specify a Versatile-specific SMC_IRQ_FLAGS value or the new
> > > generic IRQ layer will complain thusly:
> > 
> > I don't think I heard anything back from my previous suggestion that
> > the IRQ flags are passed through the platform device IRQ resource.
> > 
> > Doing so would avoid adding yet another platform specific block into
> > the file.
> > 
> > BTW, Integrator platforms will also suffer from this, which will add
> > another ifdef to this header.
> > 
> > Let's do it right and arrange to pass these flags from the platform
> > code.  It's not like they're in a critical path.
> 
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/smc91x.h |   18 ++++++++++++++++++
>  1 file changed, 18 insertions(+)
> 
> diff -puN drivers/net/smc91x.h~update-smc91x-driver-with-arm-versatile-board-info drivers/net/smc91x.h
> --- a/drivers/net/smc91x.h~update-smc91x-driver-with-arm-versatile-board-info
> +++ a/drivers/net/smc91x.h
> @@ -435,6 +435,24 @@ static inline void LPD7_SMC_outsw (unsig
>  
>  #include <asm/unit/smc91111.h>
>  
> +#elif	defined(CONFIG_ARCH_VERSATILE)
> +
> +#define SMC_CAN_USE_8BIT	1
> +#define SMC_CAN_USE_16BIT	1
> +#define SMC_CAN_USE_32BIT	1
> +#define SMC_NOWAIT		1
> +
> +#define SMC_inb(a, r)		readb((a) + (r))
> +#define SMC_inw(a, r)		readw((a) + (r))
> +#define SMC_inl(a, r)		readl((a) + (r))
> +#define SMC_outb(v, a, r)	writeb(v, (a) + (r))
> +#define SMC_outw(v, a, r)	writew(v, (a) + (r))
> +#define SMC_outl(v, a, r)	writel(v, (a) + (r))
> +#define SMC_insl(a, r, p, l)	readsl((a) + (r), p, l)
> +#define SMC_outsl(a, r, p, l)	writesl((a) + (r), p, l)
> +
> +#define SMC_IRQ_FLAGS		(0)
> +
>  #else
>  
>  /*
> _

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:

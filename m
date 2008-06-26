From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH 01/10] smc91x: remove unused code enclosed by #ifdef
 CONFIG_ISA .. #endif
Date: Thu, 26 Jun 2008 19:52:05 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0806261951260.2979@xanadu.home>
References: <1214300867-15495-2-git-send-email-eric.y.miao@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	linux-netdev <netdev@vger.kernel.org>,
	Magnus Damm <magnus.damm@gmail.com>,
	Eric Miao <eric.miao@marvell.com>
To: Eric Miao <eric.y.miao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:15320 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbYFZXwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 19:52:07 -0400
Received: from xanadu.home ([66.131.194.97]) by VL-MO-MR002.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0K3300KGEGYTJ990@VL-MO-MR002.ip.videotron.ca> for
 netdev@vger.kernel.org; Thu, 26 Jun 2008 19:52:05 -0400 (EDT)
In-reply-to: <1214300867-15495-2-git-send-email-eric.y.miao@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Jun 2008, Eric Miao wrote:

> From: Eric Miao <eric.miao@marvell.com>
> 
> Apparently, the code enclosed by #ifdef CONFIG_ISA .. #endif are no longer
> used, remove them from the driver to avoid confusion.
> 
> Signed-off-by: Eric Miao <eric.miao@marvell.com>

Acked-by: Nicolas Pitre <nico@cam.org>

> ---
>  drivers/net/smc91x.c |   38 --------------------------------------
>  drivers/net/smc91x.h |   13 -------------
>  2 files changed, 0 insertions(+), 51 deletions(-)
> 
> diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
> index a188e33..d471308 100644
> --- a/drivers/net/smc91x.c
> +++ b/drivers/net/smc91x.c
> @@ -23,8 +23,6 @@
>   * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
>   *
>   * Arguments:
> - * 	io	= for the base address
> - *	irq	= for the IRQ
>   *	nowait	= 0 for normal wait states, 1 eliminates additional wait states
>   *
>   * original author:
> @@ -90,33 +88,6 @@ static const char version[] =
>  
>  #include "smc91x.h"
>  
> -#ifdef CONFIG_ISA
> -/*
> - * the LAN91C111 can be at any of the following port addresses.  To change,
> - * for a slightly different card, you can add it to the array.  Keep in
> - * mind that the array must end in zero.
> - */
> -static unsigned int smc_portlist[] __initdata = {
> -	0x200, 0x220, 0x240, 0x260, 0x280, 0x2A0, 0x2C0, 0x2E0,
> -	0x300, 0x320, 0x340, 0x360, 0x380, 0x3A0, 0x3C0, 0x3E0, 0
> -};
> -
> -#ifndef SMC_IOADDR
> -# define SMC_IOADDR		-1
> -#endif
> -static unsigned long io = SMC_IOADDR;
> -module_param(io, ulong, 0400);
> -MODULE_PARM_DESC(io, "I/O base address");
> -
> -#ifndef SMC_IRQ
> -# define SMC_IRQ		-1
> -#endif
> -static int irq = SMC_IRQ;
> -module_param(irq, int, 0400);
> -MODULE_PARM_DESC(irq, "IRQ number");
> -
> -#endif  /* CONFIG_ISA */
> -
>  #ifndef SMC_NOWAIT
>  # define SMC_NOWAIT		0
>  #endif
> @@ -2315,15 +2286,6 @@ static struct platform_driver smc_driver = {
>  
>  static int __init smc_init(void)
>  {
> -#ifdef MODULE
> -#ifdef CONFIG_ISA
> -	if (io == -1)
> -		printk(KERN_WARNING
> -			"%s: You shouldn't use auto-probing with insmod!\n",
> -			CARDNAME);
> -#endif
> -#endif
> -
>  	return platform_driver_register(&smc_driver);
>  }
>  
> diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
> index 69e97a1..97a3c52 100644
> --- a/drivers/net/smc91x.h
> +++ b/drivers/net/smc91x.h
> @@ -279,19 +279,6 @@ SMC_outw(u16 val, void __iomem *ioaddr, int reg)
>  
>  #define SMC_IRQ_FLAGS		(0)
>  
> -#elif	defined(CONFIG_ISA)
> -
> -#define SMC_CAN_USE_8BIT	1
> -#define SMC_CAN_USE_16BIT	1
> -#define SMC_CAN_USE_32BIT	0
> -
> -#define SMC_inb(a, r)		inb((a) + (r))
> -#define SMC_inw(a, r)		inw((a) + (r))
> -#define SMC_outb(v, a, r)	outb(v, (a) + (r))
> -#define SMC_outw(v, a, r)	outw(v, (a) + (r))
> -#define SMC_insw(a, r, p, l)	insw((a) + (r), p, l)
> -#define SMC_outsw(a, r, p, l)	outsw((a) + (r), p, l)
> -
>  #elif   defined(CONFIG_M32R)
>  
>  #define SMC_CAN_USE_8BIT	0
> -- 
> 1.5.4.3
> 


Nicolas

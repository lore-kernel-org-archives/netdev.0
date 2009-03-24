From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 2/3] ARM: mxc: add mx31pdk Lan9217 support
Date: Tue, 24 Mar 2009 08:58:09 +0100
Message-ID: <20090324075809.GF25436@pengutronix.de>
References: <4e090d470903232344x162ca791q3007954d064ccd00@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel@pengutronix.de, linux-arm-kernel@lists.arm.linux.org.uk,
	steve.glendinning@smsc.com, netdev@vger.kernel.org
To: Richard Zhao <linuxzsc@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:58356 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700AbZCXH6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 03:58:36 -0400
Content-Disposition: inline
In-Reply-To: <4e090d470903232344x162ca791q3007954d064ccd00@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2009 at 02:44:41PM +0800, Richard Zhao wrote:
> Signed-off-by: Richard Zhao <linuxzsc@gmail.com>
> 
> diff --git a/arch/arm/mach-mx3/mx31pdk.c b/arch/arm/mach-mx3/mx31pdk.c
> index aa7e3c5..45cef70 100644
> --- a/arch/arm/mach-mx3/mx31pdk.c
> +++ b/arch/arm/mach-mx3/mx31pdk.c
> @@ -32,6 +32,8 @@
>  #include <mach/board-mx31pdk.h>
>  #include <mach/imx-uart.h>
>  #include <mach/iomux-mx3.h>
> +#include <linux/platform_device.h>
> +#include <linux/smsc911x.h>
>  #include "devices.h"
>  #include "3stack-debug.h"
> 
> @@ -57,6 +59,43 @@ static inline void mxc_init_imx_uart(void)
>  	mxc_register_device(&mxc_uart_device0, &uart_pdata);
>  }
> 
> +/*lan9217 device*/
> +#if defined(CONFIG_SMSC911X) || defined(CONFIG_SMSC911X_MODULE)

IMO it is not worth to clutter the code with ifdefs just to save some
bytes of binary space, but ok, that's just my two cents.

> +static struct resource smsc911x_resources[] = {
> +	{
> +	 .start = LAN9217_BASE_ADDR,
> +	 .end = LAN9217_BASE_ADDR + 0x100,
> +	 .flags = IORESOURCE_MEM,
> +	 },
> +	{
> +	 .start = LAN9217_IRQ,
> +	 .end = LAN9217_IRQ,
> +	 .flags = IORESOURCE_IRQ,
> +	 },
> +};

static struct resource smsc911x_resources[] = {
	{
		.start = LAN9217_BASE_ADDR,
		.end = LAN9217_BASE_ADDR + 0x100,
		.flags = IORESOURCE_MEM,
	},{
		.start = LAN9217_IRQ,
		.end = LAN9217_IRQ,
		.flags = IORESOURCE_IRQ,
	},
};

> +
> +static struct smsc911x_platform_config smsc911x_platconfig = {
> +	.irq_polarity	= SMSC911X_IRQ_POLARITY_ACTIVE_LOW,
> +	.irq_type	= SMSC911X_IRQ_TYPE_OPEN_DRAIN,
> +	.flags		= SMSC911X_USE_16BIT | SMSC911X_USE_INTERPHY,
> +};
> +
> +static struct platform_device smsc_lan9217_device = {
> +	.name = "smsc911x",
> +	.id = 0,
> +	.num_resources = ARRAY_SIZE(smsc911x_resources),
> +	.resource = smsc911x_resources,
> +};
> +static void mxc_init_enet(void)
> +{
> +	mxc_register_device(&smsc_lan9217_device, &smsc911x_platconfig);
> +}
> +#else
> +static inline void mxc_init_enet(void)
> +{
> +}
> +#endif
> +
>  static u32 brd_io;
> 
>  static void mxc_expio_irq_handler(u32 irq, struct irq_desc *desc)
> @@ -217,6 +256,7 @@ static void __init mxc_board_init(void)
>  {
>  	mxc_init_imx_uart();
>  	mxc_expio_init();
> +	mxc_init_enet();
>  }
> 
>  static void __init mx31pdk_timer_init(void)
> -- 
> 1.5.6.3
> 

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |

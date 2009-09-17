From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH 1/3] at91sam9263: add at91_can device to generic device
 definition
Date: Thu, 17 Sep 2009 15:14:22 +0200
Message-ID: <4AB2362E.3070509@grandegger.com>
References: <1253180254-11910-1-git-send-email-mkl@pengutronix.de> <1253180254-11910-2-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Socketcan-core@lists.berlios.de,
	Andrew Victor <linux@maxim.org.za>,
	linux-arm-kernel@lists.infradead.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:52338 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753379AbZIQNOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 09:14:31 -0400
In-Reply-To: <1253180254-11910-2-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marc Kleine-Budde wrote:
> This patch adds the device definition for the at91_can device to
> the generic device definiton file for the at91sam9263.
> 
> Signed-off-by: Hans J. Koch <hjk@linutronix.de>
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
> ---
>  arch/arm/mach-at91/at91sam9263_devices.c |   36 ++++++++++++++++++++++++++++++
>  arch/arm/mach-at91/include/mach/board.h  |    6 +++++
>  2 files changed, 42 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/arm/mach-at91/at91sam9263_devices.c b/arch/arm/mach-at91/at91sam9263_devices.c
> index b7f2332..6026c2e 100644
> --- a/arch/arm/mach-at91/at91sam9263_devices.c
> +++ b/arch/arm/mach-at91/at91sam9263_devices.c
> @@ -757,6 +757,42 @@ void __init at91_add_device_ac97(struct atmel_ac97_data *data)
>  void __init at91_add_device_ac97(struct atmel_ac97_data *data) {}
>  #endif
>  
> +/* --------------------------------------------------------------------
> + *  CAN Controller
> + * -------------------------------------------------------------------- */
> +
> +#if defined(CONFIG_CAN_AT91) || defined(CONFIG_CAN_AT91_MODULE)
> +static struct resource can_resources[] = {
> +	[0] = {
> +		.start	= AT91SAM9263_BASE_CAN,
> +		.end	= AT91SAM9263_BASE_CAN + SZ_16K - 1,
> +		.flags	= IORESOURCE_MEM,
> +	},
> +	[1] = {
> +		.start	= AT91SAM9263_ID_CAN,
> +		.end	= AT91SAM9263_ID_CAN,
> +		.flags	= IORESOURCE_IRQ,
> +	},
> +};
> +
> +static struct platform_device at91sam9263_can_device = {
> +	.name		= "at91_can",
> +	.id		= -1,
> +	.resource	= can_resources,
> +	.num_resources	= ARRAY_SIZE(can_resources),
> +};
> +
> +void __init at91_add_device_can(struct at91_can_data *data)
> +{
> +	at91_set_A_periph(AT91_PIN_PA13, 0);	/* CANTX */
> +	at91_set_A_periph(AT91_PIN_PA14, 0);	/* CANRX */
> +	at91sam9263_can_device.dev.platform_data = data;
> +
> +	platform_device_register(&at91sam9263_can_device);
> +}
> +#else
> +void __init at91_add_device_can(struct at91_can_data *data) {}
> +#endif
>  
>  /* --------------------------------------------------------------------
>   *  LCD Controller
> diff --git a/arch/arm/mach-at91/include/mach/board.h b/arch/arm/mach-at91/include/mach/board.h
> index e6afff8..134731c 100644
> --- a/arch/arm/mach-at91/include/mach/board.h
> +++ b/arch/arm/mach-at91/include/mach/board.h
> @@ -179,6 +179,12 @@ extern void __init at91_add_device_isi(void);
>   /* Touchscreen Controller */
>  extern void __init at91_add_device_tsadcc(void);
>  
> +/* CAN */
> +struct at91_can_data {
> +	void (*transceiver_switch)(int on);
> +};
> +extern void __init at91_add_device_can(struct at91_can_data *data);
> +
>   /* LEDs */
>  extern void __init at91_init_leds(u8 cpu_led, u8 timer_led);
>  extern void __init at91_gpio_leds(struct gpio_led *leds, int nr);

Acked-by: Wolfgang Grandegger <wg@grandegger.com>

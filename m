From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 3/3] at91_can: add driver for Atmel's CAN controller on
 AT91SAM9263
Date: Wed, 16 Sep 2009 12:45:59 +0200
Message-ID: <4AB0C1E7.9070708@pengutronix.de>
References: <1253094405-3216-1-git-send-email-mkl@pengutronix.de>	<1253094405-3216-2-git-send-email-mkl@pengutronix.de>	<1253094405-3216-3-git-send-email-mkl@pengutronix.de> <1253094405-3216-4-git-send-email-mkl@pengutronix.de> <4AB0B8F4.50301@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Socketcan-core@lists.berlios.de,
	linux-arm-kernel@lists.infradead.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48150 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413AbZIPKuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 06:50:03 -0400
In-Reply-To: <4AB0B8F4.50301@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Wolfgang Grandegger wrote:
> Marc Kleine-Budde wrote:
>> This patch add the driver for the SoC CAN controller in Atmel's AT91SAM9263.
>>
>> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
> 
> I already reviewed at91_can.c on the Socket-CAN ML and it's almost OK
> from the Socket-CAN point of view. I just realized two minor issues:
> 
>> ---
>>  drivers/net/can/Kconfig    |    6 +
>>  drivers/net/can/Makefile   |    1 +
>>  drivers/net/can/at91_can.c | 1177 ++++++++++++++++++++++++++++++++++++++++++++
>>  3 files changed, 1184 insertions(+), 0 deletions(-)
>>  create mode 100644 drivers/net/can/at91_can.c
>>
>> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
>> index 0900743..b6d2af1 100644
>> --- a/drivers/net/can/Kconfig
>> +++ b/drivers/net/can/Kconfig
>> @@ -82,6 +82,12 @@ config CAN_KVASER_PCI
>>  	  This driver is for the the PCIcanx and PCIcan cards (1, 2 or
>>  	  4 channel) from Kvaser (http://www.kvaser.com).
>>  
>> +config CAN_AT91
>> +	tristate "Atmel AT91 onchip CAN controller"
>> +	depends on CAN && ARCH_AT91SAM9263
> 
> It should depend on CAN_DEV because it used the CAN device driver interface.

will fix

> 
>> +	---help---
>> +	  This is a driver for the SoC CAN controller in Atmel's AT91SAM9263.
>> +
>>  config CAN_DEBUG_DEVICES
>>  	bool "CAN devices debugging messages"
>>  	depends on CAN
>> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
>> index 523a941..3a54a12 100644
>> --- a/drivers/net/can/Makefile
>> +++ b/drivers/net/can/Makefile
>> @@ -8,5 +8,6 @@ obj-$(CONFIG_CAN_DEV)		+= can-dev.o
>>  can-dev-y			:= dev.o
>>  
>>  obj-$(CONFIG_CAN_SJA1000)	+= sja1000/
>> +obj-$(CONFIG_CAN_AT91)		+= at91_can.o
>>  
>>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
>> diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
>> new file mode 100644
>> index 0000000..cd1e8cb
>> --- /dev/null
>> +++ b/drivers/net/can/at91_can.c
>> @@ -0,0 +1,1177 @@
>> +/*
>> + * at91_can.c - CAN network driver for AT91 SoC CAN controller
>> + *
>> + * (C) 2007 by Hans J. Koch <hjk@linutronix.de>
>> + * (C) 2008, 2009 by Marc Kleine-Budde <kernel@pengutronix.de>
>> + *
>> + * This software may be distributed under the terms of the GNU General
>> + * Public License ("GPL") version 2 as distributed in the 'COPYING'
>> + * file from the main directory of the linux kernel source.
>> + *
>> + * Send feedback to <socketcan-users@lists.berlios.de>
> 
> This driver uses platform data. Could you please add some description on
> how they should be used, e.g. like for the MCP251x:
> 
>  * Your platform definition file should specify something like:
>  *
>  * static struct mcp251x_platform_data mcp251x_info = {
>  *         .oscillator_frequency = 8000000,
>  *         .board_specific_setup = &mcp251x_setup,
>  *         .model = CAN_MCP251X_MCP2510,
>  *         .power_enable = mcp251x_power_enable,
>  *         .transceiver_enable = NULL,
>  * };
>  *
>  * static struct spi_board_info spi_board_info[] = {
>  *         {
>  *                 .modalias      = "mcp251x",
>  *                 .platform_data = &mcp251x_info,
>  *                 .irq           = IRQ_EINT13,
>  *                 .max_speed_hz  = 2*1000*1000,
>  *                 .chip_select   = 2,
>  *         },
>  * };
>  *
>  * Please see mcp251x.h for a description of the fields in
>  * struct mcp251x_platform_data.
> 
> I find that really useful.

good point, I'll add a help text

tnx for the review,
Marc

- --
Pengutronix e.K.                         | Marc Kleine-Budde           |
Linux Solutions for Science and Industry | Phone: +49-231-2826-924     |
Vertretung West/Dortmund                 | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686         | http://www.pengutronix.de   |
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkqwwecACgkQjTAFq1RaXHNb9wCfTQ18W790/Bqsk8gEVWYnxsL6
sTkAmgNF3KzD8ics9UwemxHEi/HE4jIM
=pyRS
-----END PGP SIGNATURE-----

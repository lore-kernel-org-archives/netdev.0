From: Richard Zhao <linuxzsc@gmail.com>
Subject: Re: [PATCH 2/3] ARM: mxc: add mx31pdk Lan9217 support
Date: Tue, 24 Mar 2009 16:59:43 +0800
Message-ID: <4e090d470903240159y6bea45a7w57e627a31fd43fc9@mail.gmail.com>
References: <4e090d470903232344x162ca791q3007954d064ccd00@mail.gmail.com>
	 <20090324075809.GF25436@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Richard Zhao <linuxzsc@gmail.com>, kernel@pengutronix.de,
	linux-arm-kernel@lists.arm.linux.org.uk,
	steve.glendinning@smsc.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.177]:36089 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753651AbZCXI7p convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 04:59:45 -0400
Received: by wa-out-1112.google.com with SMTP id j5so1731080wah.21
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2009 01:59:43 -0700 (PDT)
In-Reply-To: <20090324075809.GF25436@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2009 at 3:58 PM, Sascha Hauer <s.hauer@pengutronix.de> =
wrote:
> On Tue, Mar 24, 2009 at 02:44:41PM +0800, Richard Zhao wrote:
>> Signed-off-by: Richard Zhao <linuxzsc@gmail.com>
>>
>> diff --git a/arch/arm/mach-mx3/mx31pdk.c b/arch/arm/mach-mx3/mx31pdk=
=2Ec
>> index aa7e3c5..45cef70 100644
>> --- a/arch/arm/mach-mx3/mx31pdk.c
>> +++ b/arch/arm/mach-mx3/mx31pdk.c
>> @@ -32,6 +32,8 @@
>> =A0#include <mach/board-mx31pdk.h>
>> =A0#include <mach/imx-uart.h>
>> =A0#include <mach/iomux-mx3.h>
>> +#include <linux/platform_device.h>
>> +#include <linux/smsc911x.h>
>> =A0#include "devices.h"
>> =A0#include "3stack-debug.h"
>>
>> @@ -57,6 +59,43 @@ static inline void mxc_init_imx_uart(void)
>> =A0 =A0 =A0 mxc_register_device(&mxc_uart_device0, &uart_pdata);
>> =A0}
>>
>> +/*lan9217 device*/
>> +#if defined(CONFIG_SMSC911X) || defined(CONFIG_SMSC911X_MODULE)
>
> IMO it is not worth to clutter the code with ifdefs just to save some
> bytes of binary space, but ok, that's just my two cents.
>
Hi Sascha,

ok, I will remove the ifdefs.

Thanks
Richard
>> +static struct resource smsc911x_resources[] =3D {
>> + =A0 =A0 {
>> + =A0 =A0 =A0.start =3D LAN9217_BASE_ADDR,
>> + =A0 =A0 =A0.end =3D LAN9217_BASE_ADDR + 0x100,
>> + =A0 =A0 =A0.flags =3D IORESOURCE_MEM,
>> + =A0 =A0 =A0},
>> + =A0 =A0 {
>> + =A0 =A0 =A0.start =3D LAN9217_IRQ,
>> + =A0 =A0 =A0.end =3D LAN9217_IRQ,
>> + =A0 =A0 =A0.flags =3D IORESOURCE_IRQ,
>> + =A0 =A0 =A0},
>> +};
>
> static struct resource smsc911x_resources[] =3D {
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.start =3D LAN9217_BASE_ADDR,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.end =3D LAN9217_BASE_ADDR + 0x100,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.flags =3D IORESOURCE_MEM,
> =A0 =A0 =A0 =A0},{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.start =3D LAN9217_IRQ,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.end =3D LAN9217_IRQ,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.flags =3D IORESOURCE_IRQ,
> =A0 =A0 =A0 =A0},
> };
>
>> +
>> +static struct smsc911x_platform_config smsc911x_platconfig =3D {
>> + =A0 =A0 .irq_polarity =A0 =3D SMSC911X_IRQ_POLARITY_ACTIVE_LOW,
>> + =A0 =A0 .irq_type =A0 =A0 =A0 =3D SMSC911X_IRQ_TYPE_OPEN_DRAIN,
>> + =A0 =A0 .flags =A0 =A0 =A0 =A0 =A0=3D SMSC911X_USE_16BIT | SMSC911=
X_USE_INTERPHY,
>> +};
>> +
>> +static struct platform_device smsc_lan9217_device =3D {
>> + =A0 =A0 .name =3D "smsc911x",
>> + =A0 =A0 .id =3D 0,
>> + =A0 =A0 .num_resources =3D ARRAY_SIZE(smsc911x_resources),
>> + =A0 =A0 .resource =3D smsc911x_resources,
>> +};
>> +static void mxc_init_enet(void)
>> +{
>> + =A0 =A0 mxc_register_device(&smsc_lan9217_device, &smsc911x_platco=
nfig);
>> +}
>> +#else
>> +static inline void mxc_init_enet(void)
>> +{
>> +}
>> +#endif
>> +
>> =A0static u32 brd_io;
>>
>> =A0static void mxc_expio_irq_handler(u32 irq, struct irq_desc *desc)
>> @@ -217,6 +256,7 @@ static void __init mxc_board_init(void)
>> =A0{
>> =A0 =A0 =A0 mxc_init_imx_uart();
>> =A0 =A0 =A0 mxc_expio_init();
>> + =A0 =A0 mxc_init_enet();
>> =A0}
>>
>> =A0static void __init mx31pdk_timer_init(void)
>> --
>> 1.5.6.3
>>
>
> --
> Pengutronix e.K. =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
| =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 |
> Industrial Linux Solutions =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | http://w=
ww.pengutronix.de/ =A0|
> Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0=
 =A0 =A0|
> Amtsgericht Hildesheim, HRA 2686 =A0 =A0 =A0 =A0 =A0 | Fax: =A0 +49-5=
121-206917-5555 |
>

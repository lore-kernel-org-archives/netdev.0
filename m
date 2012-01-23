From: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Subject: Re: [PATCH V4 2/4] CS89x0 : add CS89x0 platform device to the
 iMX21ADS board
Date: Tue, 24 Jan 2012 00:34:24 +0100
Message-ID: <CAGzjT4eODr-8yUUSLxeZQ_O1H3Fngep=rDwM_RaiT4xT6aVD-A@mail.gmail.com>
References: <1326996830-13548-1-git-send-email-jaccon.bastiaansen@gmail.com>
	<20120123093420.GL5446@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel@pengutronix.de, u.kleine-koenig@pengutronix.de,
	davem@davemloft.net, cavokz@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:45117 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752075Ab2AWXeY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 18:34:24 -0500
Received: by ghrr11 with SMTP id r11so551130ghr.19
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2012 15:34:24 -0800 (PST)
In-Reply-To: <20120123093420.GL5446@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Sascha,

2012/1/23 Sascha Hauer <s.hauer@pengutronix.de>:
> On Thu, Jan 19, 2012 at 07:13:50PM +0100, Jaccon Bastiaansen wrote:
>> Add CS89x0 networking support to the iMX21ADS board by using the
>> platform driver support in the CS89x0 driver.
>>
>> Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
>> ---
>> =A0arch/arm/configs/imx_v4_v5_defconfig | =A0 =A02 ++
>> =A0arch/arm/mach-imx/mach-mx21ads.c =A0 =A0 | =A0 31 +++++++++++++++=
+++++++++++++---
>> =A02 files changed, 30 insertions(+), 3 deletions(-)
>>
>> diff --git a/arch/arm/configs/imx_v4_v5_defconfig b/arch/arm/configs=
/imx_v4_v5_defconfig
>> index 11a4192..fc0106f 100644
>> --- a/arch/arm/configs/imx_v4_v5_defconfig
>> +++ b/arch/arm/configs/imx_v4_v5_defconfig
>> @@ -81,6 +81,8 @@ CONFIG_NET_ETHERNET=3Dy
>> =A0CONFIG_SMC91X=3Dy
>> =A0CONFIG_DM9000=3Dy
>> =A0CONFIG_SMC911X=3Dy
>> +CONFIG_CS89x0=3Dy
>> +CONFIG_CS89x0_PLATFORM=3Dy
>> =A0# CONFIG_NETDEV_1000 is not set
>> =A0# CONFIG_NETDEV_10000 is not set
>> =A0# CONFIG_INPUT_MOUSEDEV is not set
>> diff --git a/arch/arm/mach-imx/mach-mx21ads.c b/arch/arm/mach-imx/ma=
ch-mx21ads.c
>> index 25f8402..4fd37fc 100644
>> --- a/arch/arm/mach-imx/mach-mx21ads.c
>> +++ b/arch/arm/mach-imx/mach-mx21ads.c
>> @@ -37,8 +37,8 @@
>> =A0#define MX21ADS_REG_ADDR(offset) =A0 =A0(void __force __iomem *) =
\
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 (MX21ADS_MMIO_BASE_ADDR + (offset))
>>
>> +#define MX21ADS_CS8900A_MMIO_SIZE =A0 0x200000
>> =A0#define MX21ADS_CS8900A_IRQ =A0 =A0 =A0 =A0 IRQ_GPIOE(11)
>> -#define MX21ADS_CS8900A_IOBASE_REG =A0MX21ADS_REG_ADDR(0x000000)
>> =A0#define MX21ADS_ST16C255_IOBASE_REG MX21ADS_REG_ADDR(0x200000)
>> =A0#define MX21ADS_VERSION_REG =A0 =A0 =A0 =A0 MX21ADS_REG_ADDR(0x40=
0000)
>> =A0#define MX21ADS_IO_REG =A0 =A0 =A0 =A0 =A0 =A0 =A0MX21ADS_REG_ADD=
R(0x800000)
>> @@ -159,6 +159,26 @@ static struct platform_device mx21ads_nor_mtd_d=
evice =3D {
>> =A0 =A0 =A0 .resource =3D &mx21ads_flash_resource,
>> =A0};
>>
>> +static const struct resource mx21ads_cs8900_resources[] __initconst=
 =3D {
>> + =A0 =A0 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 .start =3D MX21_CS1_BASE_ADDR,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .end =3D MX21_CS1_BASE_ADDR + =A0MX21ADS_C=
S8900A_MMIO_SIZE - 1,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .flags =3D IORESOURCE_MEM,
>> + =A0 =A0 },
>> + =A0 =A0 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 .start =3D MX21ADS_CS8900A_IRQ,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .end =3D MX21ADS_CS8900A_IRQ,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .flags =3D IORESOURCE_IRQ,
>> + =A0 =A0 }
>> +};
>> +
>> +static const struct platform_device_info mx21ads_cs8900_devinfo __i=
nitconst =3D {
>> + =A0 =A0 .name =3D "cs89x0",
>> + =A0 =A0 .id =3D 0,
>> + =A0 =A0 .res =3D mx21ads_cs8900_resources,
>> + =A0 =A0 .num_res =3D ARRAY_SIZE(mx21ads_cs8900_resources),
>> +};
>> +
>> =A0static const struct imxuart_platform_data uart_pdata_rts __initco=
nst =3D {
>> =A0 =A0 =A0 .flags =3D IMXUART_HAVE_RTSCTS,
>> =A0};
>> @@ -254,14 +274,17 @@ mx21ads_nand_board_info __initconst =3D {
>> =A0static struct map_desc mx21ads_io_desc[] __initdata =3D {
>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* Memory-mapped I/O on MX21ADS Base board:
>> - =A0 =A0 =A0* =A0 - CS8900A Ethernet controller
>> =A0 =A0 =A0 =A0* =A0 - ST16C2552CJ UART
>> =A0 =A0 =A0 =A0* =A0 - CPU and Base board version
>> =A0 =A0 =A0 =A0* =A0 - Base board I/O register
>> + =A0 =A0 =A0*
>> + =A0 =A0 =A0* Note that the CS8900 uses the first MX21ADS_CS8900A_M=
MIO_SIZE
>> + =A0 =A0 =A0* bytes of the CS1 memory range.
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .virtual =3D MX21ADS_MMIO_BASE_ADDR,
>> - =A0 =A0 =A0 =A0 =A0 =A0 .pfn =3D __phys_to_pfn(MX21_CS1_BASE_ADDR)=
,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .pfn =3D __phys_to_pfn(MX21_CS1_BASE_ADDR =
+
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 MX21ADS_CS8900A_MMIO_SIZE),
>
> Since you now use ioremap the cs89x0 driver this mapping is not used
> for the cs89x0 anymore, so it's strange to have references to it
> here.
> You still need the mapping though, but only for MX21ADS_IO_REG.
>

The ST16C255 UART is the first peripheral in the CS1 memory range for
which this fixed mapping is now required. I could create another
constant (for example: MX21ADS_ST16C255_OFFSET) to indicate the offset
in the CS1 memory range where the mapping should start. But since that
would create another constant with the same value as
MX21ADS_CS8900A_MMIO_SIZE, I decided to use MX21ADS_CS8900A_MMIO_SIZE.

Do you prefer to a constant with another name here?

> Sascha
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

Regards,
  Jaccon

From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH V4 2/4] CS89x0 : add CS89x0 platform device to the
 iMX21ADS board
Date: Tue, 24 Jan 2012 11:56:53 +0100
Message-ID: <20120124105653.GU5446@pengutronix.de>
References: <1326996830-13548-1-git-send-email-jaccon.bastiaansen@gmail.com>
 <20120123093420.GL5446@pengutronix.de>
 <CAGzjT4eODr-8yUUSLxeZQ_O1H3Fngep=rDwM_RaiT4xT6aVD-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel@pengutronix.de, u.kleine-koenig@pengutronix.de,
	davem@davemloft.net, cavokz@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:38399 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755868Ab2AXK5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 05:57:10 -0500
Content-Disposition: inline
In-Reply-To: <CAGzjT4eODr-8yUUSLxeZQ_O1H3Fngep=rDwM_RaiT4xT6aVD-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2012 at 12:34:24AM +0100, Jaccon Bastiaansen wrote:
> Hello Sascha,
>=20
> 2012/1/23 Sascha Hauer <s.hauer@pengutronix.de>:
> > On Thu, Jan 19, 2012 at 07:13:50PM +0100, Jaccon Bastiaansen wrote:
> >> Add CS89x0 networking support to the iMX21ADS board by using the
> >> platform driver support in the CS89x0 driver.
> >>
> >> Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
> >> ---
> >> =A0arch/arm/configs/imx_v4_v5_defconfig | =A0 =A02 ++
> >> =A0arch/arm/mach-imx/mach-mx21ads.c =A0 =A0 | =A0 31 +++++++++++++=
+++++++++++++++---
> >> =A02 files changed, 30 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/arch/arm/configs/imx_v4_v5_defconfig b/arch/arm/confi=
gs/imx_v4_v5_defconfig
> >> index 11a4192..fc0106f 100644
> >> --- a/arch/arm/configs/imx_v4_v5_defconfig
> >> +++ b/arch/arm/configs/imx_v4_v5_defconfig
> >> @@ -81,6 +81,8 @@ CONFIG_NET_ETHERNET=3Dy
> >> =A0CONFIG_SMC91X=3Dy
> >> =A0CONFIG_DM9000=3Dy
> >> =A0CONFIG_SMC911X=3Dy
> >> +CONFIG_CS89x0=3Dy
> >> +CONFIG_CS89x0_PLATFORM=3Dy
> >> =A0# CONFIG_NETDEV_1000 is not set
> >> =A0# CONFIG_NETDEV_10000 is not set
> >> =A0# CONFIG_INPUT_MOUSEDEV is not set
> >> diff --git a/arch/arm/mach-imx/mach-mx21ads.c b/arch/arm/mach-imx/=
mach-mx21ads.c
> >> index 25f8402..4fd37fc 100644
> >> --- a/arch/arm/mach-imx/mach-mx21ads.c
> >> +++ b/arch/arm/mach-imx/mach-mx21ads.c
> >> @@ -37,8 +37,8 @@
> >> =A0#define MX21ADS_REG_ADDR(offset) =A0 =A0(void __force __iomem *=
) \
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 (MX21ADS_MMIO_BASE_ADDR + (offset))
> >>
> >> +#define MX21ADS_CS8900A_MMIO_SIZE =A0 0x200000
> >> =A0#define MX21ADS_CS8900A_IRQ =A0 =A0 =A0 =A0 IRQ_GPIOE(11)
> >> -#define MX21ADS_CS8900A_IOBASE_REG =A0MX21ADS_REG_ADDR(0x000000)
> >> =A0#define MX21ADS_ST16C255_IOBASE_REG MX21ADS_REG_ADDR(0x200000)
> >> =A0#define MX21ADS_VERSION_REG =A0 =A0 =A0 =A0 MX21ADS_REG_ADDR(0x=
400000)
> >> =A0#define MX21ADS_IO_REG =A0 =A0 =A0 =A0 =A0 =A0 =A0MX21ADS_REG_A=
DDR(0x800000)
> >> @@ -159,6 +159,26 @@ static struct platform_device mx21ads_nor_mtd=
_device =3D {
> >> =A0 =A0 =A0 .resource =3D &mx21ads_flash_resource,
> >> =A0};
> >>
> >> +static const struct resource mx21ads_cs8900_resources[] __initcon=
st =3D {
> >> + =A0 =A0 {
> >> + =A0 =A0 =A0 =A0 =A0 =A0 .start =3D MX21_CS1_BASE_ADDR,
> >> + =A0 =A0 =A0 =A0 =A0 =A0 .end =3D MX21_CS1_BASE_ADDR + =A0MX21ADS=
_CS8900A_MMIO_SIZE - 1,
> >> + =A0 =A0 =A0 =A0 =A0 =A0 .flags =3D IORESOURCE_MEM,
> >> + =A0 =A0 },
> >> + =A0 =A0 {
> >> + =A0 =A0 =A0 =A0 =A0 =A0 .start =3D MX21ADS_CS8900A_IRQ,
> >> + =A0 =A0 =A0 =A0 =A0 =A0 .end =3D MX21ADS_CS8900A_IRQ,
> >> + =A0 =A0 =A0 =A0 =A0 =A0 .flags =3D IORESOURCE_IRQ,
> >> + =A0 =A0 }
> >> +};
> >> +
> >> +static const struct platform_device_info mx21ads_cs8900_devinfo _=
_initconst =3D {
> >> + =A0 =A0 .name =3D "cs89x0",
> >> + =A0 =A0 .id =3D 0,
> >> + =A0 =A0 .res =3D mx21ads_cs8900_resources,
> >> + =A0 =A0 .num_res =3D ARRAY_SIZE(mx21ads_cs8900_resources),
> >> +};
> >> +
> >> =A0static const struct imxuart_platform_data uart_pdata_rts __init=
const =3D {
> >> =A0 =A0 =A0 .flags =3D IMXUART_HAVE_RTSCTS,
> >> =A0};
> >> @@ -254,14 +274,17 @@ mx21ads_nand_board_info __initconst =3D {
> >> =A0static struct map_desc mx21ads_io_desc[] __initdata =3D {
> >> =A0 =A0 =A0 /*
> >> =A0 =A0 =A0 =A0* Memory-mapped I/O on MX21ADS Base board:
> >> - =A0 =A0 =A0* =A0 - CS8900A Ethernet controller
> >> =A0 =A0 =A0 =A0* =A0 - ST16C2552CJ UART
> >> =A0 =A0 =A0 =A0* =A0 - CPU and Base board version
> >> =A0 =A0 =A0 =A0* =A0 - Base board I/O register
> >> + =A0 =A0 =A0*
> >> + =A0 =A0 =A0* Note that the CS8900 uses the first MX21ADS_CS8900A=
_MMIO_SIZE
> >> + =A0 =A0 =A0* bytes of the CS1 memory range.
> >> =A0 =A0 =A0 =A0*/
> >> =A0 =A0 =A0 {
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .virtual =3D MX21ADS_MMIO_BASE_ADDR,
> >> - =A0 =A0 =A0 =A0 =A0 =A0 .pfn =3D __phys_to_pfn(MX21_CS1_BASE_ADD=
R),
> >> + =A0 =A0 =A0 =A0 =A0 =A0 .pfn =3D __phys_to_pfn(MX21_CS1_BASE_ADD=
R +
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 MX21ADS_CS8900A_MMIO_SIZE),
> >
> > Since you now use ioremap the cs89x0 driver this mapping is not use=
d
> > for the cs89x0 anymore, so it's strange to have references to it
> > here.
> > You still need the mapping though, but only for MX21ADS_IO_REG.
> >
>=20
> The ST16C255 UART is the first peripheral in the CS1 memory range for
> which this fixed mapping is now required. I could create another
> constant (for example: MX21ADS_ST16C255_OFFSET) to indicate the offse=
t
> in the CS1 memory range where the mapping should start. But since tha=
t
> would create another constant with the same value as
> MX21ADS_CS8900A_MMIO_SIZE, I decided to use MX21ADS_CS8900A_MMIO_SIZE=
=2E
>=20
> Do you prefer to a constant with another name here?

Ok, looking again at it I understand what you are doing here and it
seems wrong. Instead of mapping MX21_CS1_BASE_ADDR you now map
MX21_CS1_BASE_ADDR + MX21ADS_CS8900A_MMIO_SIZE. This means that the
offset to MX21ADS_IO_REG is no longer 0x800000 but
0x800000 - MX21ADS_CS8900A_MMIO_SIZE.
Please just keep the mapping like it was before, it won't hurt.
BTW the 8250 serial driver also ioremaps the memory if you add
UPF_IOREMAP to the platform data.

Sascha

--=20
Pengutronix e.K.                           |                           =
  |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0  =
  |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-555=
5 |

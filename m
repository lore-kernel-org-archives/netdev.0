From: Daniel Baluta <daniel.baluta-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next-2.6] can: add support for CAN interface cards
	based on the PLX90xx PCI bridge
Date: Fri, 29 Jan 2010 11:55:16 +0200
Message-ID: <413a6a951001290155t64711fd2h3030bdcf2ce2e44f@mail.gmail.com>
References: <1264758309-1632-1-git-send-email-chebl@star.inp.nsk.su>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Pavel B. Cheblakov" <P.B.Cheblakov-tHBF8D5G73F4OK5fxMSSsQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1264758309-1632-1-git-send-email-chebl-LmX6Lu7C9G7nhuLbLO4Grw@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 29, 2010 at 11:45 AM, Pavel B. Cheblakov
<P.B.Cheblakov-tHBF8D5G73F4OK5fxMSSsQ@public.gmane.org> wrote:
> From: Pavel Cheblakov <P.B.Cheblakov-tHBF8D5G73F4OK5fxMSSsQ@public.gmane.org>
>
> This driver is for CAN interface cards based on the PLX90xx PCI bridge.
> Driver supports now:
> =A0- Adlink PCI-7841/cPCI-7841 card (http://www.adlinktech.com/)
> =A0- Adlink PCI-7841/cPCI-7841 SE card
> =A0- Marathon CAN-bus-PCI card (http://www.marathon.ru/)
> =A0- TEWS TECHNOLOGIES TPMC810 card (http://www.tews.com/)
>
> Signed-off-by: Pavel Cheblakov <P.B.Cheblakov-tHBF8D5G73F4OK5fxMSSsQ@public.gmane.org>
> ---
> =A0drivers/net/can/sja1000/Kconfig =A0 | =A0 12 +
> =A0drivers/net/can/sja1000/Makefile =A0| =A0 =A01 +
> =A0drivers/net/can/sja1000/plx_pci.c | =A0457 +++++++++++++++++++++++++++=
++++++++++
> =A03 files changed, 470 insertions(+), 0 deletions(-)
> =A0create mode 100644 drivers/net/can/sja1000/plx_pci.c
>
> diff --git a/drivers/net/can/sja1000/Kconfig b/drivers/net/can/sja1000/Kc=
onfig
> index 4c67492..9e277d6 100644
> --- a/drivers/net/can/sja1000/Kconfig
> +++ b/drivers/net/can/sja1000/Kconfig
> @@ -44,4 +44,16 @@ config CAN_KVASER_PCI
> =A0 =A0 =A0 =A0 =A0This driver is for the the PCIcanx and PCIcan cards (1=
, 2 or
> =A0 =A0 =A0 =A0 =A04 channel) from Kvaser (http://www.kvaser.com).
>
> +config CAN_PLX_PCI
> + =A0 =A0 =A0 tristate "PLX90xx PCI-bridge based Cards"
> + =A0 =A0 =A0 depends on PCI
> + =A0 =A0 =A0 ---help---
> + =A0 =A0 =A0 =A0 This driver is for CAN interface cards based on
> + =A0 =A0 =A0 =A0 the PLX90xx PCI bridge.
> + =A0 =A0 =A0 =A0 Driver supports now:
> + =A0 =A0 =A0 =A0 =A0- Adlink PCI-7841/cPCI-7841 card (http://www.adlinkt=
ech.com/)
> + =A0 =A0 =A0 =A0 =A0- Adlink PCI-7841/cPCI-7841 SE card
> + =A0 =A0 =A0 =A0 =A0- Marathon CAN-bus-PCI card (http://www.marathon.ru/)
> + =A0 =A0 =A0 =A0 =A0- TEWS TECHNOLOGIES TPMC810 card (http://www.tews.co=
m/)
> +
> =A0endif
> diff --git a/drivers/net/can/sja1000/Makefile b/drivers/net/can/sja1000/M=
akefile
> index 9d245ac..ce92455 100644
> --- a/drivers/net/can/sja1000/Makefile
> +++ b/drivers/net/can/sja1000/Makefile
> @@ -8,5 +8,6 @@ obj-$(CONFIG_CAN_SJA1000_PLATFORM) +=3D sja1000_platform.o
> =A0obj-$(CONFIG_CAN_SJA1000_OF_PLATFORM) +=3D sja1000_of_platform.o
> =A0obj-$(CONFIG_CAN_EMS_PCI) +=3D ems_pci.o
> =A0obj-$(CONFIG_CAN_KVASER_PCI) +=3D kvaser_pci.o
> +obj-$(CONFIG_CAN_PLX_PCI) +=3D plx_pci.o
>
> =A0ccflags-$(CONFIG_CAN_DEBUG_DEVICES) :=3D -DDEBUG
> diff --git a/drivers/net/can/sja1000/plx_pci.c b/drivers/net/can/sja1000/=
plx_pci.c
> new file mode 100644
> index 0000000..4b7a697
> --- /dev/null
> +++ b/drivers/net/can/sja1000/plx_pci.c
> @@ -0,0 +1,457 @@
> +/*
> + * Copyright (C) 2008-2010 Pavel Cheblakov <P.B.Cheblakov-tHBF8D5G73F4OK5fxMSSsQ@public.gmane.org>
> + *
> + * Derived from the ems_pci.c driver:
> + * =A0 =A0 Copyright (C) 2007 Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
> + * =A0 =A0 Copyright (C) 2008 Markus Plessing <plessing-zsNKPWJ8Pib6hrUXjxyGrA@public.gmane.org>
> + * =A0 =A0 Copyright (C) 2008 Sebastian Haas <haas-zsNKPWJ8Pib6hrUXjxyGrA@public.gmane.org>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the version 2 of the GNU General Public License
> + * as published by the Free Software Foundation
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software Foundatio=
n,
> + * Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/interrupt.h>
> +#include <linux/netdevice.h>
> +#include <linux/delay.h>
> +#include <linux/pci.h>
> +#include <linux/can.h>
> +#include <linux/can/dev.h>
> +#include <linux/io.h>
> +
> +#include "sja1000.h"
> +
> +#define DRV_NAME =A0"sja1000_plx_pci"
> +
> +MODULE_AUTHOR("Pavel Cheblakov <P.B.Cheblakov-tHBF8D5G73F4OK5fxMSSsQ@public.gmane.org>");
> +MODULE_DESCRIPTION("Socket-CAN driver for PLX90xx PCI-bridge cards with "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"the SJA1000 chips");
> +MODULE_SUPPORTED_DEVICE("Adlink PCI-7841/cPCI-7841, "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "Adlink PCI-7841/cPCI-7841 =
SE, "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "Marathon CAN-bus-PCI, "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "TEWS TECHNOLOGIES TPMC810"=
);
> +MODULE_LICENSE("GPL v2");
> +
> +#define PLX_PCI_MAX_CHAN 2
> +
> +struct plx_pci_card {
> + =A0 =A0 =A0 int channels; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* detect=
ed channels count */
> + =A0 =A0 =A0 struct net_device *net_dev[PLX_PCI_MAX_CHAN];
> + =A0 =A0 =A0 void __iomem *conf_addr;
> +};
> +
> +#define PLX_PCI_CAN_CLOCK (16000000 / 2)
> +
> +/* PLX90xx registers */
> +#define PLX_INTCSR =A0 =A0 0x4c =A0 =A0 =A0 =A0 =A0 =A0/* Interrup Contr=
ol/Status */

Small type: Interrup -> Interrupt

> +#define PLX_CNTRL =A0 =A0 =A00x50 =A0 =A0 =A0 =A0 =A0 =A0/* User I/O, Di=
rect Slave Response,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0* Serial EEPROM, and Initialization
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0* Control register
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0*/
> +
> +#define PLX_LINT1_EN =A0 0x1 =A0 =A0 =A0 =A0 =A0 =A0 /* Local interrupt =
1 enable */
> +#define PLX_LINT2_EN =A0 (1 << 3) =A0 =A0 =A0 =A0/* Local interrupt 2 en=
able */
> +#define PLX_PCI_INT_EN (1 << 6) =A0 =A0 =A0 =A0/* PCI Interrupt Enable */
> +#define PLX_PCI_RESET =A0(1 << 30) =A0 =A0 =A0 /* PCI Adapter Software R=
eset */
> +
> +/*
> + * The board configuration is probably following:
> + * RX1 is connected to ground.
> + * TX1 is not connected.
> + * CLKO is not connected.
> + * Setting the OCR register to 0xDA is a good idea.
> + * This means normal output mode, push-pull and the correct polarity.
> + */
> +#define PLX_PCI_OCR =A0 =A0(OCR_TX0_PUSHPULL | OCR_TX1_PUSHPULL)
> +
> +/*
> + * In the CDR register, you should set CBP to 1.
> + * You will probably also want to set the clock divider value to 7
> + * (meaning direct oscillator output) because the second SJA1000 chip
> + * is driven by the first one CLKOUT output.
> + */
> +#define PLX_PCI_CDR =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(CDR_CBP | CD=
R_CLKOUT_MASK)
> +
> +#define ADLINK_PCI_VENDOR_ID =A0 =A0 =A0 =A0 =A0 0x144A
> +#define ADLINK_PCI_DEVICE_ID =A0 =A0 =A0 =A0 =A0 0x7841
> +
> +#define MARATHON_PCI_DEVICE_ID =A0 =A0 =A0 =A0 0x2715
> +
> +#define TEWS_PCI_VENDOR_ID =A0 =A0 =A0 =A0 =A0 =A0 0x1498
> +#define TEWS_PCI_DEVICE_ID_TMPC810 =A0 =A0 0x032A
> +
> +static void plx_pci_reset_common(struct pci_dev *pdev);
> +static void plx_pci_reset_marathon(struct pci_dev *pdev);
> +
> +struct plx_pci_channel_map {
> + =A0 =A0 =A0 u32 bar;
> + =A0 =A0 =A0 u32 offset;
> + =A0 =A0 =A0 u32 size; =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* 0x00 - auto, e.g. =
length of entire bar */
> +};
> +
> +struct plx_pci_card_info {
> + =A0 =A0 =A0 const char *name;
> + =A0 =A0 =A0 int channel_count;
> + =A0 =A0 =A0 u32 can_clock;
> + =A0 =A0 =A0 u8 ocr; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* output control r=
egister */
> + =A0 =A0 =A0 u8 cdr; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* clock divider re=
gister */
> +
> + =A0 =A0 =A0 /* Parameters for mapping local configuration space */
> + =A0 =A0 =A0 struct plx_pci_channel_map conf_map;
> +
> + =A0 =A0 =A0 /* Parameters for mapping the SJA1000 chips */
> + =A0 =A0 =A0 struct plx_pci_channel_map chan_map_tbl[PLX_PCI_MAX_CHAN];
> +
> + =A0 =A0 =A0 /* Pointer to device-dependent reset function */
> + =A0 =A0 =A0 void (*reset_func)(struct pci_dev *pdev);
> +};
> +
> +static struct plx_pci_card_info plx_pci_card_info_adlink __devinitdata =
=3D {
> + =A0 =A0 =A0 "Adlink PCI-7841/cPCI-7841", 2,
> + =A0 =A0 =A0 PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
> + =A0 =A0 =A0 {1, 0x00, 0x00}, { {2, 0x00, 0x80}, {2, 0x80, 0x80} },
> + =A0 =A0 =A0 &plx_pci_reset_common
> + =A0 =A0 =A0 /* based on PLX9052 */
> +};
> +
> +static struct plx_pci_card_info plx_pci_card_info_adlink_se __devinitdat=
a =3D {
> + =A0 =A0 =A0 "Adlink PCI-7841/cPCI-7841 SE", 2,
> + =A0 =A0 =A0 PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
> + =A0 =A0 =A0 {0, 0x00, 0x00}, { {2, 0x00, 0x80}, {2, 0x80, 0x80} },
> + =A0 =A0 =A0 &plx_pci_reset_common
> + =A0 =A0 =A0 /* based on PLX9052 */
> +};
> +
> +static struct plx_pci_card_info plx_pci_card_info_marathon __devinitdata=
 =3D {
> + =A0 =A0 =A0 "Marathon CAN-bus-PCI", 2,
> + =A0 =A0 =A0 PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
> + =A0 =A0 =A0 {0, 0x00, 0x00}, { {2, 0x00, 0x00}, {4, 0x00, 0x00} },
> + =A0 =A0 =A0 &plx_pci_reset_marathon
> + =A0 =A0 =A0 /* based on PLX9052 */
> +};
> +
> +static struct plx_pci_card_info plx_pci_card_info_tews __devinitdata =3D=
 {
> + =A0 =A0 =A0 "TEWS TECHNOLOGIES TPMC810", 2,
> + =A0 =A0 =A0 PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
> + =A0 =A0 =A0 {0, 0x00, 0x00}, { {2, 0x000, 0x80}, {2, 0x100, 0x80} },
> + =A0 =A0 =A0 &plx_pci_reset_common
> + =A0 =A0 =A0 /* based on PLX9030 */
> +};
> +
> +static struct pci_device_id plx_pci_tbl[] =3D {
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Adlink PCI-7841/cPCI-7841 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ADLINK_PCI_VENDOR_ID, ADLINK_PCI_DEVICE_ID,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 PCI_ANY_ID, PCI_ANY_ID,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 PCI_CLASS_NETWORK_OTHER << 8, ~0,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (kernel_ulong_t)&plx_pci_card_info_adlink
> + =A0 =A0 =A0 },
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Adlink PCI-7841/cPCI-7841 SE */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ADLINK_PCI_VENDOR_ID, ADLINK_PCI_DEVICE_ID,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 PCI_ANY_ID, PCI_ANY_ID,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 PCI_CLASS_COMMUNICATION_OTHER << 8, ~0,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (kernel_ulong_t)&plx_pci_card_info_adlink_se
> + =A0 =A0 =A0 },
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Marathon CAN-bus-PCI card */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 PCI_VENDOR_ID_PLX, MARATHON_PCI_DEVICE_ID,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 PCI_ANY_ID, PCI_ANY_ID,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 0, 0,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (kernel_ulong_t)&plx_pci_card_info_marathon
> + =A0 =A0 =A0 },
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* TEWS TECHNOLOGIES TPMC810 card */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 TEWS_PCI_VENDOR_ID, TEWS_PCI_DEVICE_ID_TMPC=
810,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 PCI_ANY_ID, PCI_ANY_ID,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 0, 0,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (kernel_ulong_t)&plx_pci_card_info_tews
> + =A0 =A0 =A0 },
> + =A0 =A0 =A0 { 0,}
> +};
> +MODULE_DEVICE_TABLE(pci, plx_pci_tbl);
> +
> +static u8 plx_pci_read_reg(const struct sja1000_priv *priv, int port)
> +{
> + =A0 =A0 =A0 return ioread8(priv->reg_base + port);
> +}
> +
> +static void plx_pci_write_reg(const struct sja1000_priv *priv, int port,=
 u8 val)
> +{
> + =A0 =A0 =A0 iowrite8(val, priv->reg_base + port);
> +}
> +
> +/*
> + * Check if a CAN controller is present at the specified location
> + * by trying to switch 'em from the Basic mode into the PeliCAN mode.
> + * Also check states of some registers in reset mode.
> + */
> +static inline int plx_pci_check_sja1000(const struct sja1000_priv *priv)
> +{
> + =A0 =A0 =A0 int flag =3D 0;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Check registers after hardware reset (the Basic mode)
> + =A0 =A0 =A0 =A0* See states on p. 10 of the Datasheet.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if ((priv->read_reg(priv, REG_MOD) & 0xa1) =3D=3D 0x21 &&
> + =A0 =A0 =A0 =A0 =A0 (priv->read_reg(priv, REG_SR) =3D=3D 0x0c) &&
> + =A0 =A0 =A0 =A0 =A0 (priv->read_reg(priv, REG_IR) =3D=3D 0xe0))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 flag =3D 1;
> +
> + =A0 =A0 =A0 /* Bring the SJA1000 into the PeliCAN mode*/
> + =A0 =A0 =A0 priv->write_reg(priv, REG_CDR, CDR_PELICAN);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Check registers after reset in the PeliCAN mode.
> + =A0 =A0 =A0 =A0* See states on p. 23 of the Datasheet.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if ((priv->read_reg(priv, REG_MOD) & 0xf1) =3D=3D 0x01 &&
> + =A0 =A0 =A0 =A0 =A0 (priv->read_reg(priv, REG_SR) & 0x37) =3D=3D 0x34 &&
> + =A0 =A0 =A0 =A0 =A0 (priv->read_reg(priv, REG_IR) & 0xfb) =3D=3D 0x00)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return flag;
> +
> + =A0 =A0 =A0 return 0;
Perhaps some defines here will increase readability ?
> +}
> +
> +/*
> + * PLX90xx software reset
> + * Also LRESET# asserts and brings to reset device on the Local Bus (if =
wired).
> + * For most cards it's enough for reset the SJA1000 chips.
> + */
> +static void plx_pci_reset_common(struct pci_dev *pdev)
> +{
> + =A0 =A0 =A0 struct plx_pci_card *card =3D pci_get_drvdata(pdev);
> + =A0 =A0 =A0 u32 cntrl;
> +
> + =A0 =A0 =A0 cntrl =3D ioread32(card->conf_addr + PLX_CNTRL);
> + =A0 =A0 =A0 cntrl |=3D PLX_PCI_RESET;
> + =A0 =A0 =A0 iowrite32(cntrl, card->conf_addr + PLX_CNTRL);
> + =A0 =A0 =A0 udelay(100);
> + =A0 =A0 =A0 cntrl ^=3D PLX_PCI_RESET;
> + =A0 =A0 =A0 iowrite32(cntrl, card->conf_addr + PLX_CNTRL);
> +};
> +
> +/* Special reset function for Marathon card */
> +static void plx_pci_reset_marathon(struct pci_dev *pdev)
> +{
> + =A0 =A0 =A0 void __iomem *reset_addr;
> + =A0 =A0 =A0 int i;
> + =A0 =A0 =A0 int reset_bar[2] =3D {3, 5};
> +
> + =A0 =A0 =A0 plx_pci_reset_common(pdev);
> +
> + =A0 =A0 =A0 for (i =3D 0; i < 2; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 reset_addr =3D pci_iomap(pdev, reset_bar[i]=
, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!reset_addr) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pdev->dev, "Failed=
 to remap reset "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "space %d (=
BAR%d)\n", i, reset_bar[i]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* reset the SJA1000 chip */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 iowrite8(0x1, reset_addr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 udelay(100);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pci_iounmap(pdev, reset_add=
r);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +}
> +
> +static void plx_pci_del_card(struct pci_dev *pdev)
> +{
> + =A0 =A0 =A0 struct plx_pci_card *card =3D pci_get_drvdata(pdev);
> + =A0 =A0 =A0 struct net_device *dev;
> + =A0 =A0 =A0 struct sja1000_priv *priv;
> + =A0 =A0 =A0 int i =3D 0;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < card->channels; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev =3D card->net_dev[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!dev)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_info(&pdev->dev, "Removing %s\n", dev->=
name);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unregister_sja1000dev(dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv =3D netdev_priv(dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (priv->reg_base)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pci_iounmap(pdev, priv->reg=
_base);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_sja1000dev(dev);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 plx_pci_reset_common(pdev);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Disable interrupts from PCI-card (PLX90xx) and disable=
 Local_1,
> + =A0 =A0 =A0 =A0* Local_2 interrupts
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 iowrite32(0x0, card->conf_addr + PLX_INTCSR);
> +
> + =A0 =A0 =A0 if (card->conf_addr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pci_iounmap(pdev, card->conf_addr);
> +
> + =A0 =A0 =A0 kfree(card);
> +
> + =A0 =A0 =A0 pci_disable_device(pdev);
> + =A0 =A0 =A0 pci_set_drvdata(pdev, NULL);
> +}
> +
> +/*
> + * Probe PLX90xx based device for the SJA1000 chips and register each
> + * available CAN channel to SJA1000 Socket-CAN subsystem.
> + */
> +static int __devinit plx_pci_add_card(struct pci_dev *pdev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 const struct pci_device_id *ent)
> +{
> + =A0 =A0 =A0 struct sja1000_priv *priv;
> + =A0 =A0 =A0 struct net_device *dev;
> + =A0 =A0 =A0 struct plx_pci_card *card;
> + =A0 =A0 =A0 struct plx_pci_card_info *ci;
> + =A0 =A0 =A0 int err, i;
> + =A0 =A0 =A0 u32 val;
> + =A0 =A0 =A0 void __iomem *addr;
> +
> + =A0 =A0 =A0 ci =3D (struct plx_pci_card_info *)ent->driver_data;
> +
> + =A0 =A0 =A0 if (pci_enable_device(pdev) < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pdev->dev, "Failed to enable PCI d=
evice\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 dev_info(&pdev->dev, "Detected \"%s\" card at slot #%i\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ci->name, PCI_SLOT(pdev->devfn));
> +
> + =A0 =A0 =A0 /* Allocate card structures to hold addresses, ... */
> + =A0 =A0 =A0 card =3D kzalloc(sizeof(*card), GFP_KERNEL);
> + =A0 =A0 =A0 if (!card) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pdev->dev, "Unable to allocate mem=
ory\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pci_disable_device(pdev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 pci_set_drvdata(pdev, card);
> +
> + =A0 =A0 =A0 card->channels =3D 0;
> +
> + =A0 =A0 =A0 /* Remap PLX90xx configuration space */
> + =A0 =A0 =A0 addr =3D pci_iomap(pdev, ci->conf_map.bar, ci->conf_map.siz=
e);
> + =A0 =A0 =A0 if (!addr) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pdev->dev, "Failed to remap config=
uration space "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "(BAR%d)\n", ci->conf_map.b=
ar);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto failure_cleanup;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 card->conf_addr =3D addr + ci->conf_map.offset;
> +
> + =A0 =A0 =A0 ci->reset_func(pdev);
> +
> + =A0 =A0 =A0 /* Detect available channels */
> + =A0 =A0 =A0 for (i =3D 0; i < ci->channel_count; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct plx_pci_channel_map *cm =3D &ci->cha=
n_map_tbl[i];
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev =3D alloc_sja1000dev(0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!dev) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto failure_cleanup;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 card->net_dev[i] =3D dev;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv =3D netdev_priv(dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->priv =3D card;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->irq_flags =3D IRQF_SHARED;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->irq =3D pdev->irq;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Remap IO space of the SJA1000 chips
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* This is device-dependent mapping
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 addr =3D pci_iomap(pdev, cm->bar, cm->size);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!addr) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pdev->dev, "Failed=
 to remap BAR%d\n", cm->bar);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto failure_cleanup;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->reg_base =3D addr + cm->offset;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->read_reg =3D plx_pci_read_reg;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->write_reg =3D plx_pci_write_reg;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Check if channel is present */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (plx_pci_check_sja1000(priv)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->can.clock.freq =3D ci=
->can_clock;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->ocr =3D ci->ocr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->cdr =3D ci->cdr;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 SET_NETDEV_DEV(dev, &pdev->=
dev);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Register SJA1000 device =
*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D register_sja1000dev=
(dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pd=
ev->dev, "Registering device failed "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 "(err=3D%d)\n", err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_sja100=
0dev(dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto failur=
e_cleanup;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 card->channels++;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_info(&pdev->dev, "Chann=
el #%d at 0x%p, irq %d "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"registe=
red as %s\n", i + 1, priv->reg_base,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->irq=
, dev->name);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pdev->dev, "Channe=
l #%d not detected\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 i + 1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_sja1000dev(dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (!card->channels) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -ENODEV;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto failure_cleanup;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Enable interrupts from PCI-card (PLX90xx) and enable L=
ocal_1,
> + =A0 =A0 =A0 =A0* Local_2 interrupts from the SJA1000 chips
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 val =3D ioread32(card->conf_addr + PLX_INTCSR);
> + =A0 =A0 =A0 val |=3D PLX_LINT1_EN | PLX_LINT2_EN | PLX_PCI_INT_EN;
> + =A0 =A0 =A0 iowrite32(val, card->conf_addr + PLX_INTCSR);
> +
> + =A0 =A0 =A0 return 0;
> +
> +failure_cleanup:
> + =A0 =A0 =A0 dev_err(&pdev->dev, "Error: %d. Cleaning Up.\n", err);
> +
> + =A0 =A0 =A0 plx_pci_del_card(pdev);
> +
> + =A0 =A0 =A0 return err;
> +}
> +
> +static struct pci_driver plx_pci_driver =3D {
> + =A0 =A0 =A0 .name =3D DRV_NAME,
> + =A0 =A0 =A0 .id_table =3D plx_pci_tbl,
> + =A0 =A0 =A0 .probe =3D plx_pci_add_card,
> + =A0 =A0 =A0 .remove =3D plx_pci_del_card,
> +};
> +
> +static int __init plx_pci_init(void)
> +{
> + =A0 =A0 =A0 return pci_register_driver(&plx_pci_driver);
> +}
> +
> +static void __exit plx_pci_exit(void)
> +{
> + =A0 =A0 =A0 pci_unregister_driver(&plx_pci_driver);
> +}
> +
> +module_init(plx_pci_init);
> +module_exit(plx_pci_exit);
> --
> 1.6.0.6
>
> _______________________________________________
> Socketcan-core mailing list
> Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
> https://lists.berlios.de/mailman/listinfo/socketcan-core
>

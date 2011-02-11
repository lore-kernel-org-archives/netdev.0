From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v2 09/13] can: pruss CAN driver.
Date: Fri, 11 Feb 2011 22:33:20 +0100
Message-ID: <4D55AB20.8060803@pengutronix.de>
References: <1297435892-28278-1-git-send-email-subhasish@mistralsolutions.com>
	<1297435892-28278-10-git-send-email-subhasish@mistralsolutions.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4015857869512164788=="
Cc: sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	CAN NETWORK DRIVERS <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, nsekhar-l0cyMroinI0@public.gmane.org,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	CAN NETWORK DRIVERS <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, m-watkins-l0cyMroinI0@public.gmane.org,
	"Wolfgang Grandegger \(maintainer:CAN NETWORK DRIVERS\)"
	<wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Subhasish Ghosh <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1297435892-28278-10-git-send-email-subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============4015857869512164788==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig32880EE203080395FDD35A00"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig32880EE203080395FDD35A00
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 02/11/2011 03:51 PM, Subhasish Ghosh wrote:
> This patch adds support for the CAN device emulated on PRUSS.

Is this a software CAN device running on the omap dsp? Nice :)
My first impression is that this driver needs a lot of work, but we'll
help you.

Being new to the OMAP world here are soo many names for the same thing,
i.e. the CAN core and driver:

- da8cc
- pruss
- omap
- pru

These or combination of these are used all over the code. I'm preferring
one common prefix. I like the PRU_ prefix for the defines and the pru_
for functions.

Please don't encode the variable type into their names (a.k.a. polish
notation), e.g. it's "u8 data" not "u8 u8data", No typedefs, enums just
like defines in uppercase.

Get rid of the of the extra layer in pruss_can_api.c.

More comments inline:

> Signed-off-by: Subhasish Ghosh <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
> ---
>  drivers/net/can/Kconfig                     |    1 +
>  drivers/net/can/Makefile                    |    1 +
>  drivers/net/can/da8xx_pruss/Kconfig         |   73 ++
>  drivers/net/can/da8xx_pruss/Makefile        |    7 +
>  drivers/net/can/da8xx_pruss/pruss_can.c     |  758 +++++++++++++++++
>  drivers/net/can/da8xx_pruss/pruss_can_api.c | 1227 +++++++++++++++++++=
++++++++
>  drivers/net/can/da8xx_pruss/pruss_can_api.h |  290 +++++++
>  7 files changed, 2357 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/da8xx_pruss/Kconfig
>  create mode 100644 drivers/net/can/da8xx_pruss/Makefile
>  create mode 100644 drivers/net/can/da8xx_pruss/pruss_can.c
>  create mode 100644 drivers/net/can/da8xx_pruss/pruss_can_api.c
>  create mode 100644 drivers/net/can/da8xx_pruss/pruss_can_api.h
>=20
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index d5a9db6..ae8f0f9 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -112,6 +112,7 @@ config PCH_CAN
>  	  This driver can access CAN bus.
> =20
>  source "drivers/net/can/mscan/Kconfig"
> +source "drivers/net/can/da8xx_pruss/Kconfig"
> =20
>  source "drivers/net/can/sja1000/Kconfig"
> =20
> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> index 07ca159..849cdbf 100644
> --- a/drivers/net/can/Makefile
> +++ b/drivers/net/can/Makefile
> @@ -14,6 +14,7 @@ obj-$(CONFIG_CAN_SJA1000)	+=3D sja1000/
>  obj-$(CONFIG_CAN_MSCAN)		+=3D mscan/
>  obj-$(CONFIG_CAN_AT91)		+=3D at91_can.o
>  obj-$(CONFIG_CAN_TI_HECC)	+=3D ti_hecc.o
> +obj-$(CONFIG_CAN_TI_DA8XX_PRU)	+=3D da8xx_pruss/
>  obj-$(CONFIG_CAN_MCP251X)	+=3D mcp251x.o
>  obj-$(CONFIG_CAN_BFIN)		+=3D bfin_can.o
>  obj-$(CONFIG_CAN_JANZ_ICAN3)	+=3D janz-ican3.o
> diff --git a/drivers/net/can/da8xx_pruss/Kconfig b/drivers/net/can/da8x=
x_pruss/Kconfig
> new file mode 100644
> index 0000000..8b68f68
> --- /dev/null
> +++ b/drivers/net/can/da8xx_pruss/Kconfig
> @@ -0,0 +1,73 @@
> +#
> +# CAN Lite Kernel Configuration
     ^^^^^^^^^^^^^^^

what's can lite?

> +#
> +config CAN_TI_DA8XX_PRU
> +	depends on CAN_DEV && ARCH_DAVINCI && ARCH_DAVINCI_DA850
> +	tristate "PRU based CAN emulation for DA8XX"
> +	---help---
> +	Enable this to emulate a CAN controller on the PRU of DA8XX.
> +	If not sure, mark N
> +
> +config DA8XX_PRU_CANID_MBX0
> +	hex "CANID for mailbox 0"
> +	depends on CAN_TI_DA8XX_PRU
> +	default "0x123"
> +	---help---
> +	Enter the CANID for mailbox 0
> +	Default value is set to 0x123, change this as required.
> +
> +config DA8XX_PRU_CANID_MBX1
> +	hex "CANID for mailbox 1"
> +	depends on CAN_TI_DA8XX_PRU
> +	default "0x123"
> +	 ---help---
> +	Enter the CANID for mailbox 1
> +	Default value is set to 0x123, change this as required.
> +
> +config DA8XX_PRU_CANID_MBX2
> +	hex "CANID for mailbox 2"
> +	depends on CAN_TI_DA8XX_PRU
> +	default "0x123"
> +	---help---
> +	Enter the CANID for mailbox 2
> +	Default value is set to 0x123, change this as required.
> +
> +config DA8XX_PRU_CANID_MBX3
> +	hex "CANID for mailbox 3"
> +	depends on CAN_TI_DA8XX_PRU
> +	default "0x123"
> +	---help---
> +	Enter the CANID for mailbox 3
> +	Default value is set to 0x123, change this as required.
> +
> +config DA8XX_PRU_CANID_MBX4
> +	hex "CANID for mailbox 4"
> +	depends on CAN_TI_DA8XX_PRU
> +	default "0x123"
> +	---help---
> +	Enter the CANID for mailbox 4
> +	Default value is set to 0x123, change this as required.
> +
> +config DA8XX_PRU_CANID_MBX5
> +	hex "CANID for mailbox 5"
> +	depends on CAN_TI_DA8XX_PRU
> +	default "0x123"
> +	---help---
> +	Enter the CANID for mailbox 5
> +	Default value is set to 0x123, change this as required.
> +
> +config DA8XX_PRU_CANID_MBX6
> +	hex "CANID for mailbox 6"
> +	depends on CAN_TI_DA8XX_PRU
> +	default "0x123"
> +	---help---
> +	Enter the CANID for mailbox 6
> +	Default value is set to 0x123, change this as required.
> +
> +config DA8XX_PRU_CANID_MBX7
> +	hex "CANID for mailbox 7"
> +	depends on CAN_TI_DA8XX_PRU
> +	default "0x123"
> +	---help---
> +	Enter the CANID for mailbox 7
> +	Default value is set to 0x123, change this as required.

This doesn't fit to the Socketcan abstraction of a CAN card. Please
remove. After this "da8xx_pruss/Kconfig" just contains the
CAN_TI_DA8XX_PRU symbol, which can be added directly to
drivers/net/can/Kconfig. (With a perhaps a simpler kconfig symbol name.)

> diff --git a/drivers/net/can/da8xx_pruss/Makefile b/drivers/net/can/da8=
xx_pruss/Makefile
> new file mode 100644
> index 0000000..48f3055
> --- /dev/null
> +++ b/drivers/net/can/da8xx_pruss/Makefile
> @@ -0,0 +1,7 @@
> +#
> +# Makefile for CAN Lite emulation
> +#
> +can_emu-objs :=3D   pruss_can.o \
> +                  pruss_can_api.o

Do we need two c file? I haven't look at them, yet.

> +
> +obj-$(CONFIG_CAN_TI_DA8XX_PRU)    +=3D can_emu.o
> diff --git a/drivers/net/can/da8xx_pruss/pruss_can.c b/drivers/net/can/=
da8xx_pruss/pruss_can.c
> new file mode 100644
> index 0000000..1b3afde
> --- /dev/null
> +++ b/drivers/net/can/da8xx_pruss/pruss_can.c
> @@ -0,0 +1,758 @@
> +/*
> + *  TI DA8XX PRU CAN Emulation device driver
> + *  Author: subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org
> + *
> + *  This driver supports TI's PRU CAN Emulation and the
> + *  specs for the same is available at <http://www.ti.com>
> + *
> + *  Copyright (C) 2009 Texas Instruments Incorporated - http://www.ti.=
com/

You'll probably do some work on the driver, so add a 2011, here :)

> + *
> + *  This program is free software; you can redistribute it and/or
> + *  modify it under the terms of the GNU General Public License as
> + *  published by the Free Software Foundation version 2.
> + *
> + *  This program is distributed as is WITHOUT ANY WARRANTY of any
> + *  kind, whether express or implied; without even the implied warrant=
y
> + *  of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + *  GNU General Public License for more details.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/kernel.h>
> +#include <linux/bitops.h>
> +#include <linux/interrupt.h>
> +#include <linux/errno.h>
> +#include <linux/netdevice.h>
> +#include <linux/skbuff.h>
> +#include <linux/platform_device.h>
> +#include <linux/firmware.h>
> +#include <linux/clk.h>
> +#include <linux/types.h>
> +
> +#include <linux/can.h>
> +#include <linux/can/dev.h>
> +#include <linux/can/error.h>
> +#include <mach/da8xx.h>
> +#include "pruss_can_api.h"

Do we need a separate header file?
> +
> +#define DRV_NAME "da8xx_pruss_can"
> +#define DRV_DESC "TI PRU CAN Controller Driver v0.1"
> +#define PRU_CAN_START		1
> +#define PRU_CAN_STOP		0
> +#define MB_MIN			0
> +#define MB_MAX			7

please add the common PRU_ prefis to the MB_*, too.

> +
> +#define PRU_CANMID_IDE			BIT(29)	/* Extended frame format */
> +
> +#define PRU_CAN_ISR_BIT_CCI		BIT(15)
> +#define PRU_CAN_ISR_BIT_ESI		BIT(14)
> +#define PRU_CAN_ISR_BIT_SRDI		BIT(13)
> +#define PRU_CAN_ISR_BIT_RRI		BIT(8)
> +
> +#define PRU_CAN_MBXSR_BIT_STATE		BIT(7)
> +#define PRU_CAN_MBXSR_BIT_TC		BIT(6)
> +#define PRU_CAN_MBXSR_BIT_ERR		BIT(5)
> +#define PRU_CAN_MBXSR_BIT_OF		BIT(0)
> +
> +#define PRU_CAN_GSR_BIT_TXM		BIT(7)
> +#define PRU_CAN_GSR_BIT_RXM		BIT(6)
> +#define PRU_CAN_GSR_BIT_CM		BIT(5)
> +#define PRU_CAN_GSR_BIT_EPM		BIT(4)
> +#define PRU_CAN_GSR_BIT_BFM		BIT(3)
> +#define RTR_MBX_NO			8

We don't have special mailboxes for RTR, pleae remove.

add the PRU_ prefix here, too.
> +#define MAX_INIT_RETRIES		20
> +#define L138_PRU_ARM_FREQ		312000
> +#define DFLT_PRU_FREQ			156000000

Any change that you get these values from the a clock device?
e.g.:
http://lxr.linux.no/linux+v2.6.37/drivers/net/can/flexcan.c#L909
http://lxr.linux.no/linux+v2.6.37/drivers/net/can/flexcan.c#L946

> +#define DFLT_PRU_BITRATE		125000

Please remove, we don't have a default bitrate.

> +
> +#define CONFIG_DA8XX_PRU_CANID_MBX0	0x123
> +#define CONFIG_DA8XX_PRU_CANID_MBX1	0x123
> +#define CONFIG_DA8XX_PRU_CANID_MBX2	0x123
> +#define CONFIG_DA8XX_PRU_CANID_MBX3	0x123
> +#define CONFIG_DA8XX_PRU_CANID_MBX4	0x123
> +#define CONFIG_DA8XX_PRU_CANID_MBX5	0x123
> +#define CONFIG_DA8XX_PRU_CANID_MBX6	0x123
> +#define CONFIG_DA8XX_PRU_CANID_MBX7	0x123

as alreadt said, we don't have default canids, please remove.

> +
> +#ifdef __CAN_DEBUG
> +#define __can_debug(fmt, args...) printk(KERN_DEBUG "can_debug: " fmt,=
 ## args)
> +#else
> +#define __can_debug(fmt, args...)
> +#endif
> +#define __can_err(fmt, args...) printk(KERN_ERR "can_err: " fmt, ## ar=
gs)

please use pr_<level> and and friends, use pr_fmt to set a common
prefix. Or even better use netdev_<level>.

> +
> +/*
> + * omapl_pru can private data
> + */
> +struct omapl_pru_can_priv {
> +	struct can_priv can;
> +	struct workqueue_struct *pru_can_wQ;
> +	struct work_struct rx_work;
> +	struct net_device *ndev;
> +	struct device *dev; /* pdev->dev */

nitpick: pointless comment :)

> +	struct clk *clk_timer;
> +	u32 timer_freq;
> +	can_emu_app_hndl can_tx_hndl;
> +	can_emu_app_hndl can_rx_hndl;

please no new typedefs.

> +	const struct firmware *fw_rx;
> +	const struct firmware *fw_tx;
> +	spinlock_t mbox_lock;
> +	u32 trx_irq;
> +	u32 tx_head;
> +	u32 tx_tail;
> +	u32 tx_next;
> +	u32 rx_next;

If these don't reflect register values, just use "unsigned int"s here.

> +};
> +
> +static int omapl_pru_can_get_state(const struct net_device *ndev,
> +				   enum can_state *state)

just for consistency most other can drivers use "struct net_device *dev".=


> +{
> +	struct omapl_pru_can_priv *priv =3D netdev_priv(ndev);
> +	*state =3D priv->can.state;
> +	return 0;
> +}
> +
> +static int omapl_pru_can_set_bittiming(struct net_device *ndev)
> +{
> +	struct omapl_pru_can_priv *priv =3D netdev_priv(ndev);
> +	struct can_bittiming *bt =3D &priv->can.bittiming;
> +	long bit_error =3D 0;
> +
> +	if (priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES) {
> +		dev_warn(priv->dev, "WARN: Triple"
> +			 "sampling not set due to h/w limitations");
> +	}

No need to check this, just set the modes you support in
"priv->can.ctrlmode_supported".

http://lxr.linux.no/linux+v2.6.37/drivers/net/can/at91_can.c#L1091

> +	if (pru_can_calc_timing(priv->dev, priv->can.clock.freq,
> +				bt->bitrate) !=3D 0)

The above function does _set_ the bit timing into the hardware, calling
it "can_calc_timing" is a bit misleading.

Don't calculate the bit timing yoursef. Please define your
bittiming_const and set it, see:

http://lxr.linux.no/linux+v2.6.37/drivers/net/can/at91_can.c#L173
http://lxr.linux.no/linux+v2.6.37/drivers/net/can/at91_can.c#L1088

> +		return -EINVAL;
> +	bit_error =3D
> +	    (((priv->timer_freq / (priv->timer_freq / bt->bitrate)) -
> +	      bt->bitrate) * 1000) / bt->bitrate;
> +	if (bit_error) {
> +		bit_error =3D
> +		    (((priv->timer_freq / (priv->timer_freq / bt->bitrate)) -
> +		      bt->bitrate) * 1000000) / bt->bitrate;
> +		printk(KERN_INFO "\nBitrate error %ld.%ld%%\n",
> +			bit_error / 10000, bit_error % 1000);
> +	} else
> +		printk(KERN_INFO "\nBitrate error 0.0%%\n");
> +
> +	return 0;
> +}
> +
> +static void omapl_pru_can_stop(struct net_device *ndev)
> +{
> +	struct omapl_pru_can_priv *priv =3D netdev_priv(ndev);
> +	u16 int_mask =3D 0;
> +
> +	pru_can_mask_ints(priv->dev, int_mask);	/* mask all ints */
> +	pru_can_start_abort_tx(priv->dev, PRU_CAN_STOP);
> +	priv->can.state =3D CAN_STATE_STOPPED;
> +}
> +
> +/*
> + * This is to just set the can state to ERROR_ACTIVE
> + *	ip link set canX up type can bitrate 125000
> + */
> +static void omapl_pru_can_start(struct net_device *ndev)
> +{
> +	struct omapl_pru_can_priv *priv =3D netdev_priv(ndev);
> +	u16 int_mask =3D 0xFFFF;
> +
> +	if (priv->can.state !=3D CAN_STATE_STOPPED)
> +		omapl_pru_can_stop(ndev);
> +
> +	pru_can_mask_ints(priv->dev, int_mask);	/* unmask all ints */
> +
> +	pru_can_get_global_status(priv->dev, &priv->can_tx_hndl);
> +	pru_can_get_global_status(priv->dev, &priv->can_rx_hndl);
> +
> +	if (PRU_CAN_GSR_BIT_EPM & priv->can_tx_hndl.u32globalstatus)
> +		priv->can.state =3D CAN_STATE_ERROR_PASSIVE;
> +	else if (PRU_CAN_GSR_BIT_BFM & priv->can_tx_hndl.u32globalstatus)
> +		priv->can.state =3D CAN_STATE_BUS_OFF;
> +	else
> +		priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> +}
> +
> +static int omapl_pru_can_set_mode(struct net_device *ndev, enum can_mo=
de mode)
> +{
> +	int ret =3D 0;
> +
> +	switch (mode) {
> +	case CAN_MODE_START:
> +		omapl_pru_can_start(ndev);
> +		if (netif_queue_stopped(ndev))
> +			netif_wake_queue(ndev);
> +		break;
> +	case CAN_MODE_STOP:
> +		omapl_pru_can_stop(ndev);
> +		if (!netif_queue_stopped(ndev))
> +			netif_stop_queue(ndev);
> +		break;
> +	default:
> +		ret =3D -EOPNOTSUPP;
> +		break;
> +	}
> +	return ret;
> +}
> +
> +static netdev_tx_t omapl_pru_can_start_xmit(struct sk_buff *skb,
> +					    struct net_device *ndev)
> +{
> +	struct omapl_pru_can_priv *priv =3D netdev_priv(ndev);
> +	struct can_frame *cf =3D (struct can_frame *)skb->data;
> +	int count;
> +	u8 *data =3D cf->data;
> +	u8 dlc =3D cf->can_dlc;
> +	u8 *ptr8data =3D NULL;
> +
> +	netif_stop_queue(ndev);
> +	if (cf->can_id & CAN_EFF_FLAG)	/* Extended frame format */
> +		*((u32 *) &priv->can_tx_hndl.strcanmailbox) =3D
> +		    (cf->can_id & CAN_EFF_MASK) | PRU_CANMID_IDE;
> +	else			/* Standard frame format */
> +		*((u32 *) &priv->can_tx_hndl.strcanmailbox) =3D
> +		    (cf->can_id & CAN_SFF_MASK) << 18;
> +
> +	if (cf->can_id & CAN_RTR_FLAG)	/* Remote transmission request */
> +		*((u32 *) &priv->can_tx_hndl.strcanmailbox) |=3D CAN_RTR_FLAG;
> +
> +	ptr8data =3D &priv->can_tx_hndl.strcanmailbox.u8data7 + (dlc - 1);
> +	for (count =3D 0; count < (u8) dlc; count++) {
> +		*ptr8data-- =3D *data++;
> +	}
> +	*((u32 *) &priv->can_tx_hndl.strcanmailbox.u16datalength) =3D (u32) d=
lc;
> +/*
> + * search for the next available mbx
> + * if the next mbx is busy, then try the next + 1
> + * do this until the head is reached.
> + * if still unable to tx, stop accepting any packets
> + * if able to tx and the head is reached, then reset next to tail, i.e=
 mbx0
> + * if head is not reached, then just point to the next mbx
> + */
> +	for (; priv->tx_next <=3D priv->tx_head; priv->tx_next++) {
> +		priv->can_tx_hndl.ecanmailboxnumber =3D
> +		    (can_mailbox_number) priv->tx_next;
> +		if (-1 =3D=3D pru_can_write_data_to_mailbox(priv->dev,
> +					&priv->can_tx_hndl)) {
> +			if (priv->tx_next =3D=3D priv->tx_head) {
> +				priv->tx_next =3D priv->tx_tail;
> +				if (!netif_queue_stopped(ndev))
> +					netif_stop_queue(ndev);	/* IF stalled */
> +				dev_err(priv->dev,
> +					"%s: no tx mbx available", __func__);
> +				return NETDEV_TX_BUSY;
> +			} else
> +				continue;
> +		} else {
> +			/* set transmit request */
> +			pru_can_tx(priv->dev, priv->tx_next, CAN_TX_PRU_1);
> +			pru_can_tx_mode_set(priv->dev, false, ecanreceive);
> +			pru_can_tx_mode_set(priv->dev, true, ecantransmit);
> +			pru_can_start_abort_tx(priv->dev, PRU_CAN_START);
> +			priv->tx_next++;
> +			can_put_echo_skb(skb, ndev, 0);
> +			break;
> +		}
> +	}
> +	if (priv->tx_next > priv->tx_head) {
> +		priv->tx_next =3D priv->tx_tail;
> +	}
> +	return NETDEV_TX_OK;
> +}
> +
> +static int omapl_pru_can_rx(struct net_device *ndev, u32 mbxno)
> +{
> +	struct omapl_pru_can_priv *priv =3D netdev_priv(ndev);
> +	struct net_device_stats *stats =3D &ndev->stats;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	u32 pru_can_mbx_data;
> +	u8 *data =3D NULL;
> +	u8 *ptr8data =3D NULL;
> +	int count =3D 0;
> +
> +	skb =3D alloc_can_skb(ndev, &cf);
> +	if (!skb) {
> +		if (printk_ratelimit())
> +			dev_err(priv->dev,
> +				"alloc_can_skb() failed\n");
> +		return -ENOMEM;
> +	}
> +	data =3D cf->data;
> +	/*      get payload */
> +	priv->can_rx_hndl.ecanmailboxnumber =3D (can_mailbox_number) mbxno;
> +	if (pru_can_get_data_from_mailbox(priv->dev, &priv->can_rx_hndl)) {
> +		__can_err("failed to get data from mailbox\n");
> +		return -EAGAIN;
> +	}
> +	/* give ownweship to pru */
> +	pru_can_tx(priv->dev, mbxno, CAN_RX_PRU_0);
> +
> +	/* get data length code */
> +	cf->can_dlc =3D
> +	    get_can_dlc(*
> +			((u32 *) &priv->can_rx_hndl.strcanmailbox.
> +			 u16datalength) & 0xF);
> +	if (cf->can_dlc <=3D 4) {
> +		ptr8data =3D
> +		    &priv->can_rx_hndl.strcanmailbox.u8data3 + (4 -
> +								cf->can_dlc);
> +		for (count =3D 0; count < cf->can_dlc; count++) {
> +			*data++ =3D *ptr8data++;
> +		}
> +	} else {
> +		ptr8data =3D &priv->can_rx_hndl.strcanmailbox.u8data3;
> +		for (count =3D 0; count < 4; count++) {
> +			*data++ =3D *ptr8data++;
> +		}
> +		ptr8data =3D
> +		    &priv->can_rx_hndl.strcanmailbox.u8data4 - (cf->can_dlc -
> +								5);
> +		for (count =3D 0; count < cf->can_dlc - 4; count++) {
> +			*data++ =3D *ptr8data++;
> +		}
> +	}
> +
> +	pru_can_mbx_data =3D *((u32 *) &priv->can_rx_hndl.strcanmailbox);
> +	/* get id extended or std */
> +	if (pru_can_mbx_data & PRU_CANMID_IDE)
> +		cf->can_id =3D (pru_can_mbx_data & CAN_EFF_MASK) | CAN_EFF_FLAG;
> +	else
> +		cf->can_id =3D (pru_can_mbx_data >> 18) & CAN_SFF_MASK;
> +
> +	if (pru_can_mbx_data & CAN_RTR_FLAG)
> +		cf->can_id |=3D CAN_RTR_FLAG;
> +
> +	netif_rx_ni(skb);
> +	stats->rx_packets++;
> +	stats->rx_bytes +=3D cf->can_dlc;
> +	return 0;
> +}
> +
> +static int omapl_pru_can_err(struct net_device *ndev, int int_status,
> +			     int err_status)
> +{
> +	struct omapl_pru_can_priv *priv =3D netdev_priv(ndev);
> +	struct net_device_stats *stats =3D &ndev->stats;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	int tx_err_cnt, rx_err_cnt;
> +
> +	/* propogate the error condition to the can stack */
> +	skb =3D alloc_can_err_skb(ndev, &cf);
> +	if (!skb) {
> +		if (printk_ratelimit())
> +			dev_err(priv->dev,
> +				"alloc_can_err_skb() failed\n");
> +		return -ENOMEM;
> +	}
> +
> +	if (err_status & PRU_CAN_GSR_BIT_EPM) {	/* error passive int */
> +		priv->can.state =3D CAN_STATE_ERROR_PASSIVE;
> +		++priv->can.can_stats.error_passive;
> +		cf->can_id |=3D CAN_ERR_CRTL;
> +		tx_err_cnt =3D pru_can_get_error_cnt(priv->dev, CAN_TX_PRU_1);
> +		rx_err_cnt =3D pru_can_get_error_cnt(priv->dev, CAN_RX_PRU_0);
> +		if (tx_err_cnt > 127)
> +			cf->data[1] |=3D CAN_ERR_CRTL_TX_PASSIVE;
> +		if (rx_err_cnt > 127)
> +			cf->data[1] |=3D CAN_ERR_CRTL_RX_PASSIVE;
> +
> +		dev_dbg(priv->ndev->dev.parent, "Error passive interrupt\n");
> +	}
> +
> +	if (err_status & PRU_CAN_GSR_BIT_BFM) {
> +		priv->can.state =3D CAN_STATE_BUS_OFF;
> +		cf->can_id |=3D CAN_ERR_BUSOFF;
> +		/*
> +		 *      Disable all interrupts in bus-off to avoid int hog
> +		 *      this should be handled by the pru
> +		 */
> +		pru_can_mask_ints(priv->dev, 0xFFFF);
> +		can_bus_off(ndev);
> +		dev_dbg(priv->ndev->dev.parent, "Bus off mode\n");
> +	}
> +
> +	netif_rx(skb);
> +	stats->rx_packets++;
> +	stats->rx_bytes +=3D cf->can_dlc;
> +	return 0;
> +}
> +
> +void omapl_pru_can_rx_wQ(struct work_struct *work)
> +{
> +	struct omapl_pru_can_priv *priv =3D container_of(work,
> +			struct omapl_pru_can_priv, rx_work);
> +	struct net_device *ndev =3D priv->ndev;
> +	u32 bit_set, mbxno =3D 0;
> +
> +	if (-1 =3D=3D pru_can_get_intr_status(priv->dev, &priv->can_rx_hndl))=

> +		return;
> +
> +	if (PRU_CAN_ISR_BIT_RRI & priv->can_rx_hndl.u32interruptstatus) {
> +		mbxno =3D RTR_MBX_NO;
> +		omapl_pru_can_rx(ndev, mbxno);
> +	} else {
> +		/* Extract the mboxno from the status */
> +		for (bit_set =3D 0; ((priv->can_rx_hndl.u32interruptstatus & 0xFF)
> +						>> bit_set !=3D 0); bit_set++)
> +		;
> +		if (0 =3D=3D bit_set) {
> +			dev_err(priv->dev,
> +				"%s: invalid mailbox number: %X\n", __func__,
> +				priv->can_rx_hndl.u32interruptstatus);
> +		} else {
> +			mbxno =3D bit_set - 1;
> +			if (PRU_CAN_ISR_BIT_ESI & priv->can_rx_hndl.
> +			    u32interruptstatus) {
> +				pru_can_get_global_status(priv->dev,
> +					&priv->can_rx_hndl);
> +				omapl_pru_can_err(ndev,
> +				priv->can_rx_hndl.u32interruptstatus,
> +				priv->can_rx_hndl.u32globalstatus);
> +			} else {
> +				omapl_pru_can_rx(ndev, mbxno);
> +			}
> +		}
> +	}
> +}
> +
> +irqreturn_t omapl_tx_can_intr(int irq, void *dev_id)
> +{
> +	struct net_device *ndev =3D dev_id;
> +	struct omapl_pru_can_priv *priv =3D netdev_priv(ndev);
> +	struct net_device_stats *stats =3D &ndev->stats;
> +	u32 bit_set, mbxno;
> +
> +	pru_can_get_intr_status(priv->dev, &priv->can_tx_hndl);
> +	if ((PRU_CAN_ISR_BIT_CCI & priv->can_tx_hndl.u32interruptstatus)
> +	    || (PRU_CAN_ISR_BIT_SRDI & priv->can_tx_hndl.u32interruptstatus))=
 {
> +		__can_debug("tx_int_status =3D 0x%X\n",
> +			    priv->can_tx_hndl.u32interruptstatus);
> +		can_free_echo_skb(ndev, 0);
> +	} else {
> +		for (bit_set =3D 0; ((priv->can_tx_hndl.u32interruptstatus & 0xFF)
> +						>> bit_set !=3D 0); bit_set++)
> +		;
> +		if (0 =3D=3D bit_set) {
> +			__can_err("%s: invalid mailbox number\n", __func__);
> +			can_free_echo_skb(ndev, 0);
> +		} else {
> +			mbxno =3D bit_set - 1;	/* mail box numbering starts from 0 */
> +			if (PRU_CAN_ISR_BIT_ESI & priv->can_tx_hndl.
> +			    u32interruptstatus) {
> +				/* read gsr and ack pru */
> +				pru_can_get_global_status(priv->dev, &priv->can_tx_hndl);
> +				omapl_pru_can_err(ndev,
> +						  priv->can_tx_hndl.
> +						  u32interruptstatus,
> +						  priv->can_tx_hndl.
> +						  u32globalstatus);
> +			} else {
> +				stats->tx_packets++;
> +				/* stats->tx_bytes +=3D dlc; */
> +				/*can_get_echo_skb(ndev, 0);*/
> +			}
> +		}
> +	}
> +	if (netif_queue_stopped(ndev))
> +		netif_wake_queue(ndev);
> +
> +	can_get_echo_skb(ndev, 0);
> +	pru_can_tx_mode_set(priv->dev, true, ecanreceive);
> +	return IRQ_HANDLED;
> +}
> +
> +irqreturn_t omapl_rx_can_intr(int irq, void *dev_id)
> +{
> +
> +	struct net_device *ndev =3D dev_id;
> +	struct omapl_pru_can_priv *priv =3D netdev_priv(ndev);
> +	u32 intc_status =3D 0;
> +
> +	intc_status =3D pru_can_get_intc_status(priv->dev);
> +	if (intc_status & 4)
> +		return omapl_tx_can_intr(irq, dev_id);
> +	if (intc_status & 2) {
> +		if (!work_pending(&priv->rx_work))
> +			queue_work(priv->pru_can_wQ, &priv->rx_work);
> +	}
> +
> +	return IRQ_HANDLED;
> +}
> +
> +static int omapl_pru_can_open(struct net_device *ndev)
> +{
> +	struct omapl_pru_can_priv *priv =3D netdev_priv(ndev);
> +	int err;
> +
> +	/* register interrupt handler */
> +	err =3D request_irq(priv->trx_irq, &omapl_rx_can_intr, IRQF_SHARED,
> +			  "pru_can_irq", ndev);
> +	if (err) {
> +		dev_err(priv->dev, "error requesting rx interrupt\n");
> +		goto exit_trx_irq;
> +	}
> +	/* common open */
> +	err =3D open_candev(ndev);
> +	if (err) {
> +		dev_err(priv->dev, "open_candev() failed %d\n", err);
> +		goto exit_open;
> +	}
> +
> +	pru_can_emu_init(priv->dev, priv->can.clock.freq);
> +	priv->tx_tail =3D MB_MIN;
> +	priv->tx_head =3D MB_MAX;
> +
> +	pru_can_rx_id_map(priv->dev, CONFIG_DA8XX_PRU_CANID_MBX0, 0);
> +	pru_can_rx_id_map(priv->dev, CONFIG_DA8XX_PRU_CANID_MBX1, 1);
> +	pru_can_rx_id_map(priv->dev, CONFIG_DA8XX_PRU_CANID_MBX2, 2);
> +	pru_can_rx_id_map(priv->dev, CONFIG_DA8XX_PRU_CANID_MBX3, 3);
> +	pru_can_rx_id_map(priv->dev, CONFIG_DA8XX_PRU_CANID_MBX4, 4);
> +	pru_can_rx_id_map(priv->dev, CONFIG_DA8XX_PRU_CANID_MBX5, 5);
> +	pru_can_rx_id_map(priv->dev, CONFIG_DA8XX_PRU_CANID_MBX6, 6);
> +	pru_can_rx_id_map(priv->dev, CONFIG_DA8XX_PRU_CANID_MBX7, 7);
> +
> +	omapl_pru_can_start(ndev);
> +	netif_start_queue(ndev);
> +	return 0;
> +
> +exit_open:
> +	free_irq(priv->trx_irq, ndev);
> +exit_trx_irq:
> +	return err;
> +}
> +
> +static int omapl_pru_can_close(struct net_device *ndev)
> +{
> +	struct omapl_pru_can_priv *priv =3D netdev_priv(ndev);
> +
> +	if (!netif_queue_stopped(ndev))
> +		netif_stop_queue(ndev);
> +
> +	close_candev(ndev);
> +
> +	free_irq(priv->trx_irq, ndev);
> +	return 0;
> +}
> +
> +static const struct net_device_ops omapl_pru_can_netdev_ops =3D {
> +	.ndo_open		=3D omapl_pru_can_open,
> +	.ndo_stop		=3D omapl_pru_can_close,
> +	.ndo_start_xmit		=3D omapl_pru_can_start_xmit,
> +};
> +
> +static int __devinit omapl_pru_can_probe(struct platform_device *pdev)=

> +{
> +	struct net_device *ndev =3D NULL;
> +	const struct da8xx_pru_can_data *pdata;
> +	struct omapl_pru_can_priv *priv =3D NULL;
> +	struct device *dev =3D &pdev->dev;
> +	u32 err;
> +
> +	pdata =3D dev->platform_data;
> +	if (!pdata) {
> +		dev_err(&pdev->dev, "platform data not found\n");
> +		return -EINVAL;
> +	}
> +
> +	ndev =3D alloc_candev(sizeof(struct omapl_pru_can_priv), MB_MAX + 1);=

> +	if (!ndev) {
> +		dev_err(&pdev->dev, "alloc_candev failed\n");
> +		err =3D -ENOMEM;
> +		goto probe_exit;
> +	}
> +	priv =3D netdev_priv(ndev);
> +
> +	priv->trx_irq =3D platform_get_irq(to_platform_device(dev->parent), 0=
);
> +	if (!priv->trx_irq) {
> +		dev_err(&pdev->dev, "unable to get pru interrupt resources!\n");
> +		err =3D -ENODEV;
> +		goto probe_exit;
> +	}
> +
> +	priv->ndev =3D ndev;
> +	priv->dev =3D dev; /* priv->dev =3D pdev->dev */
> +
> +	priv->can.bittiming_const =3D NULL;
> +	priv->can.do_set_bittiming =3D omapl_pru_can_set_bittiming;
> +	priv->can.do_set_mode =3D omapl_pru_can_set_mode;
> +	priv->can.do_get_state =3D omapl_pru_can_get_state;
> +	priv->can_tx_hndl.u8prunumber =3D CAN_TX_PRU_1;
> +	priv->can_rx_hndl.u8prunumber =3D CAN_RX_PRU_0;
> +
> +	/* we support local echo, no arp */
> +	ndev->flags |=3D (IFF_ECHO | IFF_NOARP);
> +
> +	/* pdev->dev->device_private->driver_data =3D ndev */
> +	platform_set_drvdata(pdev, ndev);
> +	SET_NETDEV_DEV(ndev, &pdev->dev);
> +	ndev->netdev_ops =3D &omapl_pru_can_netdev_ops;
> +
> +	priv->can.clock.freq =3D pruss_get_clk_freq(priv->dev);
> +
> +	priv->clk_timer =3D clk_get(&pdev->dev, "pll1_sysclk2");
> +	if (IS_ERR(priv->clk_timer)) {
> +		dev_err(&pdev->dev, "no timer clock available\n");
> +		err =3D PTR_ERR(priv->clk_timer);
> +		priv->clk_timer =3D NULL;
> +		goto probe_exit_candev;
> +	}
> +	priv->timer_freq =3D clk_get_rate(priv->clk_timer);
> +
> +	err =3D register_candev(ndev);
> +	if (err) {
> +		dev_err(&pdev->dev, "register_candev() failed\n");
> +		err =3D -ENODEV;
> +		goto probe_exit_clk;
> +	}
> +
> +	err =3D request_firmware(&priv->fw_tx, "PRU_CAN_Emulation_Tx.bin",
> +			&pdev->dev);
> +	if (err) {
> +		dev_err(&pdev->dev, "can't load firmware\n");
> +		err =3D -ENODEV;
> +		goto probe_exit_clk;
> +	}
> +
> +	dev_info(&pdev->dev, "fw_tx size %d. downloading...\n",
> +		 priv->fw_tx->size);
> +
> +	err =3D request_firmware(&priv->fw_rx, "PRU_CAN_Emulation_Rx.bin",
> +			&pdev->dev);
> +	if (err) {
> +		dev_err(&pdev->dev, "can't load firmware\n");
> +		err =3D -ENODEV;
> +		goto probe_release_fw;
> +	}
> +	dev_info(&pdev->dev, "fw_rx size %d. downloading...\n",
> +		 priv->fw_rx->size);
> +
> +	/* init the pru */
> +	pru_can_emu_init(priv->dev, priv->can.clock.freq);
> +	udelay(200);
> +
> +	pruss_enable(priv->dev, CAN_RX_PRU_0);
> +	pruss_enable(priv->dev, CAN_TX_PRU_1);
> +
> +	/* download firmware into pru */
> +	err =3D pruss_load(priv->dev, CAN_RX_PRU_0,
> +		(u32 *)priv->fw_rx->data, (priv->fw_rx->size / 4));
> +	if (err) {
> +		dev_err(&pdev->dev, "firmware download error\n");
> +		err =3D -ENODEV;
> +		goto probe_release_fw_1;
> +	}
> +	err =3D pruss_load(priv->dev, CAN_TX_PRU_1,
> +		(u32 *)priv->fw_tx->data, (priv->fw_tx->size / 4));
> +	if (err) {
> +		dev_err(&pdev->dev, "firmware download error\n");
> +		err =3D -ENODEV;
> +		goto probe_release_fw_1;
> +	}
> +
> +	if (pru_can_calc_timing(priv->dev, DFLT_PRU_FREQ,
> +				DFLT_PRU_BITRATE) !=3D 0)
> +		return -EINVAL;
> +
> +	pruss_run(priv->dev, CAN_RX_PRU_0);
> +	pruss_run(priv->dev, CAN_TX_PRU_1);
> +
> +	/*Create The Work Queue */
> +	priv->pru_can_wQ =3D create_freezeable_workqueue("omapl_pru_wQ");
> +	if (priv->pru_can_wQ =3D=3D NULL) {
> +		dev_err(&pdev->dev, "failed to create work queue\n");
> +		err =3D -ENODEV;
> +		goto probe_release_fw_1;
> +	}
> +
> +	INIT_WORK(&priv->rx_work, omapl_pru_can_rx_wQ);
> +	dev_info(&pdev->dev,
> +		 "%s device registered (trx_irq =3D %d,  clk =3D %d)\n",
> +		 DRV_NAME, priv->trx_irq, priv->can.clock.freq);
> +
> +	return 0;
> +
> +probe_release_fw_1:
> +	release_firmware(priv->fw_rx);
> +probe_release_fw:
> +	release_firmware(priv->fw_tx);
> +probe_exit_clk:
> +	clk_put(priv->clk_timer);
> +probe_exit_candev:
> +	if (NULL !=3D ndev)
> +		free_candev(ndev);
> +probe_exit:
> +	return err;
> +}
> +
> +static int __devexit omapl_pru_can_remove(struct platform_device *pdev=
)
> +{
> +	struct net_device *ndev =3D platform_get_drvdata(pdev);
> +	struct omapl_pru_can_priv *priv =3D netdev_priv(ndev);
> +
> +	omapl_pru_can_stop(ndev);
> +
> +	pru_can_emu_exit(priv->dev);
> +	release_firmware(priv->fw_tx);
> +	release_firmware(priv->fw_rx);
> +	clk_put(priv->clk_timer);
> +	flush_workqueue(priv->pru_can_wQ);
> +	destroy_workqueue(priv->pru_can_wQ);
> +	unregister_candev(ndev);
> +	free_candev(ndev);
> +	platform_set_drvdata(pdev, NULL);
> +	return 0;
> +}
> +
> +#ifdef CONFIG_PM
> +static int omapl_pru_can_suspend(struct platform_device *pdev,
> +			pm_message_t mesg)
> +{
> +	dev_info(&pdev->dev, "%s not yet implemented\n", __func__);
> +	return 0;
> +}
> +
> +static int omapl_pru_can_resume(struct platform_device *pdev)
> +{
> +	dev_info(&pdev->dev, "%s not yet implemented\n", __func__);
> +	return 0;
> +}
> +#else
> +#define omapl_pru_can_suspend NULL
> +#define omapl_pru_can_resume NULL
> +#endif /* CONFIG_PM */
> +
> +static struct platform_driver omapl_pru_can_driver =3D {
> +	.probe		=3D omapl_pru_can_probe,
> +	.remove		=3D __devexit_p(omapl_pru_can_remove),
> +	.suspend	=3D omapl_pru_can_suspend,
> +	.resume		=3D omapl_pru_can_resume,
> +	.driver		=3D {
> +		.name	=3D DRV_NAME,
> +		.owner	=3D THIS_MODULE,
> +	},
> +};
> +
> +static int __init omapl_pru_can_init(void)
> +{
> +	__can_debug(KERN_INFO DRV_DESC "\n");
> +	return platform_driver_register(&omapl_pru_can_driver);
> +}
> +
> +module_init(omapl_pru_can_init);
> +
> +static void __exit omapl_pru_can_exit(void)
> +{
> +	__can_debug(KERN_INFO DRV_DESC " unloaded\n");
> +	platform_driver_unregister(&omapl_pru_can_driver);
> +}
> +
> +module_exit(omapl_pru_can_exit);
> +
> +MODULE_AUTHOR("Subhasish Ghosh <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>");
> +MODULE_LICENSE("GPL");
> +MODULE_DESCRIPTION("omapl pru CAN netdevice driver");
> diff --git a/drivers/net/can/da8xx_pruss/pruss_can_api.c b/drivers/net/=
can/da8xx_pruss/pruss_can_api.c
> new file mode 100644
> index 0000000..2f7438a
> --- /dev/null
> +++ b/drivers/net/can/da8xx_pruss/pruss_can_api.c
> @@ -0,0 +1,1227 @@
> +/*
> + * Copyright (C) 2010 Texas Instruments Incorporated
> + * Author: Wilfred Felix
> + *
> + * This program is free software; you can redistribute it and/or modif=
y it
> + * under the terms of the GNU General Public License as  published by =
the
> + * Free Software Foundation version 2.
> + *
> + * This program is distributed "as is" WITHOUT ANY WARRANTY of any kin=
d,
> + * whether express or implied; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> + * General Public License for more details.
> + */
> +
> +#include "pruss_can_api.h"
> +
> +static can_emu_drv_inst gstr_can_inst[ecanmaxinst];
> +
> +/*
> + * pru_can_set_brp()	Updates the  BRP register of PRU0
> + * and PRU1 of OMAP L138. This API will be called by the
> + * Application to updtae the BRP register of PRU0 and PRU1
> + *
> + * param	u16bitrateprescaler		The can bus bitrate
> + * prescaler value be set
> + *
> + * return   SUCCESS or FAILURE
> + */
> +s16 pru_can_set_brp(struct device *dev, u16 u16bitrateprescaler)
> +{
> +
> +	u32 u32offset;
> +
> +	if (u16bitrateprescaler > 255) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_RX_CLOCK_BRP_REGISTER);
> +	pruss_writel(dev, u32offset, (u32 *) &u16bitrateprescaler, 1);
> +
> +	u32offset =3D (PRU_CAN_TX_CLOCK_BRP_REGISTER);
> +	pruss_writel(dev, u32offset, (u32 *) &u16bitrateprescaler, 1);
> +
> +	return 0;
> +
> +}
> +
> +/*
> + * pru_can_set_bit_timing()		Updates the timing register
> + * of PRU0 and PRU1 of OMAP L138. This API will be called by
> + * the Application to updtae the timing register of PRU0 and PRU1
> + *
> + * param	pstrbittiming		Pointer to structure holding
> + * the bit timing values for can bus.
> + *
> + * return   SUCCESS or FAILURE
> + */
> +s16 pru_can_set_bit_timing(struct device *dev,
> +		can_bit_timing_consts *pstrbittiming)
> +{
> +
> +	u32 u32offset;
> +	u32 u32serregister;
> +
> +	u32serregister =3D 0;
> +
> +	if (pstrbittiming =3D=3D NULL) {
> +		return -1;
> +	}
> +
> +	if ((pstrbittiming->u8syncjumpwidth > PRU_CAN_MAX_SJW) ||
> +	    (pstrbittiming->u8phseg1 > PRU_CAN_MAX_PHSEG1) ||
> +	    (pstrbittiming->u8phseg2 > PRU_CAN_MAX_PHSEG2)) {
> +		return -1;
> +	}
> +
> +	u32serregister =3D u32serregister |
> +			((pstrbittiming->u8syncjumpwidth << 7) |
> +			(pstrbittiming->u8phseg1 << 3) |
> +			(pstrbittiming->u8phseg2));
> +
> +	u32offset =3D (PRU_CAN_TX_TIMING_REGISTER);
> +	pruss_writel(dev, u32offset, (u32 *) &u32serregister, 1);
> +
> +	u32offset =3D (PRU_CAN_RX_TIMING_REGISTER);
> +	pruss_writel(dev, u32offset, (u32 *) &u32serregister, 1);
> +
> +	return 0;
> +}
> +
> +
> +/*
> + * pru_can_calc_timing()
> + * Updates the  timing values of PRU0 and PRU1 of OMAP L138.
> + * This API will be called by the
> + * Application to updtae the timing values of PRU0 and PRU1
> + *
> + * return   SUCCESS or FAILURE
> + */
> +
> +s16 pru_can_calc_timing(struct device *dev, u32 pru_freq, u32 bit_rate=
)
> +{
> +	u16 u16phaseseg1;
> +	u16 u16phaseseg2;
> +	u32 u32offset;
> +	u32 u32timing_value;
> +	u32 u32setup_value;
> +	u32timing_value =3D TIMER_CLK_FREQ / bit_rate;
> +	u32offset =3D (PRU_CAN_TIMING_VAL_TX);
> +	pruss_writel(dev, u32offset, (u32 *) &u32timing_value, 4);
> +	pruss_readl(dev, u32offset, (u32 *) &u32timing_value, 4);
> +	u32setup_value =3D
> +	    (GPIO_SETUP_DELAY * (pru_freq / 1000000) / 1000) /
> +	    DELAY_LOOP_LENGTH;
> +	u32offset =3D (PRU_CAN_TIMING_VAL_TX_SJW);
> +	pruss_writel(dev, u32offset, (u32 *) &u32setup_value, 4);
> +	u16phaseseg1 =3D (u16) (u32timing_value / 2);
> +	u16phaseseg2 =3D u32timing_value - u16phaseseg1;
> +	u16phaseseg1 -=3D TIMER_SETUP_DELAY;
> +	u16phaseseg2 -=3D TIMER_SETUP_DELAY;
> +	u32setup_value =3D (u16phaseseg1 << 16) | u16phaseseg2;
> +	u32offset =3D (PRU_CAN_TIMING_VAL_RX);
> +	pruss_writel(dev, u32offset, (u32 *) &u32setup_value, 4);
> +	u32offset =3D (PRU_CAN_TIMING_VAL_RX + 4);
> +	pruss_writel(dev, u32offset, (u32 *) &u32timing_value, 4);
> +
> +	return 0;
> +}
> +
> +/*
> + * pru_can_write_data_to_mailbox()
> + * Updates the transmit mailboxes of PRU1 of OMAP L138.
> + * This API will be called by the Application to update
> + * the transmit mailboxes of PRU1
> + *
> + * param  pu16canframedata	Can mailbox data buffer
> + *
> + * param  u8mailboxnum		Mailbox to be updated
> + *
> + * return SUCCESS or FAILURE
> + */
> +s16 pru_can_write_data_to_mailbox(struct device *dev,
> +			can_emu_app_hndl *pstremuapphndl)
> +{
> +	s16 s16subrtnretval;
> +	u32 u32offset;
> +
> +	if (pstremuapphndl =3D=3D NULL) {
> +		return -1;
> +	}
> +
> +	switch ((u8) pstremuapphndl->ecanmailboxnumber) {
> +	case 0:
> +		u32offset =3D (PRU_CAN_TX_MAILBOX0);
> +		break;
> +	case 1:
> +		u32offset =3D (PRU_CAN_TX_MAILBOX1);
> +		break;
> +	case 2:
> +		u32offset =3D (PRU_CAN_TX_MAILBOX2);
> +		break;
> +	case 3:
> +		u32offset =3D (PRU_CAN_TX_MAILBOX3);
> +		break;
> +	case 4:
> +		u32offset =3D (PRU_CAN_TX_MAILBOX4);
> +		break;
> +	case 5:
> +		u32offset =3D (PRU_CAN_TX_MAILBOX5);
> +		break;
> +	case 6:
> +		u32offset =3D (PRU_CAN_TX_MAILBOX6);
> +		break;
> +	case 7:
> +		u32offset =3D (PRU_CAN_TX_MAILBOX7);
> +		break;
> +	default:
> +		return -1;
> +	}
> +
> +	s16subrtnretval =3D pruss_writel(dev, u32offset,
> +		(u32 *) &(pstremuapphndl->strcanmailbox), 4);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +	return 0;
> +}
> +
> +/*
> + * pru_can_get_data_from_mailbox()
> + * Receive data from the receive mailboxes of PRU0  of OMAP L138.
> + * This API will be called by the Application to get data from
> + * the receive mailboxes of PRU0
> + *
> + * param  pu16canframedata	Can mailbox data buffer
> + *
> + * param  u8mailboxnum		Mailbox to be updated
> + *
> + * return SUCCESS or FAILURE
> + */
> +s16 pru_can_get_data_from_mailbox(struct device *dev,
> +		can_emu_app_hndl *pstremuapphndl)
> +{
> +	s16 s16subrtnretval;
> +	u32 u32offset;
> +
> +	if (pstremuapphndl =3D=3D NULL) {
> +		return -1;
> +	}
> +
> +	switch ((u8) pstremuapphndl->ecanmailboxnumber) {
> +	case 0:
> +		u32offset =3D (PRU_CAN_RX_MAILBOX0);
> +		break;
> +	case 1:
> +		u32offset =3D (PRU_CAN_RX_MAILBOX1);
> +		break;
> +	case 2:
> +		u32offset =3D (PRU_CAN_RX_MAILBOX2);
> +		break;
> +	case 3:
> +		u32offset =3D (PRU_CAN_RX_MAILBOX3);
> +		break;
> +	case 4:
> +		u32offset =3D (PRU_CAN_RX_MAILBOX4);
> +		break;
> +	case 5:
> +		u32offset =3D (PRU_CAN_RX_MAILBOX5);
> +		break;
> +	case 6:
> +		u32offset =3D (PRU_CAN_RX_MAILBOX6);
> +		break;
> +	case 7:
> +		u32offset =3D (PRU_CAN_RX_MAILBOX7);
> +		break;
> +	case 8:
> +		u32offset =3D (PRU_CAN_RX_MAILBOX8);
> +		break;
> +	default:
> +		return -1;
> +	}
> +
> +	s16subrtnretval =3D
> +	    pruss_readl(dev, u32offset,
> +		  (u32 *) &(pstremuapphndl->strcanmailbox),
> +				  4);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +	return 0;
> +}
> +
> +/*
> + * pru_can_receive_id_map()
> + * Receive mailboxes ID Mapping of PRU0  of OMAP L138.
> + * This API will be called by the Application
> + * to map the IDs  to receive mailboxes of PRU0
> + *
> + * param  u32nodeid		Can node ID
> + *
> + * param  ecanmailboxno		Mailbox to be mapped
> + *
> + * return   SUCCESS or FAILURE
> + */
> +s16 pru_can_rx_id_map(struct device *dev, u32 u32nodeid,
> +		can_mailbox_number ecanmailboxno)
> +{
> +
> +	pruss_writel(dev, (PRU_CAN_ID_MAP +
> +		(((u8) ecanmailboxno) * 4)), (u32 *) &u32nodeid, 1);
> +
> +	return 0;
> +}
> +
> +/*
> + * pru_can_get_intr_status()
> + * Gets the interrupts status register value.
> + * This API will be called by the Application
> + * to get the interrupts status register value
> + *
> + * param  u8prunumber	PRU number for which IntStatusReg
> + * has to be read
> + *
> + * return   SUCCESS or FAILURE
> + */
> +s16 pru_can_get_intr_status(struct device *dev,
> +		can_emu_app_hndl *pstremuapphndl)
> +{
> +	u32 u32offset;
> +	s16 s16subrtnretval =3D -1;
> +
> +	if (pstremuapphndl =3D=3D NULL) {
> +		return -1;
> +	}
> +
> +	if (pstremuapphndl->u8prunumber =3D=3D DA8XX_PRUCORE_1) {
> +		u32offset =3D (PRU_CAN_TX_INTERRUPT_STATUS_REGISTER);
> +	} else if (pstremuapphndl->u8prunumber =3D=3D DA8XX_PRUCORE_0) {
> +		u32offset =3D (PRU_CAN_RX_INTERRUPT_STATUS_REGISTER);
> +	} else {
> +		return -1;
> +	}
> +
> +	s16subrtnretval =3D pruss_readl(dev, u32offset,
> +		(u32 *) &pstremuapphndl->u32interruptstatus, 1);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	return 0;
> +}
> +
> +/*
> + * pru_can_get_global_status()	Gets the globalstatus
> + * register value. This API will be called by the Application
> + * to  get the global status register value
> + *
> + * return   SUCCESS or FAILURE
> + */
> +s16 pru_can_get_global_status(struct device *dev,
> +		can_emu_app_hndl *pstremuapphndl)
> +{
> +	u32 u32offset;
> +	int s16subrtnretval =3D -1;
> +
> +	if (pstremuapphndl =3D=3D NULL) {
> +		return -1;
> +	}
> +
> +	if (pstremuapphndl->u8prunumber =3D=3D DA8XX_PRUCORE_1) {
> +		u32offset =3D (PRU_CAN_TX_GLOBAL_STATUS_REGISTER);
> +	} else if (pstremuapphndl->u8prunumber =3D=3D DA8XX_PRUCORE_0) {
> +		u32offset =3D (PRU_CAN_RX_GLOBAL_STATUS_REGISTER);
> +	} else {
> +		return -1;
> +	}
> +
> +	s16subrtnretval =3D pruss_readl(dev, u32offset,
> +		(u32 *) &pstremuapphndl->u32globalstatus, 1);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	return 0;
> +}
> +
> +/*
> + * pru_can_get_mailbox_status()		Gets the mailbox status
> + * register value. This API will be called by the Application
> + * to get the mailbox status register value
> + *
> + * return   SUCCESS or FAILURE
> + */
> +s16 pru_can_get_mailbox_status(struct device *dev,
> +		can_emu_app_hndl *pstremuapphndl)
> +{
> +	u32 u32offset;
> +	s16 s16subrtnretval =3D -1;
> +
> +	if (pstremuapphndl =3D=3D NULL) {
> +		return -1;
> +	}
> +
> +	if (pstremuapphndl->u8prunumber =3D=3D DA8XX_PRUCORE_1) {
> +		switch (pstremuapphndl->ecanmailboxnumber) {
> +		case 0:
> +			u32offset =3D (PRU_CAN_TX_MAILBOX0_STATUS_REGISTER);
> +			break;
> +		case 1:
> +			u32offset =3D (PRU_CAN_TX_MAILBOX1_STATUS_REGISTER);
> +			break;
> +		case 2:
> +			u32offset =3D (PRU_CAN_TX_MAILBOX2_STATUS_REGISTER);
> +			break;
> +		case 3:
> +			u32offset =3D (PRU_CAN_TX_MAILBOX3_STATUS_REGISTER);
> +			break;
> +		case 4:
> +			u32offset =3D (PRU_CAN_TX_MAILBOX4_STATUS_REGISTER);
> +			break;
> +		case 5:
> +			u32offset =3D (PRU_CAN_TX_MAILBOX5_STATUS_REGISTER);
> +			break;
> +		case 6:
> +			u32offset =3D (PRU_CAN_TX_MAILBOX6_STATUS_REGISTER);
> +			break;
> +		case 7:
> +			u32offset =3D (PRU_CAN_TX_MAILBOX7_STATUS_REGISTER);
> +			break;
> +		default:
> +			return -1;
> +		}
> +	}
> +
> +	else if (pstremuapphndl->u8prunumber =3D=3D DA8XX_PRUCORE_0) {
> +		switch (pstremuapphndl->ecanmailboxnumber) {
> +		case 0:
> +			u32offset =3D (PRU_CAN_RX_MAILBOX0_STATUS_REGISTER);
> +			break;
> +		case 1:
> +			u32offset =3D (PRU_CAN_RX_MAILBOX1_STATUS_REGISTER);
> +			break;
> +		case 2:
> +			u32offset =3D (PRU_CAN_RX_MAILBOX2_STATUS_REGISTER);
> +			break;
> +		case 3:
> +			u32offset =3D (PRU_CAN_RX_MAILBOX3_STATUS_REGISTER);
> +			break;
> +		case 4:
> +			u32offset =3D (PRU_CAN_RX_MAILBOX4_STATUS_REGISTER);
> +			break;
> +		case 5:
> +			u32offset =3D (PRU_CAN_RX_MAILBOX5_STATUS_REGISTER);
> +			break;
> +		case 6:
> +			u32offset =3D (PRU_CAN_RX_MAILBOX6_STATUS_REGISTER);
> +			break;
> +		case 7:
> +			u32offset =3D (PRU_CAN_RX_MAILBOX7_STATUS_REGISTER);
> +			break;
> +		case 8:
> +			u32offset =3D (PRU_CAN_RX_MAILBOX8_STATUS_REGISTER);
> +			break;
> +		default:
> +			return -1;
> +		}
> +	}
> +
> +	else {
> +		return -1;
> +	}
> +
> +	s16subrtnretval =3D pruss_readl(dev, u32offset,
> +		(u32 *) &pstremuapphndl->u32mailboxstatus, 1);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	return 0;
> +}
> +
> +s16 pru_can_tx_mode_set(struct device *dev, bool btransfer_flag,
> +				can_transfer_direction ecan_trx)
> +{
> +	u32 u32offset;
> +	u32 u32value;
> +
> +	if (ecan_trx =3D=3D ecantransmit) {
> +		u32offset =3D (PRU_CAN_RX_GLOBAL_STATUS_REGISTER);
> +		pruss_readl(dev, u32offset, &u32value, 1);
> +		if (btransfer_flag =3D=3D true) {
> +			u32value &=3D 0x1F;
> +			u32value |=3D 0x80;
> +		} else {
> +			u32value &=3D 0x7F;
> +		}
> +		pruss_writel(dev, u32offset, &u32value, 1);
> +		u32offset =3D (PRU_CAN_TX_GLOBAL_STATUS_REGISTER);
> +		pruss_writel(dev, u32offset, &u32value, 1);
> +	} else if (ecan_trx =3D=3D ecanreceive) {
> +		u32offset =3D (PRU_CAN_RX_GLOBAL_STATUS_REGISTER);
> +		pruss_readl(dev, u32offset, &u32value, 1);
> +		if (btransfer_flag =3D=3D true) {
> +			u32value &=3D 0x1F;
> +			u32value |=3D 0x40;
> +		} else {
> +			u32value &=3D 0xBF;
> +		}
> +		pruss_writel(dev, u32offset, &u32value, 1);
> +		u32offset =3D (PRU_CAN_TX_GLOBAL_STATUS_REGISTER);
> +		pruss_writel(dev, u32offset, &u32value, 1);
> +	} else
> +		return -1;
> +
> +	return 0;
> +}
> +
> +/*
> + * pru_can_config_mode_set()		Sets the timing value
> + * for data transfer. This API will be called by the Application
> + * to set timing valus for data transfer
> + *
> + * return   SUCCESS or FAILURE
> + */
> +s16 pru_can_config_mode_set(struct device *dev, bool bconfigmodeflag)
> +{
> +
> +	u32 u32bitrateprescaler;
> +	u32 u32canbittiming;
> +
> +	pruss_readl(dev, (PRU_CAN_TX_CLOCK_BRP_REGISTER),
> +			(u32 *) &u32bitrateprescaler, 1);
> +	pruss_readl(dev, (PRU_CAN_TX_TIMING_REGISTER),
> +			(u32 *) &u32canbittiming, 1);
> +
> +	if (bconfigmodeflag =3D=3D 1) {
> +		pru_can_calc_timing(dev, u32canbittiming, u32bitrateprescaler);
> +	}
> +
> +	else {
> +		pru_can_calc_timing(dev, 0, 0);
> +	}
> +
> +	return 0;
> +}
> +
> +/*
> + * pru_can_emu_init()		Initializes the Can
> + * Emulation Parameters. This API will be called by the Application
> + * to Initialize the Can Emulation Parameters
> + *
> + * param    u32pruclock         PRU Clock value
> + *
> + * return   SUCCESS or FAILURE
> + */
> +s16 pru_can_emu_init(struct device *dev, u32 u32pruclock)
> +{
> +	u32 u32offset;
> +	u32 u32value;
> +	s16 s16subrtnretval =3D -1;
> +	u8 u8loop;
> +
> +	for (u8loop =3D 0; u8loop < (u8) ecanmaxinst; u8loop++) {
> +		gstr_can_inst[u8loop].bcaninststate =3D (bool) 0;
> +		gstr_can_inst[u8loop].ecantransferdirection =3D
> +		    (can_transfer_direction) 0;
> +		gstr_can_inst[u8loop].u32apphandlerptr =3D 0;
> +	}
> +
> +	u32offset =3D (PRU_CAN_TX_GLOBAL_CONTROL_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000000;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_TX_GLOBAL_STATUS_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000040;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +	u32offset =3D (PRU_CAN_RX_GLOBAL_STATUS_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000040;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_TX_INTERRUPT_MASK_REGISTER & 0xFFFF);
> +	u32value =3D 0x00004000;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_TX_INTERRUPT_STATUS_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000000;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_TX_MAILBOX0_STATUS_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000001;
> +	s16subrtnretval =3D
> +	    pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_TX_MAILBOX1_STATUS_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000001;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_TX_MAILBOX2_STATUS_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000001;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_TX_MAILBOX3_STATUS_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000001;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_TX_MAILBOX4_STATUS_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000001;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_TX_MAILBOX5_STATUS_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000001;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_TX_MAILBOX6_STATUS_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000001;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_TX_MAILBOX7_STATUS_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000001;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_TX_ERROR_COUNTER_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000000;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_TX_TIMING_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000000;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_TX_CLOCK_BRP_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000000;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_TX_ERROR_COUNTER_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000000;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRUSS_INTC_POLARITY0 & 0xFFFF);
> +	u32value =3D 0xFFFFFFFF;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +	u32offset =3D (PRUSS_INTC_POLARITY1 & 0xFFFF);
> +	u32value =3D 0xFFFFFFFF;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +	u32offset =3D (PRUSS_INTC_TYPE0 & 0xFFFF);
> +	u32value =3D 0x1C000000;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +	u32offset =3D (PRUSS_INTC_TYPE1 & 0xFFFF);
> +	u32value =3D 0x00000000;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRUSS_INTC_HSTINTENIDXCLR & 0xFFFF);
> +	u32value =3D 0x0;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRUSS_INTC_GLBLEN & 0xFFFF);
> +	u32value =3D 0x1;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +	/* tx intr map arm->pru */
> +	u32offset =3D (PRUSS_INTC_HSTINTENIDXSET & 0xFFFF);
> +	u32value =3D 0x0;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRUSS_INTC_HOSTMAP0 & 0xFFFF);
> +	u32value =3D 0x03020100;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRUSS_INTC_HOSTMAP1 & 0xFFFF);
> +	u32value =3D 0x07060504;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRUSS_INTC_HOSTMAP2 & 0xFFFF);
> +	u32value =3D 0x0000908;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRUSS_INTC_CHANMAP0 & 0xFFFF);
> +	u32value =3D 0;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRUSS_INTC_CHANMAP8 & 0xFFFF);
> +	u32value =3D 0x00020200;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRUSS_INTC_STATIDXCLR & 0xFFFF);
> +	u32value =3D 32;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRUSS_INTC_STATIDXCLR & 0xFFFF);
> +	u32value =3D 19;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRUSS_INTC_ENIDXSET & 0xFFFF);
> +	u32value =3D 19;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +	u32offset =3D (PRUSS_INTC_STATIDXCLR & 0xFFFF);
> +	u32value =3D 18;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRUSS_INTC_ENIDXSET & 0xFFFF);
> +	u32value =3D 18;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRUSS_INTC_STATIDXCLR & 0xFFFF);
> +	u32value =3D 34;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRUSS_INTC_ENIDXSET & 0xFFFF);
> +	u32value =3D 34;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRUSS_INTC_ENIDXSET & 0xFFFF);
> +	u32value =3D 32;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRUSS_INTC_HOSTINTEN & 0xFFFF);
> +	u32value =3D 0x5;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +/* PRU0 - Rx Internal Registers Initializations */
> +
> +	u32offset =3D (PRU_CAN_RX_GLOBAL_CONTROL_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000000;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_RX_GLOBAL_STATUS_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000040;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_RX_INTERRUPT_MASK_REGISTER & 0xFFFF);
> +	u32value =3D 0x00004000;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_RX_INTERRUPT_STATUS_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000000;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_RX_MAILBOX0_STATUS_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000000;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_RX_MAILBOX1_STATUS_REGISTER & 0xFFFF);
> +	u32value =3D 0x0000000;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_RX_MAILBOX2_STATUS_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000000;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_RX_MAILBOX3_STATUS_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000000;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_RX_MAILBOX4_STATUS_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000000;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_RX_MAILBOX5_STATUS_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000000;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_RX_MAILBOX6_STATUS_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000000;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_RX_MAILBOX7_STATUS_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000000;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_RX_ERROR_COUNTER_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000000;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_RX_TIMING_REGISTER & 0xFFFF);
> +	u32value =3D 0x0000000;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +
> +	u32offset =3D (PRU_CAN_RX_CLOCK_BRP_REGISTER & 0xFFFF);
> +	u32value =3D 0x00000000;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset, (u32 *) &u32value, 1=
);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +	return 0;
> +}
> +
> +
> +/*
> + * pru_can_emu_open()		Opens the can emu for
> + * application to use. This API will be called by the Application
> + * to Open the can emu for application to use.
> + *
> + * param	pstremuapphndl	Pointer to application handler
> + * structure
> + *
> + * return   SUCCESS or FAILURE
> + */
> +s16 pru_can_emu_open(struct device *dev, can_emu_app_hndl *pstremuapph=
ndl)
> +{
> +
> +	if (pstremuapphndl =3D=3D NULL) {
> +		return -1;
> +	}
> +
> +	if (gstr_can_inst[pstremuapphndl->ecaninstance].bcaninststate =3D=3D =
1) {
> +		return -1;
> +	}
> +
> +	gstr_can_inst[(u8) pstremuapphndl->ecaninstance].
> +					bcaninststate =3D (bool)1;
> +	gstr_can_inst[(u8) pstremuapphndl->
> +		ecaninstance].ecantransferdirection =3D
> +		(can_transfer_direction)(u8)pstremuapphndl->ecantransferdirection;
> +	gstr_can_inst[(u8) pstremuapphndl->ecaninstance].
> +		u32apphandlerptr =3D (u32) pstremuapphndl;
> +
> +	return 0;
> +}
> +
> +
> +/*
> + * brief    pru_can_emu_close()	Closes the can emu for other
> + * applications to use. This API will be called by the Application to =
Close
> + * the can emu for other applications to use
> + *
> + * param	pstremuapphndl	Pointer to application handler structure
> + *
> + * return   SUCCESS or FAILURE
> + */
> +s16 pru_can_emu_close(struct device *dev, can_emu_app_hndl *pstremuapp=
hndl)
> +{
> +
> +	if (pstremuapphndl =3D=3D NULL) {
> +		return -1;
> +	}
> +	if (gstr_can_inst[pstremuapphndl->ecaninstance].bcaninststate =3D=3D =
0) {
> +		return -1;
> +	}
> +	if ((u32) pstremuapphndl !=3D gstr_can_inst[(u8) pstremuapphndl->
> +			ecaninstance].u32apphandlerptr){
> +		return -1;
> +	}
> +	gstr_can_inst[(u8) pstremuapphndl->ecaninstance].bcaninststate
> +		=3D (bool) 0;
> +	gstr_can_inst[(u8) pstremuapphndl->
> +	ecaninstance].ecantransferdirection =3D (can_transfer_direction) 0;
> +	gstr_can_inst[(u8) pstremuapphndl->ecaninstance].u32apphandlerptr =3D=
 0;
> +
> +	return 0;
> +}
> +
> +/*
> + * brief    pru_can_emu_exit()	Diables all the PRUs
> + * This API will be called by the Application to disable all PRUs
> + * param	None
> + * return   SUCCESS or FAILURE
> + */
> +s16 pru_can_emu_exit(struct device *dev)
> +{
> +	s16 s16subrtnretval;
> +
> +	s16subrtnretval =3D pruss_disable(dev, CAN_RX_PRU_0);
> +	if (s16subrtnretval =3D=3D -1)
> +		return -1;
> +	s16subrtnretval =3D pruss_disable(dev, CAN_TX_PRU_1);
> +	if (s16subrtnretval =3D=3D -1)
> +		return -1;
> +
> +	return 0;
> +}
> +
> +s16 pru_can_emu_sreset(struct device *dev)
> +{
> +	return 0;
> +}
> +
> +s16 pru_can_tx(struct device *dev, u8 u8mailboxnumber, u8 u8prunumber)=

> +{
> +	u32 u32offset =3D 0;
> +	u32 u32value =3D 0;
> +	s16 s16subrtnretval =3D -1;
> +
> +	if (DA8XX_PRUCORE_1 =3D=3D u8prunumber) {
> +		switch (u8mailboxnumber) {
> +		case 0:
> +			u32offset =3D (PRU_CAN_TX_MAILBOX0_STATUS_REGISTER & 0xFFFF);
> +			u32value =3D 0x00000080;
> +			s16subrtnretval =3D pruss_writel(dev, u32offset,
> +					(u32 *) &u32value, 1);
> +			if (s16subrtnretval =3D=3D -1) {
> +				return -1;
> +			}
> +			break;
> +		case 1:
> +			u32offset =3D (PRU_CAN_TX_MAILBOX1_STATUS_REGISTER & 0xFFFF);
> +			u32value =3D 0x00000080;
> +			s16subrtnretval =3D pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval =3D=3D -1) {
> +				return -1;
> +			}
> +			break;
> +		case 2:
> +			u32offset =3D (PRU_CAN_TX_MAILBOX2_STATUS_REGISTER & 0xFFFF);
> +			u32value =3D 0x00000080;
> +			s16subrtnretval =3D pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval =3D=3D -1) {
> +				return -1;
> +			}
> +			break;
> +		case 3:
> +			u32offset =3D (PRU_CAN_TX_MAILBOX3_STATUS_REGISTER & 0xFFFF);
> +			u32value =3D 0x00000080;
> +			s16subrtnretval =3D pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval =3D=3D -1) {
> +				return -1;
> +			}
> +			break;
> +		case 4:
> +			u32offset =3D (PRU_CAN_TX_MAILBOX4_STATUS_REGISTER & 0xFFFF);
> +			u32value =3D 0x00000080;
> +			s16subrtnretval =3D pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval =3D=3D -1) {
> +				return -1;
> +			}
> +			break;
> +		case 5:
> +			u32offset =3D (PRU_CAN_TX_MAILBOX5_STATUS_REGISTER & 0xFFFF);
> +			u32value =3D 0x00000080;
> +			s16subrtnretval =3D pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval =3D=3D -1) {
> +				return -1;
> +			}
> +			break;
> +		case 6:
> +			u32offset =3D (PRU_CAN_TX_MAILBOX6_STATUS_REGISTER & 0xFFFF);
> +			u32value =3D 0x00000080;
> +			s16subrtnretval =3D pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval =3D=3D -1) {
> +				return -1;
> +			}
> +			break;
> +		case 7:
> +			u32offset =3D (PRU_CAN_TX_MAILBOX7_STATUS_REGISTER & 0xFFFF);
> +			u32value =3D 0x00000080;
> +			s16subrtnretval =3D pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval =3D=3D -1) {
> +				return -1;
> +			}
> +			break;
> +		default:
> +			return -1;
> +		}
> +	} else {
> +
> +		u32offset =3D (PRU_CAN_RX_INTERRUPT_STATUS_REGISTER & 0xFFFF);
> +		u32value =3D 0x00000000;
> +		s16subrtnretval =3D pruss_readl(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +		if (s16subrtnretval =3D=3D -1) {
> +			return -1;
> +		}
> +		u32value =3D u32value & ~(1 << u8mailboxnumber);
> +		s16subrtnretval =3D pruss_writel(dev, u32offset,
> +					(u32 *) &u32value, 1);
> +		if (s16subrtnretval =3D=3D -1) {
> +			return -1;
> +		}
> +
> +		switch (u8mailboxnumber) {
> +		case 0:
> +			u32offset =3D (PRU_CAN_RX_MAILBOX0_STATUS_REGISTER & 0xFFFF);
> +			u32value =3D 0x00000000;
> +			s16subrtnretval =3D pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval =3D=3D -1) {
> +				return -1;
> +			}
> +			break;
> +		case 1:
> +			u32offset =3D (PRU_CAN_RX_MAILBOX1_STATUS_REGISTER & 0xFFFF);
> +			u32value =3D 0x00000000;
> +			s16subrtnretval =3D pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval =3D=3D -1) {
> +				return -1;
> +			}
> +			break;
> +		case 2:
> +			u32offset =3D (PRU_CAN_RX_MAILBOX2_STATUS_REGISTER & 0xFFFF);
> +			u32value =3D 0x00000000;
> +			s16subrtnretval =3D pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval =3D=3D -1) {
> +				return -1;
> +			}
> +			break;
> +		case 3:
> +			u32offset =3D (PRU_CAN_RX_MAILBOX3_STATUS_REGISTER & 0xFFFF);
> +			u32value =3D 0x00000000;
> +			s16subrtnretval =3D pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval =3D=3D -1) {
> +				return -1;
> +			}
> +			break;
> +		case 4:
> +			u32offset =3D (PRU_CAN_RX_MAILBOX4_STATUS_REGISTER & 0xFFFF);
> +			u32value =3D 0x00000000;
> +			s16subrtnretval =3D pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval =3D=3D -1) {
> +				return -1;
> +			}
> +			break;
> +		case 5:
> +			u32offset =3D (PRU_CAN_RX_MAILBOX5_STATUS_REGISTER & 0xFFFF);
> +			u32value =3D 0x00000000;
> +			s16subrtnretval =3D pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval =3D=3D -1) {
> +				return -1;
> +			}
> +			break;
> +		case 6:
> +			u32offset =3D (PRU_CAN_RX_MAILBOX6_STATUS_REGISTER & 0xFFFF);
> +			u32value =3D 0x00000000;
> +			s16subrtnretval =3D pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval =3D=3D -1) {
> +				return -1;
> +			}
> +			break;
> +		case 7:
> +			u32offset =3D (PRU_CAN_RX_MAILBOX7_STATUS_REGISTER & 0xFFFF);
> +			u32value =3D 0x00000000;
> +			s16subrtnretval =3D pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval =3D=3D -1) {
> +				return -1;
> +			}
> +			break;
> +		default:
> +			return -1;
> +		}
> +	}
> +	return 0;
> +}
> +
> +s16 pru_can_start_abort_tx(struct device *dev, bool bcantransmitabortf=
lag)
> +{
> +	u32 u32offset;
> +	u32 u32value;
> +	s16 s16subrtnretval;
> +	u32offset =3D (PRUSS_INTC_STATIDXCLR & 0xFFFF);
> +	u32value =3D 32;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset,
> +					(u32 *) &u32value, 1);
> +
> +	u32offset =3D (PRUSS_INTC_ENIDXSET & 0xFFFF);
> +	u32value =3D 32;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset,
> +					(u32 *) &u32value, 1);
> +
> +	u32offset =3D (PRUSS_INTC_STATIDXSET & 0xFFFF);
> +	u32value =3D 32;
> +	s16subrtnretval =3D pruss_writel(dev, u32offset,
> +					(u32 *) &u32value, 1);
> +	if (s16subrtnretval =3D=3D -1) {
> +		return -1;
> +	}
> +	return 0;
> +}
> +
> +s16 pru_can_mask_ints(struct device *dev, u32 int_mask)
> +{
> +	return 0;
> +}
> +
> +int pru_can_get_error_cnt(struct device *dev, u8 u8prunumber)
> +{
> +	return 0;
> +}
> +
> +int pru_can_get_intc_status(struct device *dev)
> +{
> +	u32 u32offset =3D 0;
> +	u32 u32getvalue =3D 0;
> +	u32 u32clrvalue =3D 0;
> +
> +	u32offset =3D (PRUSS_INTC_STATCLRINT1 & 0xFFFF);
> +	pruss_readl(dev, u32offset, (u32 *) &u32getvalue, 1);
> +
> +	if (u32getvalue & 4)
> +		u32clrvalue =3D 34;	/* CLR Event 34 */
> +
> +	if (u32getvalue & 2)
> +		u32clrvalue =3D 33;	/* CLR Event 33  */
> +
> +	if (u32clrvalue) {
> +		u32offset =3D (PRUSS_INTC_STATIDXCLR & 0xFFFF);
> +		pruss_writel(dev, u32offset, &u32clrvalue, 1);
> +	} else
> +		return -1;
> +
> +	return u32getvalue;
> +}
> diff --git a/drivers/net/can/da8xx_pruss/pruss_can_api.h b/drivers/net/=
can/da8xx_pruss/pruss_can_api.h
> new file mode 100644
> index 0000000..7550456
> --- /dev/null
> +++ b/drivers/net/can/da8xx_pruss/pruss_can_api.h
> @@ -0,0 +1,290 @@
> +/*
> + * Copyright (C) 2010 Texas Instruments Incorporated
> + * Author: Ganeshan N
> + *
> + * This program is free software; you can redistribute it and/or modif=
y it
> + * under the terms of the GNU General Public License as  published by =
the
> + * Free Software Foundation version 2.
> + *
> + * This program is distributed "as is" WITHOUT ANY WARRANTY of any kin=
d,
> + * whether express or implied; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> + * General Public License for more details.
> + */
> +
> +#ifndef _PRU_CAN_API_H_
> +#define _PRU_CAN_API_H_
> +
> +#include <linux/types.h>
> +#include <linux/mfd/pruss/da8xx_pru.h>
> +
> +
> +#define CAN_BIT_TIMINGS			(0x273)
> +
> +/* Timer Clock is sourced from DDR freq (PLL1 SYS CLK 2) */
> +#define	TIMER_CLK_FREQ			132000000

any change to get this from a clk_dev?

> +
> +#define TIMER_SETUP_DELAY		14
> +#define GPIO_SETUP_DELAY		150
> +
> +#define CAN_RX_PRU_0			PRUSS_NUM0
> +#define CAN_TX_PRU_1			PRUSS_NUM1
> +
> +/* Number of Instruction in the Delay loop */
> +#define DELAY_LOOP_LENGTH		2

please create a struct describing your register layout.

> +
> +#define PRU1_BASE_ADDR			0x2000
> +
> +#define PRU_CAN_TX_GLOBAL_CONTROL_REGISTER		(PRU1_BASE_ADDR)
> +#define PRU_CAN_TX_GLOBAL_STATUS_REGISTER		(PRU1_BASE_ADDR	+ 0x04)
> +#define PRU_CAN_TX_INTERRUPT_MASK_REGISTER		(PRU1_BASE_ADDR	+ 0x08)
> +#define PRU_CAN_TX_INTERRUPT_STATUS_REGISTER		(PRU1_BASE_ADDR	+ 0x0C)
> +#define PRU_CAN_TX_MAILBOX0_STATUS_REGISTER		(PRU1_BASE_ADDR	+ 0x10)
> +#define PRU_CAN_TX_MAILBOX1_STATUS_REGISTER		(PRU1_BASE_ADDR	+ 0x14)
> +#define PRU_CAN_TX_MAILBOX2_STATUS_REGISTER		(PRU1_BASE_ADDR	+ 0x18)
> +#define PRU_CAN_TX_MAILBOX3_STATUS_REGISTER		(PRU1_BASE_ADDR	+ 0x1C)
> +#define PRU_CAN_TX_MAILBOX4_STATUS_REGISTER		(PRU1_BASE_ADDR	+ 0x20)
> +#define PRU_CAN_TX_MAILBOX5_STATUS_REGISTER		(PRU1_BASE_ADDR	+ 0x24)
> +#define PRU_CAN_TX_MAILBOX6_STATUS_REGISTER		(PRU1_BASE_ADDR	+ 0x28)
> +#define PRU_CAN_TX_MAILBOX7_STATUS_REGISTER		(PRU1_BASE_ADDR	+ 0x2C)

please use an array for the mailbox status register.

> +#define PRU_CAN_TX_ERROR_COUNTER_REGISTER		(PRU1_BASE_ADDR	+ 0x30)
> +#define PRU_CAN_TX_TIMING_REGISTER			(PRU1_BASE_ADDR	+ 0x34)
> +#define PRU_CAN_TX_CLOCK_BRP_REGISTER			(PRU1_BASE_ADDR	+ 0x38)
> +
> +#define PRU_CAN_TX_MAILBOX0				(PRU1_BASE_ADDR	+ 0x40)
> +#define PRU_CAN_TX_MAILBOX1				(PRU1_BASE_ADDR	+ 0x50)
> +#define PRU_CAN_TX_MAILBOX2				(PRU1_BASE_ADDR	+ 0x60)
> +#define PRU_CAN_TX_MAILBOX3				(PRU1_BASE_ADDR	+ 0x70)
> +#define PRU_CAN_TX_MAILBOX4				(PRU1_BASE_ADDR	+ 0x80)
> +#define PRU_CAN_TX_MAILBOX5				(PRU1_BASE_ADDR	+ 0x90)
> +#define PRU_CAN_TX_MAILBOX6				(PRU1_BASE_ADDR	+ 0xA0)
> +#define PRU_CAN_TX_MAILBOX7				(PRU1_BASE_ADDR	+ 0xB0)

also use an array here

> +
> +#define PRU_CAN_TIMING_VAL_TX				(PRU1_BASE_ADDR	+ 0xC0)
> +#define PRU_CAN_TIMING_VAL_TX_SJW			(PRU1_BASE_ADDR	+ 0xC4)
> +#define PRU_CAN_TRANSMIT_FRAME				(PRU1_BASE_ADDR	+ 0xE0)
> +
> +#define PRU0_BASE_ADDR					0
> +
> +#define PRU_CAN_RX_GLOBAL_CONTROL_REGISTER		(PRU0_BASE_ADDR)
> +#define PRU_CAN_RX_GLOBAL_STATUS_REGISTER		(PRU0_BASE_ADDR	+ 0x04)
> +#define PRU_CAN_RX_INTERRUPT_MASK_REGISTER		(PRU0_BASE_ADDR	+ 0x08)
> +#define PRU_CAN_RX_INTERRUPT_STATUS_REGISTER		(PRU0_BASE_ADDR	+ 0x0C)
> +#define PRU_CAN_RX_MAILBOX0_STATUS_REGISTER		(PRU0_BASE_ADDR	+ 0x10)
> +#define PRU_CAN_RX_MAILBOX1_STATUS_REGISTER		(PRU0_BASE_ADDR	+ 0x14)
> +#define PRU_CAN_RX_MAILBOX2_STATUS_REGISTER		(PRU0_BASE_ADDR	+ 0x18)
> +#define PRU_CAN_RX_MAILBOX3_STATUS_REGISTER		(PRU0_BASE_ADDR	+ 0x1C)
> +#define PRU_CAN_RX_MAILBOX4_STATUS_REGISTER		(PRU0_BASE_ADDR	+ 0x20)
> +#define PRU_CAN_RX_MAILBOX5_STATUS_REGISTER		(PRU0_BASE_ADDR	+ 0x24)
> +#define PRU_CAN_RX_MAILBOX6_STATUS_REGISTER		(PRU0_BASE_ADDR	+ 0x28)
> +#define PRU_CAN_RX_MAILBOX7_STATUS_REGISTER		(PRU0_BASE_ADDR	+ 0x2C)
> +#define PRU_CAN_RX_MAILBOX8_STATUS_REGISTER		(PRU0_BASE_ADDR	+ 0x30)

=2E..array

> +#define PRU_CAN_RX_ERROR_COUNTER_REGISTER		(PRU0_BASE_ADDR	+ 0x34)
> +#define PRU_CAN_RX_TIMING_REGISTER			(PRU0_BASE_ADDR	+ 0x38)
> +#define PRU_CAN_RX_CLOCK_BRP_REGISTER			(PRU0_BASE_ADDR	+ 0x3C)
> +
> +#define PRU_CAN_RX_MAILBOX0				(PRU0_BASE_ADDR	+ 0x40)
> +#define PRU_CAN_RX_MAILBOX1				(PRU0_BASE_ADDR	+ 0x50)
> +#define PRU_CAN_RX_MAILBOX2				(PRU0_BASE_ADDR	+ 0x60)
> +#define PRU_CAN_RX_MAILBOX3				(PRU0_BASE_ADDR	+ 0x70)
> +#define PRU_CAN_RX_MAILBOX4				(PRU0_BASE_ADDR	+ 0x80)
> +#define PRU_CAN_RX_MAILBOX5				(PRU0_BASE_ADDR	+ 0x90)
> +#define PRU_CAN_RX_MAILBOX6				(PRU0_BASE_ADDR	+ 0xA0)
> +#define PRU_CAN_RX_MAILBOX7				(PRU0_BASE_ADDR	+ 0xB0)
> +#define PRU_CAN_RX_MAILBOX8				(PRU0_BASE_ADDR	+ 0xC0)

=2E.array

The rx and tx register set look quite similar. Is it intended that you
have 8 tx but 9 rx mailboxes? Anyway....make a struct descriing the
register set and use it twice, one for rx and one for tx.

> +
> +#define PRU_CAN_TIMING_VAL_RX				(PRU0_BASE_ADDR	+ 0xD0)
> +#define PRU_CAN_RECEIVE_FRAME				(PRU0_BASE_ADDR	+ 0xD4)
> +#define PRU_CAN_ID_MAP					(PRU0_BASE_ADDR	+ 0xF0)
> +
> +#define PRU_CAN_ERROR_ACTIVE				128
> +
> +#define CAN_ACK_FAILED					0xE
> +#define CAN_ARBTR_FAIL					0xD
> +#define CAN_BIT_ERROR					0xC
> +#define CAN_TRANSMISSION_SUCCESS			0xA
> +
> +#define STD_DATA_FRAME					0x1
> +#define EXTD_DATA_FRAME					0x2
> +#define STD_REMOTE_FRAME				0x3
> +#define EXTD_REMOTE_FRAME				0x4
> +
> +#define PRU_CAN_MAX_SJW					8
> +#define PRU_CAN_MAX_PHSEG1				25
> +#define PRU_CAN_MAX_PHSEG2				25
> +
> +#define DA8XX_PRUCANCORE_0_REGS				0x7000
> +#define DA8XX_PRUCANCORE_1_REGS				0x7800
> +#define PRU0_PROG_RAM_START_OFFSET			0x8000
> +#define PRU1_PROG_RAM_START_OFFSET			0xC000
> +#define PRU_CAN_INIT_MAX_TIMEOUT			0xFF
> +
> +typedef enum {
> +	ecaninst0 =3D 0,
> +	ecaninst1,
> +	ecanmaxinst
> +} can_instance_enum;

seens unused
> +
> +typedef enum {
> +	ecanmailbox0 =3D 0,
> +	ecanmailbox1,
> +	ecanmailbox2,
> +	ecanmailbox3,
> +	ecanmailbox4,
> +	ecanmailbox5,
> +	ecanmailbox6,
> +	ecanmailbox7
> +} can_mailbox_number;

unused, too
> +
> +typedef enum {
> +	ecandirectioninit =3D 0,
> +	ecantransmit,
> +	ecanreceive
> +} can_transfer_direction;

please add a common prefix and please write them uppsercase.

> +
> +typedef struct {
> +	u16 u16extendedidentifier;
> +	u16 u16baseidentifier;
> +	u8 u8data7;
> +	u8 u8data6;
> +	u8 u8data5;
> +	u8 u8data4;
> +	u8 u8data3;
> +	u8 u8data2;
> +	u8 u8data1;
> +	u8 u8data0;

use an array for the data.

> +	u16 u16datalength;
> +	u16 u16crc;
> +} can_mail_box_structure;
> +
> +typedef struct {
> +	can_transfer_direction ecantransferdirection;
> +} can_mailbox_config;
> +
> +typedef struct {
> +	can_instance_enum ecaninstance;
> +	can_transfer_direction ecantransferdirection;
> +	can_mail_box_structure strcanmailbox;
> +	can_mailbox_number ecanmailboxnumber;
> +	u8 u8prunumber;
> +	u32 u32globalstatus;
> +	u32 u32interruptstatus;
> +	u32 u32mailboxstatus;
> +} can_emu_app_hndl;

You already have defines your priv. No need for further structs.

> +
> +typedef struct {
> +	bool bcaninststate;
> +	can_transfer_direction ecantransferdirection;
> +	u32 u32apphandlerptr;
> +} can_emu_drv_inst;

dito

> +
> +typedef struct {
> +	u8 u8syncjumpwidth;
> +	u8 u8phseg1;
> +	u8 u8phseg2;
> +} can_bit_timing_consts;
> +
> +/* Field Definition Macros  */
> +
> +/* CONTROL */
>

get rid of all the following functions, you don't need that extra layer
in the can driver.

> +/*
> + * pru_can_set_brp() Updates the  BRP register of PRU.
> + */
> +s16 pru_can_set_brp(struct device *dev, u16 u16prescaler);
> +
> +/*
> + * pru_can_set_bit_timing() Updates the  timing register of PRU
> + */
> +s16 pru_can_set_bit_timing(struct device *dev,
> +			can_bit_timing_consts *pstrbittiming);
> +
> +/*
> + * pru_can_calc_timing() Updates the timing values of PRU
> + */
> +s16 pru_can_calc_timing(struct device *dev,
> +			u32 u32bittiming, u32 u32bitrateprescaler);
> +
> +/*
> + * pru_can_write_data_to_mailbox() Updates the transmit mailboxes of P=
RU1
> + */
> +s16 pru_can_write_data_to_mailbox(struct device *dev,
> +			can_emu_app_hndl *pstremuapphndl);
> +
> +/*
> + * pru_can_get_data_from_mailbox() Receive data from receive mailboxes=

> + */
> +s16 pru_can_get_data_from_mailbox(struct device *dev,
> +			can_emu_app_hndl *pstremuapphndl);
> +
> +/*
> + * pru_can_rx_id_map() Receive mailboxes ID Mapping of PRU0
> + */
> +s16 pru_can_rx_id_map(struct device *dev,
> +			u32 u32nodeid, can_mailbox_number ecanmailboxno);
> +
> +/*
> + *pru_can_get_intr_status() Get interrupts status register value
> + */
> +s16 pru_can_get_intr_status(struct device *dev,
> +			can_emu_app_hndl *pstremuapphndl);
> +
> +
> +/*
> + * pru_can_get_global_status() Get the globalstatus register value
> + */
> +s16 pru_can_get_global_status(struct device *dev,
> +			can_emu_app_hndl *pstremuapphndl);
> +
> +/*
> + * pru_can_get_mailbox_status() Get mailbox status reg value
> + */
> +s16 pru_can_get_mailbox_status(struct device *dev,
> +			can_emu_app_hndl *pstremuapphndl);
> +
> +/*
> + * pru_can_configuration_mode_set() Sets timing val for data transfer
> + */
> +s16 pru_can_config_mode_set(struct device *dev,
> +			bool bconfig_modeflag);
> +
> +/*
> + * pru_can_emu_init() Initializes Can Emulation Parameters
> + */
> +s16 pru_can_emu_init(struct device *dev,
> +			u32 u32pruclock);
> +
> +/*
> + * pru_can_emu_open() Opens can emu for application to use
> + */
> +s16 pru_can_emu_open(struct device *dev,
> +			can_emu_app_hndl *pstremuapphndl);
> +
> +/*
> + * pru_can_emu_close() Closes can emu for applications to use
> + */
> +s16 pru_can_emu_close(struct device *dev,
> +			can_emu_app_hndl *pstremuapphndl);
> +
> +/*
> + * pru_can_emu_exit() Diables all the PRUs
> + */
> +s16 pru_can_emu_exit(struct device *dev);
> +
> +s16 pru_can_tx_mode_set(struct device *dev, bool btransfer_flag,
> +			 can_transfer_direction ecan_trx);
> +
> +s16 pru_can_emu_sreset(struct device *dev);
> +
> +s16 pru_can_tx(struct device *dev,
> +			u8 u8mailboxnumber, u8 u8prunumber);
> +
> +s16 pru_can_start_abort_tx(struct device *dev,
> +			bool btxabort_flag);
> +
> +s16 pru_can_mask_ints(struct device *dev, u32 int_mask);
> +
> +s32 pru_can_get_error_cnt(struct device *dev, u8 u8prunumber);
> +
> +s32 pru_can_get_intc_status(struct device *dev);
> +#endif

regards, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig32880EE203080395FDD35A00
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk1VqyAACgkQjTAFq1RaXHOeWwCZASCYFhYJ4427XMC6MOTPSP5b
R6MAn0JKWGDad9ERn/4wPtCWqs5Okj4c
=Gx0M
-----END PGP SIGNATURE-----

--------------enig32880EE203080395FDD35A00--

--===============4015857869512164788==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============4015857869512164788==--

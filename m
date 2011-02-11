From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH v2 09/13] can: pruss CAN driver.
Date: Fri, 11 Feb 2011 21:33:51 +0100
Message-ID: <4D559D2F.3060205@grandegger.com>
References: <1297435892-28278-1-git-send-email-subhasish@mistralsolutions.com>
	<1297435892-28278-10-git-send-email-subhasish@mistralsolutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	CAN NETWORK DRIVERS <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, nsekhar-l0cyMroinI0@public.gmane.org,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	CAN NETWORK DRIVERS <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	m-watkins-l0cyMroinI0@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
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

Hello,

thanks for your contribution.

First some general comments:

- Please send a separate patch for the Socket-CAN driver.
  Or are there good reasons why we should look at the other 12 patches?

- Please run checkpatch.pl and fix the reported warnings. There are
  many.

- You are using casts extensively. Please get rid of them.

- Decoding the variable type into the name is *deprecated* in Linux.

- Also very long names are *deprecated* in Linux.

- Don't use typedef's.

Some more comments inline...

On 02/11/2011 03:51 PM, Subhasish Ghosh wrote:
> This patch adds support for the CAN device emulated on PRUSS.
> 
> Signed-off-by: Subhasish Ghosh <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
> ---
>  drivers/net/can/Kconfig                     |    1 +
>  drivers/net/can/Makefile                    |    1 +
>  drivers/net/can/da8xx_pruss/Kconfig         |   73 ++
>  drivers/net/can/da8xx_pruss/Makefile        |    7 +
>  drivers/net/can/da8xx_pruss/pruss_can.c     |  758 +++++++++++++++++
>  drivers/net/can/da8xx_pruss/pruss_can_api.c | 1227 +++++++++++++++++++++++++++
>  drivers/net/can/da8xx_pruss/pruss_can_api.h |  290 +++++++
>  7 files changed, 2357 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/da8xx_pruss/Kconfig
>  create mode 100644 drivers/net/can/da8xx_pruss/Makefile
>  create mode 100644 drivers/net/can/da8xx_pruss/pruss_can.c
>  create mode 100644 drivers/net/can/da8xx_pruss/pruss_can_api.c
>  create mode 100644 drivers/net/can/da8xx_pruss/pruss_can_api.h

Why not s/da8xx_pruss/pruss_can/ ?

> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index d5a9db6..ae8f0f9 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -112,6 +112,7 @@ config PCH_CAN
>  	  This driver can access CAN bus.
>  
>  source "drivers/net/can/mscan/Kconfig"
> +source "drivers/net/can/da8xx_pruss/Kconfig"
>  
>  source "drivers/net/can/sja1000/Kconfig"
>  
> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> index 07ca159..849cdbf 100644
> --- a/drivers/net/can/Makefile
> +++ b/drivers/net/can/Makefile
> @@ -14,6 +14,7 @@ obj-$(CONFIG_CAN_SJA1000)	+= sja1000/
>  obj-$(CONFIG_CAN_MSCAN)		+= mscan/
>  obj-$(CONFIG_CAN_AT91)		+= at91_can.o
>  obj-$(CONFIG_CAN_TI_HECC)	+= ti_hecc.o
> +obj-$(CONFIG_CAN_TI_DA8XX_PRU)	+= da8xx_pruss/

Please use a common name/prefix, e.g. pruss_can.

>  obj-$(CONFIG_CAN_MCP251X)	+= mcp251x.o
>  obj-$(CONFIG_CAN_BFIN)		+= bfin_can.o
>  obj-$(CONFIG_CAN_JANZ_ICAN3)	+= janz-ican3.o
> diff --git a/drivers/net/can/da8xx_pruss/Kconfig b/drivers/net/can/da8xx_pruss/Kconfig
> new file mode 100644
> index 0000000..8b68f68
> --- /dev/null
> +++ b/drivers/net/can/da8xx_pruss/Kconfig
> @@ -0,0 +1,73 @@
> +#
> +# CAN Lite Kernel Configuration
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

Well, defining CAN identifiers via Kconfig entries is really wired.
Could you please explain why that's necessary and what's so special with
that CAN hardware. We need a better solution if the CAN controller
cannot handle and CAN id.

> diff --git a/drivers/net/can/da8xx_pruss/Makefile b/drivers/net/can/da8xx_pruss/Makefile
> new file mode 100644
> index 0000000..48f3055
> --- /dev/null
> +++ b/drivers/net/can/da8xx_pruss/Makefile
> @@ -0,0 +1,7 @@
> +#
> +# Makefile for CAN Lite emulation
> +#
> +can_emu-objs :=   pruss_can.o \
> +                  pruss_can_api.o
> +
> +obj-$(CONFIG_CAN_TI_DA8XX_PRU)    += can_emu.o

Again another name.

> diff --git a/drivers/net/can/da8xx_pruss/pruss_can.c b/drivers/net/can/da8xx_pruss/pruss_can.c
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
> + *  Copyright (C) 2009 Texas Instruments Incorporated - http://www.ti.com/
> + *
> + *  This program is free software; you can redistribute it and/or
> + *  modify it under the terms of the GNU General Public License as
> + *  published by the Free Software Foundation version 2.
> + *
> + *  This program is distributed as is WITHOUT ANY WARRANTY of any
> + *  kind, whether express or implied; without even the implied warranty
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
> +
> +#define DRV_NAME "da8xx_pruss_can"
> +#define DRV_DESC "TI PRU CAN Controller Driver v0.1"
> +#define PRU_CAN_START		1
> +#define PRU_CAN_STOP		0
> +#define MB_MIN			0
> +#define MB_MAX			7
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
> +#define MAX_INIT_RETRIES		20
> +#define L138_PRU_ARM_FREQ		312000
> +#define DFLT_PRU_FREQ			156000000
> +#define DFLT_PRU_BITRATE		125000
> +
> +#define CONFIG_DA8XX_PRU_CANID_MBX0	0x123
> +#define CONFIG_DA8XX_PRU_CANID_MBX1	0x123
> +#define CONFIG_DA8XX_PRU_CANID_MBX2	0x123
> +#define CONFIG_DA8XX_PRU_CANID_MBX3	0x123
> +#define CONFIG_DA8XX_PRU_CANID_MBX4	0x123
> +#define CONFIG_DA8XX_PRU_CANID_MBX5	0x123
> +#define CONFIG_DA8XX_PRU_CANID_MBX6	0x123
> +#define CONFIG_DA8XX_PRU_CANID_MBX7	0x123
> +
> +#ifdef __CAN_DEBUG
> +#define __can_debug(fmt, args...) printk(KERN_DEBUG "can_debug: " fmt, ## args)
> +#else
> +#define __can_debug(fmt, args...)
> +#endif
> +#define __can_err(fmt, args...) printk(KERN_ERR "can_err: " fmt, ## args)

Please use dev_dbg, dev_err, ... or netif_dbg, netdev_err, ... instead.

> +/*
> + * omapl_pru can private data
> + */
> +struct omapl_pru_can_priv {
> +	struct can_priv can;
> +	struct workqueue_struct *pru_can_wQ;
> +	struct work_struct rx_work;
> +	struct net_device *ndev;
> +	struct device *dev; /* pdev->dev */
> +	struct clk *clk_timer;
> +	u32 timer_freq;
> +	can_emu_app_hndl can_tx_hndl;
> +	can_emu_app_hndl can_rx_hndl;
> +	const struct firmware *fw_rx;
> +	const struct firmware *fw_tx;
> +	spinlock_t mbox_lock;
> +	u32 trx_irq;
> +	u32 tx_head;
> +	u32 tx_tail;
> +	u32 tx_next;
> +	u32 rx_next;
> +};
> +
> +static int omapl_pru_can_get_state(const struct net_device *ndev,
> +				   enum can_state *state)
> +{
> +	struct omapl_pru_can_priv *priv = netdev_priv(ndev);
> +	*state = priv->can.state;
> +	return 0;
> +}


There is no need for that function as you handle state changes in the
interrupt context.

> +static int omapl_pru_can_set_bittiming(struct net_device *ndev)
> +{
> +	struct omapl_pru_can_priv *priv = netdev_priv(ndev);
> +	struct can_bittiming *bt = &priv->can.bittiming;
> +	long bit_error = 0;
> +
> +	if (priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES) {
> +		dev_warn(priv->dev, "WARN: Triple"
> +			 "sampling not set due to h/w limitations");
> +	}

No need for this test as you have not set the CAN_CTRLMODE_3_SAMPLES bit
in priv.ctrlmode_supported.

> +	if (pru_can_calc_timing(priv->dev, priv->can.clock.freq,
> +				bt->bitrate) != 0)
> +		return -EINVAL;
> +	bit_error =
> +	    (((priv->timer_freq / (priv->timer_freq / bt->bitrate)) -
> +	      bt->bitrate) * 1000) / bt->bitrate;
> +	if (bit_error) {
> +		bit_error =
> +		    (((priv->timer_freq / (priv->timer_freq / bt->bitrate)) -
> +		      bt->bitrate) * 1000000) / bt->bitrate;
> +		printk(KERN_INFO "\nBitrate error %ld.%ld%%\n",
> +			bit_error / 10000, bit_error % 1000);
> +	} else
> +		printk(KERN_INFO "\nBitrate error 0.0%%\n");
> +
> +	return 0;

Please use the pre-calculated bit-timing parameters. Have a look to the
SJA1000 driver for further information:

http://lxr.linux.no/#linux+v2.6.37/drivers/net/can/sja1000/sja1000.c#L202

In general, please use the bit-timing interface of Socket-CAN and drop
you own.

> +}
> +
> +static void omapl_pru_can_stop(struct net_device *ndev)
> +{
> +	struct omapl_pru_can_priv *priv = netdev_priv(ndev);
> +	u16 int_mask = 0;
> +
> +	pru_can_mask_ints(priv->dev, int_mask);	/* mask all ints */
> +	pru_can_start_abort_tx(priv->dev, PRU_CAN_STOP);
> +	priv->can.state = CAN_STATE_STOPPED;
> +}
> +
> +/*
> + * This is to just set the can state to ERROR_ACTIVE
> + *	ip link set canX up type can bitrate 125000
> + */
> +static void omapl_pru_can_start(struct net_device *ndev)
> +{
> +	struct omapl_pru_can_priv *priv = netdev_priv(ndev);
> +	u16 int_mask = 0xFFFF;
> +
> +	if (priv->can.state != CAN_STATE_STOPPED)
> +		omapl_pru_can_stop(ndev);
> +
> +	pru_can_mask_ints(priv->dev, int_mask);	/* unmask all ints */
> +
> +	pru_can_get_global_status(priv->dev, &priv->can_tx_hndl);
> +	pru_can_get_global_status(priv->dev, &priv->can_rx_hndl);
> +
> +	if (PRU_CAN_GSR_BIT_EPM & priv->can_tx_hndl.u32globalstatus)

Decoding the variable type into the name is deprecated in Linux.

> +		priv->can.state = CAN_STATE_ERROR_PASSIVE;
> +	else if (PRU_CAN_GSR_BIT_BFM & priv->can_tx_hndl.u32globalstatus)
> +		priv->can.state = CAN_STATE_BUS_OFF;
> +	else
> +		priv->can.state = CAN_STATE_ERROR_ACTIVE;
> +}
> +
> +static int omapl_pru_can_set_mode(struct net_device *ndev, enum can_mode mode)
> +{
> +	int ret = 0;
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

This case is not supported.

> +	default:
> +		ret = -EOPNOTSUPP;
> +		break;
> +	}
> +	return ret;
> +}
> +
> +static netdev_tx_t omapl_pru_can_start_xmit(struct sk_buff *skb,
> +					    struct net_device *ndev)
> +{
> +	struct omapl_pru_can_priv *priv = netdev_priv(ndev);
> +	struct can_frame *cf = (struct can_frame *)skb->data;
> +	int count;
> +	u8 *data = cf->data;
> +	u8 dlc = cf->can_dlc;
> +	u8 *ptr8data = NULL;
> +
> +	netif_stop_queue(ndev);
> +	if (cf->can_id & CAN_EFF_FLAG)	/* Extended frame format */
> +		*((u32 *) &priv->can_tx_hndl.strcanmailbox) =
> +		    (cf->can_id & CAN_EFF_MASK) | PRU_CANMID_IDE;



> +	else			/* Standard frame format */
> +		*((u32 *) &priv->can_tx_hndl.strcanmailbox) =
> +		    (cf->can_id & CAN_SFF_MASK) << 18;

You use many of such wired expressions. strcanmailbox is a struct

  typedef struct {
	u16 u16extendedidentifier;
	u16 u16baseidentifier;
        ...
  } can_mail_box_structure;

and you obviously set the fist two fields. In contrast, the member
u16extendedidentifier is never directly used. Puh, that's magic. Please
make your code more transparent and readable.

> +	if (cf->can_id & CAN_RTR_FLAG)	/* Remote transmission request */
> +		*((u32 *) &priv->can_tx_hndl.strcanmailbox) |= CAN_RTR_FLAG;
> +
> +	ptr8data = &priv->can_tx_hndl.strcanmailbox.u8data7 + (dlc - 1);
> +	for (count = 0; count < (u8) dlc; count++) {
> +		*ptr8data-- = *data++;
> +	}
> +	*((u32 *) &priv->can_tx_hndl.strcanmailbox.u16datalength) = (u32) dlc;

...

> +irqreturn_t omapl_rx_can_intr(int irq, void *dev_id)
> +{
> +
> +	struct net_device *ndev = dev_id;
> +	struct omapl_pru_can_priv *priv = netdev_priv(ndev);
> +	u32 intc_status = 0;
> +
> +	intc_status = pru_can_get_intc_status(priv->dev);
> +	if (intc_status & 4)
> +		return omapl_tx_can_intr(irq, dev_id);
> +	if (intc_status & 2) {
> +		if (!work_pending(&priv->rx_work))
> +			queue_work(priv->pru_can_wQ, &priv->rx_work);

You handle RX in a work queue!? Please use NAPI instead.

> +	}
> +
> +	return IRQ_HANDLED;
> +}
> +
> +static int omapl_pru_can_open(struct net_device *ndev)
> +{
> +	struct omapl_pru_can_priv *priv = netdev_priv(ndev);
> +	int err;
> +
> +	/* register interrupt handler */
> +	err = request_irq(priv->trx_irq, &omapl_rx_can_intr, IRQF_SHARED,
> +			  "pru_can_irq", ndev);
> +	if (err) {
> +		dev_err(priv->dev, "error requesting rx interrupt\n");
> +		goto exit_trx_irq;
> +	}
> +	/* common open */
> +	err = open_candev(ndev);
> +	if (err) {
> +		dev_err(priv->dev, "open_candev() failed %d\n", err);
> +		goto exit_open;
> +	}
> +
> +	pru_can_emu_init(priv->dev, priv->can.clock.freq);
> +	priv->tx_tail = MB_MIN;
> +	priv->tx_head = MB_MAX;
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
> +	struct omapl_pru_can_priv *priv = netdev_priv(ndev);
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
> +static const struct net_device_ops omapl_pru_can_netdev_ops = {
> +	.ndo_open		= omapl_pru_can_open,
> +	.ndo_stop		= omapl_pru_can_close,
> +	.ndo_start_xmit		= omapl_pru_can_start_xmit,
> +};
> +
> +static int __devinit omapl_pru_can_probe(struct platform_device *pdev)
> +{
> +	struct net_device *ndev = NULL;
> +	const struct da8xx_pru_can_data *pdata;
> +	struct omapl_pru_can_priv *priv = NULL;
> +	struct device *dev = &pdev->dev;
> +	u32 err;
> +
> +	pdata = dev->platform_data;
> +	if (!pdata) {
> +		dev_err(&pdev->dev, "platform data not found\n");
> +		return -EINVAL;
> +	}
> +
> +	ndev = alloc_candev(sizeof(struct omapl_pru_can_priv), MB_MAX + 1);
> +	if (!ndev) {
> +		dev_err(&pdev->dev, "alloc_candev failed\n");
> +		err = -ENOMEM;
> +		goto probe_exit;
> +	}
> +	priv = netdev_priv(ndev);
> +
> +	priv->trx_irq = platform_get_irq(to_platform_device(dev->parent), 0);
> +	if (!priv->trx_irq) {
> +		dev_err(&pdev->dev, "unable to get pru interrupt resources!\n");
> +		err = -ENODEV;
> +		goto probe_exit;
> +	}
> +
> +	priv->ndev = ndev;
> +	priv->dev = dev; /* priv->dev = pdev->dev */
> +
> +	priv->can.bittiming_const = NULL;
> +	priv->can.do_set_bittiming = omapl_pru_can_set_bittiming;
> +	priv->can.do_set_mode = omapl_pru_can_set_mode;
> +	priv->can.do_get_state = omapl_pru_can_get_state;
> +	priv->can_tx_hndl.u8prunumber = CAN_TX_PRU_1;
> +	priv->can_rx_hndl.u8prunumber = CAN_RX_PRU_0;
> +
> +	/* we support local echo, no arp */
> +	ndev->flags |= (IFF_ECHO | IFF_NOARP);
> +
> +	/* pdev->dev->device_private->driver_data = ndev */
> +	platform_set_drvdata(pdev, ndev);
> +	SET_NETDEV_DEV(ndev, &pdev->dev);
> +	ndev->netdev_ops = &omapl_pru_can_netdev_ops;
> +
> +	priv->can.clock.freq = pruss_get_clk_freq(priv->dev);
> +
> +	priv->clk_timer = clk_get(&pdev->dev, "pll1_sysclk2");
> +	if (IS_ERR(priv->clk_timer)) {
> +		dev_err(&pdev->dev, "no timer clock available\n");
> +		err = PTR_ERR(priv->clk_timer);
> +		priv->clk_timer = NULL;
> +		goto probe_exit_candev;
> +	}
> +	priv->timer_freq = clk_get_rate(priv->clk_timer);
> +
> +	err = register_candev(ndev);
> +	if (err) {
> +		dev_err(&pdev->dev, "register_candev() failed\n");
> +		err = -ENODEV;
> +		goto probe_exit_clk;
> +	}
> +
> +	err = request_firmware(&priv->fw_tx, "PRU_CAN_Emulation_Tx.bin",
> +			&pdev->dev);
> +	if (err) {
> +		dev_err(&pdev->dev, "can't load firmware\n");
> +		err = -ENODEV;
> +		goto probe_exit_clk;
> +	}
> +
> +	dev_info(&pdev->dev, "fw_tx size %d. downloading...\n",
> +		 priv->fw_tx->size);
> +
> +	err = request_firmware(&priv->fw_rx, "PRU_CAN_Emulation_Rx.bin",
> +			&pdev->dev);
> +	if (err) {
> +		dev_err(&pdev->dev, "can't load firmware\n");
> +		err = -ENODEV;
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
> +	err = pruss_load(priv->dev, CAN_RX_PRU_0,
> +		(u32 *)priv->fw_rx->data, (priv->fw_rx->size / 4));
> +	if (err) {
> +		dev_err(&pdev->dev, "firmware download error\n");
> +		err = -ENODEV;
> +		goto probe_release_fw_1;
> +	}
> +	err = pruss_load(priv->dev, CAN_TX_PRU_1,
> +		(u32 *)priv->fw_tx->data, (priv->fw_tx->size / 4));
> +	if (err) {
> +		dev_err(&pdev->dev, "firmware download error\n");
> +		err = -ENODEV;
> +		goto probe_release_fw_1;
> +	}
> +
> +	if (pru_can_calc_timing(priv->dev, DFLT_PRU_FREQ,
> +				DFLT_PRU_BITRATE) != 0)
> +		return -EINVAL;

Please don't define a default bit-rate. It's error prune.

> +
> +	pruss_run(priv->dev, CAN_RX_PRU_0);
> +	pruss_run(priv->dev, CAN_TX_PRU_1);
> +
> +	/*Create The Work Queue */
> +	priv->pru_can_wQ = create_freezeable_workqueue("omapl_pru_wQ");
> +	if (priv->pru_can_wQ == NULL) {
> +		dev_err(&pdev->dev, "failed to create work queue\n");
> +		err = -ENODEV;
> +		goto probe_release_fw_1;
> +	}
> +
> +	INIT_WORK(&priv->rx_work, omapl_pru_can_rx_wQ);
> +	dev_info(&pdev->dev,
> +		 "%s device registered (trx_irq = %d,  clk = %d)\n",
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
> +	if (NULL != ndev)
> +		free_candev(ndev);
> +probe_exit:
> +	return err;
> +}
> +
> +static int __devexit omapl_pru_can_remove(struct platform_device *pdev)
> +{
> +	struct net_device *ndev = platform_get_drvdata(pdev);
> +	struct omapl_pru_can_priv *priv = netdev_priv(ndev);
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
> +static struct platform_driver omapl_pru_can_driver = {
> +	.probe		= omapl_pru_can_probe,
> +	.remove		= __devexit_p(omapl_pru_can_remove),
> +	.suspend	= omapl_pru_can_suspend,
> +	.resume		= omapl_pru_can_resume,
> +	.driver		= {
> +		.name	= DRV_NAME,
> +		.owner	= THIS_MODULE,
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
> diff --git a/drivers/net/can/da8xx_pruss/pruss_can_api.c b/drivers/net/can/da8xx_pruss/pruss_can_api.c
> new file mode 100644
> index 0000000..2f7438a
> --- /dev/null
> +++ b/drivers/net/can/da8xx_pruss/pruss_can_api.c
> @@ -0,0 +1,1227 @@
> +/*
> + * Copyright (C) 2010 Texas Instruments Incorporated
> + * Author: Wilfred Felix
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License as  published by the
> + * Free Software Foundation version 2.
> + *
> + * This program is distributed "as is" WITHOUT ANY WARRANTY of any kind,
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
> +	u32offset = (PRU_CAN_RX_CLOCK_BRP_REGISTER);
> +	pruss_writel(dev, u32offset, (u32 *) &u16bitrateprescaler, 1);
> +
> +	u32offset = (PRU_CAN_TX_CLOCK_BRP_REGISTER);
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
> +	u32serregister = 0;
> +
> +	if (pstrbittiming == NULL) {
> +		return -1;
> +	}
> +
> +	if ((pstrbittiming->u8syncjumpwidth > PRU_CAN_MAX_SJW) ||
> +	    (pstrbittiming->u8phseg1 > PRU_CAN_MAX_PHSEG1) ||
> +	    (pstrbittiming->u8phseg2 > PRU_CAN_MAX_PHSEG2)) {
> +		return -1;
> +	}
> +
> +	u32serregister = u32serregister |
> +			((pstrbittiming->u8syncjumpwidth << 7) |
> +			(pstrbittiming->u8phseg1 << 3) |
> +			(pstrbittiming->u8phseg2));
> +
> +	u32offset = (PRU_CAN_TX_TIMING_REGISTER);
> +	pruss_writel(dev, u32offset, (u32 *) &u32serregister, 1);
> +
> +	u32offset = (PRU_CAN_RX_TIMING_REGISTER);
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
> +s16 pru_can_calc_timing(struct device *dev, u32 pru_freq, u32 bit_rate)
> +{
> +	u16 u16phaseseg1;
> +	u16 u16phaseseg2;
> +	u32 u32offset;
> +	u32 u32timing_value;
> +	u32 u32setup_value;
> +	u32timing_value = TIMER_CLK_FREQ / bit_rate;
> +	u32offset = (PRU_CAN_TIMING_VAL_TX);
> +	pruss_writel(dev, u32offset, (u32 *) &u32timing_value, 4);
> +	pruss_readl(dev, u32offset, (u32 *) &u32timing_value, 4);
> +	u32setup_value =
> +	    (GPIO_SETUP_DELAY * (pru_freq / 1000000) / 1000) /
> +	    DELAY_LOOP_LENGTH;
> +	u32offset = (PRU_CAN_TIMING_VAL_TX_SJW);
> +	pruss_writel(dev, u32offset, (u32 *) &u32setup_value, 4);
> +	u16phaseseg1 = (u16) (u32timing_value / 2);
> +	u16phaseseg2 = u32timing_value - u16phaseseg1;
> +	u16phaseseg1 -= TIMER_SETUP_DELAY;
> +	u16phaseseg2 -= TIMER_SETUP_DELAY;
> +	u32setup_value = (u16phaseseg1 << 16) | u16phaseseg2;
> +	u32offset = (PRU_CAN_TIMING_VAL_RX);
> +	pruss_writel(dev, u32offset, (u32 *) &u32setup_value, 4);
> +	u32offset = (PRU_CAN_TIMING_VAL_RX + 4);
> +	pruss_writel(dev, u32offset, (u32 *) &u32timing_value, 4);
> +
> +	return 0;
> +}

Why can't you use the common Socket-CAN bit-timing infrastructure.

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
> +	if (pstremuapphndl == NULL) {
> +		return -1;
> +	}
> +
> +	switch ((u8) pstremuapphndl->ecanmailboxnumber) {
> +	case 0:
> +		u32offset = (PRU_CAN_TX_MAILBOX0);
> +		break;
> +	case 1:
> +		u32offset = (PRU_CAN_TX_MAILBOX1);
> +		break;
> +	case 2:
> +		u32offset = (PRU_CAN_TX_MAILBOX2);
> +		break;
> +	case 3:
> +		u32offset = (PRU_CAN_TX_MAILBOX3);
> +		break;
> +	case 4:
> +		u32offset = (PRU_CAN_TX_MAILBOX4);
> +		break;
> +	case 5:
> +		u32offset = (PRU_CAN_TX_MAILBOX5);
> +		break;
> +	case 6:
> +		u32offset = (PRU_CAN_TX_MAILBOX6);
> +		break;
> +	case 7:
> +		u32offset = (PRU_CAN_TX_MAILBOX7);
> +		break;
> +	default:
> +		return -1;
> +	}

There are more efficient ways to implemet that, e.g. by using an array.


> +	s16subrtnretval = pruss_writel(dev, u32offset,
> +		(u32 *) &(pstremuapphndl->strcanmailbox), 4);
> +	if (s16subrtnretval == -1) {
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
> +	if (pstremuapphndl == NULL) {
> +		return -1;
> +	}
> +
> +	switch ((u8) pstremuapphndl->ecanmailboxnumber) {
> +	case 0:
> +		u32offset = (PRU_CAN_RX_MAILBOX0);
> +		break;
> +	case 1:
> +		u32offset = (PRU_CAN_RX_MAILBOX1);
> +		break;
> +	case 2:
> +		u32offset = (PRU_CAN_RX_MAILBOX2);
> +		break;
> +	case 3:
> +		u32offset = (PRU_CAN_RX_MAILBOX3);
> +		break;
> +	case 4:
> +		u32offset = (PRU_CAN_RX_MAILBOX4);
> +		break;
> +	case 5:
> +		u32offset = (PRU_CAN_RX_MAILBOX5);
> +		break;
> +	case 6:
> +		u32offset = (PRU_CAN_RX_MAILBOX6);
> +		break;
> +	case 7:
> +		u32offset = (PRU_CAN_RX_MAILBOX7);
> +		break;
> +	case 8:
> +		u32offset = (PRU_CAN_RX_MAILBOX8);
> +		break;
> +	default:
> +		return -1;
> +	}

Ditto.

> +	s16subrtnretval =
> +	    pruss_readl(dev, u32offset,
> +		  (u32 *) &(pstremuapphndl->strcanmailbox),
> +				  4);
> +	if (s16subrtnretval == -1) {
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
> +	s16 s16subrtnretval = -1;
> +
> +	if (pstremuapphndl == NULL) {
> +		return -1;
> +	}
> +
> +	if (pstremuapphndl->u8prunumber == DA8XX_PRUCORE_1) {
> +		u32offset = (PRU_CAN_TX_INTERRUPT_STATUS_REGISTER);
> +	} else if (pstremuapphndl->u8prunumber == DA8XX_PRUCORE_0) {
> +		u32offset = (PRU_CAN_RX_INTERRUPT_STATUS_REGISTER);
> +	} else {
> +		return -1;
> +	}
> +
> +	s16subrtnretval = pruss_readl(dev, u32offset,
> +		(u32 *) &pstremuapphndl->u32interruptstatus, 1);
> +	if (s16subrtnretval == -1) {
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
> +	int s16subrtnretval = -1;
> +
> +	if (pstremuapphndl == NULL) {
> +		return -1;
> +	}
> +
> +	if (pstremuapphndl->u8prunumber == DA8XX_PRUCORE_1) {
> +		u32offset = (PRU_CAN_TX_GLOBAL_STATUS_REGISTER);
> +	} else if (pstremuapphndl->u8prunumber == DA8XX_PRUCORE_0) {
> +		u32offset = (PRU_CAN_RX_GLOBAL_STATUS_REGISTER);
> +	} else {
> +		return -1;
> +	}
> +
> +	s16subrtnretval = pruss_readl(dev, u32offset,
> +		(u32 *) &pstremuapphndl->u32globalstatus, 1);
> +	if (s16subrtnretval == -1) {
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
> +	s16 s16subrtnretval = -1;
> +
> +	if (pstremuapphndl == NULL) {
> +		return -1;
> +	}
> +
> +	if (pstremuapphndl->u8prunumber == DA8XX_PRUCORE_1) {
> +		switch (pstremuapphndl->ecanmailboxnumber) {
> +		case 0:
> +			u32offset = (PRU_CAN_TX_MAILBOX0_STATUS_REGISTER);
> +			break;
> +		case 1:
> +			u32offset = (PRU_CAN_TX_MAILBOX1_STATUS_REGISTER);
> +			break;
> +		case 2:
> +			u32offset = (PRU_CAN_TX_MAILBOX2_STATUS_REGISTER);
> +			break;
> +		case 3:
> +			u32offset = (PRU_CAN_TX_MAILBOX3_STATUS_REGISTER);
> +			break;
> +		case 4:
> +			u32offset = (PRU_CAN_TX_MAILBOX4_STATUS_REGISTER);
> +			break;
> +		case 5:
> +			u32offset = (PRU_CAN_TX_MAILBOX5_STATUS_REGISTER);
> +			break;
> +		case 6:
> +			u32offset = (PRU_CAN_TX_MAILBOX6_STATUS_REGISTER);
> +			break;
> +		case 7:
> +			u32offset = (PRU_CAN_TX_MAILBOX7_STATUS_REGISTER);
> +			break;
> +		default:
> +			return -1;
> +		}
> +	}
> +
> +	else if (pstremuapphndl->u8prunumber == DA8XX_PRUCORE_0) {
> +		switch (pstremuapphndl->ecanmailboxnumber) {
> +		case 0:
> +			u32offset = (PRU_CAN_RX_MAILBOX0_STATUS_REGISTER);
> +			break;
> +		case 1:
> +			u32offset = (PRU_CAN_RX_MAILBOX1_STATUS_REGISTER);
> +			break;
> +		case 2:
> +			u32offset = (PRU_CAN_RX_MAILBOX2_STATUS_REGISTER);
> +			break;
> +		case 3:
> +			u32offset = (PRU_CAN_RX_MAILBOX3_STATUS_REGISTER);
> +			break;
> +		case 4:
> +			u32offset = (PRU_CAN_RX_MAILBOX4_STATUS_REGISTER);
> +			break;
> +		case 5:
> +			u32offset = (PRU_CAN_RX_MAILBOX5_STATUS_REGISTER);
> +			break;
> +		case 6:
> +			u32offset = (PRU_CAN_RX_MAILBOX6_STATUS_REGISTER);
> +			break;
> +		case 7:
> +			u32offset = (PRU_CAN_RX_MAILBOX7_STATUS_REGISTER);
> +			break;
> +		case 8:
> +			u32offset = (PRU_CAN_RX_MAILBOX8_STATUS_REGISTER);
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
> +	s16subrtnretval = pruss_readl(dev, u32offset,
> +		(u32 *) &pstremuapphndl->u32mailboxstatus, 1);
> +	if (s16subrtnretval == -1) {
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
> +	if (ecan_trx == ecantransmit) {
> +		u32offset = (PRU_CAN_RX_GLOBAL_STATUS_REGISTER);
> +		pruss_readl(dev, u32offset, &u32value, 1);
> +		if (btransfer_flag == true) {
> +			u32value &= 0x1F;
> +			u32value |= 0x80;
> +		} else {
> +			u32value &= 0x7F;
> +		}
> +		pruss_writel(dev, u32offset, &u32value, 1);
> +		u32offset = (PRU_CAN_TX_GLOBAL_STATUS_REGISTER);
> +		pruss_writel(dev, u32offset, &u32value, 1);
> +	} else if (ecan_trx == ecanreceive) {
> +		u32offset = (PRU_CAN_RX_GLOBAL_STATUS_REGISTER);
> +		pruss_readl(dev, u32offset, &u32value, 1);
> +		if (btransfer_flag == true) {
> +			u32value &= 0x1F;
> +			u32value |= 0x40;
> +		} else {
> +			u32value &= 0xBF;
> +		}
> +		pruss_writel(dev, u32offset, &u32value, 1);
> +		u32offset = (PRU_CAN_TX_GLOBAL_STATUS_REGISTER);
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
> +	if (bconfigmodeflag == 1) {
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
> +	s16 s16subrtnretval = -1;
> +	u8 u8loop;
> +
> +	for (u8loop = 0; u8loop < (u8) ecanmaxinst; u8loop++) {
> +		gstr_can_inst[u8loop].bcaninststate = (bool) 0;
> +		gstr_can_inst[u8loop].ecantransferdirection =
> +		    (can_transfer_direction) 0;
> +		gstr_can_inst[u8loop].u32apphandlerptr = 0;
> +	}
> +
> +	u32offset = (PRU_CAN_TX_GLOBAL_CONTROL_REGISTER & 0xFFFF);
> +	u32value = 0x00000000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_TX_GLOBAL_STATUS_REGISTER & 0xFFFF);
> +	u32value = 0x00000040;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +	u32offset = (PRU_CAN_RX_GLOBAL_STATUS_REGISTER & 0xFFFF);
> +	u32value = 0x00000040;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_TX_INTERRUPT_MASK_REGISTER & 0xFFFF);
> +	u32value = 0x00004000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_TX_INTERRUPT_STATUS_REGISTER & 0xFFFF);
> +	u32value = 0x00000000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_TX_MAILBOX0_STATUS_REGISTER & 0xFFFF);
> +	u32value = 0x00000001;
> +	s16subrtnretval =
> +	    pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_TX_MAILBOX1_STATUS_REGISTER & 0xFFFF);
> +	u32value = 0x00000001;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_TX_MAILBOX2_STATUS_REGISTER & 0xFFFF);
> +	u32value = 0x00000001;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_TX_MAILBOX3_STATUS_REGISTER & 0xFFFF);
> +	u32value = 0x00000001;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_TX_MAILBOX4_STATUS_REGISTER & 0xFFFF);
> +	u32value = 0x00000001;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_TX_MAILBOX5_STATUS_REGISTER & 0xFFFF);
> +	u32value = 0x00000001;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_TX_MAILBOX6_STATUS_REGISTER & 0xFFFF);
> +	u32value = 0x00000001;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_TX_MAILBOX7_STATUS_REGISTER & 0xFFFF);
> +	u32value = 0x00000001;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_TX_ERROR_COUNTER_REGISTER & 0xFFFF);
> +	u32value = 0x00000000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_TX_TIMING_REGISTER & 0xFFFF);
> +	u32value = 0x00000000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_TX_CLOCK_BRP_REGISTER & 0xFFFF);
> +	u32value = 0x00000000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_TX_ERROR_COUNTER_REGISTER & 0xFFFF);
> +	u32value = 0x00000000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRUSS_INTC_POLARITY0 & 0xFFFF);
> +	u32value = 0xFFFFFFFF;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +	u32offset = (PRUSS_INTC_POLARITY1 & 0xFFFF);
> +	u32value = 0xFFFFFFFF;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +	u32offset = (PRUSS_INTC_TYPE0 & 0xFFFF);
> +	u32value = 0x1C000000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +	u32offset = (PRUSS_INTC_TYPE1 & 0xFFFF);
> +	u32value = 0x00000000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRUSS_INTC_HSTINTENIDXCLR & 0xFFFF);
> +	u32value = 0x0;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRUSS_INTC_GLBLEN & 0xFFFF);
> +	u32value = 0x1;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +	/* tx intr map arm->pru */
> +	u32offset = (PRUSS_INTC_HSTINTENIDXSET & 0xFFFF);
> +	u32value = 0x0;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRUSS_INTC_HOSTMAP0 & 0xFFFF);
> +	u32value = 0x03020100;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRUSS_INTC_HOSTMAP1 & 0xFFFF);
> +	u32value = 0x07060504;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRUSS_INTC_HOSTMAP2 & 0xFFFF);
> +	u32value = 0x0000908;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRUSS_INTC_CHANMAP0 & 0xFFFF);
> +	u32value = 0;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRUSS_INTC_CHANMAP8 & 0xFFFF);
> +	u32value = 0x00020200;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRUSS_INTC_STATIDXCLR & 0xFFFF);
> +	u32value = 32;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRUSS_INTC_STATIDXCLR & 0xFFFF);
> +	u32value = 19;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRUSS_INTC_ENIDXSET & 0xFFFF);
> +	u32value = 19;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +	u32offset = (PRUSS_INTC_STATIDXCLR & 0xFFFF);
> +	u32value = 18;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRUSS_INTC_ENIDXSET & 0xFFFF);
> +	u32value = 18;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRUSS_INTC_STATIDXCLR & 0xFFFF);
> +	u32value = 34;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRUSS_INTC_ENIDXSET & 0xFFFF);
> +	u32value = 34;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRUSS_INTC_ENIDXSET & 0xFFFF);
> +	u32value = 32;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRUSS_INTC_HOSTINTEN & 0xFFFF);
> +	u32value = 0x5;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +/* PRU0 - Rx Internal Registers Initializations */
> +
> +	u32offset = (PRU_CAN_RX_GLOBAL_CONTROL_REGISTER & 0xFFFF);
> +	u32value = 0x00000000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_RX_GLOBAL_STATUS_REGISTER & 0xFFFF);
> +	u32value = 0x00000040;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_RX_INTERRUPT_MASK_REGISTER & 0xFFFF);
> +	u32value = 0x00004000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_RX_INTERRUPT_STATUS_REGISTER & 0xFFFF);
> +	u32value = 0x00000000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_RX_MAILBOX0_STATUS_REGISTER & 0xFFFF);
> +	u32value = 0x00000000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_RX_MAILBOX1_STATUS_REGISTER & 0xFFFF);
> +	u32value = 0x0000000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_RX_MAILBOX2_STATUS_REGISTER & 0xFFFF);
> +	u32value = 0x00000000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_RX_MAILBOX3_STATUS_REGISTER & 0xFFFF);
> +	u32value = 0x00000000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_RX_MAILBOX4_STATUS_REGISTER & 0xFFFF);
> +	u32value = 0x00000000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_RX_MAILBOX5_STATUS_REGISTER & 0xFFFF);
> +	u32value = 0x00000000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_RX_MAILBOX6_STATUS_REGISTER & 0xFFFF);
> +	u32value = 0x00000000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_RX_MAILBOX7_STATUS_REGISTER & 0xFFFF);
> +	u32value = 0x00000000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_RX_ERROR_COUNTER_REGISTER & 0xFFFF);
> +	u32value = 0x00000000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_RX_TIMING_REGISTER & 0xFFFF);
> +	u32value = 0x0000000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}
> +
> +	u32offset = (PRU_CAN_RX_CLOCK_BRP_REGISTER & 0xFFFF);
> +	u32value = 0x00000000;
> +	s16subrtnretval = pruss_writel(dev, u32offset, (u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
> +		return -1;
> +	}

Above I realize a lot of duplicated code. Could be handled by an array
more efficiently, I believe.


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
> +s16 pru_can_emu_open(struct device *dev, can_emu_app_hndl *pstremuapphndl)
> +{
> +
> +	if (pstremuapphndl == NULL) {
> +		return -1;
> +	}
> +
> +	if (gstr_can_inst[pstremuapphndl->ecaninstance].bcaninststate == 1) {
> +		return -1;
> +	}
> +
> +	gstr_can_inst[(u8) pstremuapphndl->ecaninstance].
> +					bcaninststate = (bool)1;
> +	gstr_can_inst[(u8) pstremuapphndl->
> +		ecaninstance].ecantransferdirection =
> +		(can_transfer_direction)(u8)pstremuapphndl->ecantransferdirection;
> +	gstr_can_inst[(u8) pstremuapphndl->ecaninstance].
> +		u32apphandlerptr = (u32) pstremuapphndl;
> +
> +	return 0;
> +}
> +
> +
> +/*
> + * brief    pru_can_emu_close()	Closes the can emu for other
> + * applications to use. This API will be called by the Application to Close
> + * the can emu for other applications to use
> + *
> + * param	pstremuapphndl	Pointer to application handler structure
> + *
> + * return   SUCCESS or FAILURE
> + */
> +s16 pru_can_emu_close(struct device *dev, can_emu_app_hndl *pstremuapphndl)
> +{
> +
> +	if (pstremuapphndl == NULL) {
> +		return -1;
> +	}
> +	if (gstr_can_inst[pstremuapphndl->ecaninstance].bcaninststate == 0) {
> +		return -1;
> +	}
> +	if ((u32) pstremuapphndl != gstr_can_inst[(u8) pstremuapphndl->
> +			ecaninstance].u32apphandlerptr){
> +		return -1;
> +	}
> +	gstr_can_inst[(u8) pstremuapphndl->ecaninstance].bcaninststate
> +		= (bool) 0;
> +	gstr_can_inst[(u8) pstremuapphndl->
> +	ecaninstance].ecantransferdirection = (can_transfer_direction) 0;
> +	gstr_can_inst[(u8) pstremuapphndl->ecaninstance].u32apphandlerptr = 0;
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
> +	s16subrtnretval = pruss_disable(dev, CAN_RX_PRU_0);
> +	if (s16subrtnretval == -1)
> +		return -1;
> +	s16subrtnretval = pruss_disable(dev, CAN_TX_PRU_1);
> +	if (s16subrtnretval == -1)
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
> +s16 pru_can_tx(struct device *dev, u8 u8mailboxnumber, u8 u8prunumber)
> +{
> +	u32 u32offset = 0;
> +	u32 u32value = 0;
> +	s16 s16subrtnretval = -1;
> +
> +	if (DA8XX_PRUCORE_1 == u8prunumber) {
> +		switch (u8mailboxnumber) {
> +		case 0:
> +			u32offset = (PRU_CAN_TX_MAILBOX0_STATUS_REGISTER & 0xFFFF);
> +			u32value = 0x00000080;
> +			s16subrtnretval = pruss_writel(dev, u32offset,
> +					(u32 *) &u32value, 1);
> +			if (s16subrtnretval == -1) {
> +				return -1;
> +			}
> +			break;
> +		case 1:
> +			u32offset = (PRU_CAN_TX_MAILBOX1_STATUS_REGISTER & 0xFFFF);
> +			u32value = 0x00000080;
> +			s16subrtnretval = pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval == -1) {
> +				return -1;
> +			}
> +			break;
> +		case 2:
> +			u32offset = (PRU_CAN_TX_MAILBOX2_STATUS_REGISTER & 0xFFFF);
> +			u32value = 0x00000080;
> +			s16subrtnretval = pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval == -1) {
> +				return -1;
> +			}
> +			break;
> +		case 3:
> +			u32offset = (PRU_CAN_TX_MAILBOX3_STATUS_REGISTER & 0xFFFF);
> +			u32value = 0x00000080;
> +			s16subrtnretval = pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval == -1) {
> +				return -1;
> +			}
> +			break;
> +		case 4:
> +			u32offset = (PRU_CAN_TX_MAILBOX4_STATUS_REGISTER & 0xFFFF);
> +			u32value = 0x00000080;
> +			s16subrtnretval = pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval == -1) {
> +				return -1;
> +			}
> +			break;
> +		case 5:
> +			u32offset = (PRU_CAN_TX_MAILBOX5_STATUS_REGISTER & 0xFFFF);
> +			u32value = 0x00000080;
> +			s16subrtnretval = pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval == -1) {
> +				return -1;
> +			}
> +			break;
> +		case 6:
> +			u32offset = (PRU_CAN_TX_MAILBOX6_STATUS_REGISTER & 0xFFFF);
> +			u32value = 0x00000080;
> +			s16subrtnretval = pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval == -1) {
> +				return -1;
> +			}
> +			break;
> +		case 7:
> +			u32offset = (PRU_CAN_TX_MAILBOX7_STATUS_REGISTER & 0xFFFF);
> +			u32value = 0x00000080;
> +			s16subrtnretval = pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval == -1) {
> +				return -1;
> +			}
> +			break;
> +		default:
> +			return -1;
> +		}
> +	} else {
> +
> +		u32offset = (PRU_CAN_RX_INTERRUPT_STATUS_REGISTER & 0xFFFF);
> +		u32value = 0x00000000;
> +		s16subrtnretval = pruss_readl(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +		if (s16subrtnretval == -1) {
> +			return -1;
> +		}
> +		u32value = u32value & ~(1 << u8mailboxnumber);
> +		s16subrtnretval = pruss_writel(dev, u32offset,
> +					(u32 *) &u32value, 1);
> +		if (s16subrtnretval == -1) {
> +			return -1;
> +		}
> +
> +		switch (u8mailboxnumber) {
> +		case 0:
> +			u32offset = (PRU_CAN_RX_MAILBOX0_STATUS_REGISTER & 0xFFFF);
> +			u32value = 0x00000000;
> +			s16subrtnretval = pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval == -1) {
> +				return -1;
> +			}
> +			break;
> +		case 1:
> +			u32offset = (PRU_CAN_RX_MAILBOX1_STATUS_REGISTER & 0xFFFF);
> +			u32value = 0x00000000;
> +			s16subrtnretval = pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval == -1) {
> +				return -1;
> +			}
> +			break;
> +		case 2:
> +			u32offset = (PRU_CAN_RX_MAILBOX2_STATUS_REGISTER & 0xFFFF);
> +			u32value = 0x00000000;
> +			s16subrtnretval = pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval == -1) {
> +				return -1;
> +			}
> +			break;
> +		case 3:
> +			u32offset = (PRU_CAN_RX_MAILBOX3_STATUS_REGISTER & 0xFFFF);
> +			u32value = 0x00000000;
> +			s16subrtnretval = pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval == -1) {
> +				return -1;
> +			}
> +			break;
> +		case 4:
> +			u32offset = (PRU_CAN_RX_MAILBOX4_STATUS_REGISTER & 0xFFFF);
> +			u32value = 0x00000000;
> +			s16subrtnretval = pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval == -1) {
> +				return -1;
> +			}
> +			break;
> +		case 5:
> +			u32offset = (PRU_CAN_RX_MAILBOX5_STATUS_REGISTER & 0xFFFF);
> +			u32value = 0x00000000;
> +			s16subrtnretval = pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval == -1) {
> +				return -1;
> +			}
> +			break;
> +		case 6:
> +			u32offset = (PRU_CAN_RX_MAILBOX6_STATUS_REGISTER & 0xFFFF);
> +			u32value = 0x00000000;
> +			s16subrtnretval = pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval == -1) {
> +				return -1;
> +			}
> +			break;
> +		case 7:
> +			u32offset = (PRU_CAN_RX_MAILBOX7_STATUS_REGISTER & 0xFFFF);
> +			u32value = 0x00000000;
> +			s16subrtnretval = pruss_writel(dev, u32offset,
> +						(u32 *) &u32value, 1);
> +			if (s16subrtnretval == -1) {
> +				return -1;
> +			}
> +			break;
> +		default:
> +			return -1;
> +		}

Ditto.

> +	}
> +	return 0;
> +}
> +
> +s16 pru_can_start_abort_tx(struct device *dev, bool bcantransmitabortflag)
> +{
> +	u32 u32offset;
> +	u32 u32value;
> +	s16 s16subrtnretval;
> +	u32offset = (PRUSS_INTC_STATIDXCLR & 0xFFFF);
> +	u32value = 32;
> +	s16subrtnretval = pruss_writel(dev, u32offset,
> +					(u32 *) &u32value, 1);
> +
> +	u32offset = (PRUSS_INTC_ENIDXSET & 0xFFFF);
> +	u32value = 32;
> +	s16subrtnretval = pruss_writel(dev, u32offset,
> +					(u32 *) &u32value, 1);
> +
> +	u32offset = (PRUSS_INTC_STATIDXSET & 0xFFFF);
> +	u32value = 32;
> +	s16subrtnretval = pruss_writel(dev, u32offset,
> +					(u32 *) &u32value, 1);
> +	if (s16subrtnretval == -1) {
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
> +	u32 u32offset = 0;
> +	u32 u32getvalue = 0;
> +	u32 u32clrvalue = 0;
> +
> +	u32offset = (PRUSS_INTC_STATCLRINT1 & 0xFFFF);
> +	pruss_readl(dev, u32offset, (u32 *) &u32getvalue, 1);
> +
> +	if (u32getvalue & 4)
> +		u32clrvalue = 34;	/* CLR Event 34 */
> +
> +	if (u32getvalue & 2)
> +		u32clrvalue = 33;	/* CLR Event 33  */
> +
> +	if (u32clrvalue) {
> +		u32offset = (PRUSS_INTC_STATIDXCLR & 0xFFFF);
> +		pruss_writel(dev, u32offset, &u32clrvalue, 1);
> +	} else
> +		return -1;
> +
> +	return u32getvalue;
> +}
> diff --git a/drivers/net/can/da8xx_pruss/pruss_can_api.h b/drivers/net/can/da8xx_pruss/pruss_can_api.h
> new file mode 100644
> index 0000000..7550456
> --- /dev/null
> +++ b/drivers/net/can/da8xx_pruss/pruss_can_api.h
> @@ -0,0 +1,290 @@
> +/*
> + * Copyright (C) 2010 Texas Instruments Incorporated
> + * Author: Ganeshan N
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License as  published by the
> + * Free Software Foundation version 2.
> + *
> + * This program is distributed "as is" WITHOUT ANY WARRANTY of any kind,
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
> +
> +#define TIMER_SETUP_DELAY		14
> +#define GPIO_SETUP_DELAY		150
> +
> +#define CAN_RX_PRU_0			PRUSS_NUM0
> +#define CAN_TX_PRU_1			PRUSS_NUM1
> +
> +/* Number of Instruction in the Delay loop */
> +#define DELAY_LOOP_LENGTH		2
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
> +
> +#define PRU_CAN_TIMING_VAL_RX				(PRU0_BASE_ADDR	+ 0xD0)
> +#define PRU_CAN_RECEIVE_FRAME				(PRU0_BASE_ADDR	+ 0xD4)
> +#define PRU_CAN_ID_MAP					(PRU0_BASE_ADDR	+ 0xF0)

Please consider using a struct to define the register layout. This would
make you code much much more readable and compact:

	writel(&regs->brp_register, bitrateprescaler);

instead of:

	u32offset = (PRU_CAN_TX_CLOCK_BRP_REGISTER);
	pruss_writel(dev, u32offset, (u32 *) &u16bitrateprescaler, 1);


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
> +	ecaninst0 = 0,
> +	ecaninst1,
> +	ecanmaxinst
> +} can_instance_enum;
> +
> +typedef enum {
> +	ecanmailbox0 = 0,
> +	ecanmailbox1,
> +	ecanmailbox2,
> +	ecanmailbox3,
> +	ecanmailbox4,
> +	ecanmailbox5,
> +	ecanmailbox6,
> +	ecanmailbox7
> +} can_mailbox_number;
> +
> +typedef enum {
> +	ecandirectioninit = 0,
> +	ecantransmit,
> +	ecanreceive
> +} can_transfer_direction;
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
> +
> +typedef struct {
> +	bool bcaninststate;
> +	can_transfer_direction ecantransferdirection;
> +	u32 u32apphandlerptr;
> +} can_emu_drv_inst;
> +
> +typedef struct {
> +	u8 u8syncjumpwidth;
> +	u8 u8phseg1;
> +	u8 u8phseg2;
> +} can_bit_timing_consts;

Don't use typedef's!

Thanks.

Wolfgang.

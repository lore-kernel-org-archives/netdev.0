From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Mon, 20 Jan 2014 10:18:28 +0100
Message-ID: <52DCE9E4.7010209@pengutronix.de>
References: <201312270037.15822.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="qb9TE2ITo7vrlTv0mwWEsa4a2MHRNlW32"
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, wg@grandegger.com,
	linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <201312270037.15822.sergei.shtylyov@cogentembedded.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--qb9TE2ITo7vrlTv0mwWEsa4a2MHRNlW32
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 12/26/2013 10:37 PM, Sergei Shtylyov wrote:
> Add support for the CAN controller found in Renesas R-Car SoCs.=20
>=20
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>=20
> ---
> The patch is against the 'linux-can-next.git' repo.
>=20
> Changes in version 5:
> - removed the code specific to the mailbox mode handling and added the =
code
>   for the FIFO mode, dropping support for CAN_CTRLMODE_ONE_SHOT;
> - stop accumulating errors in the byte 1 of an error frame;
> - added #define RCAR_CAN_CTLR_CANM for CTLR.CANM field, added 'CANM_' i=
nfix to
>   all its values;
> - replaced ~RCAR_CAN_CTLR_CANM_FORCE_RESET with ~RCAR_CAN_CTLR_CANM;=20
> - added polling for the CAN reset status bit when going from/to CAN res=
et.
>=20
> Changes in version 4:
> - added 'RCAR_CAN_' prefix to all #define's;
> - replaced all BIT(N) invocations with (1 << N) which allowed to remove=
 casts
>   to 'u8';
> - called rcar_can_set_bittiming() from rcar_can_start()  again and  sto=
pped
>   registering it as do_set_bittiming() method which allowed to remove c=
lock
>   API calls and control register writes from this function and make it =
*void*;
> - added #define RCAR_CAN_CTLR_IDFM for more clarity;
> - clarified comment to #define RCAR_CAN_IER_TXMIE;
> - did some whitespace cleanups.
>=20
> Changes in version 3:
> - replaced the register #define's with 'struct rcar_can_regs' fields, r=
eplaced
>   rcar_can_{read|write}[bwl]() with mere {read|write}[bwl]();
> - removed hardware bus-off recovery support which allowed to also remov=
e
>   rcar_can_start() prototype;
> - added RX/TX error count to error data frame for error warning/passive=
;
> - moved TX completion interrupt handling into separate function;
> - added '__packed' to 'struct rcar_can_mbox_regs' and 'struct rcar_can_=
regs';
> - removed unneeded type cast in the probe() method.
>=20
> Changes in version 2:
> - added function to clean up TX mailboxes after bus error and bus-off;
> - added module parameter to enable hardware recovery from bus-off, adde=
d handler
>   for the bus-off recovery interrupt, and set the control register acco=
rding to
>   the parameter value and the restart timer setting in rcar_can_start()=
;
> - changed the way CAN_ERR_CRTL_[RT]X_{PASSIVE|WARNING} flags are set to=
 a more
>   realistic one;
> - replaced MBX_* macros and rcar_can_mbx_{read|write}[bl]() functions w=
ith
>   'struct rcar_can_mbox_regs', 'struct rcar_can_regs', and {read|write}=
[bl](),
>   replaced 'reg_base' field of 'struct rcar_can_priv' with 'struct rcar=
_can_regs
>   __iomem *regs';
> - added 'ier' field to 'struct rcar_can_priv' to cache the current valu=
e of the
>   interrupt enable register;
> - added a check for enabled interrupts on entry to rcar_can_interrupt()=
;
> - limited transmit mailbox search loop in rcar_can_interrupt();
> - decoupled  TX byte count increment from can_get_echo_skb() call;
> - removed netif_queue_stopped() call from rcar_can_interrupt();
> - added clk_prepare_enable()/clk_disable_unprepare() to ndo_{open|close=
}(),
>   do_set_bittiming(), and do_get_berr_counter() methods, removed clk_en=
able()
>   call from the probe() method and clk_disable() call from the remove()=
 method;
> - allowed rcar_can_set_bittiming() to be called when the device is clos=
ed and
>   remove  explicit call to it from rcar_can_start();
> - switched to using mailbox number priority transmit mode, and switched=
 to the
>   sequential mailbox use in ndo_start_xmit() method;
> - stopped reading the message control registers in ndo_start_xmit() met=
hod;
> - avoided returning NETDEV_TX_BUSY from ndo_start_xmit() method;
> - stopped reading data when RTR bit is set in the CAN frame;
> - made 'num_pkts' variable *int* and moved its check to the *while* con=
dition in
>   rcar_can_rx_poll();
> - used dev_get_platdata() in the probe() method;
> - enabled bus error interrupt only if CAN_CTRLMODE_BERR_REPORTING flag =
is set;
> - started reporting CAN_CTRLMODE_BERR_REPORTING support and stopped rep=
orting
>   CAN_CTRLMODE_3_SAMPLES support;
> - set CAN_ERR_ACK flag on ACK error;
> - switched to incrementing bus error counter only once per bus error in=
terrupt;
> - started switching to CAN sleep mode in rcar_can_stop() and stopped sw=
itching
>   to it in the remove() method;
> - removed netdev_err() calls on allocation failure in rcar_can_error() =
and
>   rcar_can_rx_pkt();
> - removed "CANi" from the register offset macro comments.
>=20
>  drivers/net/can/Kconfig               |    9=20
>  drivers/net/can/Makefile              |    1=20
>  drivers/net/can/rcar_can.c            |  857 +++++++++++++++++++++++++=
+++++++++
>  include/linux/can/platform/rcar_can.h |   15=20
>  4 files changed, 882 insertions(+)
>=20
> Index: linux-can-next/drivers/net/can/Kconfig
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-can-next.orig/drivers/net/can/Kconfig
> +++ linux-can-next/drivers/net/can/Kconfig
> @@ -125,6 +125,15 @@ config CAN_GRCAN
>  	  endian syntheses of the cores would need some modifications on
>  	  the hardware level to work.
> =20
> +config CAN_RCAR
> +	tristate "Renesas R-Car CAN controller"
> +	---help---
> +	  Say Y here if you want to use CAN controller found on Renesas R-Car=

> +	  SoCs.
> +
> +	  To compile this driver as a module, choose M here: the module will
> +	  be called rcar_can.
> +
>  source "drivers/net/can/mscan/Kconfig"
> =20
>  source "drivers/net/can/sja1000/Kconfig"
> Index: linux-can-next/drivers/net/can/Makefile
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-can-next.orig/drivers/net/can/Makefile
> +++ linux-can-next/drivers/net/can/Makefile
> @@ -25,5 +25,6 @@ obj-$(CONFIG_CAN_JANZ_ICAN3)	+=3D janz-ica
>  obj-$(CONFIG_CAN_FLEXCAN)	+=3D flexcan.o
>  obj-$(CONFIG_PCH_CAN)		+=3D pch_can.o
>  obj-$(CONFIG_CAN_GRCAN)		+=3D grcan.o
> +obj-$(CONFIG_CAN_RCAR)		+=3D rcar_can.o
> =20
>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) :=3D -DDEBUG
> Index: linux-can-next/drivers/net/can/rcar_can.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- /dev/null
> +++ linux-can-next/drivers/net/can/rcar_can.c
> @@ -0,0 +1,857 @@
> +/*
> + * Renesas R-Car CAN device driver
> + *
> + * Copyright (C) 2013 Cogent Embedded, Inc. <source@cogentembedded.com=
>
> + * Copyright (C) 2013 Renesas Solutions Corp.
> + *
> + * This program is free software; you can redistribute  it and/or modi=
fy it
> + * under  the terms of  the GNU General  Public License as published b=
y the
> + * Free Software Foundation;  either version 2 of the  License, or (at=
 your
> + * option) any later version.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +#include <linux/interrupt.h>
> +#include <linux/errno.h>
> +#include <linux/netdevice.h>
> +#include <linux/platform_device.h>
> +#include <linux/can/led.h>
> +#include <linux/can/dev.h>
> +#include <linux/clk.h>
> +#include <linux/can/platform/rcar_can.h>
> +
> +#define RCAR_CAN_DRV_NAME	"rcar_can"
> +
> +/* Mailbox configuration:
> + * mailbox 60 - 63 - Rx FIFO mailboxes
> + * mailbox 56 - 59 - Tx FIFO mailboxes
> + * non-FIFO mailboxes are not used
> + */
> +#define RCAR_CAN_N_MBX		64 /* Number of mailboxes in non-FIFO mode */
> +#define RCAR_CAN_RX_FIFO_MBX	60 /* Mailbox - window to Rx FIFO */
> +#define RCAR_CAN_TX_FIFO_MBX	56 /* Mailbox - window to Tx FIFO */
> +#define RCAR_CAN_N_ECHO_SKB	10
> +
> +/* Mailbox registers structure */
> +struct rcar_can_mbox_regs {
> +	u32 id;		/* IDE and RTR bits, SID and EID */
> +	u8 stub;	/* Not used */
> +	u8 dlc;		/* Data Length Code - bits [0..3] */
> +	u8 data[8];	/* Data Bytes */
> +	u8 tsh;		/* Time Stamp Higher Byte */
> +	u8 tsl;		/* Time Stamp Lower Byte */
> +} __packed;

If you have contact to the hardware designer please blame him for
placing the data register unaligned into the register space. :)

> +
> +struct rcar_can_regs {
> +	struct rcar_can_mbox_regs mb[RCAR_CAN_N_MBX]; /* Mailbox registers */=

> +	u32 mkr_2_9[8];	/* Mask Registers 2-9 */
> +	u32 fidcr[2];	/* FIFO Received ID Compare Register */
> +	u32 mkivlr1;	/* Mask Invalid Register 1 */
> +	u32 mier1;	/* Mailbox Interrupt Enable Register 1 */
> +	u32 mkr_0_1[2];	/* Mask Registers 0-1 */
> +	u32 mkivlr0;    /* Mask Invalid Register 0*/
> +	u32 mier0;      /* Mailbox Interrupt Enable Register 0 */
> +	u8 pad_440[0x3c0];
> +	u8 mctl[64];	/* Message Control Registers */
> +	u16 ctlr;	/* Control Register */
> +	u16 str;	/* Status register */
> +	u8 bcr[3];	/* Bit Configuration Register */
> +	u8 clkr;	/* Clock Select Register */

bcr[3] and clkr looks broken, see comment where the register is used.

> +	u8 rfcr;	/* Receive FIFO Control Register */
> +	u8 rfpcr;	/* Receive FIFO Pointer Control Register */
> +	u8 tfcr;	/* Transmit FIFO Control Register */
> +	u8 tfpcr;       /* Transmit FIFO Pointer Control Register */
> +	u8 eier;	/* Error Interrupt Enable Register */
> +	u8 eifr;	/* Error Interrupt Factor Judge Register */
> +	u8 recr;	/* Receive Error Count Register */
> +	u8 tecr;        /* Transmit Error Count Register */
> +	u8 ecsr;	/* Error Code Store Register */
> +	u8 cssr;	/* Channel Search Support Register */
> +	u8 mssr;	/* Mailbox Search Status Register */
> +	u8 msmr;	/* Mailbox Search Mode Register */
> +	u16 tsr;	/* Time Stamp Register */
> +	u8 afsr;	/* Acceptance Filter Support Register */
> +	u8 pad_857;
> +	u8 tcr;		/* Test Control Register */
> +	u8 pad_859[7];
> +	u8 ier;		/* Interrupt Enable Register */
> +	u8 isr;		/* Interrupt Status Register */
> +	u8 pad_862;
> +	u8 mbsmr;	/* Mailbox Search Mask Register */
> +} __packed;
> +
> +struct rcar_can_priv {
> +	struct can_priv can;	/* Must be the first member! */
> +	struct net_device *ndev;
> +	struct napi_struct napi;
> +	struct rcar_can_regs __iomem *regs;
> +	struct clk *clk;
> +	spinlock_t skb_lock;
> +	u32 frames_queued;
> +	u32 bytes_queued;
> +	u8 clock_select;
> +	u8 ier;
> +};
> +
> +static const struct can_bittiming_const rcar_can_bittiming_const =3D {=

> +	.name =3D RCAR_CAN_DRV_NAME,
> +	.tseg1_min =3D 4,
> +	.tseg1_max =3D 16,
> +	.tseg2_min =3D 2,
> +	.tseg2_max =3D 8,
> +	.sjw_max =3D 4,
> +	.brp_min =3D 1,
> +	.brp_max =3D 1024,
> +	.brp_inc =3D 1,
> +};
> +
> +/* Control Register bits */
> +#define RCAR_CAN_CTLR_BOM	(3 << 11) /* Bus-Off Recovery Mode Bits */
> +#define RCAR_CAN_CTLR_BOM_ENT	(1 << 11) /* Entry to halt mode */
> +					/* at bus-off entry */
> +#define RCAR_CAN_CTLR_SLPM	(1 << 10)
> +#define RCAR_CAN_CTLR_CANM	(3 << 8) /* Operating Mode Select Bit */
> +#define RCAR_CAN_CTLR_CANM_HALT	(1 << 9)
> +#define RCAR_CAN_CTLR_CANM_RESET (1 << 8)
> +#define RCAR_CAN_CTLR_CANM_FORCE_RESET (3 << 8)
> +#define RCAR_CAN_CTLR_MLM	(1 << 3) /* Message Lost Mode Select */
> +#define RCAR_CAN_CTLR_IDFM	(3 << 1) /* ID Format Mode Select Bits */
> +#define RCAR_CAN_CTLR_IDFM_MIXED (1 << 2) /* Mixed ID mode */
> +#define RCAR_CAN_CTLR_MBM	(1 << 0) /* Mailbox Mode select */
> +
> +/* Status Register bits */
> +#define RCAR_CAN_STR_RSTST	(1 << 8) /* Reset Status Bit */
> +
> +/* FIFO Received ID Compare Registers 0 and 1 bits */
> +#define RCAR_CAN_FIDCR_IDE	(1 << 31) /* ID Extension Bit */
> +#define RCAR_CAN_FIDCR_RTR	(1 << 30) /* Remote Transmission Request Bi=
t */
> +
> +/* Receive FIFO Control Register bits */
> +#define RCAR_CAN_RFCR_RFEST	(1 << 7) /* Receive FIFO Empty Status Flag=
 */
> +#define RCAR_CAN_RFCR_RFUST	(7 << 1) /* Receive FIFO Unread Message */=

> +					/* Number Status Bits */
> +#define RCAR_CAN_RFCR_RFUST_SHIFT 1	/* Offset of Receive FIFO Unread *=
/
> +					/* Message Number Status Bits */
> +#define RCAR_CAN_RFCR_RFE	(1 << 0) /* Receive FIFO Enable */
> +
> +/* Transmit FIFO Control Register bits */
> +#define RCAR_CAN_TFCR_TFUST	(7 << 1) /* Transmit FIFO Unsent Message *=
/
> +					/* Number Status Bits */
> +#define RCAR_CAN_TFCR_TFUST_SHIFT 1	/* Offset of Transmit FIFO Unsent =
*/
> +					/* Message Number Status Bits */
> +#define RCAR_CAN_TFCR_TFE	(1 << 0) /* Transmit FIFO Enable */
> +
> +#define RCAR_CAN_N_RX_MKREGS1	2	/* Number of mask registers */
> +					/* for Rx mailboxes 0-31 */
> +#define RCAR_CAN_N_RX_MKREGS2	8
> +
> +/* Bit Configuration Register settings */
> +#define RCAR_CAN_BCR_TSEG1(x)	(((x) & 0x0f) << 28)
> +#define RCAR_CAN_BCR_BPR(x)	(((x) & 0x3ff) << 16)
> +#define RCAR_CAN_BCR_SJW(x)	(((x) & 0x3) << 12)
> +#define RCAR_CAN_BCR_TSEG2(x)	(((x) & 0x07) << 8)
> +
> +/* Mailbox and Mask Registers bits */
> +#define RCAR_CAN_IDE		(1 << 31)
> +#define RCAR_CAN_RTR		(1 << 30)
> +#define RCAR_CAN_SID_SHIFT	18
> +
> +/* Mailbox Interrupt Enable Register 1 bits */
> +#define RCAR_CAN_MIER1_RXFIE	(1 << 28) /* Receive  FIFO Interrupt Enab=
le */
> +#define RCAR_CAN_MIER1_TXFIT	(1 << 25) /* Transmit FIFO Interrupt Timi=
ng */
> +					/* Generate interrupt when */
> +					/* Tx FIFO becomes empty due to */
> +					/* completion of transmission */
> +#define RCAR_CAN_MIER1_TXFIE	(1 << 24) /* Transmit FIFO Interrupt Enab=
le */
> +
> +/* Interrupt Enable Register bits */
> +#define RCAR_CAN_IER_ERSIE	(1 << 5) /* Error (ERS) Interrupt Enable Bi=
t */
> +#define RCAR_CAN_IER_RXFIE	(1 << 4) /* Reception FIFO Interrupt */
> +					/* Enable Bit */
> +#define RCAR_CAN_IER_TXFIE	(1 << 3) /* Transmission FIFO Interrupt */
> +					/* Enable Bit */
> +/* Interrupt Status Register bits */
> +#define RCAR_CAN_ISR_ERSF	(1 << 5) /* Error (ERS) Interrupt Status Bit=
 */
> +#define RCAR_CAN_ISR_RXFF	(1 << 4) /* Reception FIFO Interrupt */
> +					/* Status Bit */
> +#define RCAR_CAN_ISR_TXFF	(1 << 3) /* Transmission FIFO Interrupt */
> +					/* Status Bit */
> +
> +/* Error Interrupt Enable Register bits */
> +#define RCAR_CAN_EIER_BLIE	(1 << 7) /* Bus Lock Interrupt Enable */
> +#define RCAR_CAN_EIER_OLIE	(1 << 6) /* Overload Frame Transmit */
> +					/* Interrupt Enable */
> +#define RCAR_CAN_EIER_ORIE	(1 << 5) /* Receive Overrun  Interrupt Enab=
le */
> +#define RCAR_CAN_EIER_BORIE	(1 << 4) /* Bus-Off Recovery Interrupt Ena=
ble */
> +#define RCAR_CAN_EIER_BOEIE	(1 << 3) /* Bus-Off Entry Interrupt Enable=
 */
> +#define RCAR_CAN_EIER_EPIE	(1 << 2) /* Error Passive Interrupt Enable =
*/
> +#define RCAR_CAN_EIER_EWIE	(1 << 1) /* Error Warning Interrupt Enable =
*/
> +#define RCAR_CAN_EIER_BEIE	(1 << 0) /* Bus Error Interrupt Enable */
> +
> +/* Error Interrupt Factor Judge Register bits */
> +#define RCAR_CAN_EIFR_BLIF	(1 << 7) /* Bus Lock Detect Flag */
> +#define RCAR_CAN_EIFR_OLIF	(1 << 6) /* Overload Frame Transmission */
> +					 /* Detect Flag */
> +#define RCAR_CAN_EIFR_ORIF	(1 << 5) /* Receive Overrun Detect Flag */
> +#define RCAR_CAN_EIFR_BORIF	(1 << 4) /* Bus-Off Recovery Detect Flag *=
/
> +#define RCAR_CAN_EIFR_BOEIF	(1 << 3) /* Bus-Off Entry Detect Flag */
> +#define RCAR_CAN_EIFR_EPIF	(1 << 2) /* Error Passive Detect Flag */
> +#define RCAR_CAN_EIFR_EWIF	(1 << 1) /* Error Warning Detect Flag */
> +#define RCAR_CAN_EIFR_BEIF	(1 << 0) /* Bus Error Detect Flag */
> +
> +/* Error Code Store Register bits */
> +#define RCAR_CAN_ECSR_EDPM	(1 << 7) /* Error Display Mode Select Bit *=
/
> +#define RCAR_CAN_ECSR_ADEF	(1 << 6) /* ACK Delimiter Error Flag */
> +#define RCAR_CAN_ECSR_BE0F	(1 << 5) /* Bit Error (dominant) Flag */
> +#define RCAR_CAN_ECSR_BE1F	(1 << 4) /* Bit Error (recessive) Flag */
> +#define RCAR_CAN_ECSR_CEF	(1 << 3) /* CRC Error Flag */
> +#define RCAR_CAN_ECSR_AEF	(1 << 2) /* ACK Error Flag */
> +#define RCAR_CAN_ECSR_FEF	(1 << 1) /* Form Error Flag */
> +#define RCAR_CAN_ECSR_SEF	(1 << 0) /* Stuff Error Flag */
> +
> +#define RCAR_CAN_NAPI_WEIGHT 4
> +
> +static void tx_failure_cleanup(struct net_device *ndev)
> +{
> +	u32 i;
> +
> +	for (i =3D 0; i < RCAR_CAN_N_ECHO_SKB; i++)
> +		can_free_echo_skb(ndev, i);
> +}
> +
> +static void rcar_can_error(struct net_device *ndev)
> +{
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +	struct net_device_stats *stats =3D &ndev->stats;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	u8 eifr, txerr =3D 0, rxerr =3D 0;
> +
> +	/* Propagate the error condition to the CAN stack */
> +	skb =3D alloc_can_err_skb(ndev, &cf);
> +	if (!skb)
> +		return;
> +
> +	eifr =3D readb(&priv->regs->eifr);
> +	if (eifr & (RCAR_CAN_EIFR_EWIF | RCAR_CAN_EIFR_EPIF)) {
> +		cf->can_id |=3D CAN_ERR_CRTL;
> +		txerr =3D readb(&priv->regs->tecr);
> +		rxerr =3D readb(&priv->regs->recr);
> +		cf->data[6] =3D txerr;
> +		cf->data[7] =3D rxerr;
> +	}
> +	if (eifr & RCAR_CAN_EIFR_BEIF) {
> +		int rx_errors =3D 0, tx_errors =3D 0;
> +		u8 ecsr;
> +
> +		netdev_dbg(priv->ndev, "Bus error interrupt:\n");
> +		cf->can_id |=3D CAN_ERR_BUSERROR | CAN_ERR_PROT;
> +		cf->data[2] =3D CAN_ERR_PROT_UNSPEC;
> +
> +		ecsr =3D readb(&priv->regs->ecsr);
> +		if (ecsr & RCAR_CAN_ECSR_ADEF) {
> +			netdev_dbg(priv->ndev, "ACK Delimiter Error\n");
> +			cf->data[3] |=3D CAN_ERR_PROT_LOC_ACK_DEL;
> +			tx_errors++;
> +			writeb(~RCAR_CAN_ECSR_ADEF, &priv->regs->ecsr);
> +		}
> +		if (ecsr & RCAR_CAN_ECSR_BE0F) {
> +			netdev_dbg(priv->ndev, "Bit Error (dominant)\n");
> +			cf->data[2] |=3D CAN_ERR_PROT_BIT0;
> +			tx_errors++;
> +			writeb(~RCAR_CAN_ECSR_BE0F, &priv->regs->ecsr);
> +		}
> +		if (ecsr & RCAR_CAN_ECSR_BE1F) {
> +			netdev_dbg(priv->ndev, "Bit Error (recessive)\n");
> +			cf->data[2] |=3D CAN_ERR_PROT_BIT1;
> +			tx_errors++;
> +			writeb(~RCAR_CAN_ECSR_BE1F, &priv->regs->ecsr);
> +		}
> +		if (ecsr & RCAR_CAN_ECSR_CEF) {
> +			netdev_dbg(priv->ndev, "CRC Error\n");
> +			cf->data[3] |=3D CAN_ERR_PROT_LOC_CRC_SEQ;
> +			rx_errors++;
> +			writeb(~RCAR_CAN_ECSR_CEF, &priv->regs->ecsr);
> +		}
> +		if (ecsr & RCAR_CAN_ECSR_AEF) {
> +			netdev_dbg(priv->ndev, "ACK Error\n");
> +			cf->can_id |=3D CAN_ERR_ACK;
> +			cf->data[3] |=3D CAN_ERR_PROT_LOC_ACK;
> +			tx_errors++;
> +			writeb(~RCAR_CAN_ECSR_AEF, &priv->regs->ecsr);
> +		}
> +		if (ecsr & RCAR_CAN_ECSR_FEF) {
> +			netdev_dbg(priv->ndev, "Form Error\n");
> +			cf->data[2] |=3D CAN_ERR_PROT_FORM;
> +			rx_errors++;
> +			writeb(~RCAR_CAN_ECSR_FEF, &priv->regs->ecsr);
> +		}
> +		if (ecsr & RCAR_CAN_ECSR_SEF) {
> +			netdev_dbg(priv->ndev, "Stuff Error\n");
> +			cf->data[2] |=3D CAN_ERR_PROT_STUFF;
> +			rx_errors++;
> +			writeb(~RCAR_CAN_ECSR_SEF, &priv->regs->ecsr);
> +		}
> +
> +		priv->can.can_stats.bus_error++;
> +		ndev->stats.rx_errors +=3D rx_errors;
> +		ndev->stats.tx_errors +=3D tx_errors;
> +		writeb(~RCAR_CAN_EIFR_BEIF, &priv->regs->eifr);
> +	}
> +	if (eifr & RCAR_CAN_EIFR_EWIF) {
> +		netdev_dbg(priv->ndev, "Error warning interrupt\n");
> +		priv->can.state =3D CAN_STATE_ERROR_WARNING;
> +		priv->can.can_stats.error_warning++;
> +		cf->data[1] =3D txerr > rxerr ? CAN_ERR_CRTL_TX_WARNING :
> +					      CAN_ERR_CRTL_RX_WARNING;
> +		/* Clear interrupt condition */
> +		writeb(~RCAR_CAN_EIFR_EWIF, &priv->regs->eifr);
> +	}
> +	if (eifr & RCAR_CAN_EIFR_EPIF) {
> +		netdev_dbg(priv->ndev, "Error passive interrupt\n");
> +		priv->can.state =3D CAN_STATE_ERROR_PASSIVE;
> +		priv->can.can_stats.error_passive++;
> +		cf->data[1] =3D txerr > rxerr ? CAN_ERR_CRTL_TX_PASSIVE :
> +					      CAN_ERR_CRTL_RX_PASSIVE;
> +		/* Clear interrupt condition */
> +		writeb(~RCAR_CAN_EIFR_EPIF, &priv->regs->eifr);
> +	}
> +	if (eifr & RCAR_CAN_EIFR_BOEIF) {
> +		netdev_dbg(priv->ndev, "Bus-off entry interrupt\n");
> +		tx_failure_cleanup(ndev);
> +		priv->ier =3D RCAR_CAN_IER_ERSIE;
> +		writeb(priv->ier, &priv->regs->ier);
> +		priv->can.state =3D CAN_STATE_BUS_OFF;
> +		cf->can_id |=3D CAN_ERR_BUSOFF;
> +		/* Clear interrupt condition */
> +		writeb(~RCAR_CAN_EIFR_BOEIF, &priv->regs->eifr);
> +		can_bus_off(ndev);
> +	}
> +	if (eifr & RCAR_CAN_EIFR_ORIF) {
> +		netdev_dbg(priv->ndev, "Receive overrun error interrupt\n");
> +		cf->can_id |=3D CAN_ERR_CRTL;
> +		cf->data[1] =3D CAN_ERR_CRTL_RX_OVERFLOW;
> +		ndev->stats.rx_over_errors++;
> +		ndev->stats.rx_errors++;
> +		writeb(~RCAR_CAN_EIFR_ORIF, &priv->regs->eifr);
> +	}
> +	if (eifr & RCAR_CAN_EIFR_OLIF) {
> +		netdev_dbg(priv->ndev,
> +			   "Overload Frame Transmission error interrupt\n");
> +		cf->can_id |=3D CAN_ERR_PROT;
> +		cf->data[2] |=3D CAN_ERR_PROT_OVERLOAD;
> +		ndev->stats.rx_over_errors++;
> +		ndev->stats.rx_errors++;
> +		writeb(~RCAR_CAN_EIFR_OLIF, &priv->regs->eifr);
> +	}
> +
> +	netif_rx(skb);
> +	stats->rx_packets++;
> +	stats->rx_bytes +=3D cf->can_dlc;
> +}
> +
> +static void rcar_can_tx_done(struct net_device *ndev)
> +{
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +	struct net_device_stats *stats =3D &ndev->stats;
> +	int i;
> +
> +	spin_lock(&priv->skb_lock);
> +	for (i =3D 0; i < priv->frames_queued; i++)
> +		can_get_echo_skb(ndev, i);
> +	stats->tx_bytes +=3D priv->bytes_queued;
> +	stats->tx_packets +=3D priv->frames_queued;
> +	priv->bytes_queued =3D 0;
> +	priv->frames_queued =3D 0;
> +	spin_unlock(&priv->skb_lock);

This looks broken. What happens if you send 2 CAN frames in a row, the
first one is send, a TX complete interrupt is issued and you handle it
here? You assume, that all CAN frames have been sent.

> +	can_led_event(ndev, CAN_LED_EVENT_TX);
> +	netif_wake_queue(ndev);
> +}
> +
> +static irqreturn_t rcar_can_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *ndev =3D (struct net_device *)dev_id;
the cast is not needed
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +	u8 isr;
> +
> +	isr =3D readb(&priv->regs->isr);
> +	if (!(isr & priv->ier))
> +		return IRQ_NONE;
> +
> +	if (isr & RCAR_CAN_ISR_ERSF)
> +		rcar_can_error(ndev);
> +
> +	if (isr & RCAR_CAN_ISR_TXFF) {
> +		/* Clear interrupt */
> +		writeb(isr & ~RCAR_CAN_ISR_TXFF, &priv->regs->isr);
> +		rcar_can_tx_done(ndev);
> +	}
> +
> +	if (isr & RCAR_CAN_ISR_RXFF) {
> +		if (napi_schedule_prep(&priv->napi)) {
> +			/* Disable Rx FIFO interrupts */
> +			priv->ier &=3D ~RCAR_CAN_IER_RXFIE;
> +			writeb(priv->ier, &priv->regs->ier);
> +			__napi_schedule(&priv->napi);
> +		}
> +	}
> +
> +	return IRQ_HANDLED;
> +}
> +
> +static void rcar_can_set_bittiming(struct net_device *dev)
> +{
> +	struct rcar_can_priv *priv =3D netdev_priv(dev);
> +	struct can_bittiming *bt =3D &priv->can.bittiming;
> +	u32 bcr;
> +	u8 clkr;
> +
> +	/* Don't overwrite CLKR with 32-bit BCR access */
> +	/* CLKR has 8-bit access */

Can you explain the register layout here? Why do you access BCR with 32
bits when the register is defined as 3x8 bit? Can't you make it a
standard 32 bit register?

> +	clkr =3D readb(&priv->regs->clkr);
> +	bcr =3D RCAR_CAN_BCR_TSEG1(bt->phase_seg1 + bt->prop_seg - 1) |
> +	      RCAR_CAN_BCR_BPR(bt->brp - 1) | RCAR_CAN_BCR_SJW(bt->sjw - 1) |=

> +	      RCAR_CAN_BCR_TSEG2(bt->phase_seg2 - 1);
> +	writel(bcr, &priv->regs->bcr);
> +	writeb(clkr, &priv->regs->clkr);
> +}
> +
> +static void rcar_can_start(struct net_device *ndev)
> +{
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +	u16 ctlr, str;
> +
> +	/* Set controller to known mode:
> +	 * - FIFO mailbox mode
> +	 * - accept all messages
> +	 * - overrun mode
> +	 * CAN is in sleep mode after MCU hardware or software reset.
> +	 */
> +	ctlr =3D readw(&priv->regs->ctlr);
> +	ctlr &=3D ~RCAR_CAN_CTLR_SLPM;
> +	writew(ctlr, &priv->regs->ctlr);
> +	/* Go to reset mode */
> +	ctlr |=3D RCAR_CAN_CTLR_CANM_FORCE_RESET;
> +	writew(ctlr, &priv->regs->ctlr);
> +	do {
> +		str =3D readw(&priv->regs->str);
> +	} while (!(str & RCAR_CAN_STR_RSTST));

Please add a timeout for this loop and the loop below.

> +	rcar_can_set_bittiming(ndev);
> +	ctlr |=3D RCAR_CAN_CTLR_IDFM_MIXED; /* Select mixed ID mode */
> +	ctlr |=3D RCAR_CAN_CTLR_BOM_ENT;	/* Entry to halt mode automatically =
*/
> +					/* at bus-off */
> +	ctlr |=3D RCAR_CAN_CTLR_MBM;	/* Select FIFO mailbox mode */
> +	ctlr |=3D RCAR_CAN_CTLR_MLM;	/* Overrun mode */
> +	writew(ctlr, &priv->regs->ctlr);
> +
> +	writeb(priv->clock_select, &priv->regs->clkr);
> +
> +	/* Accept all SID and EID */
> +	writel(0, &priv->regs->mkr_2_9[6]);
> +	writel(0, &priv->regs->mkr_2_9[7]);
> +	/* In FIFO mailbox mode, write "0" to bits 24 to 31 */
> +	writel(0, &priv->regs->mkivlr1);
> +	/* Accept all frames */
> +	writel(0, &priv->regs->fidcr[0]);
> +	writel(RCAR_CAN_FIDCR_IDE | RCAR_CAN_FIDCR_RTR, &priv->regs->fidcr[1]=
);
> +	/* Enable and configure FIFO mailbox interrupts */
> +	writel(RCAR_CAN_MIER1_RXFIE | RCAR_CAN_MIER1_TXFIT |
> +	       RCAR_CAN_MIER1_TXFIE, &priv->regs->mier1);
> +
> +	priv->ier =3D RCAR_CAN_IER_ERSIE | RCAR_CAN_IER_RXFIE |
> +		    RCAR_CAN_IER_TXFIE;
> +	writeb(priv->ier, &priv->regs->ier);
> +
> +	/* Accumulate error codes */
> +	writeb(RCAR_CAN_ECSR_EDPM, &priv->regs->ecsr);
> +	/* Enable error interrupts */
> +	writeb(RCAR_CAN_EIER_EWIE | RCAR_CAN_EIER_EPIE | RCAR_CAN_EIER_BOEIE =
|
> +	       (priv->can.ctrlmode & CAN_CTRLMODE_BERR_REPORTING ?
> +	       RCAR_CAN_EIER_BEIE : 0) | RCAR_CAN_EIER_ORIE |
> +	       RCAR_CAN_EIER_OLIE, &priv->regs->eier);
> +	priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> +
> +	/* Go to operation mode */
> +	writew(ctlr & ~RCAR_CAN_CTLR_CANM, &priv->regs->ctlr);
> +	do {
> +		str =3D readw(&priv->regs->str);
> +	} while (str & RCAR_CAN_STR_RSTST);
> +	/* Enable Rx and Tx FIFO */
> +	writeb(RCAR_CAN_RFCR_RFE, &priv->regs->rfcr);
> +	writeb(RCAR_CAN_TFCR_TFE, &priv->regs->tfcr);
> +}
> +
> +static int rcar_can_open(struct net_device *ndev)
> +{
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +	int err;
> +
> +	clk_prepare_enable(priv->clk);

clk_prepare_enable can fail

> +	err =3D open_candev(ndev);
> +	if (err) {
> +		netdev_err(ndev, "open_candev() failed %d\n", err);
> +		goto out;

please adjust the jump label, you have to disable the clock.

> +	}
> +	napi_enable(&priv->napi);
> +	err =3D request_irq(ndev->irq, rcar_can_interrupt, 0, ndev->name, nde=
v);
> +	if (err) {
> +		netdev_err(ndev, "error requesting interrupt %x\n", ndev->irq);
> +		goto out_close;
> +	}
> +	can_led_event(ndev, CAN_LED_EVENT_OPEN);
> +	rcar_can_start(ndev);
> +	netif_start_queue(ndev);
> +	return 0;
> +out_close:
> +	napi_disable(&priv->napi);
> +	close_candev(ndev);
> +	clk_disable_unprepare(priv->clk);
> +out:
> +	return err;
> +}
> +
> +static void rcar_can_stop(struct net_device *ndev)
> +{
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +	u16 ctlr, str;
> +
> +	/* Go to (force) reset mode */
> +	ctlr =3D readw(&priv->regs->ctlr);
> +	ctlr |=3D RCAR_CAN_CTLR_CANM_FORCE_RESET;
> +	writew(ctlr, &priv->regs->ctlr);
> +	do {
> +		str =3D readw(&priv->regs->str);
> +	} while (!(str & RCAR_CAN_STR_RSTST));

please add a timeout to the loop

> +	writel(0, &priv->regs->mier0);
> +	writel(0, &priv->regs->mier1);
> +	writeb(0, &priv->regs->ier);
> +	writeb(0, &priv->regs->eier);
> +	/* Go to sleep mode */
> +	ctlr |=3D RCAR_CAN_CTLR_SLPM;
> +	writew(ctlr, &priv->regs->ctlr);
> +	priv->can.state =3D CAN_STATE_STOPPED;
> +}
> +
> +static int rcar_can_close(struct net_device *ndev)
> +{
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +
> +	netif_stop_queue(ndev);
> +	rcar_can_stop(ndev);
> +	free_irq(ndev->irq, ndev);
> +	napi_disable(&priv->napi);
> +	clk_disable_unprepare(priv->clk);
> +	close_candev(ndev);
> +	can_led_event(ndev, CAN_LED_EVENT_STOP);
> +	return 0;
> +}
> +
> +static netdev_tx_t rcar_can_start_xmit(struct sk_buff *skb,
> +				       struct net_device *ndev)
> +{
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +	struct can_frame *cf =3D (struct can_frame *)skb->data;
> +	u32 data, i;
> +	unsigned long flags;
> +	u8 tfcr;
> +
> +	if (can_dropped_invalid_skb(ndev, skb))
> +		return NETDEV_TX_OK;
> +	tfcr =3D readb(&priv->regs->tfcr);
> +	if ((tfcr & RCAR_CAN_TFCR_TFUST) >> RCAR_CAN_TFCR_TFUST_SHIFT > 2)
> +		netif_stop_queue(ndev);

Can you explain what's checked here?

> +
> +	if (cf->can_id & CAN_EFF_FLAG) {
> +		/* Extended frame format */
> +		data =3D (cf->can_id & CAN_EFF_MASK) | RCAR_CAN_IDE;
> +	} else {
> +		/* Standard frame format */
> +		data =3D (cf->can_id & CAN_SFF_MASK) << RCAR_CAN_SID_SHIFT;
> +	}
> +	if (cf->can_id & CAN_RTR_FLAG) {
> +		/* Remote transmission request */
> +		data |=3D RCAR_CAN_RTR;
> +	}

You can move the comments into the line of if and else and remove the {
& } as there is only one line after if and else.

> +	writel(data, &priv->regs->mb[RCAR_CAN_TX_FIFO_MBX].id);
> +
> +	writeb(cf->can_dlc, &priv->regs->mb[RCAR_CAN_TX_FIFO_MBX].dlc);
> +
> +	for (i =3D 0; i < cf->can_dlc; i++)
> +		writeb(cf->data[i],
> +		       &priv->regs->mb[RCAR_CAN_TX_FIFO_MBX].data[i]);
> +
> +	spin_lock_irqsave(&priv->skb_lock, flags);
> +	can_put_echo_skb(skb, ndev, priv->frames_queued++);
> +	priv->bytes_queued +=3D cf->can_dlc;

How does the frames_queued and bytes_queued mechanism work?

> +	spin_unlock_irqrestore(&priv->skb_lock, flags);
> +	/* Start Tx: write 0xFF to the TFPCR register to increment
> +	 * the CPU-side pointer for the transmit FIFO to the next
> +	 * mailbox location
> +	 */
> +	writeb(0xFF, &priv->regs->tfpcr);

please use lowercase for hex.

> +
> +	return NETDEV_TX_OK;

I'm missing flow control here. You have to stop the queue if there isn't
any room in the tx fifo.

> +}
> +
> +static const struct net_device_ops rcar_can_netdev_ops =3D {
> +	.ndo_open =3D rcar_can_open,
> +	.ndo_stop =3D rcar_can_close,
> +	.ndo_start_xmit =3D rcar_can_start_xmit,
> +};
> +
> +static void rcar_can_rx_pkt(struct rcar_can_priv *priv)
> +{
> +	struct net_device_stats *stats =3D &priv->ndev->stats;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	u32 data;
> +	u8 dlc;
> +
> +	skb =3D alloc_can_skb(priv->ndev, &cf);
> +	if (!skb) {
> +		stats->rx_dropped++;
> +		return;
> +	}
> +
> +	data =3D readl(&priv->regs->mb[RCAR_CAN_RX_FIFO_MBX].id);
> +	if (data & RCAR_CAN_IDE)
> +		cf->can_id =3D (data & CAN_EFF_MASK) | CAN_EFF_FLAG;
> +	else
> +		cf->can_id =3D (data >> RCAR_CAN_SID_SHIFT) & CAN_SFF_MASK;
> +
> +	dlc =3D readb(&priv->regs->mb[RCAR_CAN_RX_FIFO_MBX].dlc);
> +	cf->can_dlc =3D get_can_dlc(dlc);
> +	if (data & RCAR_CAN_RTR) {
> +		cf->can_id |=3D CAN_RTR_FLAG;
> +	} else {
> +		for (dlc =3D 0; dlc < cf->can_dlc; dlc++)
> +			cf->data[dlc] =3D
> +			readb(&priv->regs->mb[RCAR_CAN_RX_FIFO_MBX].data[dlc]);
> +	}
> +
> +	can_led_event(priv->ndev, CAN_LED_EVENT_RX);
> +
> +	netif_receive_skb(skb);
> +	stats->rx_bytes +=3D cf->can_dlc;
> +	stats->rx_packets++;
> +}
> +
> +static int rcar_can_rx_poll(struct napi_struct *napi, int quota)
> +{
> +	struct rcar_can_priv *priv =3D container_of(napi,
> +						  struct rcar_can_priv, napi);
> +	int num_pkts =3D 0;
> +
> +	while (num_pkts < quota) {
> +		u8 i, rfcr, nframes, isr;
> +
> +		isr =3D readb(&priv->regs->isr);
> +		/* Clear interrupt bit */
> +		if (isr & RCAR_CAN_ISR_RXFF)
> +			writeb(isr & ~RCAR_CAN_ISR_RXFF, &priv->regs->isr);
> +		rfcr =3D readb(&priv->regs->rfcr);
> +		if (rfcr & RCAR_CAN_RFCR_RFEST)
> +			break;
> +		nframes =3D (rfcr & RCAR_CAN_RFCR_RFUST) >>
> +			  RCAR_CAN_RFCR_RFUST_SHIFT;
> +		for (i =3D 0; i < nframes; i++) {
> +			rcar_can_rx_pkt(priv);
> +			/* Write 0xFF to the RFPCR register to increment
> +			 * the CPU-side pointer for the receive FIFO
> +			 * to the next mailbox location
> +			 */
> +			writeb(0xFF, &priv->regs->rfpcr);
> +			++num_pkts;
> +		}

The for loop inside the while loop makes no sense if you increment
num_pkts. You are not allowed to receive more than quota CAN frames.

> +	}
> +	/* All packets processed */
> +	if (num_pkts < quota) {
> +		napi_complete(napi);
> +		priv->ier |=3D RCAR_CAN_IER_RXFIE;
> +		writeb(priv->ier, &priv->regs->ier);
> +	}
> +	return num_pkts;
> +}
> +
> +static int rcar_can_do_set_mode(struct net_device *ndev, enum can_mode=
 mode)
> +{
> +	switch (mode) {
> +	case CAN_MODE_START:
> +		rcar_can_start(ndev);
> +		netif_wake_queue(ndev);
> +		return 0;
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +}
> +
> +static int rcar_can_get_berr_counter(const struct net_device *dev,
> +				     struct can_berr_counter *bec)
> +{
> +	struct rcar_can_priv *priv =3D netdev_priv(dev);
> +
> +	clk_prepare_enable(priv->clk);

clk_prepare_enable can fail

> +	bec->txerr =3D readb(&priv->regs->tecr);
> +	bec->rxerr =3D readb(&priv->regs->recr);
> +	clk_disable_unprepare(priv->clk);
> +	return 0;
> +}
> +
> +static int rcar_can_probe(struct platform_device *pdev)
> +{
> +	struct rcar_can_platform_data *pdata;
> +	struct rcar_can_priv *priv;
> +	struct net_device *ndev;
> +	struct resource *mem;
> +	void __iomem *addr;
> +	int err =3D -ENODEV;
> +	int irq;
> +
> +	pdata =3D dev_get_platdata(&pdev->dev);
> +	if (!pdata) {
> +		dev_err(&pdev->dev, "No platform data provided!\n");
> +		goto fail;
> +	}
> +
> +	irq =3D platform_get_irq(pdev, 0);
> +	if (!irq) {
> +		dev_err(&pdev->dev, "No IRQ resource\n");
> +		goto fail;
> +	}
> +
> +	mem =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	addr =3D devm_ioremap_resource(&pdev->dev, mem);
> +	if (IS_ERR(addr)) {
> +		err =3D PTR_ERR(addr);
> +		goto fail;
> +	}
> +
> +	ndev =3D alloc_candev(sizeof(struct rcar_can_priv), RCAR_CAN_N_ECHO_S=
KB);
> +	if (!ndev) {
> +		dev_err(&pdev->dev, "alloc_candev failed\n");
> +		err =3D -ENOMEM;
> +		goto fail;
> +	}
> +
> +	priv =3D netdev_priv(ndev);
> +
> +	priv->clk =3D devm_clk_get(&pdev->dev, NULL);
> +	if (IS_ERR(priv->clk)) {
> +		err =3D PTR_ERR(priv->clk);
> +		dev_err(&pdev->dev, "cannot get clock: %d\n", err);
> +		goto fail_clk;
> +	}
> +
> +	ndev->netdev_ops =3D &rcar_can_netdev_ops;
> +	ndev->irq =3D irq;
> +	ndev->flags |=3D IFF_ECHO;
> +	priv->ndev =3D ndev;
> +	priv->regs =3D addr;
> +	priv->clock_select =3D pdata->clock_select;
> +	priv->can.clock.freq =3D clk_get_rate(priv->clk);
> +	priv->can.bittiming_const =3D &rcar_can_bittiming_const;
> +	priv->can.do_set_mode =3D rcar_can_do_set_mode;
> +	priv->can.do_get_berr_counter =3D rcar_can_get_berr_counter;
> +	priv->can.ctrlmode_supported =3D CAN_CTRLMODE_BERR_REPORTING;
> +	platform_set_drvdata(pdev, ndev);
> +	SET_NETDEV_DEV(ndev, &pdev->dev);
> +	spin_lock_init(&priv->skb_lock);
> +
> +	netif_napi_add(ndev, &priv->napi, rcar_can_rx_poll,
> +		       RCAR_CAN_NAPI_WEIGHT);
> +	err =3D register_candev(ndev);
> +	if (err) {
> +		dev_err(&pdev->dev, "register_candev() failed\n");
> +		goto fail_candev;
> +	}
> +
> +	devm_can_led_init(ndev);
> +
> +	dev_info(&pdev->dev, "device registered (reg_base=3D%p, irq=3D%u)\n",=

> +		 priv->regs, ndev->irq);
> +
> +	return 0;
> +fail_candev:
> +	netif_napi_del(&priv->napi);
> +fail_clk:
> +	free_candev(ndev);
> +fail:
> +	return err;
> +}
> +
> +static int rcar_can_remove(struct platform_device *pdev)
> +{
> +	struct net_device *ndev =3D platform_get_drvdata(pdev);
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +
> +	unregister_candev(ndev);
> +	netif_napi_del(&priv->napi);
> +	free_candev(ndev);
> +	return 0;
> +}
> +
> +#ifdef CONFIG_PM_SLEEP
> +static int rcar_can_suspend(struct device *dev)
> +{
> +	struct net_device *ndev =3D dev_get_drvdata(dev);
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +	u16 ctlr;
> +
> +	if (netif_running(ndev)) {
> +		netif_stop_queue(ndev);
> +		netif_device_detach(ndev);
> +	}
> +	ctlr =3D readw(&priv->regs->ctlr);
> +	ctlr |=3D RCAR_CAN_CTLR_CANM_HALT;
> +	writew(ctlr, &priv->regs->ctlr);
> +	ctlr |=3D RCAR_CAN_CTLR_SLPM;
> +	writew(ctlr, &priv->regs->ctlr);
> +	priv->can.state =3D CAN_STATE_SLEEPING;
> +
> +	clk_disable(priv->clk);
> +	return 0;
> +}
> +
> +static int rcar_can_resume(struct device *dev)
> +{
> +	struct net_device *ndev =3D dev_get_drvdata(dev);
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +	u16 ctlr;
> +
> +	clk_enable(priv->clk);
> +
> +	ctlr =3D readw(&priv->regs->ctlr);
> +	ctlr &=3D ~RCAR_CAN_CTLR_SLPM;
> +	writew(ctlr, &priv->regs->ctlr);
> +	ctlr &=3D ~RCAR_CAN_CTLR_CANM;
> +	writew(ctlr, &priv->regs->ctlr);
> +	priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> +
> +	if (netif_running(ndev)) {
> +		netif_device_attach(ndev);
> +		netif_start_queue(ndev);
> +	}
> +	return 0;
> +}
> +#endif
> +
> +static SIMPLE_DEV_PM_OPS(rcar_can_pm_ops, rcar_can_suspend, rcar_can_r=
esume);
> +
> +static struct platform_driver rcar_can_driver =3D {
> +	.driver =3D {
> +		.name =3D RCAR_CAN_DRV_NAME,
> +		.owner =3D THIS_MODULE,
> +		.pm =3D &rcar_can_pm_ops,
> +	},
> +	.probe =3D rcar_can_probe,
> +	.remove =3D rcar_can_remove,
> +};
> +
> +module_platform_driver(rcar_can_driver);
> +
> +MODULE_AUTHOR("Cogent Embedded, Inc.");
> +MODULE_LICENSE("GPL");
> +MODULE_DESCRIPTION("CAN driver for Renesas R-Car SoC");
> +MODULE_ALIAS("platform:" RCAR_CAN_DRV_NAME);
> Index: linux-can-next/include/linux/can/platform/rcar_can.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- /dev/null
> +++ linux-can-next/include/linux/can/platform/rcar_can.h
> @@ -0,0 +1,15 @@
> +#ifndef _CAN_PLATFORM_RCAR_CAN_H_
> +#define _CAN_PLATFORM_RCAR_CAN_H_
> +
> +#include <linux/types.h>
> +
> +/* Clock Select Register settings */
> +#define CLKR_CLKEXT	3	/* Externally input clock */
> +#define CLKR_CLKP2	1	/* Peripheral clock (clkp2) */
> +#define CLKR_CLKP1	0	/* Peripheral clock (clkp1) */

Please make it an enum

> +
> +struct rcar_can_platform_data {
> +	u8 clock_select;	/* Clock source select */
> +};
> +
> +#endif	/* !_CAN_PLATFORM_RCAR_CAN_H_ */
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--qb9TE2ITo7vrlTv0mwWEsa4a2MHRNlW32
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlLc6eQACgkQjTAFq1RaXHMAdACfWdVGSy31rlxjvZGH7C2Iy4Wm
GSkAnRimmoQj6p/eEtZtyxBLCztr1kad
=xc/P
-----END PGP SIGNATURE-----

--qb9TE2ITo7vrlTv0mwWEsa4a2MHRNlW32--

From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v6 1/1] can: c_can: Added support for Bosch
	C_CAN controller
Date: Thu, 10 Feb 2011 10:28:10 +0100
Message-ID: <4D53AFAA.8070509@pengutronix.de>
References: <D5ECB3C7A6F99444980976A8C6D896384DEE36615D@EAPEX1MAIL1.st.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7178123171881246219=="
Cc: "socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Bhupesh SHARMA <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <D5ECB3C7A6F99444980976A8C6D896384DEE36615D-8vAmw3ZAcdzhJTuQ9jeba9BPR1lH4CV8@public.gmane.org>
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
--===============7178123171881246219==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig7D04BF5025E182EEC5C1C0AC"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig7D04BF5025E182EEC5C1C0AC
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello

On 02/09/2011 11:54 AM, Bhupesh SHARMA wrote:
[...]
>> The driver looks quite good, some comments inline, most of them
>> nitpicking and or style related.
>>
>> Have a look at the netif_stop_queue(). In the at91 driver there are tw=
o
>> possibilities that to stop the queue. First the next tx mailbox is
>> still in use, second we have a wrap around. But your hardware is a bit=

>> different. Anyways a second look doesn't harm.
>=20
> As the Tx/Rx path of my driver are based on at91 driver, I have earlier=

> gone through the possibility of stopping the tx queue in the two cases =
as
> you mentioned above :)
>=20
> As per at91 specs, MRDY=3D0 signifies:
> "Mailbox data registers cannot be read/written by the software applicat=
ion"
>=20
> But, after reading the Bosch C_CAN specs Transmission Request Register(=
TxRqst)'s
> bits if set to 1, signify that the transmission of this Message Object =
is
> requested and is not yet done. If you agree we can add a check against =
the same here.
> Please do go through the Bosch C_CAN specs for details:
> http://www.semiconductors.bosch.de/media/en/pdf/ipmodules_1/
> c_can/users_manual_c_can.pdf

Better save then sorry, add the check.

>=20
>>> ---
>>> Changes since V5:
>>> 1. Seperated the state change and bus error handling paths.
>>> 2. Added logic to write LEC value to 0x7 from CPU to check for
>> updates
>>>    later.
>>> 3. Corrected the ERROR_WARNING handling logic to correctly send error=

>>>    frames on the bus.
>>>
>>>  drivers/net/can/Kconfig                |    2 +
>>>  drivers/net/can/Makefile               |    1 +
>>>  drivers/net/can/c_can/Kconfig          |   15 +
>>>  drivers/net/can/c_can/Makefile         |    8 +
>>>  drivers/net/can/c_can/c_can.c          |  993
>> ++++++++++++++++++++++++++++++++
>>>  drivers/net/can/c_can/c_can.h          |  230 ++++++++
>>>  drivers/net/can/c_can/c_can_platform.c |  207 +++++++
>>>  7 files changed, 1456 insertions(+), 0 deletions(-)  create mode
>>> 100644 drivers/net/can/c_can/Kconfig  create mode 100644
>>> drivers/net/can/c_can/Makefile  create mode 100644
>>> drivers/net/can/c_can/c_can.c  create mode 100644
>>> drivers/net/can/c_can/c_can.h  create mode 100644
>>> drivers/net/can/c_can/c_can_platform.c
>>>
>>> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig index
>>> 5dec456..1d699e3 100644
>>> --- a/drivers/net/can/Kconfig
>>> +++ b/drivers/net/can/Kconfig
>>> @@ -115,6 +115,8 @@ source "drivers/net/can/mscan/Kconfig"
>>>
>>>  source "drivers/net/can/sja1000/Kconfig"
>>>
>>> +source "drivers/net/can/c_can/Kconfig"
>>> +
>>>  source "drivers/net/can/usb/Kconfig"
>>>
>>>  source "drivers/net/can/softing/Kconfig"
>>> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
>> index
>>> 53c82a7..24ebfe8 100644
>>> --- a/drivers/net/can/Makefile
>>> +++ b/drivers/net/can/Makefile
>>> @@ -13,6 +13,7 @@ obj-y                             +=3D softing/
>>>
>>>  obj-$(CONFIG_CAN_SJA1000)  +=3D sja1000/
>>>  obj-$(CONFIG_CAN_MSCAN)            +=3D mscan/
>>> +obj-$(CONFIG_CAN_C_CAN)            +=3D c_can/
>>>  obj-$(CONFIG_CAN_AT91)             +=3D at91_can.o
>>>  obj-$(CONFIG_CAN_TI_HECC)  +=3D ti_hecc.o
>>>  obj-$(CONFIG_CAN_MCP251X)  +=3D mcp251x.o
>>> diff --git a/drivers/net/can/c_can/Kconfig
>>> b/drivers/net/can/c_can/Kconfig new file mode 100644 index
>>> 0000000..ffb9773
>>> --- /dev/null
>>> +++ b/drivers/net/can/c_can/Kconfig
>>> @@ -0,0 +1,15 @@
>>> +menuconfig CAN_C_CAN
>>> +   tristate "Bosch C_CAN devices"
>>> +   depends on CAN_DEV && HAS_IOMEM
>>> +
>>> +if CAN_C_CAN
>>> +
>>> +config CAN_C_CAN_PLATFORM
>>> +   tristate "Generic Platform Bus based C_CAN driver"
>>> +   ---help---
>>> +     This driver adds support for the C_CAN chips connected to
>>> +     the "platform bus" (Linux abstraction for directly to the
>>> +     processor attached devices) which can be found on various
>>> +     boards from ST Microelectronics (http://www.st.com)
>>> +     like the SPEAr1310 and SPEAr320 evaluation boards.
>>> +endif
>>> diff --git a/drivers/net/can/c_can/Makefile
>>> b/drivers/net/can/c_can/Makefile new file mode 100644 index
>>> 0000000..9273f6d
>>> --- /dev/null
>>> +++ b/drivers/net/can/c_can/Makefile
>>> @@ -0,0 +1,8 @@
>>> +#
>>> +#  Makefile for the Bosch C_CAN controller drivers.
>>> +#
>>> +
>>> +obj-$(CONFIG_CAN_C_CAN) +=3D c_can.o
>>> +obj-$(CONFIG_CAN_C_CAN_PLATFORM) +=3D c_can_platform.o
>>> +
>>> +ccflags-$(CONFIG_CAN_DEBUG_DEVICES) :=3D -DDEBUG
>>> diff --git a/drivers/net/can/c_can/c_can.c
>>> b/drivers/net/can/c_can/c_can.c new file mode 100644 index
>>> 0000000..7ef4aa9
>>> --- /dev/null
>>> +++ b/drivers/net/can/c_can/c_can.c
>>> @@ -0,0 +1,993 @@
>>> +/*
>>> + * CAN bus driver for Bosch C_CAN controller
>>> + *
>>> + * Copyright (C) 2010 ST Microelectronics
>>> + * Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
>>> + *
>>> + * Borrowed heavily from the C_CAN driver originally written by:
>>> + * Copyright (C) 2007
>>> + * - Sascha Hauer, Marc Kleine-Budde, Pengutronix
>>> +<s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
>>> + * - Simon Kallweit, intefo AG <simon.kallweit-+G9qxTFKJT/tRgLqZ5aouw@public.gmane.org>
>>> + *
>>> + * TX and RX NAPI implementation has been borrowed from at91 CAN
>>> +driver
>>> + * written by:
>>> + * Copyright
>>> + * (C) 2007 by Hans J. Koch <hjk-vqZO0P4V72/QD6PfKP4TzA@public.gmane.org>
>>> + * (C) 2008, 2009 by Marc Kleine-Budde <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
>>> + *
>>> + * Bosch C_CAN controller is compliant to CAN protocol version 2.0
>> part A and B.
>>> + * Bosch C_CAN user manual can be obtained from:
>>> + *
>> http://www.semiconductors.bosch.de/media/en/pdf/ipmodules_1/c_can/
>>> + * users_manual_c_can.pdf
>>> + *
>>> + * This file is licensed under the terms of the GNU General Public
>>> + * License version 2. This program is licensed "as is" without any
>>> + * warranty of any kind, whether express or implied.
>>> + */
>>> +
>>> +#include <linux/kernel.h>
>>> +#include <linux/version.h>
>>> +#include <linux/module.h>
>>> +#include <linux/interrupt.h>
>>> +#include <linux/delay.h>
>>> +#include <linux/netdevice.h>
>>> +#include <linux/if_arp.h>
>>> +#include <linux/if_ether.h>
>>> +#include <linux/list.h>
>>> +#include <linux/delay.h>
>>> +#include <linux/io.h>
>>> +
>>> +#include <linux/can.h>
>>> +#include <linux/can/dev.h>
>>> +#include <linux/can/error.h>
>>> +
>>> +#include "c_can.h"
>>> +
>>> +static struct can_bittiming_const c_can_bittiming_const =3D {
>>> +   .name =3D KBUILD_MODNAME,
>>> +   .tseg1_min =3D 2,         /* Time segment 1 =3D prop_seg + phase_=
seg1
>> */
>>> +   .tseg1_max =3D 16,
>>> +   .tseg2_min =3D 1,         /* Time segment 2 =3D phase_seg2 */
>>> +   .tseg2_max =3D 8,
>>> +   .sjw_max =3D 4,
>>> +   .brp_min =3D 1,
>>> +   .brp_max =3D 1024,        /* 6-bit BRP field + 4-bit BRPE field*/=

>>> +   .brp_inc =3D 1,
>>> +};
>>> +
>>> +static inline int get_tx_next_msg_obj(const struct c_can_priv *priv)=

>>> +{
>>> +   return (priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) +
>>> +                   C_CAN_MSG_OBJ_TX_FIRST;
>>> +}
>>> +
>>> +static inline int get_tx_echo_msg_obj(const struct c_can_priv *priv)=

>>> +{
>>> +   return (priv->tx_echo & C_CAN_NEXT_MSG_OBJ_MASK) +
>>> +                   C_CAN_MSG_OBJ_TX_FIRST;
>>> +}
>>> +
>>> +static u32 c_can_read_reg32(struct c_can_priv *priv, void *reg) {
>>> +   u32 val =3D priv->read_reg(priv, reg);
>>> +   val |=3D ((u32) priv->read_reg(priv, reg + 2)) << 16;
>>> +   return val;
>>> +}
>>> +
>>> +static void c_can_enable_all_interrupts(struct c_can_priv *priv,
>>> +                                           int enable)
>>> +{
>>> +   unsigned int cntrl_save =3D priv->read_reg(priv,
>>> +                                           &priv->regs->control);
>>> +
>>> +   if (enable)
>>> +           cntrl_save |=3D (CONTROL_SIE | CONTROL_EIE | CONTROL_IE);=

>>> +   else
>>> +           cntrl_save &=3D ~(CONTROL_EIE | CONTROL_IE | CONTROL_SIE)=
;
>>> +
>>> +   priv->write_reg(priv, &priv->regs->control, cntrl_save); }
>>> +
>>> +static inline int c_can_check_busy_status(struct c_can_priv *priv,
>>> +int iface) {
>>> +   int count =3D MIN_TIMEOUT_VALUE;
>>> +
>>> +   while (count && priv->read_reg(priv,
>>> +                           &priv->regs->ifregs[iface].com_req) &
>>> +                           IF_COMR_BUSY) {
>>> +           count--;
>>> +           udelay(1);
>>> +   }
>>> +
>>> +   return count;
>>
>> it's an unusual return value...maybe return 0 on success and -EBUSY
>> otherwise?
>=20
> Hmm.. this will add the checking MIN_TIMEOUT_VALUE against 0 here,

You mean check "count" against 0 here...

> instead of "c_can_object_get" and "c_can_object_put" routines.
> If you persist we can add the same in V7 though.. :)

We have a function "c_can_check_busy_status()". What does it return? The
name doesn't tell me. I think it would be more clear if you just rename
the function to "c_can_is_busy()" or "c_can_object_is_busy()".

The you can use it like this:

if (c_can_is_busy()) {
	printk("mailbox still busy!\n");
	return -EWHATEVER;
}

>=20
>>> +}
>>> +
>>> +static inline void c_can_object_get(struct net_device *dev,
>>> +                                   int iface, int objno, int mask)
>>> +{
>>> +   int ret;
>>> +   struct c_can_priv *priv =3D netdev_priv(dev);
>>> +
>>> +   /*
>>> +    * As per specs, after writting the message object number in the
>>> +    * IF command request register the transfer b/w interface
>>> +    * register and message RAM must be complete in 6 CAN-CLK
>>> +    * period.
>>> +    */
>>> +   priv->write_reg(priv, &priv->regs->ifregs[iface].com_mask,
>>> +                   IFX_WRITE_LOW_16BIT(mask));
>>> +   priv->write_reg(priv, &priv->regs->ifregs[iface].com_req,
>>> +                   IFX_WRITE_LOW_16BIT(objno));
>>> +
>>> +   ret =3D c_can_check_busy_status(priv, iface);
>>> +   if (!ret)
>>> +           netdev_err(dev, "timed out in object get\n"); }

There's no error handling for the object is busy case....


[...]

>>> diff --git a/drivers/net/can/c_can/c_can.h
>>> b/drivers/net/can/c_can/c_can.h new file mode 100644 index
>>> 0000000..bd094e6
>>> --- /dev/null
>>> +++ b/drivers/net/can/c_can/c_can.h
>>> @@ -0,0 +1,230 @@
>>> +/*
>>> + * CAN bus driver for Bosch C_CAN controller
>>> + *
>>> + * Copyright (C) 2010 ST Microelectronics
>>> + * Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
>>> + *
>>> + * Borrowed heavily from the C_CAN driver originally written by:
>>> + * Copyright (C) 2007
>>> + * - Sascha Hauer, Marc Kleine-Budde, Pengutronix
>>> +<s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
>>> + * - Simon Kallweit, intefo AG <simon.kallweit-+G9qxTFKJT/tRgLqZ5aouw@public.gmane.org>
>>> + *
>>> + * Bosch C_CAN controller is compliant to CAN protocol version 2.0
>> part A and B.
>>> + * Bosch C_CAN user manual can be obtained from:
>>> + *
>> http://www.semiconductors.bosch.de/media/en/pdf/ipmodules_1/c_can/
>>> + * users_manual_c_can.pdf
>>> + *
>>> + * This file is licensed under the terms of the GNU General Public
>>> + * License version 2. This program is licensed "as is" without any
>>> + * warranty of any kind, whether express or implied.
>>> + */
>>> +
>>> +#ifndef C_CAN_H
>>> +#define C_CAN_H
>>> +
>>> +/* control register */
>>> +#define CONTROL_TEST               BIT(7)
>>> +#define CONTROL_CCE                BIT(6)
>>> +#define CONTROL_DISABLE_AR BIT(5)
>>> +#define CONTROL_ENABLE_AR  (0 << 5)
>>> +#define CONTROL_EIE                BIT(3)
>>> +#define CONTROL_SIE                BIT(2)
>>> +#define CONTROL_IE         BIT(1)
>>> +#define CONTROL_INIT               BIT(0)
>>> +
>>> +/* test register */
>>> +#define TEST_RX                    BIT(7)
>>> +#define TEST_TX1           BIT(6)
>>> +#define TEST_TX2           BIT(5)
>>> +#define TEST_LBACK         BIT(4)
>>> +#define TEST_SILENT                BIT(3)
>>> +#define TEST_BASIC         BIT(2)
>>> +
>>> +/* status register */
>>> +#define STATUS_BOFF                BIT(7)
>>> +#define STATUS_EWARN               BIT(6)
>>> +#define STATUS_EPASS               BIT(5)
>>> +#define STATUS_RXOK                BIT(4)
>>> +#define STATUS_TXOK                BIT(3)
>>> +
>>> +/* error counter register */
>>> +#define ERR_CNT_TEC_MASK   0xff
>>> +#define ERR_CNT_TEC_SHIFT  0
>>> +#define ERR_CNT_REC_SHIFT  8
>>> +#define ERR_CNT_REC_MASK   (0x7f << ERR_CNT_REC_SHIFT)
>>> +#define ERR_CNT_RP_SHIFT   15
>>> +#define ERR_CNT_RP_MASK            (0x1 << ERR_CNT_RP_SHIFT)
>>> +
>>> +/* bit-timing register */
>>> +#define BTR_BRP_MASK               0x3f
>>> +#define BTR_BRP_SHIFT              0
>>> +#define BTR_SJW_SHIFT              6
>>> +#define BTR_SJW_MASK               (0x3 << BTR_SJW_SHIFT)
>>> +#define BTR_TSEG1_SHIFT            8
>>> +#define BTR_TSEG1_MASK             (0xf << BTR_TSEG1_SHIFT)
>>> +#define BTR_TSEG2_SHIFT            12
>>> +#define BTR_TSEG2_MASK             (0x7 << BTR_TSEG2_SHIFT)
>>> +
>>> +/* brp extension register */
>>> +#define BRP_EXT_BRPE_MASK  0x0f
>>> +#define BRP_EXT_BRPE_SHIFT 0
>>> +
>>> +/* IFx command request */
>>> +#define IF_COMR_BUSY               BIT(15)
>>> +
>>> +/* IFx command mask */
>>> +#define IF_COMM_WR         BIT(7)
>>> +#define IF_COMM_MASK               BIT(6)
>>> +#define IF_COMM_ARB                BIT(5)
>>> +#define IF_COMM_CONTROL            BIT(4)
>>> +#define IF_COMM_CLR_INT_PND        BIT(3)
>>> +#define IF_COMM_TXRQST             BIT(2)
>>> +#define IF_COMM_DATAA              BIT(1)
>>> +#define IF_COMM_DATAB              BIT(0)
>>> +#define IF_COMM_ALL                (IF_COMM_MASK | IF_COMM_ARB | \
>>> +                           IF_COMM_CONTROL | IF_COMM_TXRQST | \
>>> +                           IF_COMM_DATAA | IF_COMM_DATAB)
>>> +
>>> +/* IFx arbitration */
>>> +#define IF_ARB_MSGVAL              BIT(15)
>>> +#define IF_ARB_MSGXTD              BIT(14)
>>> +#define IF_ARB_TRANSMIT            BIT(13)
>>> +
>>> +/* IFx message control */
>>> +#define IF_MCONT_NEWDAT            BIT(15)
>>> +#define IF_MCONT_MSGLST            BIT(14)
>>> +#define IF_MCONT_CLR_MSGLST        (0 << 14)
>>> +#define IF_MCONT_INTPND            BIT(13)
>>> +#define IF_MCONT_UMASK             BIT(12)
>>> +#define IF_MCONT_TXIE              BIT(11)
>>> +#define IF_MCONT_RXIE              BIT(10)
>>> +#define IF_MCONT_RMTEN             BIT(9)
>>> +#define IF_MCONT_TXRQST            BIT(8)
>>> +#define IF_MCONT_EOB               BIT(7)
>>> +#define IF_MCONT_DLC_MASK  0xf
>>> +
>>> +/*
>>> + * IFx register masks:
>>> + * allow easy operation on 16-bit registers when the
>>> + * argument is 32-bit instead
>>> + */
>>> +#define IFX_WRITE_LOW_16BIT(x)     ((x) & 0xFFFF)
>>> +#define IFX_WRITE_HIGH_16BIT(x)    (((x) & 0xFFFF0000) >> 16)
>>> +
>>> +/* message object split */
>>> +#define C_CAN_NO_OF_OBJECTS        32
>>> +#define C_CAN_MSG_OBJ_RX_NUM       16
>>> +#define C_CAN_MSG_OBJ_TX_NUM       16
>>> +
>>> +#define C_CAN_MSG_OBJ_RX_FIRST     1
>>> +#define C_CAN_MSG_OBJ_RX_LAST      (C_CAN_MSG_OBJ_RX_FIRST + \
>>> +                           C_CAN_MSG_OBJ_RX_NUM - 1)
>>> +
>>> +#define C_CAN_MSG_OBJ_TX_FIRST     (C_CAN_MSG_OBJ_RX_LAST + 1)
>>> +#define C_CAN_MSG_OBJ_TX_LAST      (C_CAN_MSG_OBJ_TX_FIRST + \
>>> +                           C_CAN_MSG_OBJ_TX_NUM - 1)
>>> +
>>> +#define C_CAN_MSG_OBJ_RX_SPLIT     9
>>> +#define C_CAN_MSG_RX_LOW_LAST      (C_CAN_MSG_OBJ_RX_SPLIT - 1)
>>> +
>>> +#define C_CAN_NEXT_MSG_OBJ_MASK    (C_CAN_MSG_OBJ_TX_NUM - 1)
>>> +#define RECEIVE_OBJECT_BITS        0x0000ffff
>>> +
>>> +/* status interrupt */
>>> +#define STATUS_INTERRUPT   0x8000
>>> +
>>> +/* global interrupt masks */
>>> +#define ENABLE_ALL_INTERRUPTS      1
>>> +#define DISABLE_ALL_INTERRUPTS     0
>>> +
>>> +/* minimum timeout for checking BUSY status */
>>> +#define MIN_TIMEOUT_VALUE  6
>>> +
>>> +/* napi related */
>>> +#define C_CAN_NAPI_WEIGHT  C_CAN_MSG_OBJ_RX_NUM
>>> +
>>> +/* c_can IF registers */
>>> +struct c_can_if_regs {
>>> +   u16 com_req;
>>> +   u16 com_mask;
>>> +   u16 mask1;
>>> +   u16 mask2;
>>> +   u16 arb1;
>>> +   u16 arb2;
>>> +   u16 msg_cntrl;
>>> +   u16 data[4];
>>> +   u16 _reserved[13];
>>> +};
>>> +
>>> +/* c_can hardware registers */
>>> +struct c_can_regs {
>>> +   u16 control;
>>> +   u16 status;
>>> +   u16 err_cnt;
>>> +   u16 btr;
>>> +   u16 interrupt;
>>> +   u16 test;
>>> +   u16 brp_ext;
>>> +   u16 _reserved1;
>>> +   struct c_can_if_regs ifregs[2]; /* [0] =3D IF1 and [1] =3D IF2 */=

>>> +   u16 _reserved2[8];
>>> +   u16 txrqst1;
>>> +   u16 txrqst2;
>>> +   u16 _reserved3[6];
>>> +   u16 newdat1;
>>> +   u16 newdat2;
>>> +   u16 _reserved4[6];
>>> +   u16 intpnd1;
>>> +   u16 intpnd2;
>>> +   u16 _reserved5[6];
>>> +   u16 msgval1;
>>> +   u16 msgval2;
>>> +   u16 _reserved6[6];
>>> +};
>>> +
>>> +/* c_can lec values */
>>> +enum c_can_lec_type {
>>> +   LEC_NO_ERROR =3D 0,
>>> +   LEC_STUFF_ERROR,
>>> +   LEC_FORM_ERROR,
>>> +   LEC_ACK_ERROR,
>>> +   LEC_BIT1_ERROR,
>>> +   LEC_BIT0_ERROR,
>>> +   LEC_CRC_ERROR,
>>> +   LEC_UNUSED,
>>> +};
>>> +
>>> +/*
>>> + * c_can error types:
>>> + * Bus errors (BUS_OFF, ERROR_WARNING, ERROR_PASSIVE) are supported
>>> +*/ enum c_can_bus_error_types {
>>> +   C_CAN_NO_ERROR =3D 0,
>>> +   C_CAN_BUS_OFF,
>>> +   C_CAN_ERROR_WARNING,
>>> +   C_CAN_ERROR_PASSIVE,
>>> +};
>>
>> nitpick: are the defines, enums and structs needed in more than one c
>> file? If not, please move them into the c-file where they are used.
>=20
> Well most of the strcuts/defines are useful in both `c_can.c` and
> `c_can_platform.c`, but I will explore how to separate the rest in
> the respective c-files. But inititally we agreed to a *sja1000* like
> approach and hence this placement in h-file.

Yes, your're right.

But keeping only in one .c or .h file used things out of the .h file is
a good rule for cleaner code :)

regards, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig7D04BF5025E182EEC5C1C0AC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEUEARECAAYFAk1Tr64ACgkQjTAFq1RaXHPRkACYxlXv8PmqI0ZcAe8aHoxjHxZz
uwCfR2xmX6zzI7O2bvQyJSnp3wkpafA=
=ZkFV
-----END PGP SIGNATURE-----

--------------enig7D04BF5025E182EEC5C1C0AC--

--===============7178123171881246219==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============7178123171881246219==--

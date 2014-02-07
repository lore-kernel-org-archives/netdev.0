From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: xilinx CAN controller support.
Date: Fri, 07 Feb 2014 10:37:36 +0100
Message-ID: <52F4A960.10809@pengutronix.de>
References: <6c2bcce0-9897-4d1d-a8b9-47924e40f73c@VA3EHSMHS008.ehs.local> <52F382D5.6090706@pengutronix.de> <8b4dad82-c72a-4e1f-b1af-b8c7964bbf24@TX2EHSMHS043.ehs.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="PKnUmcdjFF5DwOLgDARra9urN512C4oD2"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>,
	"wg@grandegger.com" <wg@grandegger.com>,
	Michal Simek <michals@xilinx.com>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <8b4dad82-c72a-4e1f-b1af-b8c7964bbf24@TX2EHSMHS043.ehs.local>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--PKnUmcdjFF5DwOLgDARra9urN512C4oD2
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 02/07/2014 09:42 AM, Appana Durga Kedareswara Rao wrote:
>>> ---
>>> This patch is rebased on the 3.14 rc1 kernel.
>>> ---
>>>  .../devicetree/bindings/net/can/xilinx_can.txt     |   43 +
>>>  drivers/net/can/Kconfig                            |    8 +
>>>  drivers/net/can/Makefile                           |    1 +
>>>  drivers/net/can/xilinx_can.c                       | 1150 ++++++++++=
++++++++++
>>>  4 files changed, 1202 insertions(+), 0 deletions(-)  create mode
>>> 100644 Documentation/devicetree/bindings/net/can/xilinx_can.txt
>>>  create mode 100644 drivers/net/can/xilinx_can.c
>>>
>>> diff --git a/Documentation/devicetree/bindings/net/can/xilinx_can.txt=

>>> b/Documentation/devicetree/bindings/net/can/xilinx_can.txt
>>> new file mode 100644
>>> index 0000000..34f9643
>>> --- /dev/null
>>> +++ b/Documentation/devicetree/bindings/net/can/xilinx_can.txt
>>> @@ -0,0 +1,43 @@
>>> +Xilinx Axi CAN/Zynq CANPS controller Device Tree Bindings
>>> +---------------------------------------------------------
>>> +
>>> +Required properties:
>>> +- compatible               : Should be "xlnx,zynq-can-1.00.a" for Zy=
nq
>> CAN
>>> +                     controllers and "xlnx,axi-can-1.00.a" for Axi C=
AN
>>> +                     controllers.
>>> +- reg                      : Physical base address and size of the A=
xi CAN/Zynq
>>> +                     CANPS registers map.
>>> +- interrupts               : Property with a value describing the in=
terrupt
>>> +                     number.
>>> +- interrupt-parent : Must be core interrupt controller
>>> +- clock-names              : List of input clock names - "ref_clk",
>> "aper_clk"
>>> +                     (See clock bindings for details. Two clocks are=

>>> +                      required for Zynq CAN. For Axi CAN
>>> +                      case it is one(ref_clk)).
>>> +- clocks           : Clock phandles (see clock bindings for details)=
=2E
>>> +- xlnx,can-tx-dpth : Can Tx fifo depth (Required for Axi CAN).
>>> +- xlnx,can-rx-dpth : Can Rx fifo depth (Required for Axi CAN).
>>> +
>>> +
>>> +Example:
>>> +
>>> +For Zynq CANPS Dts file:
>>> +   zynq_can_0: zynq-can@e0008000 {
>>> +                   compatible =3D "xlnx,zynq-can-1.00.a";
>>> +                   clocks =3D <&clkc 19>, <&clkc 36>;
>>> +                   clock-names =3D "ref_clk", "aper_clk";
>>> +                   reg =3D <0xe0008000 0x1000>;
>>> +                   interrupts =3D <0 28 4>;
>>> +                   interrupt-parent =3D <&intc>;
>>
>> Above xlnx,can-{rx,tx}-dpth is mentioned as required, but it's not in =
the
>> Zynq example.
>=20
> One of the Difference b/w the AXI CAN and zynq CAN is in AXI CAN the fi=
fo depth(tx,rx)
> Is user configurable. But in case of ZYNQ CAN  the fifo depth  is fixed=
 for tx and rx fifo's(64)
> Xlnx,can-{rx,tx}-dpth is required only for AXI CAN case it is not requi=
red for zynq CAN.
> That's why didn't putted that property in device tree.

The device tree should be a hardware only description and should not
hold any user configurable data. Please split your patch into two
patches. The first one should add the driver with a fixed fifo size
(e.g. 0x40) for the AXI, too. The second patch should make the fifo
configurable via device tree.

If it's acceptable to describe the fifo usage by device tree, I'd like
to make it a generic CAN driver option. But we have to look around, e.g.
what the Ethernet driver use to configure their hardware.

>=20
>>
>>> +           };
>>> +For Axi CAN Dts file:
>>> +   axi_can_0: axi-can@40000000 {
>>> +                   compatible =3D "xlnx,axi-can-1.00.a";
>>> +                   clocks =3D <&clkc 0>;
>>> +                   clock-names =3D "ref_clk" ;
>>> +                   reg =3D <0x40000000 0x10000>;
>>> +                   interrupt-parent =3D <&intc>;
>>> +                   interrupts =3D <0 59 1>;
>>> +                   xlnx,can-tx-dpth =3D <0x40>;
>>> +                   xlnx,can-rx-dpth =3D <0x40>;
>>> +           };
>>> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig index
>>> d447b88..2344fb5 100644
>>> --- a/drivers/net/can/Kconfig
>>> +++ b/drivers/net/can/Kconfig
>>> @@ -125,6 +125,14 @@ config CAN_GRCAN
>>>       endian syntheses of the cores would need some modifications on
>>>       the hardware level to work.
>>>
>>> +config CAN_XILINXCAN
>>> +   tristate "Xilinx CAN"
>>> +   depends on ARCH_ZYNQ || MICROBLAZE
>>> +   default n
>>
>> "default n" is default, please remove.
>>
>=20
> Ok
>=20
>>> +   ---help---
>>> +     Xilinx CAN driver. This driver supports both soft AXI CAN IP an=
d
>>> +     Zynq CANPS IP.
>>> +
>>>  source "drivers/net/can/mscan/Kconfig"
>>>
>>>  source "drivers/net/can/sja1000/Kconfig"
>>> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile inde=
x
>>> c744039..0b8e11e 100644
>>> --- a/drivers/net/can/Makefile
>>> +++ b/drivers/net/can/Makefile
>>> @@ -25,5 +25,6 @@ obj-$(CONFIG_CAN_JANZ_ICAN3)      +=3D janz-
>> ican3.o
>>>  obj-$(CONFIG_CAN_FLEXCAN)  +=3D flexcan.o
>>>  obj-$(CONFIG_PCH_CAN)              +=3D pch_can.o
>>>  obj-$(CONFIG_CAN_GRCAN)            +=3D grcan.o
>>> +obj-$(CONFIG_CAN_XILINXCAN)        +=3D xilinx_can.o
>>>
>>>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) :=3D -DDEBUG diff --git
>>> a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_can.c new fil=
e
>>> mode 100644 index 0000000..c1b2b9d
>>> --- /dev/null
>>> +++ b/drivers/net/can/xilinx_can.c
>>> @@ -0,0 +1,1150 @@
>>> +/* Xilinx CAN device driver
>>> + *
>>> + * Copyright (C) 2012 - 2014 Xilinx, Inc.
>>> + * Copyright (C) 2009 PetaLogix. All rights reserved.
>>> + *
>>> + * Description:
>>> + * This driver is developed for Axi CAN IP and for Zynq CANPS Contro=
ller.
>>> + * This program is free software: you can redistribute it and/or
>>> +modify
>>> + * it under the terms of the GNU General Public License as published=

>>> +by
>>> + * the Free Software Foundation, either version 2 of the License, or=

>>> + * (at your option) any later version.
>>> + *
>>> + * This program is distributed in the hope that it will be useful,
>>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>>> + * GNU General Public License for more details.
>>> + *
>>> + * You should have received a copy of the GNU General Public License=

>>> + * along with this program.  If not, see <http://www.gnu.org/license=
s/>.
>>> + */
>>> +
>>> +#include <linux/clk.h>
>>> +#include <linux/errno.h>
>>> +#include <linux/init.h>
>>> +#include <linux/interrupt.h>
>>> +#include <linux/io.h>
>>> +#include <linux/kernel.h>
>>> +#include <linux/module.h>
>>> +#include <linux/netdevice.h>
>>> +#include <linux/of.h>
>>> +#include <linux/platform_device.h>
>>> +#include <linux/skbuff.h>
>>> +#include <linux/string.h>
>>> +#include <linux/types.h>
>>> +#include <linux/can/dev.h>
>>> +#include <linux/can/error.h>
>>> +#include <linux/can/led.h>
>>> +
>>> +#define DRIVER_NAME        "XILINX_CAN"
>>> +
>>> +/* CAN registers set */
>>> +#define XCAN_SRR_OFFSET                    0x00 /* Software reset */=

>>> +#define XCAN_MSR_OFFSET                    0x04 /* Mode select */
>>> +#define XCAN_BRPR_OFFSET           0x08 /* Baud rate prescaler */
>>> +#define XCAN_BTR_OFFSET                    0x0C /* Bit timing */
>>> +#define XCAN_ECR_OFFSET                    0x10 /* Error counter */
>>> +#define XCAN_ESR_OFFSET                    0x14 /* Error status */
>>> +#define XCAN_SR_OFFSET                     0x18 /* Status */
>>> +#define XCAN_ISR_OFFSET                    0x1C /* Interrupt status =
*/
>>> +#define XCAN_IER_OFFSET                    0x20 /* Interrupt enable =
*/
>>> +#define XCAN_ICR_OFFSET                    0x24 /* Interrupt clear *=
/
>>> +#define XCAN_TXFIFO_ID_OFFSET              0x30 /* TX FIFO ID */
>>> +#define XCAN_TXFIFO_DLC_OFFSET             0x34 /* TX FIFO DLC */
>>> +#define XCAN_TXFIFO_DW1_OFFSET             0x38 /* TX FIFO Data
>> Word 1 */
>>> +#define XCAN_TXFIFO_DW2_OFFSET             0x3C /* TX FIFO Data
>> Word 2 */
>>> +#define XCAN_RXFIFO_ID_OFFSET              0x50 /* RX FIFO ID */
>>> +#define XCAN_RXFIFO_DLC_OFFSET             0x54 /* RX FIFO DLC */
>>> +#define XCAN_RXFIFO_DW1_OFFSET             0x58 /* RX FIFO Data
>> Word 1 */
>>> +#define XCAN_RXFIFO_DW2_OFFSET             0x5C /* RX FIFO Data
>> Word 2 */
>>> +
>>> +/* CAN register bit masks - XCAN_<REG>_<BIT>_MASK */
>>> +#define XCAN_SRR_CEN_MASK          0x00000002 /* CAN enable */
>>> +#define XCAN_SRR_RESET_MASK                0x00000001 /* Soft Reset =
the
>> CAN core */
>>> +#define XCAN_MSR_LBACK_MASK                0x00000002 /* Loop back
>> mode select */
>>> +#define XCAN_MSR_SLEEP_MASK                0x00000001 /* Sleep mode
>> select */
>>> +#define XCAN_BRPR_BRP_MASK         0x000000FF /* Baud rate
>> prescaler */
>>> +#define XCAN_BTR_SJW_MASK          0x00000180 /* Synchronous
>> jump width */
>>> +#define XCAN_BTR_TS2_MASK          0x00000070 /* Time segment
>> 2 */
>>> +#define XCAN_BTR_TS1_MASK          0x0000000F /* Time segment
>> 1 */
>>> +#define XCAN_ECR_REC_MASK          0x0000FF00 /* Receive error
>> counter */
>>> +#define XCAN_ECR_TEC_MASK          0x000000FF /* Transmit error
>> counter */
>>> +#define XCAN_ESR_ACKER_MASK                0x00000010 /* ACK error *=
/
>>> +#define XCAN_ESR_BERR_MASK         0x00000008 /* Bit error */
>>> +#define XCAN_ESR_STER_MASK         0x00000004 /* Stuff error */
>>> +#define XCAN_ESR_FMER_MASK         0x00000002 /* Form error */
>>> +#define XCAN_ESR_CRCER_MASK                0x00000001 /* CRC error *=
/
>>> +#define XCAN_SR_TXFLL_MASK         0x00000400 /* TX FIFO is full
>> */
>>> +#define XCAN_SR_ESTAT_MASK         0x00000180 /* Error status */
>>> +#define XCAN_SR_ERRWRN_MASK                0x00000040 /* Error warni=
ng
>> */
>>> +#define XCAN_SR_NORMAL_MASK                0x00000008 /* Normal mode=

>> */
>>> +#define XCAN_SR_LBACK_MASK         0x00000002 /* Loop back
>> mode */
>>> +#define XCAN_SR_CONFIG_MASK                0x00000001 /* Configurati=
on
>> mode */
>>> +#define XCAN_IXR_TXFEMP_MASK               0x00004000 /* TX FIFO Emp=
ty
>> */
>>> +#define XCAN_IXR_WKUP_MASK         0x00000800 /* Wake up
>> interrupt */
>>> +#define XCAN_IXR_SLP_MASK          0x00000400 /* Sleep
>> interrupt */
>>> +#define XCAN_IXR_BSOFF_MASK                0x00000200 /* Bus off
>> interrupt */
>>> +#define XCAN_IXR_ERROR_MASK                0x00000100 /* Error inter=
rupt
>> */
>>> +#define XCAN_IXR_RXNEMP_MASK               0x00000080 /* RX FIFO
>> NotEmpty intr */
>>> +#define XCAN_IXR_RXOFLW_MASK               0x00000040 /* RX FIFO
>> Overflow intr */
>>> +#define XCAN_IXR_RXOK_MASK         0x00000010 /* Message
>> received intr */
>>> +#define XCAN_IXR_TXOK_MASK         0x00000002 /* TX successful
>> intr */
>>> +#define XCAN_IXR_ARBLST_MASK               0x00000001 /* Arbitration=

>> lost intr */
>>> +#define XCAN_IDR_ID1_MASK          0xFFE00000 /* Standard msg
>> identifier */
>>> +#define XCAN_IDR_SRR_MASK          0x00100000 /* Substitute
>> remote TXreq */
>>> +#define XCAN_IDR_IDE_MASK          0x00080000 /* Identifier
>> extension */
>>> +#define XCAN_IDR_ID2_MASK          0x0007FFFE /* Extended
>> message ident */
>>> +#define XCAN_IDR_RTR_MASK          0x00000001 /* Remote TX
>> request */
>>> +#define XCAN_DLCR_DLC_MASK         0xF0000000 /* Data length
>> code */
>>> +
>>> +#define XCAN_INTR_ALL              (XCAN_IXR_TXOK_MASK |
>> XCAN_IXR_BSOFF_MASK |\
>>> +                            XCAN_IXR_WKUP_MASK |
>> XCAN_IXR_SLP_MASK | \
>>> +                            XCAN_IXR_RXNEMP_MASK |
>> XCAN_IXR_ERROR_MASK | \
>>> +                            XCAN_IXR_ARBLST_MASK |
>> XCAN_IXR_RXOK_MASK)
>>> +
>>> +/* CAN register bit shift - XCAN_<REG>_<BIT>_SHIFT */
>>> +#define XCAN_BTR_SJW_SHIFT         7  /* Synchronous jump width
>> */
>>> +#define XCAN_BTR_TS2_SHIFT         4  /* Time segment 2 */
>>> +#define XCAN_IDR_ID1_SHIFT         21 /* Standard Messg
>> Identifier */
>>> +#define XCAN_IDR_ID2_SHIFT         1  /* Extended Message
>> Identifier */
>>> +#define XCAN_DLCR_DLC_SHIFT                28 /* Data length code */=

>>> +#define XCAN_ESR_REC_SHIFT         8  /* Rx Error Count */
>>> +
>>> +/* CAN frame length constants */
>>> +#define XCAN_ECHO_SKB_MAX          64
>>> +#define XCAN_NAPI_WEIGHT           64
>>> +#define XCAN_FRAME_MAX_DATA_LEN            8
>>> +#define XCAN_TIMEOUT                       (50 * HZ)
>>> +
>>> +/**
>>> + * struct xcan_priv - This definition define CAN driver instance
>>> + * @can:                   CAN private data structure.
>>> + * @open_time:                     For holding timeout values
>>> + * @waiting_ech_skb_index: Pointer for skb
>>> + * @ech_skb_next:          This tell the next packet in the queue
>>> + * @waiting_ech_skb_num:   Gives the number of packets waiting
>>> + * @xcan_echo_skb_max_tx:  Maximum number packets the driver
>> can send
>>> + * @xcan_echo_skb_max_rx:  Maximum number packets the driver
>> can receive
>>> + * @napi:                  NAPI structure
>>> + * @ech_skb_lock:          For spinlock purpose
>>> + * @read_reg:                      For reading data from CAN registe=
rs
>>> + * @write_reg:                     For writing data to CAN registers=

>>> + * @dev:                   Network device data structure
>>> + * @reg_base:                      Ioremapped address to registers
>>> + * @irq_flags:                     For request_irq()
>>> + * @aperclk:                       Pointer to struct clk
>>> + * @devclk:                        Pointer to struct clk
>>> + */
>>> +struct xcan_priv {
>>> +   struct can_priv can;
>>> +   int open_time;
>>> +   int waiting_ech_skb_index;
>>> +   int ech_skb_next;
>>> +   int waiting_ech_skb_num;
>>> +   int xcan_echo_skb_max_tx;
>>> +   int xcan_echo_skb_max_rx;
>>> +   struct napi_struct napi;
>>> +   spinlock_t ech_skb_lock;
>>> +   u32 (*read_reg)(const struct xcan_priv *priv, int reg);
>>> +   void (*write_reg)(const struct xcan_priv *priv, int reg, u32 val)=
;
>>
>> Why do you have {read,write}_reg function here?
>=20
> xcan_write_reg/xcan_read_reg is used because this IP is also in big end=
ian version.
> We won't support It but if someone else want to support that's why putt=
ed these function's here.
>=20
> If you are not ok with this will remove.

As far as I know, the kernel will either be little or big endian, so we
can make a use of an ifdef for here, if we support LE and BE.

>=20
>>
>>> +   struct net_device *dev;
>>> +   void __iomem *reg_base;
>>> +   unsigned long irq_flags;
>>> +   struct clk *aperclk;
>>> +   struct clk *devclk;
>>> +};
>>> +
>>> +/* CAN Bittiming constants as per Xilinx CAN specs */ static struct
>>> +can_bittiming_const xcan_bittiming_const =3D {

Please make it "static const struct"

>>> +   .name =3D DRIVER_NAME,
>>> +   .tseg1_min =3D 1,
>>> +   .tseg1_max =3D 16,
>>> +   .tseg2_min =3D 1,
>>> +   .tseg2_max =3D 8,
>>> +   .sjw_max =3D 4,
>>> +   .brp_min =3D 1,
>>> +   .brp_max =3D 256,
>>> +   .brp_inc =3D 1,
>>> +};
>>> +
>>> +/**
>>> + * xcan_write_reg - Write a value to the device register
>>> + * @priv:  Driver private data structure
>>> + * @reg:   Register offset
>>> + * @val:   Value to write at the Register offset
>>> + *
>>> + * Write data to the paricular CAN register  */ static void
>>> +xcan_write_reg(const struct xcan_priv *priv, int reg, u32 val) {
>>> +   writel(val, priv->reg_base + reg);
>>> +}
>>> +
>>> +/**
>>> + * xcan_read_reg - Read a value from the device register
>>> + * @priv:  Driver private data structure
>>> + * @reg:   Register offset
>>> + *
>>> + * Read data from the particular CAN register
>>> + * Return: value read from the CAN register  */ static u32
>>> +xcan_read_reg(const struct xcan_priv *priv, int reg) {
>>> +   return readl(priv->reg_base + reg);
>>> +}
>>> +
>>> +/**
>>> + * set_reset_mode - Resets the CAN device mode
>>> + * @ndev:  Pointer to net_device structure
>>> + *
>>> + * This is the driver reset mode routine.The driver
>>> + * enters into configuration mode.
>>> + *
>>> + * Return: 0 on success and failure value on error  */ static int
>>> +set_reset_mode(struct net_device *ndev) {
>>> +   struct xcan_priv *priv =3D netdev_priv(ndev);
>>> +   unsigned long timeout;
>>> +
>>> +   priv->can.state =3D CAN_STATE_STOPPED;
>>> +   priv->write_reg(priv, XCAN_SRR_OFFSET, XCAN_SRR_OFFSET);
>>> +
>>> +   timeout =3D jiffies + XCAN_TIMEOUT;
>>> +   while (!(priv->read_reg(priv, XCAN_SR_OFFSET) &
>> XCAN_SR_CONFIG_MASK)) {
>>> +           if (time_after(jiffies, timeout)) {
>>> +                   netdev_warn(ndev, "timedout waiting for config
>> mode\n");
>>> +                   return -ETIMEDOUT;
>>> +           }
>>> +           schedule_timeout(1);
>>
>> better use usleep_range()
>>
>=20
> Ok
>>> +   }
>>> +
>>> +   return 0;
>>> +}
>>> +
>>> +/**
>>> + * xcan_set_bittiming - CAN set bit timing routine
>>> + * @ndev:  Pointer to net_device structure
>>> + *
>>> + * This is the driver set bittiming  routine.
>>> + * Return: 0 on success and failure value on error  */ static int
>>> +xcan_set_bittiming(struct net_device *ndev) {
>>> +   struct xcan_priv *priv =3D netdev_priv(ndev);
>>> +   struct can_bittiming *bt =3D &priv->can.bittiming;
>>> +   u32 btr0, btr1;
>>> +   u32 is_config_mode;
>>> +
>>> +   /* Check whether Xilinx CAN is in configuration mode.
>>> +    * It cannot set bit timing if Xilinx CAN is not in configuration=
 mode.
>>> +    */
>>> +   is_config_mode =3D priv->read_reg(priv, XCAN_SR_OFFSET) &
>>> +                           XCAN_SR_CONFIG_MASK;
>>> +   if (!is_config_mode) {
>>> +           netdev_alert(ndev,
>>> +                   "Cannot set bittiming can is not in config mode\n=
");
>>> +           return -EPERM;
>>> +   }
>>> +
>>> +   netdev_dbg(ndev,
>> "brp=3D%d,prop=3D%d,phase_seg1:%d,phase_reg2=3D%d,sjw=3D%d\n",
>>> +                   bt->brp, bt->prop_seg, bt->phase_seg1, bt-
>>> phase_seg2,
>>> +                   bt->sjw);
>>
>> I think this dbg can be removed, as it just prints the userspace value=
s.
>>
> Ok
>=20
>>> +
>>> +   /* Setting Baud Rate prescalar value in BRPR Register */
>>> +   btr0 =3D (bt->brp - 1) & XCAN_BRPR_BRP_MASK;
>>> +
>>> +   /* Setting Time Segment 1 in BTR Register */
>>> +   btr1 =3D (bt->prop_seg + bt->phase_seg1 - 1) & XCAN_BTR_TS1_MASK;=

>>> +
>>> +   /* Setting Time Segment 2 in BTR Register */
>>> +   btr1 |=3D ((bt->phase_seg2 - 1) << XCAN_BTR_TS2_SHIFT) &
>>> +           XCAN_BTR_TS2_MASK;
>>> +
>>> +   /* Setting Synchronous jump width in BTR Register */
>>> +   btr1 |=3D ((bt->sjw - 1) << XCAN_BTR_SJW_SHIFT) &
>> XCAN_BTR_SJW_MASK;
>>> +
>>> +   if (priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES)
>>> +           netdev_info(ndev, "Doesn't support Triple Sampling\n");
>>
>> no need to check, it's not passed to the driver until you advertise yo=
u
>> support it (see priv->can.ctrlmode_supported).
>=20
>=20
> Ok
>=20
>>
>>> +   netdev_dbg(ndev, "Setting BTR0=3D0x%02x BTR1=3D0x%02x\n", btr0,
>> btr1);
>>> +
>>> +   priv->write_reg(priv, XCAN_BRPR_OFFSET, btr0);
>>> +   priv->write_reg(priv, XCAN_BTR_OFFSET, btr1);
>>> +
>>> +   netdev_dbg(ndev, "BRPR=3D0x%08x, BTR=3D0x%08x\n",
>>> +                   priv->read_reg(priv, XCAN_BRPR_OFFSET),
>>> +                   priv->read_reg(priv, XCAN_BTR_OFFSET));
>>
>> One of the dbg should be enough.
>>
>=20
>=20
> Ok
>>> +
>>> +   return 0;
>>> +}
>>> +
>>> +/**
>>> + * xcan_start - This the drivers start routine
>>> + * @ndev:  Pointer to net_device structure
>>> + *
>>> + * This is the drivers start routine.
>>> + * Based on the State of the CAN device it puts
>>> + * the CAN device into a proper mode.
>>> + *
>>> + * Return: 0 always
>>> + */
>>> +static int xcan_start(struct net_device *ndev) {
>>> +   struct xcan_priv *priv =3D netdev_priv(ndev);
>>> +
>>> +   /* Check if it is in reset mode */
>>> +   if (priv->can.state !=3D CAN_STATE_STOPPED)
>>> +           set_reset_mode(ndev);
>>
>> Please check return value of set_reset_mode
>=20
> Ok
>=20
>=20
>>
>>> +
>>> +   /* Enable interrupts */
>>> +   priv->write_reg(priv, XCAN_IER_OFFSET, XCAN_INTR_ALL);
>>> +
>>> +   /* Check whether it is loopback mode or normal mode  */
>>> +   if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK)
>>> +           /* Put device into loopback mode */
>>> +           priv->write_reg(priv, XCAN_MSR_OFFSET,
>> XCAN_MSR_LBACK_MASK);
>>> +   else
>>> +           /* The device is in normal mode */
>>> +           priv->write_reg(priv, XCAN_MSR_OFFSET, 0);
>>> +
>>> +   if (priv->can.state =3D=3D CAN_STATE_STOPPED) {
>>
>> I think your driver is always in CAN_STATE_STOPPED, right?
>=20
> Usually it in stopped state only(configuration mode) during initializat=
ion.
>=20
>>
>>> +           /* Enable Xilinx CAN */
>>> +           priv->write_reg(priv, XCAN_SRR_OFFSET,
>> XCAN_SRR_CEN_MASK);
>>> +           priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
>>> +           if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK) {
>>> +                   while ((priv->read_reg(priv, XCAN_SR_OFFSET) &
>>> +                                   XCAN_SR_LBACK_MASK) =3D=3D 0)
>>> +                                   ;
>>> +           } else {
>>> +                   while ((priv->read_reg(priv, XCAN_SR_OFFSET)
>>> +                                   & XCAN_SR_NORMAL_MASK) =3D=3D 0)
>>> +                                   ;
>>
>> Please add a timeout to the loops.
>=20
> Ok
>>
>>> +           }
>>> +           netdev_dbg(ndev, "status:#x%08x\n",
>>> +                           priv->read_reg(priv, XCAN_SR_OFFSET));
>>> +   }
>>> +   priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
>>> +   return 0;
>>> +}
>>> +
>>> +/**
>>> + * xcan_do_set_mode - This sets the mode of the driver
>>> + * @ndev:  Pointer to net_device structure
>>> + * @mode:  Tells the mode of the driver
>>> + *
>>> + * This check the drivers state and calls the
>>> + * the corresponding modes to set.
>>> + *
>>> + * Return: 0 on success and failure value on error  */ static int
>>> +xcan_do_set_mode(struct net_device *ndev, enum can_mode mode) {
>>> +   struct xcan_priv *priv =3D netdev_priv(ndev);
>>> +   int ret;
>>> +
>>> +   netdev_dbg(ndev, "Setting the mode of the driver%s\n", __func__);=

>>
>> please remove dbg
>=20
> Ok
>>
>>> +
>>> +   if (!priv->open_time)
>>> +           return -EINVAL;
>>
>> please remove open_time completely.
>=20
> Ok
>=20
>=20
>=20
>>
>>> +
>>> +   switch (mode) {
>>> +   case CAN_MODE_START:
>>> +           ret =3D xcan_start(ndev);
>>> +           if (ret < 0)
>>> +                   netdev_err(ndev, "xcan_start failed!\n");
>>> +
>>> +           if (netif_queue_stopped(ndev))
>>> +                   netif_wake_queue(ndev);
>>
>> just call wake_queue
>=20
> Ok. But existing drivers are using netif_wake_queue right?

Sorry, I meant: Remove the if, just call netif_wake_queue directly.

>=20
>>> +           break;
>>> +   default:
>>> +           ret =3D -EOPNOTSUPP;
>>> +           break;
>>> +   }
>>> +
>>> +   return ret;
>>> +}
>>> +
>>> +/**
>>> + * xcan_start_xmit - Starts the transmission
>>> + * @skb:   sk_buff pointer that contains data to be Txed
>>> + * @ndev:  Pointer to net_device structure
>>> + *
>>> + * This function is invoked from upper layers to initiate
>>> +transmission. This
>>> + * function uses the next available free txbuff and populates their
>>> +fields to
>>> + * start the transmission.
>>> + *
>>> + * Return: 0 on success and failure value on error  */ static int
>>> +xcan_start_xmit(struct sk_buff *skb, struct net_device *ndev) {
>>> +   struct xcan_priv *priv =3D netdev_priv(ndev);
>>> +   struct net_device_stats *stats =3D &ndev->stats;
>>> +   struct can_frame *cf =3D (struct can_frame *)skb->data;
>>> +   u32 id, dlc, tmp_dw1, tmp_dw2 =3D 0, data1, data2 =3D 0;
>>> +   unsigned long flags;
>>> +
>>
>> Please add here:
>>
>>       if (can_dropped_invalid_skb(dev, skb))
>>               return NETDEV_TX_OK;
>=20
> Ok
>=20
>=20
>=20
>>
>>> +   /* Check if the TX buffer is full */
>>> +   if (priv->read_reg(priv, XCAN_SR_OFFSET) & XCAN_SR_TXFLL_MASK)
>> {
>>> +           netif_stop_queue(ndev);
>>> +           netdev_err(ndev, "TX register is still full!\n");
>>> +           return NETDEV_TX_BUSY;
>>> +   } else if (priv->waiting_ech_skb_num =3D=3D priv-
>>> xcan_echo_skb_max_tx) {
>>> +           netif_stop_queue(ndev);
>>> +           netdev_err(ndev, "waiting:0x%08x, max:0x%08x\n",
>>> +                   priv->waiting_ech_skb_num, priv-
>>> xcan_echo_skb_max_tx);
>>> +           return NETDEV_TX_BUSY;
>>> +   }
>>
>> You should handle flow control after you put the CAN frame into the
>> hardware, but before activating the TX complete interrutp.
>>
>=20
> Ok
>=20
>=20
>>> +   /* Watch carefully on the bit sequence */
>>> +   if ((cf->can_id & CAN_EFF_FLAG) =3D=3D 0) {
>>
>> Nitpick easier to read is:
>>
>>
>>       if (cf->can_id & CAN_EFF_FLAG) {
>>               /* EFF handling */
>>       } else {
>>               /* STD handling */
>>       }
>>
> Ok
>=20
>=20
>>> +           /* Standard CAN ID format */
>>> +           id =3D ((cf->can_id & CAN_SFF_MASK) << XCAN_IDR_ID1_SHIFT=
)
>> &
>>> +                   XCAN_IDR_ID1_MASK;
>>> +
>>> +           if (cf->can_id & CAN_RTR_FLAG)
>>> +                   /* Extended frames remote TX request */
>>> +                   id |=3D XCAN_IDR_SRR_MASK;
>>> +   } else {
>>> +           /* Extended CAN ID format */
>>> +           id =3D ((cf->can_id & CAN_EFF_MASK) << XCAN_IDR_ID2_SHIFT=
)
>> &
>>> +                   XCAN_IDR_ID2_MASK;
>>> +           id |=3D (((cf->can_id & CAN_EFF_MASK) >>
>>> +                   (CAN_EFF_ID_BITS-CAN_SFF_ID_BITS)) <<
>>> +                   XCAN_IDR_ID1_SHIFT) & XCAN_IDR_ID1_MASK;
>>> +
>>> +           /* The substibute remote TX request bit should be "1"
>>> +            * for extended frames as in the Xilinx CAN datasheet
>>> +            */
>>> +           id |=3D XCAN_IDR_IDE_MASK | XCAN_IDR_SRR_MASK;
>>> +
>>> +           if (cf->can_id & CAN_RTR_FLAG)
>>> +                   /* Extended frames remote TX request */
>>> +                   id |=3D XCAN_IDR_RTR_MASK;
>>> +   }
>>> +
>>> +   dlc =3D (cf->can_dlc & 0xf) << XCAN_DLCR_DLC_SHIFT;
>>
>>       With the above check can_dlc is valid.
>>
>>> +
>>> +   tmp_dw1 =3D le32_to_cpup((u32 *)(cf->data));
>>> +   data1 =3D htonl(tmp_dw1);
>>
>> This looks broken. cf->data is in big endian, what is the endianess of=
 your
>> registers?
>>
>=20
> Endianess of  our registers is little endian that's why need to do like=
 this.

Is it always little endian or native endianess (e.g. when we're running
a big endian kernel)?

As the driver support only little endian so far, make I suggest to use
be32_to_cpup():

	u32 data[2] =3D { 0, 0 };

	if (dlc > 0)
		data[0] =3D be32_to_cpup((__be32 *)(cf->data + 0));
	if (dlc > 4)
		data[1] =3D be32_to_cpup((__be32 *)(cf->data + 4));

>=20
>>> +   if (dlc > 4) {
>>> +           tmp_dw2 =3D le32_to_cpup((u32 *)(cf->data + 4));
>>> +           data2 =3D htonl(tmp_dw2);
>>> +   }
>>> +
>>> +   netdev_dbg(ndev,
>> "tx:id=3D0x%08x,dlc=3D0x%08x,d1=3D0x%08x,d2=3D0x%08x\n",
>>> +                   id, dlc, data1, data2);
>>
>> please remove the dbg
>>
>=20
> Ok
>=20
>>> +   /* Write the Frame to Xilinx CAN TX FIFO */
>>> +   priv->write_reg(priv, XCAN_TXFIFO_ID_OFFSET, id);
>>> +   priv->write_reg(priv, XCAN_TXFIFO_DLC_OFFSET, dlc);
>>> +   priv->write_reg(priv, XCAN_TXFIFO_DW1_OFFSET, data1);
>>> +   priv->write_reg(priv, XCAN_TXFIFO_DW2_OFFSET, data2);
>>
>> Which write triggers the transmission?
>>
>=20
> The last write triggers the transmission.
> If we are sending data less than 4 bytes in that case also we need to
> Fill this( XCAN_TXFIFO_DW2_OFFSET) with default value .

I see, can you please add a comment to the code. What about
XCAN_TXFIFO_DW1_OFFSET in case dlc =3D=3D 0?

>=20
>>> +   stats->tx_bytes +=3D cf->can_dlc;
>>
>> Can you move the tx_bytes +=3D to your tx-complete routine?
>=20
> Ok
>>
>>> +   ndev->trans_start =3D jiffies;
>>
>> Please remove
>=20
> Ok
>=20
>=20
>>> +
>>> +   can_put_echo_skb(skb, ndev, priv->ech_skb_next);
>>
>> This looks racy, first fill the echo_skb, then start the transmission.=

>=20
> Ok But I didn't understand it clearly.
> Will you please explain a little clear.

This will trigger transmission:

	priv->write_reg(priv, XCAN_TXFIFO_DW2_OFFSET, data2);

Then you get a tx-complete interrupt.
The tx-complete handler takes care about the echo skb. But the echo skb
hasn't been filed yet.
Your tx code continues:

	can_put_echo_skb(skb, ndev, priv->ech_skb_next);

The echo skb handling is now totlaly messed up :)

>=20
>=20
>>> +
>>> +   priv->ech_skb_next =3D (priv->ech_skb_next + 1) %
>>> +                                   priv->xcan_echo_skb_max_tx;
>>> +
>>> +   spin_lock_irqsave(&priv->ech_skb_lock, flags);
>>> +   priv->waiting_ech_skb_num++;
>>> +   spin_unlock_irqrestore(&priv->ech_skb_lock, flags);
>>> +
>>
>> Please move the flow controll handling here.
>>
>=20
> Ok
>=20
>>> +   return NETDEV_TX_OK;
>>> +}
>>> +
>>> +/**
>>> + * xcan_rx -  Is called from CAN isr to complete the received
>>> + *         frame  processing
>>> + * @ndev:  Pointer to net_device structure
>>> + *
>>> + * This function is invoked from the CAN isr(poll) to process the Rx=

>>> +frames. It
>>> + * does minimal processing and invokes "netif_receive_skb" to
>>> +complete further
>>> + * processing.
>>> + * Return: 0 on success and negative error value on error  */ static=

>>> +int xcan_rx(struct net_device *ndev) {
>>> +   struct xcan_priv *priv =3D netdev_priv(ndev);
>>> +   struct net_device_stats *stats =3D &ndev->stats;
>>> +   struct can_frame *cf;
>>> +   struct sk_buff *skb;
>>> +   u32 id_xcan, dlc, data1, data2;
>>> +
>>> +   skb =3D alloc_can_skb(ndev, &cf);
>>> +   if (!skb)
>>> +           return -ENOMEM;
>>> +
>>> +   /* Read a frame from Xilinx zynq CANPS */
>>> +   id_xcan =3D priv->read_reg(priv, XCAN_RXFIFO_ID_OFFSET);
>>> +   dlc =3D priv->read_reg(priv, XCAN_RXFIFO_DLC_OFFSET) &
>> XCAN_DLCR_DLC_MASK;
>>> +   data1 =3D priv->read_reg(priv, XCAN_RXFIFO_DW1_OFFSET);
>>> +   data2 =3D priv->read_reg(priv, XCAN_RXFIFO_DW2_OFFSET);
>>
>> If you don't use data? below, don't read them in the first place. Bett=
er move
>> the read below, where you fill the data of the can_frame.
>>
>=20
> Ok
>=20
>> +     netdev_dbg(ndev,
>> "rx:id=3D0x%08x,dlc=3D0x%08x,d1=3D0x%08x,d2=3D0x%08x\n",
>>> +           id_xcan, dlc, data1, data2);
>>>
>> please remove dbg
>=20
> Ok
>=20
>>
>>  +
>>> +   /* Change Xilinx CAN data length format to socketCAN data format
>> */
>>> +   cf->can_dlc =3D get_can_dlc((dlc & XCAN_DLCR_DLC_MASK) >>
>>> +                           XCAN_DLCR_DLC_SHIFT);
>>> +
>>> +   /* Change Xilinx CAN ID format to socketCAN ID format */
>>> +   if (id_xcan & XCAN_IDR_IDE_MASK) {
>>> +           /* The received frame is an Extended format frame */
>>> +           cf->can_id =3D (id_xcan & XCAN_IDR_ID1_MASK) >> 3;
>>> +           cf->can_id |=3D (id_xcan & XCAN_IDR_ID2_MASK) >>
>>> +                           XCAN_IDR_ID2_SHIFT;
>>> +           cf->can_id |=3D CAN_EFF_FLAG;
>>> +           if (id_xcan & XCAN_IDR_RTR_MASK)
>>> +                   cf->can_id |=3D CAN_RTR_FLAG;
>>> +   } else {
>>> +           /* The received frame is a standard format frame */
>>> +           cf->can_id =3D (id_xcan & XCAN_IDR_ID1_MASK) >>
>>> +                           XCAN_IDR_ID1_SHIFT;
>>> +           if (id_xcan & XCAN_IDR_RTR_MASK)
>>> +                   cf->can_id |=3D CAN_RTR_FLAG;
>>> +   }
>>> +
>>> +   /* Change Xilinx CAN data format to socketCAN data format */
>>
>> Don't fill cf->data if RTR is set. The endianess handling looks weird =
here,
>> too.
>>
> OK
>=20
>>> +   *(u32 *)(cf->data) =3D ntohl(data1);
>>> +   if (cf->can_dlc > 4)
>>> +           *(u32 *)(cf->data + 4) =3D ntohl(data2);
>>> +   else
>>> +           *(u32 *)(cf->data + 4) =3D 0;
>>
>> no need to set to zero
>>
> Ok
>>> +   stats->rx_bytes +=3D cf->can_dlc;
>>
>> please group rx_bytes and rx_packets handling
>>> +
>=20
> Ok
>>> +   can_led_event(ndev, CAN_LED_EVENT_RX);
>>> +
>>> +   netif_receive_skb(skb);
>>> +
>>> +   stats->rx_packets++;
>>> +   return 0;
>>> +}
>>> +
>>> +/**
>>> + * xcan_err_interrupt - error frame Isr
>>> + * @ndev:  net_device pointer
>>> + * @isr:   interrupt status register value
>>> + *
>>> + * This is the CAN error interrupt and it will
>>> + * check the the type of error and forward the error
>>> + * frame to upper layers.
>>> + */
>>> +static void xcan_err_interrupt(struct net_device *ndev, u32 isr) {
>>> +   struct xcan_priv *priv =3D netdev_priv(ndev);
>>> +   struct net_device_stats *stats =3D &ndev->stats;
>>> +   struct can_frame *cf;
>>> +   struct sk_buff *skb;
>>> +   u32 err_status, status;
>>> +
>>> +   skb =3D alloc_can_err_skb(ndev, &cf);
>>> +   if (!skb) {
>>> +           netdev_err(ndev, "alloc_can_err_skb() failed!\n");
>>> +           return;
>>> +   }
>>> +
>>> +   err_status =3D priv->read_reg(priv, XCAN_ESR_OFFSET);
>>> +   priv->write_reg(priv, XCAN_ESR_OFFSET, err_status);
>>> +   status =3D priv->read_reg(priv, XCAN_SR_OFFSET);
>>> +
>>> +   if (isr & XCAN_IXR_BSOFF_MASK) {
>>> +           priv->can.state =3D CAN_STATE_BUS_OFF;
>>> +           cf->can_id |=3D CAN_ERR_BUSOFF;
>>> +           priv->can.can_stats.bus_off++;
>>> +           /* Leave device in Config Mode in bus-off state */
>>> +           priv->write_reg(priv, XCAN_SRR_OFFSET,
>> XCAN_SRR_RESET_MASK);
>>> +           can_bus_off(ndev);
>>> +   } else if ((status & XCAN_SR_ESTAT_MASK) =3D=3D
>> XCAN_SR_ESTAT_MASK) {
>>> +           cf->can_id |=3D CAN_ERR_CRTL;
>>> +           priv->can.state =3D CAN_STATE_ERROR_PASSIVE;
>>> +           priv->can.can_stats.error_passive++;
>>> +           cf->data[1] |=3D CAN_ERR_CRTL_RX_PASSIVE |
>>> +                                   CAN_ERR_CRTL_TX_PASSIVE;
>>> +   } else if (status & XCAN_SR_ERRWRN_MASK) {
>>> +           cf->can_id |=3D CAN_ERR_CRTL;
>>> +           priv->can.state =3D CAN_STATE_ERROR_WARNING;
>>> +           priv->can.can_stats.error_warning++;
>>> +           cf->data[1] |=3D CAN_ERR_CRTL_RX_WARNING |
>>> +                                   CAN_ERR_CRTL_TX_WARNING;
>>> +   }
>>> +
>>> +   /* Check for Arbitration lost interrupt */
>>> +   if (isr & XCAN_IXR_ARBLST_MASK) {
>>> +           cf->can_id |=3D CAN_ERR_LOSTARB;
>>> +           cf->data[0] =3D CAN_ERR_LOSTARB_UNSPEC;
>>> +           priv->can.can_stats.arbitration_lost++;
>>> +   }
>>> +
>>> +   /* Check for RX FIFO Overflow interrupt */
>>> +   if (isr & XCAN_IXR_RXOFLW_MASK) {
>>> +           cf->can_id |=3D CAN_ERR_CRTL;
>>> +           cf->data[1] |=3D CAN_ERR_CRTL_RX_OVERFLOW;
>>> +           stats->rx_over_errors++;
>>> +           stats->rx_errors++;
>>> +           priv->write_reg(priv, XCAN_SRR_OFFSET,
>> XCAN_SRR_RESET_MASK);
>>> +   }
>>> +
>>> +   /* Check for error interrupt */
>>> +   if (isr & XCAN_IXR_ERROR_MASK) {
>>> +           cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
>>> +           cf->data[2] |=3D CAN_ERR_PROT_UNSPEC;
>>> +
>>> +           /* Check for Ack error interrupt */
>>> +           if (err_status & XCAN_ESR_ACKER_MASK) {
>>> +                   cf->can_id |=3D CAN_ERR_ACK;
>>> +                   cf->data[3] |=3D CAN_ERR_PROT_LOC_ACK;
>>> +                   stats->tx_errors++;
>>> +           }
>>> +
>>> +           /* Check for Bit error interrupt */
>>> +           if (err_status & XCAN_ESR_BERR_MASK) {
>>> +                   cf->can_id |=3D CAN_ERR_PROT;
>>> +                   cf->data[2] =3D CAN_ERR_PROT_BIT;
>>> +                   stats->tx_errors++;
>>> +           }
>>> +
>>> +           /* Check for Stuff error interrupt */
>>> +           if (err_status & XCAN_ESR_STER_MASK) {
>>> +                   cf->can_id |=3D CAN_ERR_PROT;
>>> +                   cf->data[2] =3D CAN_ERR_PROT_STUFF;
>>> +                   stats->rx_errors++;
>>> +           }
>>> +
>>> +           /* Check for Form error interrupt */
>>> +           if (err_status & XCAN_ESR_FMER_MASK) {
>>> +                   cf->can_id |=3D CAN_ERR_PROT;
>>> +                   cf->data[2] =3D CAN_ERR_PROT_FORM;
>>> +                   stats->rx_errors++;
>>> +           }
>>> +
>>> +           /* Check for CRC error interrupt */
>>> +           if (err_status & XCAN_ESR_CRCER_MASK) {
>>> +                   cf->can_id |=3D CAN_ERR_PROT;
>>> +                   cf->data[3] =3D CAN_ERR_PROT_LOC_CRC_SEQ |
>>> +                                   CAN_ERR_PROT_LOC_CRC_DEL;
>>> +                   stats->rx_errors++;
>>> +           }
>>> +                   priv->can.can_stats.bus_error++;
>>> +   }
>>> +
>>> +   netif_rx(skb);
>>> +   stats->rx_packets++;
>>> +   stats->rx_bytes +=3D cf->can_dlc;
>>> +
>>> +   netdev_dbg(ndev, "%s: error status register:0x%x\n",
>>> +                   __func__, priv->read_reg(priv, XCAN_ESR_OFFSET));=

>> }
>>> +
>>> +/**
>>> + * xcan_state_interrupt - It will check the state of the CAN device
>>> + * @ndev:  net_device pointer
>>> + * @isr:   interrupt status register value
>>> + *
>>> + * This will checks the state of the CAN device
>>> + * and puts the device into appropriate state.
>>> + */
>>> +static void xcan_state_interrupt(struct net_device *ndev, u32 isr) {=

>>> +   struct xcan_priv *priv =3D netdev_priv(ndev);
>>> +
>>> +   /* Check for Sleep interrupt if set put CAN device in sleep state=
 */
>>> +   if (isr & XCAN_IXR_SLP_MASK)
>>> +           priv->can.state =3D CAN_STATE_SLEEPING;
>>> +
>>> +   /* Check for Wake up interrupt if set put CAN device in Active st=
ate
>> */
>>> +   if (isr & XCAN_IXR_WKUP_MASK)
>>> +           priv->can.state =3D CAN_STATE_ERROR_ACTIVE; }
>>> +
>>> +/**
>>> + * xcan_rx_poll - Poll routine for rx packets (NAPI)
>>> + * @napi:  napi structure pointer
>>> + * @quota: Max number of rx packets to be processed.
>>> + *
>>> + * This is the poll routine for rx part.
>>> + * It will process the packets maximux quota value.
>>> + *
>>> + * Return: number of packets received  */ static int
>>> +xcan_rx_poll(struct napi_struct *napi, int quota) {
>>> +   struct net_device *ndev =3D napi->dev;
>>> +   struct xcan_priv *priv =3D netdev_priv(ndev);
>>> +   u32 isr, ier;
>>> +   int work_done =3D 0;
>>> +
>>> +   isr =3D priv->read_reg(priv, XCAN_ISR_OFFSET);
>>> +   while ((isr & XCAN_IXR_RXNEMP_MASK) && (work_done < quota)) {
>>> +           if (isr & XCAN_IXR_RXOK_MASK) {
>>> +                   priv->write_reg(priv, XCAN_ICR_OFFSET,
>>> +                           XCAN_IXR_RXOK_MASK);
>>> +                   if (xcan_rx(ndev) < 0)
>>> +                           return work_done;
>>> +                   work_done++;
>>> +           } else {
>>> +                   priv->write_reg(priv, XCAN_ICR_OFFSET,
>>> +                           XCAN_IXR_RXNEMP_MASK);
>>> +                   break;
>>> +           }
>>> +           priv->write_reg(priv, XCAN_ICR_OFFSET,
>> XCAN_IXR_RXNEMP_MASK);
>>> +           isr =3D priv->read_reg(priv, XCAN_ISR_OFFSET);
>>> +   }
>>> +
>>> +   if (work_done < quota) {
>>> +           napi_complete(napi);
>>> +           ier =3D priv->read_reg(priv, XCAN_IER_OFFSET);
>>> +           ier |=3D (XCAN_IXR_RXOK_MASK |
>> XCAN_IXR_RXNEMP_MASK);
>>> +           priv->write_reg(priv, XCAN_IER_OFFSET, ier);
>>> +   }
>>> +   return work_done;
>>> +}
>>> +
>>> +/**
>>> + * xcan_tx_interrupt - Tx Done Isr
>>> + * @ndev:  net_device pointer
>>> + */
>>> +static void xcan_tx_interrupt(struct net_device *ndev) {
>>> +   unsigned long flags;
>>> +   struct xcan_priv *priv =3D netdev_priv(ndev);
>>> +   struct net_device_stats *stats =3D &ndev->stats;
>>> +   u32 processed =3D 0, txpackets;
>>> +
>>> +   stats->tx_packets++;
>>> +   netdev_dbg(ndev, "%s: waiting total:%d,current:%d\n", __func__,
>>> +                   priv->waiting_ech_skb_num, priv-
>>> waiting_ech_skb_index);
>>> +
>>> +   txpackets =3D priv->waiting_ech_skb_num;
>>> +
>>> +   if (txpackets) {
>>> +           can_get_echo_skb(ndev, priv->waiting_ech_skb_index);
>>> +           priv->waiting_ech_skb_index =3D
>>> +                   (priv->waiting_ech_skb_index + 1) %
>>> +                   priv->xcan_echo_skb_max_tx;
>>> +           processed++;
>>> +           txpackets--;
>>> +   }
>>> +
>>> +   spin_lock_irqsave(&priv->ech_skb_lock, flags);
>>> +   priv->waiting_ech_skb_num -=3D processed;
>>> +   spin_unlock_irqrestore(&priv->ech_skb_lock, flags);
>>> +
>>> +   netdev_dbg(ndev, "%s: waiting total:%d,current:%d\n", __func__,
>>> +                   priv->waiting_ech_skb_num, priv-
>>> waiting_ech_skb_index);
>>> +
>>> +   netif_wake_queue(ndev);
>>> +
>>> +   can_led_event(ndev, CAN_LED_EVENT_TX); }
>>> +
>>> +/**
>>> + * xcan_interrupt - CAN Isr
>>> + * @irq:   irq number
>>> + * @dev_id:        device id poniter
>>> + *
>>> + * This is the xilinx CAN Isr. It checks for the type of interrupt
>>> + * and invokes the corresponding ISR.
>>> + *
>>> + * Return:
>>> + * IRQ_NONE - If CAN device is in sleep mode, IRQ_HANDLED otherwise
>>> +*/ static irqreturn_t xcan_interrupt(int irq, void *dev_id) {
>>> +   struct net_device *ndev =3D (struct net_device *)dev_id;
>>> +   struct xcan_priv *priv =3D netdev_priv(ndev);
>>> +   u32 isr, ier;
>>> +
>>> +   if (priv->can.state =3D=3D CAN_STATE_STOPPED)
>>
>> This should not happen, please remove.
>=20
> Ok
>>
>>> +           return IRQ_NONE;
>>> +
>>> +   /* Get the interrupt status from Xilinx CAN */
>>> +   isr =3D priv->read_reg(priv, XCAN_ISR_OFFSET);
>>> +   if (!isr)
>>> +           return IRQ_NONE;
>>> +
>>> +   netdev_dbg(ndev, "%s: isr:#x%08x, err:#x%08x\n", __func__,
>>> +                   isr, priv->read_reg(priv, XCAN_ESR_OFFSET));
>>> +
>>> +   /* Check for the type of interrupt and Processing it */
>>> +   if (isr & (XCAN_IXR_SLP_MASK | XCAN_IXR_WKUP_MASK)) {
>>> +           priv->write_reg(priv, XCAN_ICR_OFFSET,
>> (XCAN_IXR_SLP_MASK |
>>> +                           XCAN_IXR_WKUP_MASK));
>>> +           xcan_state_interrupt(ndev, isr);
>>> +   }
>>> +
>>> +   /* Check for Tx interrupt and Processing it */
>>> +   if (isr & XCAN_IXR_TXOK_MASK) {
>>> +           priv->write_reg(priv, XCAN_ICR_OFFSET,
>> XCAN_IXR_TXOK_MASK);
>>> +           xcan_tx_interrupt(ndev);
>>> +   }
>>> +
>>> +   /* Check for the type of error interrupt and Processing it */
>>> +   if (isr & (XCAN_IXR_ERROR_MASK | XCAN_IXR_RXOFLW_MASK |
>>> +                   XCAN_IXR_BSOFF_MASK |
>> XCAN_IXR_ARBLST_MASK)) {
>>> +           priv->write_reg(priv, XCAN_ICR_OFFSET,
>> (XCAN_IXR_ERROR_MASK |
>>> +                           XCAN_IXR_RXOFLW_MASK |
>> XCAN_IXR_BSOFF_MASK |
>>> +                           XCAN_IXR_ARBLST_MASK));
>>> +           xcan_err_interrupt(ndev, isr);
>>> +   }
>>> +
>>> +   /* Check for the type of receive interrupt and Processing it */
>>> +   if (isr & (XCAN_IXR_RXNEMP_MASK | XCAN_IXR_RXOK_MASK)) {
>>> +           ier =3D priv->read_reg(priv, XCAN_IER_OFFSET);
>>> +           ier &=3D ~(XCAN_IXR_RXNEMP_MASK |
>> XCAN_IXR_RXOK_MASK);
>>> +           priv->write_reg(priv, XCAN_IER_OFFSET, ier);
>>> +           napi_schedule(&priv->napi);
>>> +   }
>>> +   return IRQ_HANDLED;
>>> +}
>>> +
>>> +/**
>>> + * xcan_stop - Driver stop routine
>>> + * @ndev:  Pointer to net_device structure
>>> + *
>>> + * This is the drivers stop routine. It will disable the
>>> + * interrupts and put the device into configuration mode.
>>> + */
>>> +static void xcan_stop(struct net_device *ndev) {
>>> +   struct xcan_priv *priv =3D netdev_priv(ndev);
>>> +   u32 ier;
>>> +
>>> +   /* Disable interrupts and leave the can in configuration mode */
>>> +   ier =3D priv->read_reg(priv, XCAN_IER_OFFSET);
>>> +   ier &=3D ~XCAN_INTR_ALL;
>>> +   priv->write_reg(priv, XCAN_IER_OFFSET, ier);
>>> +   priv->write_reg(priv, XCAN_SRR_OFFSET, XCAN_SRR_RESET_MASK);
>>> +   priv->can.state =3D CAN_STATE_STOPPED; }
>>> +
>>> +/**
>>> + * xcan_open - Driver open routine
>>> + * @ndev:  Pointer to net_device structure
>>> + *
>>> + * This is the driver open routine.
>>> + * Return: 0 on success and failure value on error  */ static int
>>> +xcan_open(struct net_device *ndev) {
>>> +   struct xcan_priv *priv =3D netdev_priv(ndev);
>>> +   int err;
>>> +
>>> +   /* Set chip into reset mode */
>>> +   err =3D set_reset_mode(ndev);
>>> +   if (err < 0)
>>> +           netdev_err(ndev, "mode resetting failed failed!\n");
>>> +
>>> +   /* Common open */
>>> +   err =3D open_candev(ndev);
>>> +   if (err)
>>> +           return err;
>>> +
>>> +   err =3D xcan_start(ndev);
>>> +   if (err < 0)
>>> +           netdev_err(ndev, "xcan_start failed!\n");
>>> +
>>> +
>>> +   can_led_event(ndev, CAN_LED_EVENT_OPEN);
>>> +   napi_enable(&priv->napi);
>>> +   netif_start_queue(ndev);
>>> +
>>> +   return 0;
>>> +}
>>> +
>>> +/**
>>> + * xcan_close - Driver close routine
>>> + * @ndev:  Pointer to net_device structure
>>> + *
>>> + * Return: 0 always
>>> + */
>>> +static int xcan_close(struct net_device *ndev) {
>>> +   struct xcan_priv *priv =3D netdev_priv(ndev);
>>> +
>>> +   netif_stop_queue(ndev);
>>> +   napi_disable(&priv->napi);
>>> +   xcan_stop(ndev);
>>> +   close_candev(ndev);
>>> +
>>> +   can_led_event(ndev, CAN_LED_EVENT_STOP);
>>> +
>>> +   return 0;
>>> +}
>>> +
>>> +/**
>>> + * xcan_get_berr_counter - error counter routine
>>> + * @ndev:  Pointer to net_device structure
>>> + * @bec:   Pointer to can_berr_counter structure
>>> + *
>>> + * This is the driver error counter routine.
>>> + * Return: 0 always
>>> + */
>>> +static int xcan_get_berr_counter(const struct net_device *ndev,
>>> +                                   struct can_berr_counter *bec)
>>> +{
>>> +   struct xcan_priv *priv =3D netdev_priv(ndev);
>>> +
>>> +   bec->txerr =3D priv->read_reg(priv, XCAN_ECR_OFFSET) &
>> XCAN_ECR_TEC_MASK;
>>> +   bec->rxerr =3D ((priv->read_reg(priv, XCAN_ECR_OFFSET) &
>>> +                   XCAN_ECR_REC_MASK) >> XCAN_ESR_REC_SHIFT);
>>> +   return 0;
>>> +}
>>> +
>>> +static const struct net_device_ops xcan_netdev_ops =3D {
>>> +   .ndo_open       =3D xcan_open,
>>> +   .ndo_stop       =3D xcan_close,
>>> +   .ndo_start_xmit =3D xcan_start_xmit,
>>> +};
>>> +
>>> +#ifdef CONFIG_PM_SLEEP
>>> +/**
>>> + * xcan_suspend - Suspend method for the driver
>>> + * @_dev:  Address of the platform_device structure
>>> + *
>>> + * Put the driver into low power mode.
>>> + * Return: 0 always
>>> + */
>>> +static int xcan_suspend(struct device *_dev) {
>>> +   struct platform_device *pdev =3D container_of(_dev,
>>> +                   struct platform_device, dev);
>>> +   struct net_device *ndev =3D platform_get_drvdata(pdev);
>>> +   struct xcan_priv *priv =3D netdev_priv(ndev);
>>> +
>>> +   if (netif_running(ndev)) {
>>> +           netif_stop_queue(ndev);
>>> +           netif_device_detach(ndev);
>>> +   }
>>> +
>>> +   priv->write_reg(priv, XCAN_MSR_OFFSET,
>> XCAN_MSR_SLEEP_MASK);
>>> +   priv->can.state =3D CAN_STATE_SLEEPING;
>>> +
>>> +   clk_disable(priv->aperclk);
>>> +   clk_disable(priv->devclk);
>>> +
>>> +   return 0;
>>> +}
>>> +
>>> +/**
>>> + * xcan_resume - Resume from suspend
>>> + * @dev:   Address of the platformdevice structure
>>> + *
>>> + * Resume operation after suspend.
>>> + * Return: 0 on success and failure value on error  */ static int
>>> +xcan_resume(struct device *dev) {
>>> +   struct platform_device *pdev =3D container_of(dev,
>>> +                   struct platform_device, dev);
>>> +   struct net_device *ndev =3D platform_get_drvdata(pdev);
>>> +   struct xcan_priv *priv =3D netdev_priv(ndev);
>>> +   int ret;
>>> +
>>> +   ret =3D clk_enable(priv->aperclk);
>>> +   if (ret) {
>>> +           dev_err(dev, "Cannot enable clock.\n");
>>> +           return ret;
>>> +   }
>>> +   ret =3D clk_enable(priv->devclk);
>>> +   if (ret) {
>>> +           dev_err(dev, "Cannot enable clock.\n");
>>> +           return ret;
>>> +   }
>>> +
>>> +   priv->write_reg(priv, XCAN_MSR_OFFSET, 0);
>>> +   priv->write_reg(priv, XCAN_SRR_OFFSET, XCAN_SRR_CEN_MASK);
>>> +   priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
>>> +
>>> +   if (netif_running(ndev)) {
>>> +           netif_device_attach(ndev);
>>> +           netif_start_queue(ndev);
>>> +   }
>>> +
>>> +   return 0;
>>> +}
>>> +#endif
>>> +
>>> +static SIMPLE_DEV_PM_OPS(xcan_dev_pm_ops, xcan_suspend,
>> xcan_resume);
>>> +
>>> +/**
>>> + * xcan_probe - Platform registration call
>>> + * @pdev:  Handle to the platform device structure
>>> + *
>>> + * This function does all the memory allocation and registration for=

>>> +the CAN
>>> + * device.
>>> + *
>>> + * Return: 0 on success and failure value on error  */ static int
>>> +xcan_probe(struct platform_device *pdev) {
>>> +   struct resource *res; /* IO mem resources */
>>> +   struct net_device *ndev;
>>> +   struct xcan_priv *priv;
>>> +   int ret, fifodep;
>>> +
>>> +   /* Create a CAN device instance */
>>> +   ndev =3D alloc_candev(sizeof(struct xcan_priv),
>> XCAN_ECHO_SKB_MAX);
>>> +   if (!ndev)
>>> +           return -ENOMEM;
>>> +
>>> +   priv =3D netdev_priv(ndev);
>>> +   priv->dev =3D ndev;
>>> +   priv->can.bittiming_const =3D &xcan_bittiming_const;
>>> +   priv->can.do_set_bittiming =3D xcan_set_bittiming;
>>> +   priv->can.do_set_mode =3D xcan_do_set_mode;
>>> +   priv->can.do_get_berr_counter =3D xcan_get_berr_counter;
>>> +   priv->can.ctrlmode_supported =3D CAN_CTRLMODE_LOOPBACK |
>>> +                                   CAN_CTRLMODE_BERR_REPORTING;
>>> +   priv->xcan_echo_skb_max_tx =3D XCAN_ECHO_SKB_MAX;
>>> +   priv->xcan_echo_skb_max_rx =3D XCAN_NAPI_WEIGHT;
>>> +
>>> +   /* Get IRQ for the device */
>>> +   ndev->irq =3D platform_get_irq(pdev, 0);
>>> +   ret =3D devm_request_irq(&pdev->dev, ndev->irq, &xcan_interrupt,
>>> +                           priv->irq_flags, dev_name(&pdev->dev),
>>> +                           (void *)ndev);
>>
>> We usually request the interrupt on in the open() function
>>
>=20
>=20
> Ok Will Move into open routine

This means you cannot use devm_ here and you have to tear down the
interrupt handler in the close function.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--PKnUmcdjFF5DwOLgDARra9urN512C4oD2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlL0qWAACgkQjTAFq1RaXHPXUgCeJr/9Woch+YtKFIvYy5XpgTrw
1pcAn1zPfSmlshve6HzAO1hBR4aVNx9P
=POke
-----END PGP SIGNATURE-----

--PKnUmcdjFF5DwOLgDARra9urN512C4oD2--

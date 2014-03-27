From: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>
Subject: RE: [PATCH v6] can: xilinx CAN controller support
Date: Thu, 27 Mar 2014 14:21:38 +0000
Message-ID: <fcc94d34-fb45-4eba-ac83-427c42472b8c@VA3EHSMHS036.ehs.local>
References: <5ff46a21-3047-40ff-9221-f08e476f9ce6@VA3EHSMHS030.ehs.local>
 <53343256.8020802@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "wg@grandegger.com" <wg@grandegger.com>,
	"mkl@pengutronix.de" <mkl@pengutronix.de>,
	Michal Simek <michals@xilinx.com>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: "monstr@monstr.eu" <monstr@monstr.eu>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <53343256.8020802@monstr.eu>
Content-Language: en-US
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Michal,


> -----Original Message-----
> From: Michal Simek [mailto:monstr@monstr.eu]
> Sent: Thursday, March 27, 2014 7:45 PM
> To: Appana Durga Kedareswara Rao
> Cc: wg@grandegger.com; mkl@pengutronix.de; Michal Simek;
> grant.likely@linaro.org; robh+dt@kernel.org; devicetree@vger.kernel.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; linux-
> can@vger.kernel.org; Appana Durga Kedareswara Rao; linux-arm-
> kernel@lists.infradead.org
> Subject: Re: [PATCH v6] can: xilinx CAN controller support
>
> Hi Kedar,
>
> On 03/26/2014 06:26 AM, Kedareswara rao Appana wrote:
> > This patch adds xilinx CAN controller support.
> > This driver supports both ZYNQ CANPS and Soft IP AXI CAN controller.
> >
> > Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
> > ---
> > This patch is rebased on the 3.14 rc8 kernel Chnages for v6:
> > - Updated the driver with review comments.
> > - Used the clock names specified in the IP data sheet.
> > - Updated the devicetree bindings doc as per Rob suggestion.
> > Changes for v5:
> > - Updated the driver with the review comments.
> > - Remove the check for the tx fifo full interrupt condition
> >   form Tx interrupt routine as we are checking it in the _xmit
> >   routine.
> > - Clearing the txok interrupt in the tx interrupt routine for
> >   every Tx can frame.
> > Changes for v4:
> > - Added check for the tx fifo full interrupt condition in
> >   Tx interrupt routine.
> > - Added be iohelper functions.
> > - Moved the clock enable/disable to probe/remove because of
> >   Added big endian support for AXI CAN controller case(reading
> >   a register during probe for that we need to enable clock).
> > Changes for v3:
> > - Updated the driver with the review comments.
> > - Modified the tranmit logic as per Marc suggestion.
> > - Enabling the clock when the interface is up to reduce the
> >   Power consumption.
> > Changes for v2:
> > - Updated with the review comments.
> > - Removed the unnecessary debug prints.
> > - include tx,rx fifo depths in ZYNQ CANPS case also.
> > ---
> >  .../devicetree/bindings/net/can/xilinx_can.txt     |   44 +
> >  drivers/net/can/Kconfig                            |    7 +
> >  drivers/net/can/Makefile                           |    1 +
> >  drivers/net/can/xilinx_can.c                       | 1179 ++++++++++++++++++++
> >  4 files changed, 1231 insertions(+), 0 deletions(-)  create mode
> > 100644 Documentation/devicetree/bindings/net/can/xilinx_can.txt
> >  create mode 100644 drivers/net/can/xilinx_can.c
> >
> > diff --git a/Documentation/devicetree/bindings/net/can/xilinx_can.txt
> > b/Documentation/devicetree/bindings/net/can/xilinx_can.txt
> > new file mode 100644
> > index 0000000..4646396
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/can/xilinx_can.txt
> > @@ -0,0 +1,44 @@
> > +Xilinx Axi CAN/Zynq CANPS controller Device Tree Bindings
> > +---------------------------------------------------------
> > +
> > +Required properties:
> > +- compatible               : Should be "xlnx,zynq-can-1.00.a" for Zynq
> CAN
>
> We should do one more change and better now than later.
> Please use just "xlnx,zynq-can-1.0" compatible string here.
>
Ok



> > +                     controllers and "xlnx,axi-can-1.00.a" for Axi CAN
> > +                     controllers.
> > +- reg                      : Physical base address and size of the Axi CAN/Zynq
> > +                     CANPS registers map.
> > +- interrupts               : Property with a value describing the interrupt
> > +                     number.
> > +- interrupt-parent : Must be core interrupt controller
> > +- clock-names              : List of input clock names - "can_clk", "pclk"
> > +                     (For CANPS), "can_clk" , "s_axi_aclk"(For AXI CAN)
> > +                     (See clock bindings for details).
> > +- clocks           : Clock phandles (see clock bindings for details).
> > +- tx-fifo-depth            : Can Tx fifo depth.
> > +- rx-fifo-depth            : Can Rx fifo depth.
> > +
> > +
> > +Example:
> > +
> > +For Zynq CANPS Dts file:
> > +   zynq_can_0: can@e0008000 {
> > +                   compatible = "xlnx,zynq-can-1.00.a";
>
> the same here.
>
Ok

> > +                   clocks = <&clkc 19>, <&clkc 36>;
> > +                   clock-names = "can_clk", "pclk";
> > +                   reg = <0xe0008000 0x1000>;
> > +                   interrupts = <0 28 4>;
> > +                   interrupt-parent = <&intc>;
> > +                   tx-fifo-depth = <0x40>;
> > +                   rx-fifo-depth = <0x40>;
> > +           };
> > +For Axi CAN Dts file:
> > +   axi_can_0: axi-can@40000000 {
> > +                   compatible = "xlnx,axi-can-1.00.a";
> > +                   clocks = <&clkc 0>;
> > +                   clock-names = "can_clk","s_axi_aclk" ;
> > +                   reg = <0x40000000 0x10000>;
> > +                   interrupt-parent = <&intc>;
> > +                   interrupts = <0 59 1>;
> > +                   tx-fifo-depth = <0x40>;
> > +                   rx-fifo-depth = <0x40>;
> > +           };
>
> I don't know which thread I discussed this with Rob but please send this
> binding separately out of this and copy devicetree@vger.kernel.org for this
> patch.
> They should give us ACK on device-tree binding.
>
Ok

>
> > diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig index
> > 9e7d95d..9049884 100644
> > --- a/drivers/net/can/Kconfig
> > +++ b/drivers/net/can/Kconfig
> > @@ -125,6 +125,13 @@ config CAN_GRCAN
> >       endian syntheses of the cores would need some modifications on
> >       the hardware level to work.
> >
> > +config CAN_XILINXCAN
> > +   tristate "Xilinx CAN"
> > +   depends on ARCH_ZYNQ || MICROBLAZE || COMPILE_TEST
> > +   depends on COMMON_CLK && HAS_IOMEM
> > +   ---help---
> > +     Xilinx CAN driver. This driver supports both soft AXI CAN IP and
> > +     Zynq CANPS IP.
> >  source "drivers/net/can/mscan/Kconfig"
> >
> >  source "drivers/net/can/sja1000/Kconfig"
> > diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile index
> > c744039..0b8e11e 100644
> > --- a/drivers/net/can/Makefile
> > +++ b/drivers/net/can/Makefile
> > @@ -25,5 +25,6 @@ obj-$(CONFIG_CAN_JANZ_ICAN3)      += janz-
> ican3.o
> >  obj-$(CONFIG_CAN_FLEXCAN)  += flexcan.o
> >  obj-$(CONFIG_PCH_CAN)              += pch_can.o
> >  obj-$(CONFIG_CAN_GRCAN)            += grcan.o
> > +obj-$(CONFIG_CAN_XILINXCAN)        += xilinx_can.o
> >
> >  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG diff --git
> > a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_can.c new file
> > mode 100644 index 0000000..3bb289c
> > --- /dev/null
> > +++ b/drivers/net/can/xilinx_can.c
> > @@ -0,0 +1,1179 @@
> > +/* Xilinx CAN device driver
> > + *
> > + * Copyright (C) 2012 - 2014 Xilinx, Inc.
> > + * Copyright (C) 2009 PetaLogix. All rights reserved.
> > + *
> > + * Description:
> > + * This driver is developed for Axi CAN IP and for Zynq CANPS Controller.
> > + * This program is free software: you can redistribute it and/or
> > +modify
> > + * it under the terms of the GNU General Public License as published
> > +by
> > + * the Free Software Foundation, either version 2 of the License, or
> > + * (at your option) any later version.
> > + *
> > + * This program is distributed in the hope that it will be useful,
> > + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> > + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> > + * GNU General Public License for more details.
> > + *
> > + * You should have received a copy of the GNU General Public License
> > + * along with this program.  If not, see <http://www.gnu.org/licenses/>.
>
> Please remove this paragraph. Some testing tools reports this as a
> problematic part.
>
> <snip>
>
Ok

> > +/* Match table for OF platform binding */ static struct of_device_id
> > +xcan_of_match[] = {
> > +   { .compatible = "xlnx,zynq-can-1.00.a", },
>
> And here also xlnx,zynq-can-1.0
>
Ok Will change

Regards,
Kedar.

> Thanks,
> Michal
>
> --
> Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
> w: www.monstr.eu p: +42-0-721842854
> Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
> Maintainer of Linux kernel - Xilinx Zynq ARM architecture Microblaze U-
> BOOT custodian and responsible for u-boot arm zynq platform
>



This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.



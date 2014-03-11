From: Appana Durga Kedareswara Rao <appana.durga.rao-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Subject: RE: [PATCH v5] can: xilinx CAN controller support.
Date: Tue, 11 Mar 2014 12:35:13 +0000
Message-ID: <21dba33d-9def-43e1-becd-335f6cb5fd83@CO9EHSMHS011.ehs.local>
References: <5254bfec-c6fd-4681-a34d-706d51e60fbb@VA3EHSMHS004.ehs.local>
 <CAL_JsqL3V7Gmkx5MoAhzwbM8Po6QURUY+g3ytxs+H_u-FLR6SQ@mail.gmail.com>
 <531DD8C3.5050006@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Michal Simek <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"robherring2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <robherring2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Michal Simek <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <531DD8C3.5050006-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Michal,

> -----Original Message-----
> From: Michal Simek [mailto:michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org]
> Sent: Monday, March 10, 2014 8:53 PM
> To: Rob Herring
> Cc: Appana Durga Kedareswara Rao; Wolfgang Grandegger; Marc Kleine-
> Budde; Michal Simek; Grant Likely; Rob Herring; linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> netdev; linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org; linux-
> kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Appana Durga
> Kedareswara Rao
> Subject: Re: [PATCH v5] can: xilinx CAN controller support.
>
> On 03/10/2014 04:15 PM, Rob Herring wrote:
> > On Tue, Mar 4, 2014 at 7:20 AM, Kedareswara rao Appana
> > <appana.durga.rao-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org> wrote:
> >> This patch adds xilinx CAN controller support.
> >> This driver supports both ZYNQ CANPS and Soft IP AXI CAN controller.
> >>
> >> Signed-off-by: Kedareswara rao Appana <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
> >> ---
> >> This patch is rebased on the 3.14 rc5 kernel.
> >> Changes for v5:
> >> - Updated the driver with the review comments.
> >> - Remove the check for the tx fifo full interrupt condition
> >>   form Tx interrupt routine as we are checking it in the _xmit
> >>   routine.
> >> - Clearing the txok interrupt in the tx interrupt routine for
> >>   every Tx can frame.
> >> Changes for v4:
> >> - Added check for the tx fifo full interrupt condition in
> >>   Tx interrupt routine.
> >> - Added be iohelper functions.
> >> - Moved the clock enable/disable to probe/remove because of
> >>   Added big endian support for AXI CAN controller case(reading
> >>   a register during probe for that we need to enable clock).
> >> Changes for v3:
> >> - Updated the driver with the review comments.
> >> - Modified the tranmit logic as per Marc suggestion.
> >> - Enabling the clock when the interface is up to reduce the
> >>   Power consumption.
> >> Changes for v2:
> >> - Updated with the review comments.
> >> - Removed the unnecessary debug prints.
> >> - include tx,rx fifo depths in ZYNQ CANPS case also.
> >> ---
> >>  .../devicetree/bindings/net/can/xilinx_can.txt     |   45 +
> >>  drivers/net/can/Kconfig                            |    7 +
> >>  drivers/net/can/Makefile                           |    1 +
> >>  drivers/net/can/xilinx_can.c                       | 1195 ++++++++++++++++++++
> >>  4 files changed, 1248 insertions(+), 0 deletions(-)  create mode
> >> 100644 Documentation/devicetree/bindings/net/can/xilinx_can.txt
> >>  create mode 100644 drivers/net/can/xilinx_can.c
> >>
> >> diff --git a/Documentation/devicetree/bindings/net/can/xilinx_can.txt
> >> b/Documentation/devicetree/bindings/net/can/xilinx_can.txt
> >> new file mode 100644
> >> index 0000000..0e57103
> >> --- /dev/null
> >> +++ b/Documentation/devicetree/bindings/net/can/xilinx_can.txt
> >> @@ -0,0 +1,45 @@
> >> +Xilinx Axi CAN/Zynq CANPS controller Device Tree Bindings
> >> +---------------------------------------------------------
> >> +
> >> +Required properties:
> >> +- compatible           : Should be "xlnx,zynq-can-1.00.a" for Zynq CAN
> >> +                         controllers and "xlnx,axi-can-1.00.a" for Axi CAN
> >> +                         controllers.
> >> +- reg                  : Physical base address and size of the Axi CAN/Zynq
> >> +                         CANPS registers map.
> >> +- interrupts           : Property with a value describing the interrupt
> >> +                         number.
> >> +- interrupt-parent     : Must be core interrupt controller
> >> +- clock-names          : List of input clock names - "ref_clk", "aper_clk"
> >> +                         (See clock bindings for details. Two clocks are
> >> +                          required for Zynq CAN. For Axi CAN
> >> +                          case it is one(ref_clk)).
> >> +- clocks               : Clock phandles (see clock bindings for details).
> >> +- tx-fifo-depth                : Can Tx fifo depth.
> >> +- rx-fifo-depth                : Can Rx fifo depth.
> >> +
> >> +
> >> +Example:
> >> +
> >> +For Zynq CANPS Dts file:
> >> +       zynq_can_0: zynq-can@e0008000 {
> >
> > The preferred node name convention is to use the type of device. There
> > is no standard in this case, but I would use just "can@...".
> >
> > Otherwise, for the binding:
> >
> > Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>
> Thanks Rob for your ACK.
>
> Kedar: You have got more things to change from Marc that's why please
> change this too.
>
Thanks Rob for the ACk
Michal@  I  will do

Regards,
Kedar.


> Thanks,
> Michal
>
>



This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

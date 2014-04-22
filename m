From: Appana Durga Kedareswara Rao <appana.durga.rao-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Subject: RE: [PATCH v7 1/2] can: xilinx CAN controller support
Date: Tue, 22 Apr 2014 07:56:46 +0000
Message-ID: <707ea084-ed82-407b-8967-1e82a994b784@AM1EHSMHS003.ehs.local>
References: <3e750ec3-9d47-4b4e-8173-56698ab19786@CH1EHSMHS029.ehs.local>
 <53424C32.7090000@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org" <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	"mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org" <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Michal Simek <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	"grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org" <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>,
	"mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org" <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <53424C32.7090000-pSz03upnqPeHXe+LvDLADg@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Marc,

> -----Original Message-----
> From: Michal Simek [mailto:monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org]
> Sent: Monday, April 07, 2014 12:27 PM
> To: Appana Durga Kedareswara Rao
> Cc: wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org; mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org; Michal Simek;
> grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org; robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org; linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org; linux-
> kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Appana Durga
> Kedareswara Rao
> Subject: Re: [PATCH v7 1/2] can: xilinx CAN controller support
>
> On 04/02/2014 03:13 PM, Kedareswara rao Appana wrote:
> > This patch adds xilinx CAN controller support.
> > This driver supports both ZYNQ CANPS and Soft IP AXI CAN controller.
> >
> > Signed-off-by: Kedareswara rao Appana <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
> > ---
> > Changes for v7:
> > - Updated the driver with review comments.
> > - Moved the driver bindings doc as a separte patch.
> > Changes for v6:
> > - Updated the driver with review comments.
> > - Used the clock names specified in the data sheet.
> > - Updated the devicetree bindings doc as per Rob suggestion.
> > Changes for v5:
> > - Updated the driver with the review comments.
> > - Remove the check for the tx fifo full interrupt condition
> >   form Tx interrupt routine as we are checking it in the _xmit
> >   routine.
> > - Clearing the txok interrupt in the tx interrupt routine for
> >   every Tx can frame.
> > Changes for v4:
> > - Added check for the tx fifo full interrupt condition in Tx interrupt
> > routine.
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
> > - include tx,rx fifo depths in ZYNQ CANPS case also
> > ---
> >  drivers/net/can/Kconfig      |    7 +
> >  drivers/net/can/Makefile     |    1 +
> >  drivers/net/can/xilinx_can.c | 1176
> > ++++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 1184 insertions(+), 0 deletions(-)  create mode
> > 100644 drivers/net/can/xilinx_can.c
>
> Mark: Any update on this one?
> BTW: When you apply these patches you should apply 2/2 before 1/2. There
> is new checking for binding.
>

Ping?

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


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

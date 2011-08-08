From: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
Date: Mon, 8 Aug 2011 10:25:49 -0500
Message-ID: <20110808152549.GB4926@sgi.com>
References: <20110808113136.GS4926@sgi.com> <4E3FDFC9.7080508@grandegger.com>
	<20110808135630.GU4926@sgi.com> <4E3FEFBB.9050103@grandegger.com>
	<20110808142153.GW4926@sgi.com> <4E3FF4B8.2010603@grandegger.com>
	<20110808144424.GY4926@sgi.com> <4E3FF9EA.6030601@grandegger.com>
	<20110808150925.GA4926@sgi.com> <4E3FFE61.4090109@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4E3FFE61.4090109-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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

On Mon, Aug 08, 2011 at 05:18:57PM +0200, Wolfgang Grandegger wrote:
> On 08/08/2011 05:09 PM, Robin Holt wrote:
> > On Mon, Aug 08, 2011 at 04:59:54PM +0200, Wolfgang Grandegger wrote:
> >> On 08/08/2011 04:44 PM, Robin Holt wrote:
> >>> On Mon, Aug 08, 2011 at 04:37:44PM +0200, Wolfgang Grandegger wrote:
> >>>> On 08/08/2011 04:21 PM, Robin Holt wrote:
> >>>>> On Mon, Aug 08, 2011 at 04:16:27PM +0200, Wolfgang Grandegger wrote:
> >>>>>> On 08/08/2011 03:56 PM, Robin Holt wrote:
> >>>>>>>> commit 65bb8b060a873fa4f5188f2951081f6011259614
> >>>>>>>> Author: Bhaskar Upadhaya <Bhaskar.Upadhaya-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
> >>>>>>>> Date:   Fri Mar 4 20:27:58 2011 +0530
> >>>>>>>
> >>>>>>> On a side note, that commit fixes up "fsl,flexcan-v1.0"
> >>>>>>> ...
> >>>>>>> +       do_fixup_by_compat_u32(blob, "fsl,flexcan-v1.0",
> >>>>>>> +                       "clock_freq", gd->bus_clk, 1);
> >>>>>>>
> >>>>>>> Should I go back to flexcan-v1.0 in my patches?
> >>>>>>
> >>>>>> Well, no. Let's wait. I don't think we need it. Also, it sets
> >>>>>> "clock_freq" while
> >>>>>>
> >>>>>>  http://lxr.linux.no/#linux+v3.0.1/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
> >>>>>>
> >>>>>> documents "clock-frequencies"... :-(.
> >>>>>
> >>>>> You answered a different question that I was asking.  I was asking if
> >>>>> I should change fsl,flexcan back to fsl,flexcan-v1.0 as documented on
> >>>>> line 5.  The clock_freq looks like a uboot change will need to be made
> >>>>> as well.
> >>>>
> >>>> Well, I wrote above: "Well, no. Let's wait. I don't think we need it."
> >>>>
> >>>> For the P1010 we can sinmply derive the clock frequency from
> >>>> "fsl_get_sys_freq()", which is fine for the time being. No extra
> >>>> properties, etc. The clk implemetation might go into
> >>>>
> >>>>  http://lxr.linux.no/#linux+v3.0.1/arch/powerpc/platforms/85xx/clock.c
> >>>>
> >>>> or
> >>>>
> >>>>  http://lxr.linux.no/#linux+v3.0.1/arch/powerpc/sysdev/fsl_soc.c
> >>>>
> >>>> And may depend on HAVE_CAN_FLEXCAN
> >>>>
> >>>> BTW, I have not found HAVE_CAN_FLEXCAN in your patch. What kernel are
> >>>> you using?
> >>>
> >>> I am starting with the v3.0 kernel, apply one patch from the freescale BSP
> >>> we receive under NDA which introduces the P1010RDB board into the QorIQ
> >>> platform, and then work from there for the flexcan stuff.  That patch
> >>> introduces the HAVE_CAN_FLEXCAN.  I do not like how freescale structured
> >>> that Kconfig bit, so I have tweaked it to be selected automatically
> >>> when P1010RDB, NET, and CAN are selected.  That allows the CAN_FLEXCAN
> >>> selection to determine is we are going to build the flexcan.c file.
> >>
> >> ARM boards select HAVE_CAN_FLEXCAN and I do not see a good reason why
> >> we should do it differently for PowerPC. 
> >>
> >> For mainline inclusion, you should provide your patches against the
> >> David Millers "net-next-2.6" tree, which already seems to have support
> >> for the P1010RDB:
> >>
> >>   config P1010_RDB
> >>         bool "Freescale P1010RDB"
> >>         select DEFAULT_UIMAGE
> >>         help
> >>           This option enables support for the MPC85xx RDB (P1010 RDB) board
> >>
> >>           P1010RDB contains P1010Si, which provides CPU performance up to 800
> >>           MHz and 1600 DMIPS, additional functionality and faster interfaces
> >>           (DDR3/3L, SATA II, and PCI  Express).
> >>
> >>
> >>> Our contact with Freescale would prefer that I not post that patch until
> >>> we get the OK from freescale to do so since we received it under NDA.
> >>
> >> I don't think we currently need it. I prefer dropping and cleaning up
> >> the device tree stuff as it is not needed for the P1010 anyway. If a
> >> new processor shows up with enhanced capabilities requiring
> >> configuration via device tree, we or somebody else can provide a patch.
> >> Marc, what do you think?
> > 
> > I will rebase shortly and provide a newer set of patches.
> > 
> > I do think powerpc does need the device tree support.  That is how the flexcan_probe
> > is getting called.  How would you suggest I do it otherwise?
> 
> Why do you think that?

In patch 3/5 in this series (attached below), I made a change in how
device discovery works.  Without that of_match stuff, the flexcan
driver was never getting its flexcan_probe function called.  As soon
as I added that, it worked.  Looking at the driver_register path, this
appeared to be the "correct" way to implement the device discovery.
Did I miss something?

Thanks,
Robin


The OpenFirmware devices are not matched without specifying
an of_match array.  Introduce that array as that is used for
matching on the Freescale P1010 processor.

Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

---
I kept the of_match for "fsl,flexcan-v1.0" for the time being.  I will
happily drop it for final submission once I have a boot loader worked
up that matches on either string.
---
 drivers/net/can/flexcan.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index ecdd4e6..d4ac81b 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -1028,8 +1028,22 @@ static int __devexit flexcan_remove(struct platform_device *pdev)
 	return 0;
 }
 
+static struct of_device_id flexcan_of_match[] = {
+	{
+		.compatible = "fsl,flexcan-v1.0",
+	},
+	{
+		.compatible = "fsl,flexcan",
+	},
+	{},
+};
+
 static struct platform_driver flexcan_driver = {
-	.driver.name = DRV_NAME,
+	.driver = {
+		.name = DRV_NAME,
+		.owner = THIS_MODULE,
+		.of_match_table = flexcan_of_match,
+	},
 	.probe = flexcan_probe,
 	.remove = __devexit_p(flexcan_remove),
 };
-- 
1.7.2.1

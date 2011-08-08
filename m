From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
Date: Mon, 08 Aug 2011 18:03:06 +0200
Message-ID: <4E4008BA.6030303@grandegger.com>
References: <20110808113136.GS4926@sgi.com>
	<4E3FDFC9.7080508@grandegger.com>	<20110808135630.GU4926@sgi.com>
	<4E3FEFBB.9050103@grandegger.com>	<20110808142153.GW4926@sgi.com>
	<4E3FF4B8.2010603@grandegger.com>	<20110808144424.GY4926@sgi.com>
	<4E3FF9EA.6030601@grandegger.com>	<4E3FFD5B.7080000@pengutronix.de>
	<4E4001E1.3030508@grandegger.com> <20110808155540.GD4926@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110808155540.GD4926-sJ/iWh9BUns@public.gmane.org>
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

On 08/08/2011 05:55 PM, Robin Holt wrote:
> On Mon, Aug 08, 2011 at 05:33:53PM +0200, Wolfgang Grandegger wrote:
>> On 08/08/2011 05:14 PM, Marc Kleine-Budde wrote:
> ...
> 
>>> On 08/08/2011 04:59 PM, Wolfgang Grandegger wrote:
>>>> On 08/08/2011 04:44 PM, Robin Holt wrote:
>>>>> On Mon, Aug 08, 2011 at 04:37:44PM +0200, Wolfgang Grandegger wrote:
>>>>>> On 08/08/2011 04:21 PM, Robin Holt wrote:
>>>>>>> On Mon, Aug 08, 2011 at 04:16:27PM +0200, Wolfgang Grandegger wrote:
>>>>>>>> On 08/08/2011 03:56 PM, Robin Holt wrote:
>>>>>>>>>> commit 65bb8b060a873fa4f5188f2951081f6011259614
>>>>>>>>>> Author: Bhaskar Upadhaya <Bhaskar.Upadhaya-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
>>>>>>>>>> Date:   Fri Mar 4 20:27:58 2011 +0530
>>>>>>>>>
>>>>>>>>> On a side note, that commit fixes up "fsl,flexcan-v1.0"
>>>>>>>>> ...
>>>>>>>>> +       do_fixup_by_compat_u32(blob, "fsl,flexcan-v1.0",
>>>>>>>>> +                       "clock_freq", gd->bus_clk, 1);
>>>>>>>>>
>>>>>>>>> Should I go back to flexcan-v1.0 in my patches?
>>>>>>>>
>>>>>>>> Well, no. Let's wait. I don't think we need it. Also, it sets
>>>>>>>> "clock_freq" while
>>>>>>>>
>>>>>>>>  http://lxr.linux.no/#linux+v3.0.1/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
>>>>>>>>
>>>>>>>> documents "clock-frequencies"... :-(.
>>>>>>>
>>>>>>> You answered a different question that I was asking.  I was asking if
>>>>>>> I should change fsl,flexcan back to fsl,flexcan-v1.0 as documented on
>>>>>>> line 5.  The clock_freq looks like a uboot change will need to be made
>>>>>>> as well.
>>>>>>
>>>>>> Well, I wrote above: "Well, no. Let's wait. I don't think we need it."
>>>>>>
>>>>>> For the P1010 we can sinmply derive the clock frequency from
>>>>>> "fsl_get_sys_freq()", which is fine for the time being. No extra
>>>>>> properties, etc. The clk implemetation might go into
>>>>>>
>>>>>>  http://lxr.linux.no/#linux+v3.0.1/arch/powerpc/platforms/85xx/clock.c
>>>>>>
>>>>>> or
>>>>>>
>>>>>>  http://lxr.linux.no/#linux+v3.0.1/arch/powerpc/sysdev/fsl_soc.c
>>>>>>
>>>>>> And may depend on HAVE_CAN_FLEXCAN
>>>>>>
>>>>>> BTW, I have not found HAVE_CAN_FLEXCAN in your patch. What kernel are
>>>>>> you using?
>>>>>
>>>>> I am starting with the v3.0 kernel, apply one patch from the freescale BSP
>>>>> we receive under NDA which introduces the P1010RDB board into the QorIQ
>>>>> platform, and then work from there for the flexcan stuff.  That patch
>>>>> introduces the HAVE_CAN_FLEXCAN.  I do not like how freescale structured
>>>>> that Kconfig bit, so I have tweaked it to be selected automatically
>>>>> when P1010RDB, NET, and CAN are selected.  That allows the CAN_FLEXCAN
>>>>> selection to determine is we are going to build the flexcan.c file.
>>>>
>>>> ARM boards select HAVE_CAN_FLEXCAN and I do not see a good reason why
>>>> we should do it differently for PowerPC. 
>>>>
>>>> For mainline inclusion, you should provide your patches against the
>>>> David Millers "net-next-2.6" tree, which already seems to have support
>>>> for the P1010RDB:
>>>>
>>>>   config P1010_RDB
>>>>         bool "Freescale P1010RDB"
>>>>         select DEFAULT_UIMAGE
>>>>         help
>>>>           This option enables support for the MPC85xx RDB (P1010 RDB) board
>>>>
>>>>           P1010RDB contains P1010Si, which provides CPU performance up to 800
>>>>           MHz and 1600 DMIPS, additional functionality and faster interfaces
>>>>           (DDR3/3L, SATA II, and PCI  Express).
>>>>
>>>>
>>>>> Our contact with Freescale would prefer that I not post that patch until
>>>>> we get the OK from freescale to do so since we received it under NDA.
>>>>
>>>> I don't think we currently need it. I prefer dropping and cleaning up
>>>> the device tree stuff as it is not needed for the P1010 anyway. If a
>>>> new processor shows up with enhanced capabilities requiring
>>>> configuration via device tree, we or somebody else can provide a patch.
>>>> Marc, what do you think?
>>>
>>> ACK - The device tree bindings as in mainline's Documentation is a mess.
>>> If the powerpc guys are happy with a clock interfaces based approach
>>> somewhere in arch/ppc, I'm more than happy to remove:
>>> - fsl,flexcan-clock-source (not implemented, even in the fsl driver)
>>>
>>> - fsl,flexcan-clock-divider \__ replace with code in arch/ppc, or
>>> - clock-frequency           /   a single clock-frequency attribute
>>
>> In the "net-next-2.6" tree there is also:
>>
>>  $ grep flexcan arch/powerpc/boots/dts/*.dts
>>   p1010rdb.dts:			fsl,flexcan-clock-source = "platform";
>>   p1010rdb.dts:			fsl,flexcan-clock-source = "platform";
>>   p1010si.dtsi:			compatible = "fsl,flexcan-v1.0";
>>   p1010si.dtsi:			fsl,flexcan-clock-divider = <2>;
>>   p1010si.dtsi:			compatible = "fsl,flexcan-v1.0";
>>   p1010si.dtsi:			fsl,flexcan-clock-divider = <2>;
>>
>> Especially the fsl,flexcan-clock-divider = <2>; might make people think,
>> that they could set something else.
> 
> I am currently lost on the direction.  I think I need something like:
> 
> 1) Patch 1/5 removing the "#include <mach/clock.h>" stays.

OK.

> 2) Patch 2/5 abstracting readl/writel stays.

OK.

> 3) Patch 3/5 of_match for ppc and the match string is "fsl,flexcan" stays.

Yep.

> 4) Patch 4/5 I have not been given clear direction to not do it but have
>    not gotten a favorable response.

Please drop this one for mainline.

> 5) Patch 5/5 goes from being a powerpc patch back to being a flexcan.c

No, I just would prefer a more general place, e.g.:

 http://lxr.linux.no/#linux+v3.0.1/arch/powerpc/platforms/85xx/clock.c

Furthermore you need patches to cleanup some DTS and platform files and
the Documentation.

Wolfgang.

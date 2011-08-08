From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
Date: Mon, 08 Aug 2011 15:08:25 +0200
Message-ID: <4E3FDFC9.7080508@grandegger.com>
References: <1312641270-6018-1-git-send-email-holt@sgi.com>	<1312641270-6018-6-git-send-email-holt@sgi.com>	<4E3FA066.3020301@grandegger.com>
	<20110808113136.GS4926@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110808113136.GS4926-sJ/iWh9BUns@public.gmane.org>
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

On 08/08/2011 01:31 PM, Robin Holt wrote:
> On Mon, Aug 08, 2011 at 10:37:58AM +0200, Wolfgang Grandegger wrote:
>> On 08/06/2011 04:34 PM, Robin Holt wrote:
>>> flexcan driver needs the clk_get, clk_get_rate, etc functions
>>> to work.  This patch provides the minimum functionality.
>>
>> This needs some more general thoughts... apart from the question where
>> the code should go.
>>
>> Like for the MSCAN on the MPC5200, the user should be *able* to select
>> an appropriate clock source and divider via DTS node properties.
>> Currently it seems, that the DTS properties must match some
>> pre-configured values, most likely set by the boot loader. Please
>> correct me if I'm wrong. For me this is generic and should go into the
>> Flexcan driver. From there, a platform specific function, e.g.
>> flexcan_set_clock() might be called.
> 
> OK.  Dug a bit more.  The p1010 built-in clocksource seems to be the
> periphereal clock frequency which is system bus frequency divided
> by 2.  The clock source can not be changed, but the clock divider can
> by freezing the interface and setting the CTRL register.  This appears
> to only be done by the boot loader.  I do not see why we can not leave

And likely Freescale's bootloader does also fixup the DTS Flexcan node.
Ah, oh, there's already someting in the mainline U-BOOT:

commit 65bb8b060a873fa4f5188f2951081f6011259614
Author: Bhaskar Upadhaya <Bhaskar.Upadhaya-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Date:   Fri Mar 4 20:27:58 2011 +0530

    powerpc/85xx: Fix up clock_freq property in CAN node of dts

    Fix up the device tree property associated with the Flexcan clock
    frequency. This property is used to calculate the bit timing parameters
    for Flexcan.

    Signed-off-by: Bhaskar Upadhaya <Bhaskar.Upadhaya-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
    Signed-off-by: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>


> that functionality in the boot loader and then go back to a variation
> on my earlier flexcan_clk_* patch.  Is that close to the direction you
> think we should go or have I completely misunderstood your wishes?

The boot loader might not chose the optimum clock source and frequency,
which might even be application dependent. Therefore it would be nice to
allow the user to change it if necessary. Some CAN interfaces do even
allow to use an external clock source. The main question is where we add
that functionality. As more as I think of it, the clock interface would
not be that bad, especially if it's available.

Furthermore, if the bootloader sets the clock source and divider, we do
not need device tree properties for it. A simply register lookup would
reveal what values are used. We may just need the input clock source.

Wolfgang.

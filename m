From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
Date: Tue, 09 Aug 2011 10:32:31 +0200
Message-ID: <4E40F09F.60305@grandegger.com>
References: <1312641270-6018-1-git-send-email-holt@sgi.com>	<1312641270-6018-6-git-send-email-holt@sgi.com>	<4E3FA066.3020301@grandegger.com>	<20110808113136.GS4926@sgi.com>	<4E3FDFC9.7080508@grandegger.com>	<20110808135630.GU4926@sgi.com>	<4E3FEFBB.9050103@grandegger.com>	<20110808142153.GW4926@sgi.com>	<4E3FF4B8.2010603@grandegger.com>	<20110808144424.GY4926@sgi.com>
	<4E3FF9EA.6030601@grandegger.com> <4E3FFD5B.7080000@pengutronix.de>
	<4E4001E1.3030508@grandegger.com> <4E403097.4020306@pengutronix.de>
	<9C64B7751C3BCA41B64A68E23005A7BE1B9D6C@039-SN1MPN1-002.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <9C64B7751C3BCA41B64A68E23005A7BE1B9D6C-TcFNo7jSaXPiTqIcKZ1S2K4g8xLGJsHaLnY5E4hWTkheoWH0uzbU5w@public.gmane.org>
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

Hi Bhaskar,

On 08/09/2011 09:57 AM, U Bhaskar-B22300 wrote:
> 
> 
>> -----Original Message-----
>> From: Marc Kleine-Budde [mailto:mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org]
>> Sent: Tuesday, August 09, 2011 12:23 AM
>> To: Wolfgang Grandegger
>> Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; U Bhaskar-
>> B22300
>> Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
>>
>> On 08/08/2011 05:33 PM, Wolfgang Grandegger wrote:
>>>> ACK - The device tree bindings as in mainline's Documentation is a
>> mess.
>>>> If the powerpc guys are happy with a clock interfaces based approach
>>>> somewhere in arch/ppc, I'm more than happy to remove:
>>>> - fsl,flexcan-clock-source (not implemented, even in the fsl driver)
> [Bhaskar]I have pushed the FlexCAN series of patches, It contains the usage of all the fields posted in the FlexCAN bindings at
> http://git.kernel.org/?p=linux/kernel/git/stable/linux-3.0.y.git;a=blob;f=Documentation/devicetree/bindings/net/can/fsl-flexcan.txt;h=1a729f089866259ef82d0db5893ff7a8c54d5ccf;hb=94ed5b4788a7cdbe68bc7cb8516972cbebdc8274  

As Marc already pointed out, Robin already has a much more advanced
patch stack in preparation. Especially your patches do not care about
the already existing Flexcan core on the Freescale's ARM socks.

>>>>
>>>> - fsl,flexcan-clock-divider \__ replace with code in arch/ppc, or
>>>> - clock-frequency           /   a single clock-frequency attribute
>>>
>>> In the "net-next-2.6" tree there is also:
>>>
>>>  $ grep flexcan arch/powerpc/boots/dts/*.dts
>>>   p1010rdb.dts:			fsl,flexcan-clock-source = "platform";
>>>   p1010rdb.dts:			fsl,flexcan-clock-source = "platform";
>>>   p1010si.dtsi:			compatible = "fsl,flexcan-v1.0";
>>>   p1010si.dtsi:			fsl,flexcan-clock-divider = <2>;
>>>   p1010si.dtsi:			compatible = "fsl,flexcan-v1.0";
>>>   p1010si.dtsi:			fsl,flexcan-clock-divider = <2>;
>>>
>>> Especially the fsl,flexcan-clock-divider = <2>; might make people
>>> think, that they could set something else.
>>
> [Bhaskar] As it is mentioned in the Flexcan bindings, the need of fsl,flexcan-clock-divider = <2>;
> 	    But I kept it as "2" because FlexCan clock source is the platform clock and it is CCB/2
> 	    If the "2" is misleading, the bindings can be changed or some text can be written to make the meaning of "2"
>           Understandable , Please suggest ..  

The clock source and frequency is fixed. Why do we need an extra
properties for that. We have panned to remove these bogus bindings from
the Linux kernel, which sneaked in *without* any review on the relevant
mailing lists (at least I have not realized any posting). We do not
think they are really needed. They just confuse the user. We also prefer
to use the compatibility string "fsl,flexcan" instead
"fsl,flexcan-v1.0". It's unusual to add a version number, which is  for
the Flexcan on the PowerPC cores only, I assume, but there will be
device tree for ARM soon. A proper compatibility string would be
"fsl,p1010-flexcan" if we really need to distinguish.

Please join the discussion on the mailing list helping to get this
driver mainline.

Thanks,

Wolfgang.

From: "Anton.Glukhov" <anton.a.glukhov@gmail.com>
Subject: Re: [PATCH] net, can, ti_hecc: add DT support for the ti,hecc
 controller
Date: Tue, 20 Oct 2015 18:09:59 +0300
Message-ID: <56265947.8050008@gmail.com>
References: <1445236757-29019-1-git-send-email-hs@denx.de>
 <56249491.4020009@pengutronix.de> <56249B58.6090100@denx.de>
 <56249C3F.3080000@pengutronix.de> <56265661.7000509@gmail.com>
 <56265852.6000601@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?Q?Beno=c3=aet_Cousson?= <bcousson@baylibre.com>,
	Anant Gole <anantgole@ti.com>, devicetree@vger.kernel.org,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	Tony Lindgren <tony@atomide.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-omap@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>, hs@denx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56265852.6000601@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 20.10.2015 18:05, Marc Kleine-Budde wrote:
> On 10/20/2015 04:57 PM, Anton.Glukhov wrote:
>> Hello Marc, Heiko!
>> I'm sorry for the delay!
>>
>> On 19.10.2015 10:31, Marc Kleine-Budde wrote:
>>> On 10/19/2015 09:27 AM, Heiko Schocher wrote:
>>>>>>   .../devicetree/bindings/net/can/ti_hecc-can.txt    | 20 ++++++++++
>>>>>>   arch/arm/boot/dts/am3517.dtsi                      | 13 +++++++
>>>>>>   drivers/net/can/ti_hecc.c                          | 45 +++++++++++++++++++++-
>>>>>>   3 files changed, 76 insertions(+), 2 deletions(-)
>>>>>>   create mode 100644 Documentation/devicetree/bindings/net/can/ti_hecc-can.txt
>>>>>>
>>>>>> diff --git a/Documentation/devicetree/bindings/net/can/ti_hecc-can.txt b/Documentation/devicetree/bindings/net/can/ti_hecc-can.txt
>>>>>> new file mode 100644
>>>>>> index 0000000..09fab59
>>>>>> --- /dev/null
>>>>>> +++ b/Documentation/devicetree/bindings/net/can/ti_hecc-can.txt
>>>>>> @@ -0,0 +1,20 @@
>>>>>> +* TI HECC CAN *
>>>>>> +
>>>>>> +Required properties:
>>>>>> +  - compatible: Should be "ti,hecc"
>>>>>
>>>>> We usually put the name of the first SoC this IP core appears in to the
>>>>> compatible.
>>>>
>>>> Ok, so "ti,am335xx-hecc" would be OK?
>>>> @Anton: you used "am35x" ... it should be "am35xx"
>>>
>>> The "xx" is not okay. Give precisely the first SoC Version this IP core
>>> was implemented in.
>>>
>>
>> It's OMAP3 based arch, but HECC is implemented only in AM3505 and AM3517 SoCs.
>> So, I'm confused about what's "name" should I use.
> 
> Which SoC was available first? Pick that.
> 

What do you mean available? I know only that HECC appear in AM3505 and AM3517. Nowhere else.

>>>>>> +  - reg: Should contain CAN controller registers location and length
>>>>>> +  - interrupts: Should contain IRQ line for the CAN controller
>>>>>
>>>>> I'm missing the description of the ti,* properties. I think they are
>>>>> required, too. Although the code doesn't enforce it.
>>>>
>>>> Ok.
>>>>
>>>>>> +
>>>>>> +Example:
>>>>>> +
>>>>>> +	can0: hecc@5c050000 {
>>>>>> +		compatible = "ti,hecc";
>>>>>> +		reg = <0x5c050000 0x4000>;
>>>>>> +		interrupts = <24>;
>>>>>> +		ti,hecc_scc_offset = <0>;
>>>>>> +		ti,hecc_scc_ram_offset = <0x3000>;
>>>>>> +		ti,hecc_ram_offset = <0x3000>;
>>>>>> +		ti,hecc_mbx_offset = <0x2000>;
>>>>>> +		ti,hecc_int_line = <0>;
>>>>>> +		ti,hecc_version = <1>;
>>>>>
>>>>> Versioning in the OF world is done via the compatible. Are the offsets a
>>>>> per SoC parameter? I'm not sure if it's better to put
>>>>> the offsets into the driver.
>>>>
>>>> I am unsure here too..
>>>
>>> The devicetree people will hopefully help here.
>>>
>>
>> I added offsets here just make it consistent with platform data in machine file.
>> Actually it seems that it's not necessary to put offsets in DT file and I can move it to driver.
>> But again, it was added to keep consistency.
> 
> The DT is supposed to be OS independent, copying from platform data to
> DT is sometimes not the best way to go. Make yourself heard on the
> devicetree mailinglist and figure out what's the best way to go here.
> 
> Are the offsets for the AM3505 and AM3517 identical?

Yes, absolutely, and there is no HECC module in another SoCs. Ok, anyway I'll try to figure out what should we use here.

> 
> Marc
> 

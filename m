From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC v2 net-next 3/4] ravb: Document binding for r8a7795
 SoC
Date: Wed, 30 Sep 2015 21:26:52 +0300
Message-ID: <560C296C.9080403@cogentembedded.com>
References: <1441936878-18290-1-git-send-email-horms+renesas@verge.net.au>
 <1441936878-18290-4-git-send-email-horms+renesas@verge.net.au>
 <55F2E44D.6010505@cogentembedded.com> <20150914004207.GA6230@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Magnus Damm <magnus.damm@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:35740 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932190AbbI3S05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 14:26:57 -0400
Received: by laer8 with SMTP id r8so56665573lae.2
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 11:26:55 -0700 (PDT)
In-Reply-To: <20150914004207.GA6230@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09/14/2015 03:42 AM, Simon Horman wrote:

    Sorry for delayed reply, I thought I'd already replied to this. :-/

>>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>>
>>> This patch updates the ravb binding to support the r8a7795 SoC by:
>>> - Adding a compat string for the new hardware
>>> - Adding 25 named interrupts to binding for the new SoC;
>>>    older SoCs continue to use a single multiplexed interrupt
>>>
>>> The example is also updated to reflect the r8a7795 as this is the
>>> more complex case.
>>>
>>> Based on work by Kazuya Mizuguchi and others.
>>>
>>> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
>>>
>>> ---
>>>
>>> v2
>>> * First post; broken out of a driver update patch
>>> * As discussed with Geert Uytterhoeven and Sergei Shtylyov
>>>    - Binding: Make all interrupts mandatory as named-interrupts of
>>>      the form ch%u
>>> ---
>>>   .../devicetree/bindings/net/renesas,ravb.txt       | 65 +++++++++++++++++++---
>>>   1 file changed, 58 insertions(+), 7 deletions(-)
>>>
>>> diff --git a/Documentation/devicetree/bindings/net/renesas,ravb.txt b/Documentation/devicetree/bindings/net/renesas,ravb.txt
>>> index 1fd8831437bf..6c360f993d33 100644
>>> --- a/Documentation/devicetree/bindings/net/renesas,ravb.txt
>>> +++ b/Documentation/devicetree/bindings/net/renesas,ravb.txt
>> [...]
>>> @@ -27,13 +33,46 @@ Optional properties:
>>>   Example:
>>>
>>>   	ethernet@e6800000 {
>>> -		compatible = "renesas,etheravb-r8a7790";
>>> -		reg = <0 0xe6800000 0 0x800>, <0 0xee0e8000 0 0x4000>;
>>> +		compatible = "renesas,etheravb-r8a7795";
>>> +		reg = <0 0xe6800000 0 0x800>, <0 0xe6a00000 0 0x10000>;
>>>   		interrupt-parent = <&gic>;
>>> -		interrupts = <0 163 IRQ_TYPE_LEVEL_HIGH>;
>>> -		clocks = <&mstp8_clks R8A7790_CLK_ETHERAVB>;
>>> -		phy-mode = "rmii";
>>> +		interrupts = <GIC_SPI 39 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 40 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 41 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 42 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 43 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 44 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 45 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 46 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 47 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 48 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 49 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 50 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 51 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 52 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 53 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 54 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 55 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 56 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 57 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 58 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 59 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 60 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 61 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 62 IRQ_TYPE_LEVEL_HIGH>,
>>> +			     <GIC_SPI 63 IRQ_TYPE_LEVEL_HIGH>;
>>> +		interrupt-names = "ch0", "ch1", "ch2", "ch3",
>>> +				  "ch4", "ch5", "ch6", "ch7",
>>> +				  "ch8", "ch9", "ch10", "ch11",
>>> +				  "ch12", "ch13", "ch14", "ch15",
>>> +				  "ch16", "ch17", "ch18", "ch19",
>>> +				  "ch20", "ch21", "ch22", "ch23",
>>> +				  "ch24";
>>
>>     To me, these names don't look very helpful. You could as well omit them
>> and use platform_get_irq() with the channel #.

> These names reflect the hardware; which is the aim of DT.

    Indeed (I've looked into the manuals by now). They just look poorly 
chosen. :-)

> As I believe you pointed out earlier it is preferred to use named
> interrupts when there is more than one. Do I misunderstand the situation
> there?

    Yes.

> If you have a positive contribution to make regarding better names then
> I am all ears.

    I liked your "tx<n>", "rx<n>" variant better...

MBR, Sergei

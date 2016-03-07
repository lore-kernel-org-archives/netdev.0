From: Alexandre Torgue <alexandre.torgue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4 2/4] Documentation: Bindings: Add STM32 DWMAC glue
Date: Mon, 7 Mar 2016 10:26:02 +0100
Message-ID: <CAJgp7zzRh+T_RSCUzLcgLa0oX3bEq2vGUuc4ikhHmp6iUajUEw@mail.gmail.com>
References: <1457107086-14764-1-git-send-email-alexandre.torgue@gmail.com>
	<1457107086-14764-3-git-send-email-alexandre.torgue@gmail.com>
	<20160305043142.GK13525@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Maxime Coquelin <mcoquelin.stm32-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160305043142.GK13525@rob-hp-laptop>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Rob,

2016-03-05 5:31 GMT+01:00 Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>:
> On Fri, Mar 04, 2016 at 04:58:04PM +0100, Alexandre TORGUE wrote:
>> Signed-off-by: Alexandre TORGUE <alexandre.torgue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>
>> diff --git a/Documentation/devicetree/bindings/net/stm32-dwmac.txt b/Documentation/devicetree/bindings/net/stm32-dwmac.txt
>> new file mode 100644
>> index 0000000..fd3566f
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/stm32-dwmac.txt
>> @@ -0,0 +1,35 @@
>> +STMicroelectronics STM32 / MCU DWMAC glue layer controller
>> +
>> +This file documents platform glue layer for stmmac.
>> +Please see stmmac.txt for the other unchanged properties.
>> +
>> +The device node has following properties.
>> +
>> +Required properties:
>
>> +- compatible:  Should be "st,stm32-dwmac" to select glue, and
>> +            "snps,dwmac-3.50a" to select IP vesrion.
>> +- clocks: Should contain the GMAC main clock, and tx clock
>
>> +- compatible:  Should be "st,stm32-dwmac" to select glue and
>> +            "snps,dwmac-3.50a" to select IP version.
>> +- clocks: Must contain an entry for each entry in clock-names.
>
> ???

Shame on me, it is a stupid copy/paste issue. For clocks, final
description could be:

 clocks: Must contain an entry for each entry in clock-names.
 clock-names: Should be "stmmaceth" for the host clock.
                       Should be "tx-clk" for the MAC TX clock.
                       Should be "rx-clk" for the MAC RX clock.

Does it seem good for you ?

Regards.

Alex

>
>> +- clock-names: Should be "stmmaceth" for the host clock.
>> +            Should be "tx-clk" for the MAC TX clock.
>> +            Should be "rx-clk" for the MAC RX clock.
>> +- st,syscon : Should be phandle/offset pair. The phandle to the syscon node which
>> +           encompases the glue register, and the offset of the control register.
>> +Example:
>> +
>> +             ethernet0: dwmac@40028000 {
>> +                     compatible = "st,stm32-dwmac", "snps,dwmac-3.50a";
>> +                     status = "disabled";
>> +                     reg = <0x40028000 0x8000>;
>> +                     reg-names = "stmmaceth";
>> +                     interrupts = <0 61 0>, <0 62 0>;
>> +                     interrupt-names = "macirq", "eth_wake_irq";
>> +                     clock-names = "stmmaceth", "tx-clk", "rx-clk";
>> +                     clocks = <&rcc 0 25>, <&rcc 0 26>, <&rcc 0 27>;
>> +                     st,syscon = <&syscfg 0x4>;
>> +                     snps,pbl = <8>;
>> +                     snps,mixed-burst;
>> +                     dma-ranges;
>> +             };
>> --
>> 1.9.1
>>
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

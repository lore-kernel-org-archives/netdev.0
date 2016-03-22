From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: Re: [PATCH v5 2/4] Documentation: Bindings: Add STM32 DWMAC glue
Date: Wed, 23 Mar 2016 00:27:04 +0800
Message-ID: <CAGb2v67aOXk2bfa5iQ_an2_6o3CJuXhTvqu22XK5hu3QvxMCmQ@mail.gmail.com>
References: <1458315428-10081-1-git-send-email-alexandre.torgue@gmail.com>
 <1458315428-10081-3-git-send-email-alexandre.torgue@gmail.com>
 <CAGb2v65SvVi0cJbaaD9cYrqC3pJ9eumwhTVk11_N7r_nTZhS9g@mail.gmail.com>
 <CAJgp7zxyQGrSSvNszawBQfS+omgKi1i35uW-eDyLdW-jP7oRjg@mail.gmail.com> <56EFFEEC.1010407@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexandre Torgue <alexandre.torgue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Maxime Coquelin <mcoquelin.stm32-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56EFFEEC.1010407-qxv4g6HH51o@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 21, 2016 at 10:02 PM, Giuseppe CAVALLARO
<peppe.cavallaro-qxv4g6HH51o@public.gmane.org> wrote:
> On 3/21/2016 11:45 AM, Alexandre Torgue wrote:
>>
>> Hi,
>>
>> 2016-03-18 17:00 GMT+01:00 Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>:
>>>
>>> Hi,
>>>
>>> On Fri, Mar 18, 2016 at 11:37 PM, Alexandre TORGUE
>>> <alexandre.torgue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>>>
>>>> Signed-off-by: Alexandre TORGUE <alexandre.torgue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>>>
>>>> diff --git a/Documentation/devicetree/bindings/net/stm32-dwmac.txt
>>>> b/Documentation/devicetree/bindings/net/stm32-dwmac.txt
>>>> new file mode 100644
>>>> index 0000000..ada2aa4
>>>> --- /dev/null
>>>> +++ b/Documentation/devicetree/bindings/net/stm32-dwmac.txt
>>>> @@ -0,0 +1,32 @@
>>>> +STMicroelectronics STM32 / MCU DWMAC glue layer controller
>>>> +
>>>> +This file documents platform glue layer for stmmac.
>>>> +Please see stmmac.txt for the other unchanged properties.
>>>> +
>>>> +The device node has following properties.
>>>> +
>>>> +Required properties:
>>>> +- compatible:  Should be "st,stm32-dwmac" to select glue, and
>>>> +              "snps,dwmac-3.50a" to select IP vesrion.
>
>
> Almost all the synp gmac chips have the HW capability register that is
> used for setting all the parameters at probe time.
> This will override fields passed from DT. In theory, it is not
> necessary to pass: "snps,dwmac-3.50a" from device tree at least there
> is either no HW cap reg or the glue has some w/a for a specific chip
> revision.
> To be honest, I like to see the "snps,dwmac-3.50a" as compatibility
> to also have a better readability (that's my personal view ;-) ).

I agree having the versioned strings is good for informational purposes,
and to signal hardware capability. It is not so good for directly
binding drivers in the implementation though.

Unfortunately, as Joachim pointed out, exynos5440 uses it so we cannot
change it.

ChenYu

> Peppe
>
>
>>>
>>> If you need have sort of hardware glue, then it is not compatible.
>>>
>>
>> We could have the case where the glue is set by a bootloader.
>> In this case, we will select IP version in compatible and we will use
>> generic dwmac glue to probe stmmac driver.
>>
>> Regards
>>
>> Alex.
>>
>>> ChenYu
>>>
>>>> +- clocks: Must contain a phandle for each entry in clock-names.
>>>> +- clock-names: Should be "stmmaceth" for the host clock.
>>>> +              Should be "tx-clk" for the MAC TX clock.
>>>> +              Should be "rx-clk" for the MAC RX clock.
>>>> +- st,syscon : Should be phandle/offset pair. The phandle to the syscon
>>>> node which
>>>> +             encompases the glue register, and the offset of the
>>>> control register.
>>>> +Example:
>>>> +
>>>> +               ethernet0: dwmac@40028000 {
>>>> +                       compatible = "st,stm32-dwmac",
>>>> "snps,dwmac-3.50a";
>>>> +                       status = "disabled";
>>>> +                       reg = <0x40028000 0x8000>;
>>>> +                       reg-names = "stmmaceth";
>>>> +                       interrupts = <0 61 0>, <0 62 0>;
>>>> +                       interrupt-names = "macirq", "eth_wake_irq";
>>>> +                       clock-names = "stmmaceth", "tx-clk", "rx-clk";
>>>> +                       clocks = <&rcc 0 25>, <&rcc 0 26>, <&rcc 0 27>;
>>>> +                       st,syscon = <&syscfg 0x4>;
>>>> +                       snps,pbl = <8>;
>>>> +                       snps,mixed-burst;
>>>> +                       dma-ranges;
>>>> +               };
>>>> --
>>>> 1.9.1
>>>>
>>>>
>>>> _______________________________________________
>>>> linux-arm-kernel mailing list
>>>> linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
>>>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>>
>>
>>
>
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

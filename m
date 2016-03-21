From: Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v5 2/4] Documentation: Bindings: Add STM32 DWMAC glue
Date: Mon, 21 Mar 2016 13:11:35 +0100
Message-ID: <CAGhQ9Vzuhj7_Pdq80ij0jFNTPK-3VSFD_2eQCifiQnUdMeKNSg@mail.gmail.com>
References: <1458315428-10081-1-git-send-email-alexandre.torgue@gmail.com>
	<1458315428-10081-3-git-send-email-alexandre.torgue@gmail.com>
	<CAGb2v65SvVi0cJbaaD9cYrqC3pJ9eumwhTVk11_N7r_nTZhS9g@mail.gmail.com>
	<CAJgp7zxyQGrSSvNszawBQfS+omgKi1i35uW-eDyLdW-jP7oRjg@mail.gmail.com>
	<CAGb2v64V_Km+i62L=L3nuzANX1eMhC2eBvKCZuVqEFdWqeTHLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexandre Torgue <alexandre.torgue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Maxime Coquelin <mcoquelin.stm32-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGb2v64V_Km+i62L=L3nuzANX1eMhC2eBvKCZuVqEFdWqeTHLg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Chen-Yu,

On 21 March 2016 at 12:08, Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org> wrote:
> On Mon, Mar 21, 2016 at 6:45 PM, Alexandre Torgue
> <alexandre.torgue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> Hi,
>>
>> 2016-03-18 17:00 GMT+01:00 Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>:
>>> Hi,
>>>
>>> On Fri, Mar 18, 2016 at 11:37 PM, Alexandre TORGUE
>>> <alexandre.torgue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>>> Signed-off-by: Alexandre TORGUE <alexandre.torgue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>>>
>>>> diff --git a/Documentation/devicetree/bindings/net/stm32-dwmac.txt b/Documentation/devicetree/bindings/net/stm32-dwmac.txt
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

s/vesrion/version

>>>
>>> If you need have sort of hardware glue, then it is not compatible.
>>>
>>
>> We could have the case where the glue is set by a bootloader.
>> In this case, we will select IP version in compatible and we will use
>> generic dwmac glue to probe stmmac driver.
>
> It seems most platforms using DWMAC follow this design set by
> the original stmmac bindings. I'm arguing that the requirement
> of setting up the glue makes them incompatible.
>
> What happens when the bootloader didn't setup the glue? And one
> forgets to build the STM32 driver, only the generic one? The
> generic driver even matches to some, but not all, version
> strings.
>
> Maybe it would've been better if the versioned strings were
> only used to indicate functionality, and not used to bind
> the drivers. But the bindings were set some time ago.

Since Alexandre has not added "snps,dwmac-3.50a" to dwmac-generic
doesn't he use it as you suggest here?

Note that we can not remove all the generic compatible strings from
dwmac-generic because there is one platform that depend on one of
them.
(see arch/arm/boot/dts/exynos5440.dtsi:190)

So we can not remove "snps,dwmac-3.70a" from the dwmac-generic driver
if we want to keep backwards compatibility with exynos5440. But I
guess we could remove the others if we want to.


regards,
Joachim Eastwood
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

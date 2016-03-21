From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH v5 2/4] Documentation: Bindings: Add STM32 DWMAC glue
Date: Mon, 21 Mar 2016 15:02:20 +0100
Message-ID: <56EFFEEC.1010407@st.com>
References: <1458315428-10081-1-git-send-email-alexandre.torgue@gmail.com>	<1458315428-10081-3-git-send-email-alexandre.torgue@gmail.com>	<CAGb2v65SvVi0cJbaaD9cYrqC3pJ9eumwhTVk11_N7r_nTZhS9g@mail.gmail.com> <CAJgp7zxyQGrSSvNszawBQfS+omgKi1i35uW-eDyLdW-jP7oRjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maxime Coquelin <mcoquelin.stm32@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	devicetree <devicetree@vger.kernel.org>,
	Joachim Eastwood <manabian@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: Alexandre Torgue <alexandre.torgue@gmail.com>,
	Chen-Yu Tsai <wens@csie.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJgp7zxyQGrSSvNszawBQfS+omgKi1i35uW-eDyLdW-jP7oRjg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/21/2016 11:45 AM, Alexandre Torgue wrote:
> Hi,
>
> 2016-03-18 17:00 GMT+01:00 Chen-Yu Tsai <wens@csie.org>:
>> Hi,
>>
>> On Fri, Mar 18, 2016 at 11:37 PM, Alexandre TORGUE
>> <alexandre.torgue@gmail.com> wrote:
>>> Signed-off-by: Alexandre TORGUE <alexandre.torgue@gmail.com>
>>>
>>> diff --git a/Documentation/devicetree/bindings/net/stm32-dwmac.txt b/Documentation/devicetree/bindings/net/stm32-dwmac.txt
>>> new file mode 100644
>>> index 0000000..ada2aa4
>>> --- /dev/null
>>> +++ b/Documentation/devicetree/bindings/net/stm32-dwmac.txt
>>> @@ -0,0 +1,32 @@
>>> +STMicroelectronics STM32 / MCU DWMAC glue layer controller
>>> +
>>> +This file documents platform glue layer for stmmac.
>>> +Please see stmmac.txt for the other unchanged properties.
>>> +
>>> +The device node has following properties.
>>> +
>>> +Required properties:
>>> +- compatible:  Should be "st,stm32-dwmac" to select glue, and
>>> +              "snps,dwmac-3.50a" to select IP vesrion.

Almost all the synp gmac chips have the HW capability register that is
used for setting all the parameters at probe time.
This will override fields passed from DT. In theory, it is not
necessary to pass: "snps,dwmac-3.50a" from device tree at least there
is either no HW cap reg or the glue has some w/a for a specific chip
revision.
To be honest, I like to see the "snps,dwmac-3.50a" as compatibility
to also have a better readability (that's my personal view ;-) ).

Peppe

>>
>> If you need have sort of hardware glue, then it is not compatible.
>>
>
> We could have the case where the glue is set by a bootloader.
> In this case, we will select IP version in compatible and we will use
> generic dwmac glue to probe stmmac driver.
>
> Regards
>
> Alex.
>
>> ChenYu
>>
>>> +- clocks: Must contain a phandle for each entry in clock-names.
>>> +- clock-names: Should be "stmmaceth" for the host clock.
>>> +              Should be "tx-clk" for the MAC TX clock.
>>> +              Should be "rx-clk" for the MAC RX clock.
>>> +- st,syscon : Should be phandle/offset pair. The phandle to the syscon node which
>>> +             encompases the glue register, and the offset of the control register.
>>> +Example:
>>> +
>>> +               ethernet0: dwmac@40028000 {
>>> +                       compatible = "st,stm32-dwmac", "snps,dwmac-3.50a";
>>> +                       status = "disabled";
>>> +                       reg = <0x40028000 0x8000>;
>>> +                       reg-names = "stmmaceth";
>>> +                       interrupts = <0 61 0>, <0 62 0>;
>>> +                       interrupt-names = "macirq", "eth_wake_irq";
>>> +                       clock-names = "stmmaceth", "tx-clk", "rx-clk";
>>> +                       clocks = <&rcc 0 25>, <&rcc 0 26>, <&rcc 0 27>;
>>> +                       st,syscon = <&syscfg 0x4>;
>>> +                       snps,pbl = <8>;
>>> +                       snps,mixed-burst;
>>> +                       dma-ranges;
>>> +               };
>>> --
>>> 1.9.1
>>>
>>>
>>> _______________________________________________
>>> linux-arm-kernel mailing list
>>> linux-arm-kernel@lists.infradead.org
>>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>
>

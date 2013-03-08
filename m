From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: Re: [PATCH v2 4/6] ARM: davinci: da850: add DT node for eth0.
Date: Fri, 8 Mar 2013 15:15:49 +0530
Message-ID: <CA+V-a8tSjF0Zz53_v=d-hUdKK4ihK_aLceOYnmQFhhKLOx3y1g@mail.gmail.com>
References: <1359380879-26306-1-git-send-email-prabhakar.lad@ti.com>
 <1359380879-26306-5-git-send-email-prabhakar.lad@ti.com> <510E51FF.8090005@ti.com>
 <CA+V-a8uT-iF_TdWQwvnc1PfcQ9z3WBuZ2MYS1X_u3wO0_p=T0w@mail.gmail.com> <510FF4C8.7000706@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-arm-kernel@lists.infradead.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, Heiko Schocher <hs@denx.de>,
	"Lad, Prabhakar" <prabhakar.lad@ti.com>
To: Sekhar Nori <nsekhar@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <510FF4C8.7000706@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sekhar,

On Mon, Feb 4, 2013 at 11:20 PM, Sekhar Nori <nsekhar@ti.com> wrote:
> On 2/4/2013 10:37 AM, Prabhakar Lad wrote:
>> Sekhar ,
>>
>> On Sun, Feb 3, 2013 at 5:33 PM, Sekhar Nori <nsekhar@ti.com> wrote:
>>> On 1/28/2013 7:17 PM, Prabhakar Lad wrote:
>>>> From: Lad, Prabhakar <prabhakar.lad@ti.com>
>>>>
>>>> Add eth0 device tree node information and pinmux for mii to da850 by
>>>> providing interrupt details and local mac address of eth0.
>>>>
>>>> Signed-off-by: Lad, Prabhakar <prabhakar.lad@ti.com>
>>>> Cc: linux-arm-kernel@lists.infradead.org
>>>> Cc: linux-kernel@vger.kernel.org
>>>> Cc: davinci-linux-open-source@linux.davincidsp.com
>>>> Cc: netdev@vger.kernel.org
>>>> Cc: devicetree-discuss@lists.ozlabs.org
>>>> Cc: Sekhar Nori <nsekhar@ti.com>
>>>> Cc: Heiko Schocher <hs@denx.de>
>>>> ---
>>>>  arch/arm/boot/dts/da850-evm.dts |    5 +++++
>>>>  arch/arm/boot/dts/da850.dtsi    |   35 +++++++++++++++++++++++++++++++++++
>>>>  2 files changed, 40 insertions(+), 0 deletions(-)
>>>>
>>>> diff --git a/arch/arm/boot/dts/da850-evm.dts b/arch/arm/boot/dts/da850-evm.dts
>>>> index a319491..19aa2b3 100644
>>>> --- a/arch/arm/boot/dts/da850-evm.dts
>>>> +++ b/arch/arm/boot/dts/da850-evm.dts
>>>> @@ -30,6 +30,11 @@
>>>>               mdio: davinci_mdio@1e24000 {
>>>>                       status = "okay";
>>>>               };
>>>> +             eth0: emac@1e20000 {
>>>> +                     status = "okay";
>>>> +                     pinctrl-names = "default";
>>>> +                     pinctrl-0 = <&mii_pins>;
>>>> +             };
>>>>       };
>>>>       nand_cs3@62000000 {
>>>>               status = "okay";
>>>> diff --git a/arch/arm/boot/dts/da850.dtsi b/arch/arm/boot/dts/da850.dtsi
>>>> index ba28f2d..76905f3 100644
>>>> --- a/arch/arm/boot/dts/da850.dtsi
>>>> +++ b/arch/arm/boot/dts/da850.dtsi
>>>> @@ -56,6 +56,26 @@
>>>>                                       0x30 0x01100000  0x0ff00000
>>>>                               >;
>>>>                       };
>>>> +                     mii_pins: pinmux_mii_pins {
>>>> +                             pinctrl-single,bits = <
>>>> +                                     /*
>>>> +                                      * MII_TXEN, MII_TXCLK, MII_COL
>>>> +                                      * MII_TXD_3, MII_TXD_2, MII_TXD_1
>>>> +                                      * MII_TXD_0
>>>> +                                      */
>>>> +                                     0x8 0x88888880 0xfffffff0
>>>> +                                     /*
>>>> +                                      * MII_RXER, MII_CRS, MII_RXCLK
>>>> +                                      * MII_RXDV, MII_RXD_3, MII_RXD_2
>>>> +                                      * MII_RXD_1, MII_RXD_0
>>>> +                                      */
>>>> +                                     0xc 0x88888888 0xffffffff
>>>> +                                     /* MDIO_CLK, MDIO_D */
>>>
>>> You call this mii_pins, but include mdio pins in there as well. Can you
>>> separate them out? Then some board which uses rmii can simply reuse the
>>> entry.
>>>
>> Ok makes sense.
>>
>>>> +                                     0x10 0x00222288 0x00ffffff
>>>> +                                     /* GPIO2_6 */
>>>> +                                     0x18 0x00000080 0x000000f0
>>>
>>> This is SoC specific pin list. Such board specific pins should not make
>>> it here.
>>>
>> Ok, so this should be set up using GPIO API's ?
>
> Yes, the pins ultimately will be controlled by gpiolib APIs, but the
> pins should be defined under the eth node in .dts
>
You mean '0x18 0x00000080 0x000000f0'  still needs to defined in eth0 node ?
Can you elaborate and give some pointers.

Regards,
--Prabhakar

> Thanks,
> Sekhar

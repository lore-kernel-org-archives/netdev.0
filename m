From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 1/2] ARM: at91/dt: describe rgmii ethernet phy
 connected to sama5d3xek boards
Date: Mon, 21 Jul 2014 10:44:51 -0700
Message-ID: <CAGVrzcb3WHyMOW91EjDEsWfMWKb4M_cpauQtY7E+1W7zacR8VQ@mail.gmail.com>
References: <1405022394-8311-1-git-send-email-boris.brezillon@free-electrons.com>
 <1405022394-8311-2-git-send-email-boris.brezillon@free-electrons.com> <53C92D70.6050604@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Boris BREZILLON <boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Jean-Christophe Plagniol-Villard <plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org>,
	Alexandre Belloni <alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Andrew Victor <linux-PelNFVqkFnVyf+4FbqDuWQ@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <53C92D70.6050604-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2014-07-18 7:21 GMT-07:00 Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>:
> On 10/07/2014 21:59, Boris BREZILLON :
>> Add ethernet-phy nodes and specify phy interrupt (connected to pin PB25)
>> and board specific timing configs.
>>
>> Atmel has two different HW designs for its CPU modules: the first one
>> (produced by Embest) is connecting PHYAD[0-2] pins to pull up resistors
>> and the other one (produced by Ronetix) is connecting PHYAD0 to a pull up
>> resistor and PHYAD[1-2] to pull down resistors.
>> As a result, Ronetix design will have its PHY available at address 0x1 and
>> Embest design at 0x7.
>> By defining both phys we're letting the phy core detect the one actually
>> available on the MDIO bus.
>>
>> Signed-off-by: Boris BREZILLON <boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
>> ---
>>
>> Florian, I dropped your Reviewed-by tag because this patch has slightly
>> changed.
>
> Hi Florian,
>
> I would like to have your Ack on this one as we discussed this solution
> with you.

Acked-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

>
> Thanks, bye,
>
>
>>  arch/arm/boot/dts/sama5d3xcm.dtsi | 30 ++++++++++++++++++++++++++++++
>>  1 file changed, 30 insertions(+)
>>
>> diff --git a/arch/arm/boot/dts/sama5d3xcm.dtsi b/arch/arm/boot/dts/sama5d3xcm.dtsi
>> index b0b1331..755369e 100644
>> --- a/arch/arm/boot/dts/sama5d3xcm.dtsi
>> +++ b/arch/arm/boot/dts/sama5d3xcm.dtsi
>> @@ -34,6 +34,36 @@
>>
>>                       macb0: ethernet@f0028000 {
>>                               phy-mode = "rgmii";
>> +                             #address-cells = <1>;
>> +                             #size-cells = <0>;
>> +
>> +                             ethernet-phy@1 {
>> +                                     reg = <0x1>;
>> +                                     interrupt-parent = <&pioB>;
>> +                                     interrupts = <25 IRQ_TYPE_EDGE_FALLING>;
>> +                                     txen-skew-ps = <800>;
>> +                                     txc-skew-ps = <3000>;
>> +                                     rxdv-skew-ps = <400>;
>> +                                     rxc-skew-ps = <3000>;
>> +                                     rxd0-skew-ps = <400>;
>> +                                     rxd1-skew-ps = <400>;
>> +                                     rxd2-skew-ps = <400>;
>> +                                     rxd3-skew-ps = <400>;
>> +                             };
>> +
>> +                             ethernet-phy@7 {
>> +                                     reg = <0x7>;
>> +                                     interrupt-parent = <&pioB>;
>> +                                     interrupts = <25 IRQ_TYPE_EDGE_FALLING>;
>> +                                     txen-skew-ps = <800>;
>> +                                     txc-skew-ps = <3000>;
>> +                                     rxdv-skew-ps = <400>;
>> +                                     rxc-skew-ps = <3000>;
>> +                                     rxd0-skew-ps = <400>;
>> +                                     rxd1-skew-ps = <400>;
>> +                                     rxd2-skew-ps = <400>;
>> +                                     rxd3-skew-ps = <400>;
>> +                             };
>>                       };
>>
>>                       pmc: pmc@fffffc00 {
>>
>
>
> --
> Nicolas Ferre



-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

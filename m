From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: Re: [PATCH RFC 1/5] net: phy: sun8i-h3-ephy: Add bindings for
 Allwinner H3 Ethernet PHY
Date: Sat, 7 May 2016 13:30:14 +0800
Message-ID: <CAGb2v65qPMieWU-1CRJYL_zZ3JpUm83+AN477jGdrWYnjjJ66g@mail.gmail.com>
References: <1459786954-12649-1-git-send-email-wens@csie.org>
 <1459786954-12649-2-git-send-email-wens@csie.org> <570BF9B0.2090602@gmail.com>
 <CAGb2v662vHfYox2Ff9Mm=sXq4UHg92SQe2ihnKY9Aa4X9yss4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
To: Hans De Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGb2v662vHfYox2Ff9Mm=sXq4UHg92SQe2ihnKY9Aa4X9yss4Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On Tue, Apr 12, 2016 at 9:38 AM, Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org> wrote:
> On Tue, Apr 12, 2016 at 3:23 AM, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> On 04/04/16 09:22, Chen-Yu Tsai wrote:
>>> The Allwinner H3 SoC incorporates an Ethernet PHY. This is enabled and
>>> configured through a memory mapped hardware register.
>>>
>>> This same register also configures the MAC interface mode and TX clock
>>> source. Also covered by the register, but not supported in these bindings,
>>> are TX/RX clock delay chains and inverters, and an RMII module.
>>>
>>> Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
>>> ---
>>>  .../bindings/net/allwinner,sun8i-h3-ephy.txt       | 44 ++++++++++++++++++++++
>>>  1 file changed, 44 insertions(+)
>>>  create mode 100644 Documentation/devicetree/bindings/net/allwinner,sun8i-h3-ephy.txt
>>>
>>> diff --git a/Documentation/devicetree/bindings/net/allwinner,sun8i-h3-ephy.txt b/Documentation/devicetree/bindings/net/allwinner,sun8i-h3-ephy.txt
>>> new file mode 100644
>>> index 000000000000..146f227e6d88
>>> --- /dev/null
>>> +++ b/Documentation/devicetree/bindings/net/allwinner,sun8i-h3-ephy.txt
>>> @@ -0,0 +1,44 @@
>>> +* Allwinner H3 E(thernet) PHY
>>> +
>>> +The Allwinner H3 integrates an MII ethernet PHY. As with external PHYs,
>>> +before it can be configured over the MDIO bus and used, certain hardware
>>> +features must be configured, such as the PHY address and LED polarity.
>>
>> Is the internal PHY address really configurable? Not that there is
>> anything wrong with it, this is good.
>
> It is. Things that are configured or provided to a discrete PHY are routed
> to registers in the SoC, things such as PHY address, clocks, resets.
>
>>> +The PHY must also be powered on and brought out of reset.
>>> +
>>> +This is accomplished with regulators and pull-up/downs for external PHYs.
>>> +For this internal PHY, a hardware register is programmed.
>>> +
>>> +The same hardware register also contains clock and interface controls
>>> +for the MAC. This is also present in earlier SoCs, and is covered by
>>> +"allwinner,sun7i-a20-gmac-clk". The controls in the H3 are slightly
>>> +different due to the inclusion of what appears to be an RMII-MII
>>> +bridge.
>>> +
>>> +Required properties:
>>> +- compatible: should be "allwinner,sun8i-h3-ephy"
>>> +- reg: address and length of the register set for the device
>>> +- clocks: A phandle to the reference clock for this device
>>> +- resets: A phandle to the reset control for this device
>>> +
>>> +Ethernet PHY related properties:
>>> +- allwinner,ephy-addr: the MDIO bus address the PHY should respond to.
>>> +                    If this is not set, the external PHY is used, and
>>> +                    everything else in this section is ignored.
>>
>> So we are going to put the same value here, and in the actual Ethernet
>> PHY device tree node that should be hanging off the EMAC/MDIO bus
>> controller, this is confusing and error prone.
>
> Yes, that would be an issue when writing the DTS.
>>
>>> +- allwinner,leds-active-low: LEDs are active low. Without this, LEDs are
>>> +                          active high.
>>> +
>>> +Ethernet MAC clock related properties:
>>> +- #clock-cells: should be 0
>>> +- clock-output-names: "mac_tx"
>>> +
>>> +Example:
>>> +
>>> +ethernet-phy@01c00030 {
>>> +     compatible = "allwinner,sun8i-h3-ephy";
>>> +     reg = <0x01c00030 0x4>;
>>
>> Looking at this register space this looks more like an internal PHY SHIM
>> that is needed to be configured before the internal PHY can be access,
>> not a proper Ethernet PHY per-se, see replies in aptch 2.
>>
>> Should not this block be a second cell associated with the Ethernet MAC
>> block? One or the other are not going to be very useful without
>> knowledge of each other.
>
> True. However the lower half of the same register also controls the
> MAC interface mode and TX clock source and delays. This we had a clock
> driver that was used in conjuction with stmmac on earlier SoCs. I was
> hoping to keep that model with the newer EMAC. At the time it was
> argued that what seemed like a clock should be handled by a clock
> driver, instead of just a "syscon". If this is reaching too far to
> handle this new use case, I will happily just provide patches to merge
> this into the MAC.

Maxime, Hans, any thoughts?

It seems like it'd be easier to just fold this into the EMAC driver.
The register is not part of the clock controller in these new SoCs,
so it's nicer than what we had in A20/A31. It's also not just a clock
control, but a bunch of various controls.

ChenYu

> I would like to know how to deal with things like a PHY requiring
> some sort of shim driver, be it an internal one, or an external mfd
> chip that happens to have an Ethernet PHY included? How do we tie
> this into the PHY node under the MDIO bus?
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

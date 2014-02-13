From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v2 09/10] Documentation: add Device tree bindings
 for Broadcom GENET
Date: Thu, 13 Feb 2014 08:57:44 -0800
Message-ID: <CAGVrzca1L-5TTnp4aEn9JY6-Yb8GtiMfzUzxgqr5vp0qCdxQZw@mail.gmail.com>
References: <1392269395-23513-1-git-send-email-f.fainelli@gmail.com>
 <1392269395-23513-10-git-send-email-f.fainelli@gmail.com> <20140213111328.GB30705@e106331-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"cernekee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <cernekee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140213111328.GB30705-NuALmloUBlrZROr8t4l/smS4ubULX0JqMm0uRHvK7Nw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Mark,

2014-02-13 3:13 GMT-08:00 Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>:
> On Thu, Feb 13, 2014 at 05:29:54AM +0000, Florian Fainelli wrote:
>> This patch adds the Device Tree bindings for the Broadcom GENET Gigabit
>> Ethernet controller. A bunch of examples are provided to illustrate the
>> versatile aspect of the hardare.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>> Changes since v1:
>> - rebased
>>
>>  .../devicetree/bindings/net/broadcom-bcmgenet.txt  | 111 +++++++++++++++++++++
>>  1 file changed, 111 insertions(+)
>>  create mode 100644 Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
>>
>> diff --git a/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt b/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
>> new file mode 100644
>> index 0000000..93c58e9
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
>> @@ -0,0 +1,111 @@
>> +* Broadcom BCM7xxx Ethernet Controller (GENET)
>> +
>> +Required properties:
>> +- compatible: should be "brcm,genet-v1", "brcm,genet-v2", "brcm,genet-v3",
>> +  "brcm,genet-v4".
>
> Presumably "should contain one of" is a better description than "should
> be"?
>
> Are the newer revisions compatible with older revisions?

Not entirely, the driver has internal macros: GENET_IS_V<N>() to help
figuring out which parts are different.

>
>> +- reg: address and length of the register set for the device.
>> +- interrupts: interrupt for the device
>> +- mdio bus node: this node should always be present regarless of the PHY
>> +  configuration of the GENET instance
>
> Nit: a node is not a property, list it after properties.
>
>> +- phy-mode: The interface between the SoC and the PHY (a string that
>> +  of_get_phy_mode() can understand).
>
> Do we not have a document under bindings listing these? I really don't
> like referring to code in bindings docs.

Sergei has been working on a patch that centralizes the Ethernet DT
binding, but I am targetting the net-next/master tree in which this is
not yet present. I could probably pro-actively mention it though.

>
>> +
>> +MDIO bus node required properties:
>> +
>> +- compatible: should be "brcm,genet-v<N>-mdio"
>
> Where N is? Could this not be an explicit list as above? It helps when
> searching for bindings.

Yes, this should match the genet-v<N> compatible string.

>
>> +- reg: address and length relative to the parent node base register address
>
> The parent node will require #address-cells and #size-cells too then.

Correct.

>
>> +- address-cells: address cell for MDIO bus addressing, should be 1
>> +- size-cells: size of the cells for MDIO bus addressing, should be 0
>> +
>> +Optional properties:
>> +- phy-handle: A phandle to a phy node defining the PHY address (as the reg
>> +  property, a single integer), used to describe configurations where a PHY
>> +  (internal or external) is used.
>
> Is there not a phy binding you could refer to instead?

This is ePAPR, but once again, Sergei's document centralizes that nicely.

>
>> +
>> +- fixed-link: When the GENET interface is connected to a MoCA hardware block
>> +  or when operating in a RGMII to RGMII type of connection, or when the
>> +  MDIO bus is voluntarily disabled, this property should be used to describe
>> +  the "fixed link", the property is described as follows:
>> +
>> +  fixed-link: <a b c d e> where a is emulated phy id - choose any,
>> +  but unique to the all specified fixed-links, b is duplex - 0 half,
>> +  1 full, c is link speed - d#10/d#100/d#1000, d is pause - 0 no
>> +  pause, 1 pause, e is asym_pause - 0 no asym_pause, 1 asym_pause.
>
> Is this not documented elsewhere such that it can be referred to?

The Freescale FEC driver is the one holding most of the documentation
for fixed-link, I can refer to it until Sergei's patch which
centralizes the Ethernet DT bindings gets merged.

>
>> +
>> +Internal Gigabit PHY example:
>> +
>> +ethernet@f0b60000 {
>> +     phy-mode = "internal";
>> +     phy-handle = <&phy1>;
>> +     mac-address = [ 00 10 18 36 23 1a ];
>> +     compatible = "brcm,genet-v4";
>> +     #address-cells = <0x1>;
>> +     #size-cells = <0x1>;
>> +     device_type = "ethernet";
>
> What's this needed by? I can't see any other devices with this
> device_type, and I was under the impression that we didn't want new
> device_type properties cropping up.

This is just an oversight, and is not required per-se, I will get it removed.

>
>> +     reg = <0xf0b60000 0xfc4c>;
>> +     interrupts = <0x0 0x14 0x0 0x0 0x15 0x0>;
>
> How many? The binding implied only one, and I'm not away of any
> interrupt controller bindings with #interrupt-cells = <6>.

In fact, only two interrupts, cells, this is a bad copy-pasting from
the bootloader providing the DTB.

Thanks for the review!
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

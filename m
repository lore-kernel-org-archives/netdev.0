From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v4 net-next] mdio_bus: Issue GPIO RESET to PHYs.
Date: Mon, 24 Apr 2017 09:32:36 -0700
Message-ID: <cdf4f58e-69b4-99cd-9e02-a1f70042f1e4@gmail.com>
References: <1491381237-24635-1-git-send-email-rogerq@ti.com>
 <64d6494d-41d2-0faf-a434-057f796637fe@ti.com>
 <daa29a99-0a17-d316-57eb-3e6162938d8d@ti.com>
 <f372db02-a919-55b4-9200-20726cd13482@ti.com>
 <fe0b7ec5-2f83-ba06-579f-3ea0d5c4990c@ti.com>
 <1c36aab1-3411-f76d-67f7-e3f6d9e9fda5@metafoo.de>
 <20170423233553.GA23498@lunn.ch>
 <551ee7a0-d153-3a36-e025-2c1f70f866b7@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, tony@atomide.com, nsekhar@ti.com,
        jsarha@ti.com, netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>, Andrew Lunn <andrew@lunn.ch>,
        Lars-Peter Clausen <lars@metafoo.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <551ee7a0-d153-3a36-e025-2c1f70f866b7@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/24/2017 02:04 AM, Roger Quadros wrote:
> On 24/04/17 02:35, Andrew Lunn wrote:
>> On Fri, Apr 21, 2017 at 03:31:09PM +0200, Lars-Peter Clausen wrote:
>>> On 04/21/2017 03:15 PM, Roger Quadros wrote:
>>>> diff --git a/Documentation/devicetree/bindings/net/mdio.txt b/Documentation/devicetree/bindings/net/mdio.txt
>>>> new file mode 100644
>>>> index 0000000..4ffbbac
>>>> --- /dev/null
>>>> +++ b/Documentation/devicetree/bindings/net/mdio.txt
>>>> @@ -0,0 +1,33 @@
>>>> +Common MDIO bus properties.
>>>> +
>>>> +These are generic properties that can apply to any MDIO bus.
>>>> +
>>>> +Optional properties:
>>>> +- reset-gpios: List of one or more GPIOs that control the RESET lines
>>>> +  of the PHYs on that MDIO bus.
>>>> +- reset-delay-us: RESET pulse width in microseconds as per PHY datasheet.
>>>> +
>>>> +A list of child nodes, one per device on the bus is expected. These
>>>> +should follow the generic phy.txt, or a device specific binding document.
>>>> +
>>>> +Example :
>>>> +This example shows these optional properties, plus other properties
>>>> +required for the TI Davinci MDIO driver.
>>>> +
>>>> +	davinci_mdio: ethernet@0x5c030000 {
>>>> +		compatible = "ti,davinci_mdio";
>>>> +		reg = <0x5c030000 0x1000>;
>>>> +		#address-cells = <1>;
>>>> +		#size-cells = <0>;
>>>> +
>>>> +		reset-gpios = <&gpio2 5 GPIO_ACTIVE_LOW>;
>>>> +		reset-delay-us = <2>;   /* PHY datasheet states 1us min */
>>>
>>> If this is the reset line of the PHY shouldn't it be a property of the PHY
>>> node rather than of the MDIO controller node (which might have a reset on
>>> its own)?
>>>> +
>>>> +		ethphy0: ethernet-phy@1 {
>>>> +			reg = <1>;
>>>> +		};
>>>> +
>>>> +		ethphy1: ethernet-phy@3 {
>>>> +			reg = <3>;
>>>> +		};
>>
>> Hi Lars-Peter
>>
>> We discussed this when the first proposal was made. There are two
>> cases, to consider.
>>
>> 1) Here, one GPIO line resets all PHYs on the same MDIO bus. In this
>> example, two PHYs.
>>
>> 2) There is one GPIO line per PHY. That is a separate case, and as you
>> say, the reset line should probably be considered a PHY property, not
>> an MDIO property. However, it can be messy, since in order to probe
>> the MDIO bus, you probably need to take the PHY out of reset.
>>
>> Anyway, this patch addresses the first case, so should be accepted. If
>> anybody wants to address the second case, they are free to do so.
> 
> Thanks for the explanation Andrew.
> 
> For the second case, even if the RESET GPIO property is specified
> in the PHY node, the RESET *will* have to be done by the MDIO bus driver
> else the PHY might not be probed at all.
> 
> Whether we need additional code to just to make the DT look prettier is
> questionable and if required can come as a separate patch.

Well, it's not about prettier vs. uglier, it's about correct vs.
incorrect. The binding document you propose here is correct for a single
reset line controlling all PHYs, and that's why such a reset line needs
to be placed at the MDIO controller level, because it's a property of
such a node.

If you need to support individual reset lines per-PHY, then there should
be some kind of amendment to the Ethernet PHY Device Tree binding
document which specifies optional reset-gpio properties for these nodes.

Until that happens, I think your v4 is good to go.
-- 
Florian

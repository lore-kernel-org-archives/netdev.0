From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Wed, 17 Aug 2016 21:04:37 -0700
Message-ID: <5CCEFB33-8F93-40D7-BD32-ACDE1CBA586D@gmail.com>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org> <20160804175541.GA2832@rob-hp-laptop> <57B220C0.3060608@codeaurora.org> <CAL_JsqL5xk3mH=h-m8nU8xTYbRjgMWt3p7BzYWj6vBUq4OpqMg@mail.gmail.com> <57B31780.5030106@codeaurora.org> <f3a49762-aa66-1949-bd6b-77bd6a74acc1@linaro.org> <57B3878D.1000805@codeaurora.org> <ff901f77-2177-52a7-2464-2f61495f91be@gmail.com> <57B4C6EE.3080903@codeaurora.org> <57B4E5F7.9040500@codeaurora.org> <bec781c6-2db9-02c7-687d-b5d6ee50c129@gmail.com> <57B52B17.1080809@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-msm <linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sagar Dharia <sdharia-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Shanker Donthineni <shankerd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Vikram Sethi <vikrams-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Christopher Covington <cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Gilad Avidov <gavidov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
	Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Mark Langsdorf <mlangsdo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Andy Gross <agross-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org>,
	"Abdulhamid, Harb" <harba-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
To: Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, Al Stone <al.stone-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <57B52B17.1080809-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On August 17, 2016 8:27:19 PM PDT, Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> wrote:
>Florian Fainelli wrote:
>
>>>      emac_sgmii: ethernet-phy@410400 {
>>>          compatible = "qcom,qdf2432-emac-phy";
>>>          reg = <0x0 0x00410400 0x0 0x100>;
>>>          interrupts = <0 0x104 0>;
>>>      };
>>>
>>
>> Is this register range relative to the emac0 node here, or is this
>> really a separate node, within the same adress space as your emac0
>node?
>
>It's a separate node within the same address space.  We can't guarantee
>
>that it's adjacent to any other EMAC register -- it could be anywhere
>in 
>memory. 0x00410400 is the real physical address of those registers.

Ok

>
>> Answer largely depends on whether your device is really located
>outside
>> of the emac, if it located outside, then a platform device matching
>the
>> compatible string would get you what you want. If the emac_sgmii
>block
>> is a sub-block within the EMAC, then a few things need fixing:
>>
>> - your emac_sgmii node should be a sub-node of the emac node, not a
>sibling
>> - the emac0 node should have a "ranges" property that indicates how
>to
>> translate the sub-nodes' "reg" property based on the base register
>> address of the emac0 block
>> - you would have to call of_platform_populate from the EMAC driver to
>> ensure that the emac_sgmii child node and therefore platform device
>gets
>> created
>
>Even if the emac_sgmii block were a sub-block, wouldn't it conflict
>with 
>the ethernet-phy@4 node?  The #address-cells and #size-cells properties
>
>cannot be valid for both the emac_sgmii and ethernet-phy@4 nodes.

These two properties apply to subnodes within the emac0 and emac_sgmii nodes, this is standard DT stuff here.

The larger issue is that the emac_sgmii node in the form you posted is going to be backed by a platform device in Linux while you want a PHY device with a reg property that describes a MDIO address (#address-cells = 1, #size-cells = 0). 

IIRC the amd xgbe driver mainline had a similar design but still implemented a PHY device anyway although it may not have been using Device Tree. It should still be possible to implement a PHY driver that you manually register and bind to its device_node pointer such that of_phy_find_device and friends still work. You would do this from the emac_sgmii platform device driver and parent devices in a way that satisfy the PHY device driver lifecycle as well.

Hope this helps.

NB: another way to do this is to give the SGMII PHY device a MDIO address, provided that it has one, and you pass the memory mapped register range as a syscon property pointing to the emac_sgmii register range. This is not really clean through.


-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

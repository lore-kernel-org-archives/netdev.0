From: Sean Wang <sean.wang@mediatek.com>
Subject: Re: [PATCH net-next 3/3] net: ethernet: mediatek: add the dts property to set if TRGMII supported on GMAC0
Date: Wed, 21 Sep 2016 23:37:36 +0800
Message-ID: <1474472256-23533-1-git-send-email-sean.wang@mediatek.com>
References: <20160921141720.GN22292@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <john@phrozen.org>, <davem@davemloft.net>, <nbd@openwrt.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>
To: <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160921141720.GN22292@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Date: Wed, 21 Sep 2016 16:17:20 +0200, Andrew Lunn <andrew@lunn.ch> wrote:
>On Wed, Sep 21, 2016 at 02:16:30PM +0800, Sean Wang wrote:
>> Date: Tue, 20 Sep 2016 21:37:58 +0200, Andrew Lunn <andrew@lunn.ch> wrote:
>> >On Tue, Sep 20, 2016 at 03:59:20PM +0800, sean.wang@mediatek.com wrote:
>> >> From: Sean Wang <sean.wang@mediatek.com>
>> >>
>> >> Add the dts property for the capability if TRGMII supported on GAMC0
>> >>
>> >> Signed-off-by: Sean Wang <sean.wang@mediatek.com>

.... deleted

>> >In this case the switch is an MDIO device, not an PHY. It will not
>> >have an phy-mode. It cannot have a phy mode, it is not a PHY.
>> >
>> >Or am i missing something here?
>> >
>> >Thanks
>> >
>> 
>> 1)
>> 
>> The switch driver is not supported for DSA so far yet 
>> but DSA is good thing and I will try make it happen
>> in the near future.
>
>O.K. But if i understand correctly, the TRGMII is so you can use the
>switch. So it needs to work when you have DSA.
>

yes, you are right. TRGMII for now is dedicated for switch
and furthermore it needs doing calibration between the host and
the switch before it works, that I expect to put
the logic of calibration into setup callback of DSA driver.


>> And another question about DSA, that is
>> if I use DSA for switch, how to know the relationship
>> between MAC and DSA ? such like I could know relationship 
>> between MAC and PHY by phy-handle.
>
>It will look like what i stated above. But i missed the cpu node in
>the ports, which is what you are asking about. There will also be a
>node like:
>
>                            port@6 {
>                                     reg = <6>;
>                                     label = "cpu";
>                                     ethernet = <&gmac1>;
>                             };
>
>And this is how you couple the MAC to DSA.

thanks, it is answerig my question : i can get the relationship from 
the node of cpu port pointing to what MAC it runs for.

>> The cause I ask is becasue I think it's good if the topology
>> about MAC/PHYs/Switch is known just by dts files.
>> 
>> 2)
>> 
>> The phy-mode I mention is for fixed-link. For current MAC driver, 
>> it just uses fixed phy to adapt into the part of switch, so the 
>> device tree looks something like the below. 
>> 
>> &eth {
>>         status = "okay";
>>         gmac0: mac@0 {
>>                 compatible = "mediatek,eth-mac";
>>                 reg = <0>;
>>                 phy-mode = "trgmii";
>>                 fixed-link {
>>                         speed = <1000>;
>>                         full-duplex;
>>                         pause;
>>                 };
>>         };
>> 
>>         gmac1: mac@1 {
>>                 compatible = "mediatek,eth-mac";
>>                 reg = <1>;
>>                 phy-handle = <&phy5>;
>>         };
>
>
>static int mtk_phy_connect(struct mtk_mac *mac)
>{
>        struct mtk_eth *eth = mac->hw;
>        struct device_node *np;
>        u32 val;
>
>        np = of_parse_phandle(mac->of_node, "phy-handle", 0);
>        if (!np && of_phy_is_fixed_link(mac->of_node))
>                if (!of_phy_register_fixed_link(mac->of_node))
>                        np = of_node_get(mac->of_node);
>	...
>        ...
>        mtk_phy_connect_node(eth, mac, np);
>
>
>So in the case of a fixed-phy, you do look in the MAC node, and when
>there is a phy-handle, you look in the PHY node.
>
>So this does work....

yes , it is all

>
>   Andrew

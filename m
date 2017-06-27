From: Andre Przywara <andre.przywara@arm.com>
Subject: Re: [PATCH v6 05/21] net-next: stmmac: Add dwmac-sun8i
Date: Tue, 27 Jun 2017 11:33:56 +0100
Message-ID: <858b5361-fde5-8ab4-b9ba-aeb7859b9a7d@arm.com>
References: <20170531071852.12422-1-clabbe.montjoie@gmail.com>
 <20170531071852.12422-6-clabbe.montjoie@gmail.com>
 <8e3d73a7-e9ff-d3e2-4bce-bcc79cdf86db@arm.com> <20170627080529.GA2468@Red>
 <CAGb2v65mhDN9vXe6DE2cZPW1BzgYPwK+D2U5VFgyr0wVVZZqDQ@mail.gmail.com>
 <20170627082103.GB2468@Red> <530f7b3e-247d-2e4d-8174-ce6195bacf5b@arm.com>
 <20170627094111.supxmzf2k3n3ewec@flea.lan>
 <44afb371-44d4-dbb5-0aac-4bbc55269344@arm.com>
 <700A8221-3CEC-4657-900D-183398D25AE7@aosc.io>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Corentin Labbe <clabbe.montjoie@gmail.com>,
        Chen-Yu Tsai <wens@csie.org>, Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        alexandre.torgue@st.com, devicetree <devicetree@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        linux-sunxi <linux-sunxi@googlegroups.com>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
        david.wu@rock-chips.com, Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        =?UTF-8?Q?Heiko_St=c3=bcbner?= <heiko@sntech.de>
To: Icenowy Zheng <icenowy@aosc.io>,
        Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:54906 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751699AbdF0Kd5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Jun 2017 06:33:57 -0400
In-Reply-To: <700A8221-3CEC-4657-900D-183398D25AE7@aosc.io>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 27/06/17 11:23, Icenowy Zheng wrote:
> 
> 
> 于 2017年6月27日 GMT+08:00 下午6:15:58, Andre Przywara <andre.przywara@arm.com> 写到:
>> Hi,
>>
>> On 27/06/17 10:41, Maxime Ripard wrote:
>>> On Tue, Jun 27, 2017 at 10:02:45AM +0100, Andre Przywara wrote:
>>>> Hi,
>>>>
>>>> (CC:ing some people from that Rockchip dmwac series)
>>>>
>>>> On 27/06/17 09:21, Corentin Labbe wrote:
>>>>> On Tue, Jun 27, 2017 at 04:11:21PM +0800, Chen-Yu Tsai wrote:
>>>>>> On Tue, Jun 27, 2017 at 4:05 PM, Corentin Labbe
>>>>>> <clabbe.montjoie@gmail.com> wrote:
>>>>>>> On Mon, Jun 26, 2017 at 01:18:23AM +0100, André Przywara wrote:
>>>>>>>> On 31/05/17 08:18, Corentin Labbe wrote:
>>>>>>>>> The dwmac-sun8i is a heavy hacked version of stmmac hardware by
>>>>>>>>> allwinner.
>>>>>>>>> In fact the only common part is the descriptor management and
>> the first
>>>>>>>>> register function.
>>>>>>>>
>>>>>>>> Hi,
>>>>>>>>
>>>>>>>> I know I am a bit late with this, but while adapting the U-Boot
>> driver
>>>>>>>> to the new binding I was wondering about the internal PHY
>> detection:
>>>>>>>>
>>>>>>>>
>>>>>>>> So here you seem to deduce the usage of the internal PHY by the
>> PHY
>>>>>>>> interface specified in the DT (MII = internal, RGMII =
>> external).
>>>>>>>> I think I raised this question before, but isn't it perfectly
>> legal for
>>>>>>>> a board to use MII with an external PHY even on those SoCs that
>> feature
>>>>>>>> an internal PHY?
>>>>>>>> On the first glance that does not make too much sense, but apart
>> from
>>>>>>>> not being the correct binding to describe all of the SoCs
>> features I see
>>>>>>>> two scenarios:
>>>>>>>> 1) A board vendor might choose to not use the internal PHY
>> because it
>>>>>>>> has bugs, lacks features (configurability) or has other issues.
>> For
>>>>>>>> instance I have heard reports that the internal PHY makes the
>> SoC go
>>>>>>>> rather hot, possibly limiting the CPU frequency. By using an
>> external
>>>>>>>> MII PHY (which are still cheaper than RGMII PHYs) this can be
>> avoided.
>>>>>>>> 2) A PHY does not necessarily need to be directly connected to
>>>>>>>> magnetics. Indeed quite some boards use (RG)MII to connect to a
>> switch
>>>>>>>> IC or some other network circuitry, for instance fibre
>> connectors.
>>>>>>>>
>>>>>>>> So I was wondering if we would need an explicit:
>>>>>>>>       allwinner,use-internal-phy;
>>>>>>>> boolean DT property to signal the usage of the internal PHY?
>>>>>>>> Alternatively we could go with the negative version:
>>>>>>>>       allwinner,disable-internal-phy;
>>>>>>>>
>>>>>>>> Or what about introducing a new "allwinner,internal-mii-phy"
>> compatible
>>>>>>>> string for the *PHY* node and use that?
>>>>>>>>
>>>>>>>> I just want to avoid that we introduce a binding that causes us
>>>>>>>> headaches later. I think we can still fix this with a followup
>> patch
>>>>>>>> before the driver and its binding hit a release kernel.
>>>>>>>>
>>>>>>>> Cheers,
>>>>>>>> Andre.
>>>>>>>>
>>>>>>>
>>>>>>> I just see some patch, where "phy-mode = internal" is valid.
>>>>>>> I will try to find a way to use it
>>>>>>
>>>>>> Can you provide a link?
>>>>>
>>>>> https://lkml.org/lkml/2017/6/23/479
>>>>>
>>>>>>
>>>>>> I'm not a fan of using phy-mode for this. There's no guarantee
>> what
>>>>>> mode the internal PHY uses. That's what phy-mode is for.
>>>>
>>>> I can understand Chen-Yu's concerns, but ...
>>>>
>>>>> For each soc the internal PHY mode is know and setted in
>> emac_variant/internal_phy
>>>>> So its not a problem.
>>>>
>>>> that is true as well, at least for now.
>>>>
>>>> So while I agree that having a separate property to indicate the
>> usage
>>>> of the internal PHY would be nice, I am bit tempted to use this
>> easier
>>>> approach and piggy back on the existing phy-mode property.
>>>
>>> We're trying to fix an issue that works for now too.
>>>
>>> If we want to consider future weird cases, then we must consider all
>>> of them. And the phy mode changing is definitely not really far
>>> fetched.
>>>
>>> I agree with Chen-Yu, and I really feel like the compatible solution
>>> you suggested would cover both your concerns, and ours.
>>
>> So something like this?
>> 	emac: emac@1c30000 {
>> 	    compatible = "allwinner,sun8i-h3-emac";
>> 	    ...
>> 	    phy-mode = "mii";
>> 	    phy-handle = <&int_mii_phy>;
>> 	    ...
>>
>> 	    mdio: mdio {
>>                #address-cells = <1>;
>>                #size-cells = <0>;
>>                int_mii_phy: ethernet-phy@1 {
>>                    compatible = "allwinner,sun8i-h3-ephy";
>>                    syscon = <&syscon>;
> 
> The MAC still needs to set some bits of syscon register.

Yes, the syscon property needs also to be in the MAC node, that was
meant to be somewhere in the second "..." ;-)

But now since Chen-Yu mentioned that we need to set up the PHY *first*
to make it actually discoverable via MDIO, I wonder if we could change
this to:
1) have the DT as described here
2) Let the dwmac-sun8i driver peek into the node referenced by
phy-handle and check the compatible string there.
3) If that matches some allwinner internal PHY name, it sets up the PHY
to make it respond when the MDIO driver queries its bus.

Or can a PHY driver set itself up (since we have clocks and resets
properties in there) *before* the MDIO bus gets scanned?
Chen-Yu's comment in the other mail hints at that this is not easily
possible.

Cheers,
Andre.

> 
>>                    reg = <1>;
>>                    clocks = <&ccu CLK_BUS_EPHY>;
>>                    resets = <&ccu RST_BUS_EPHY>;
>>                };
>>            };
>>        };
>>
>> And then move the internal-PHY setup code into a separate PHY driver?
>>
>> That looks like the architecturally best solution to me, but is
>> probably
>> also a bit involved since it would require a separate PHY driver.
>> Or can we make it simpler, but still use this binding?
>>
>> Cheers,
>> Andre.

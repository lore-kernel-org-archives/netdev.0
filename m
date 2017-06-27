From: Icenowy Zheng <icenowy@aosc.io>
Subject: Re: [linux-sunxi] Re: [PATCH v6 05/21] net-next: stmmac: Add dwmac-sun8i
Date: Tue, 27 Jun 2017 18:17:58 +0800
Message-ID: <B87F7AC7-0742-4CA9-AB6B-C86C1598667B@aosc.io>
References: <20170531071852.12422-1-clabbe.montjoie@gmail.com> <20170531071852.12422-6-clabbe.montjoie@gmail.com> <8e3d73a7-e9ff-d3e2-4bce-bcc79cdf86db@arm.com> <20170627080529.GA2468@Red> <CAGb2v65mhDN9vXe6DE2cZPW1BzgYPwK+D2U5VFgyr0wVVZZqDQ@mail.gmail.com> <20170627082103.GB2468@Red> <530f7b3e-247d-2e4d-8174-ce6195bacf5b@arm.com> <20170627094111.supxmzf2k3n3ewec@flea.lan> <CAGb2v67btmyoHDDkvA9wp0pPdEHSu7DYN4=02VxskQqC6-qNDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Andre Przywara <andre.przywara@arm.com>,
        Corentin Labbe <clabbe.montjoie@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
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
        =?ISO-8859-1?Q?Heiko_St=FCbner?= <heiko@sntech.de>
To: wens@csie.org, Chen-Yu Tsai <wens@csie.org>,
        Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGb2v67btmyoHDDkvA9wp0pPdEHSu7DYN4=02VxskQqC6-qNDQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



于 2017年6月27日 GMT+08:00 下午6:11:47, Chen-Yu Tsai <wens@csie.org> 写到:
>On Tue, Jun 27, 2017 at 5:41 PM, Maxime Ripard
><maxime.ripard@free-electrons.com> wrote:
>> On Tue, Jun 27, 2017 at 10:02:45AM +0100, Andre Przywara wrote:
>>> Hi,
>>>
>>> (CC:ing some people from that Rockchip dmwac series)
>>>
>>> On 27/06/17 09:21, Corentin Labbe wrote:
>>> > On Tue, Jun 27, 2017 at 04:11:21PM +0800, Chen-Yu Tsai wrote:
>>> >> On Tue, Jun 27, 2017 at 4:05 PM, Corentin Labbe
>>> >> <clabbe.montjoie@gmail.com> wrote:
>>> >>> On Mon, Jun 26, 2017 at 01:18:23AM +0100, André Przywara wrote:
>>> >>>> On 31/05/17 08:18, Corentin Labbe wrote:
>>> >>>>> The dwmac-sun8i is a heavy hacked version of stmmac hardware
>by
>>> >>>>> allwinner.
>>> >>>>> In fact the only common part is the descriptor management and
>the first
>>> >>>>> register function.
>>> >>>>
>>> >>>> Hi,
>>> >>>>
>>> >>>> I know I am a bit late with this, but while adapting the U-Boot
>driver
>>> >>>> to the new binding I was wondering about the internal PHY
>detection:
>>> >>>>
>>> >>>>
>>> >>>> So here you seem to deduce the usage of the internal PHY by the
>PHY
>>> >>>> interface specified in the DT (MII = internal, RGMII =
>external).
>>> >>>> I think I raised this question before, but isn't it perfectly
>legal for
>>> >>>> a board to use MII with an external PHY even on those SoCs that
>feature
>>> >>>> an internal PHY?
>>> >>>> On the first glance that does not make too much sense, but
>apart from
>>> >>>> not being the correct binding to describe all of the SoCs
>features I see
>>> >>>> two scenarios:
>>> >>>> 1) A board vendor might choose to not use the internal PHY
>because it
>>> >>>> has bugs, lacks features (configurability) or has other issues.
>For
>>> >>>> instance I have heard reports that the internal PHY makes the
>SoC go
>>> >>>> rather hot, possibly limiting the CPU frequency. By using an
>external
>>> >>>> MII PHY (which are still cheaper than RGMII PHYs) this can be
>avoided.
>>> >>>> 2) A PHY does not necessarily need to be directly connected to
>>> >>>> magnetics. Indeed quite some boards use (RG)MII to connect to a
>switch
>>> >>>> IC or some other network circuitry, for instance fibre
>connectors.
>>> >>>>
>>> >>>> So I was wondering if we would need an explicit:
>>> >>>>       allwinner,use-internal-phy;
>>> >>>> boolean DT property to signal the usage of the internal PHY?
>>> >>>> Alternatively we could go with the negative version:
>>> >>>>       allwinner,disable-internal-phy;
>>> >>>>
>>> >>>> Or what about introducing a new "allwinner,internal-mii-phy"
>compatible
>>> >>>> string for the *PHY* node and use that?
>>> >>>>
>>> >>>> I just want to avoid that we introduce a binding that causes us
>>> >>>> headaches later. I think we can still fix this with a followup
>patch
>>> >>>> before the driver and its binding hit a release kernel.
>>> >>>>
>>> >>>> Cheers,
>>> >>>> Andre.
>>> >>>>
>>> >>>
>>> >>> I just see some patch, where "phy-mode = internal" is valid.
>>> >>> I will try to find a way to use it
>>> >>
>>> >> Can you provide a link?
>>> >
>>> > https://lkml.org/lkml/2017/6/23/479
>>> >
>>> >>
>>> >> I'm not a fan of using phy-mode for this. There's no guarantee
>what
>>> >> mode the internal PHY uses. That's what phy-mode is for.
>>>
>>> I can understand Chen-Yu's concerns, but ...
>>>
>>> > For each soc the internal PHY mode is know and setted in
>emac_variant/internal_phy
>>> > So its not a problem.
>>>
>>> that is true as well, at least for now.
>>>
>>> So while I agree that having a separate property to indicate the
>usage
>>> of the internal PHY would be nice, I am bit tempted to use this
>easier
>>> approach and piggy back on the existing phy-mode property.
>>
>> We're trying to fix an issue that works for now too.
>>
>> If we want to consider future weird cases, then we must consider all
>> of them. And the phy mode changing is definitely not really far
>> fetched.
>
>I guess the issue is whether it's likely that the vendor puts 2
>internal
>PHYs in one SoC, and they use different modes and can be switched
>around.
>Otherwise it's fixed for a given SoC, and we can just handle that with
>the per-SoC GMAC compatible.
>
>Maybe Florian could tell us if this was one of the intended use cases
>for the "internal" phy mode.
>
>As for Rockchip, AFAIK they have 2 MACs, one is connected to the
>internal
>PHY, while the other is connected to the external interface, and there
>is
>no muxing involved, unlike Allwinner's solution.
>
>> I agree with Chen-Yu, and I really feel like the compatible solution
>> you suggested would cover both your concerns, and ours.
>
>If using a PHY compatible is the solution, we could just use the
>"ethernet-phy-idAAAA.BBBB" style one, and put in the bogus ID that
>Allwinner used.
>
>Care must be taken to put this at the board level for boards using
>the internal PHY, or we'd have to delete or override the property
>in all other boards.
>
>Ideally I think the internal PHY device node should _not_ be in
>the SoC level .dtsi file. If we select the external interface, then
>there's no connection to the internal PHY, and that device node becomes
>unusable and bogus. This is something I think should be fixed
>regardless
>of the phy-mode discussion above.

I think it should be in the SoC DTSI, as it's part of the SoC.

But it makes sense to set status to disabled defaultly.

>
>ChenYu

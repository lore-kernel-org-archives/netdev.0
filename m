From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v6 05/21] net-next: stmmac: Add dwmac-sun8i
Date: Sat, 1 Jul 2017 14:42:14 -0700
Message-ID: <e5d4eb94-65b7-5cf6-2e50-41a6b3323ae2@gmail.com>
References: <CAGb2v65mhDN9vXe6DE2cZPW1BzgYPwK+D2U5VFgyr0wVVZZqDQ@mail.gmail.com>
 <20170627082103.GB2468@Red> <530f7b3e-247d-2e4d-8174-ce6195bacf5b@arm.com>
 <20170627094111.supxmzf2k3n3ewec@flea.lan>
 <44afb371-44d4-dbb5-0aac-4bbc55269344@arm.com>
 <700A8221-3CEC-4657-900D-183398D25AE7@aosc.io>
 <858b5361-fde5-8ab4-b9ba-aeb7859b9a7d@arm.com> <20170627123748.GA8403@Red>
 <20170627172937.qrbcie347wlbo3z3@flea>
 <42c51c03-2247-2d75-8534-51a96a92875c@gmail.com> <20170701065358.GC23363@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Andre Przywara <andre.przywara-5wv7dgnIgG8@public.gmane.org>,
        Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>, Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
        Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
        linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        =?UTF-8?Q?Heiko_St=c3=bcbner?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
To: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170701065358.GC23363@Red>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 30/06/2017 23:53, Corentin Labbe wrote:
> On Tue, Jun 27, 2017 at 10:37:34AM -0700, Florian Fainelli wrote:
>> On 06/27/2017 10:29 AM, Maxime Ripard wrote:
>>> On Tue, Jun 27, 2017 at 02:37:48PM +0200, Corentin Labbe wrote:
>>>> On Tue, Jun 27, 2017 at 11:33:56AM +0100, Andre Przywara wrote:
>>>>> Hi,
>>>>>
>>>>> On 27/06/17 11:23, Icenowy Zheng wrote:
>>>>>>
>>>>>>
>>>>>> 于 2017年6月27日 GMT+08:00 下午6:15:58, Andre Przywara <andre.przywara-5wv7dgnIgG8@public.gmane.org> 写到:
>>>>>>> Hi,
>>>>>>>
>>>>>>> On 27/06/17 10:41, Maxime Ripard wrote:
>>>>>>>> On Tue, Jun 27, 2017 at 10:02:45AM +0100, Andre Przywara wrote:
>>>>>>>>> Hi,
>>>>>>>>>
>>>>>>>>> (CC:ing some people from that Rockchip dmwac series)
>>>>>>>>>
>>>>>>>>> On 27/06/17 09:21, Corentin Labbe wrote:
>>>>>>>>>> On Tue, Jun 27, 2017 at 04:11:21PM +0800, Chen-Yu Tsai wrote:
>>>>>>>>>>> On Tue, Jun 27, 2017 at 4:05 PM, Corentin Labbe
>>>>>>>>>>> <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>>>>>>>>>>> On Mon, Jun 26, 2017 at 01:18:23AM +0100, André Przywara wrote:
>>>>>>>>>>>>> On 31/05/17 08:18, Corentin Labbe wrote:
>>>>>>>>>>>>>> The dwmac-sun8i is a heavy hacked version of stmmac hardware by
>>>>>>>>>>>>>> allwinner.
>>>>>>>>>>>>>> In fact the only common part is the descriptor management and
>>>>>>> the first
>>>>>>>>>>>>>> register function.
>>>>>>>>>>>>>
>>>>>>>>>>>>> Hi,
>>>>>>>>>>>>>
>>>>>>>>>>>>> I know I am a bit late with this, but while adapting the U-Boot
>>>>>>> driver
>>>>>>>>>>>>> to the new binding I was wondering about the internal PHY
>>>>>>> detection:
>>>>>>>>>>>>>
>>>>>>>>>>>>>
>>>>>>>>>>>>> So here you seem to deduce the usage of the internal PHY by the
>>>>>>> PHY
>>>>>>>>>>>>> interface specified in the DT (MII = internal, RGMII =
>>>>>>> external).
>>>>>>>>>>>>> I think I raised this question before, but isn't it perfectly
>>>>>>> legal for
>>>>>>>>>>>>> a board to use MII with an external PHY even on those SoCs that
>>>>>>> feature
>>>>>>>>>>>>> an internal PHY?
>>>>>>>>>>>>> On the first glance that does not make too much sense, but apart
>>>>>>> from
>>>>>>>>>>>>> not being the correct binding to describe all of the SoCs
>>>>>>> features I see
>>>>>>>>>>>>> two scenarios:
>>>>>>>>>>>>> 1) A board vendor might choose to not use the internal PHY
>>>>>>> because it
>>>>>>>>>>>>> has bugs, lacks features (configurability) or has other issues.
>>>>>>> For
>>>>>>>>>>>>> instance I have heard reports that the internal PHY makes the
>>>>>>> SoC go
>>>>>>>>>>>>> rather hot, possibly limiting the CPU frequency. By using an
>>>>>>> external
>>>>>>>>>>>>> MII PHY (which are still cheaper than RGMII PHYs) this can be
>>>>>>> avoided.
>>>>>>>>>>>>> 2) A PHY does not necessarily need to be directly connected to
>>>>>>>>>>>>> magnetics. Indeed quite some boards use (RG)MII to connect to a
>>>>>>> switch
>>>>>>>>>>>>> IC or some other network circuitry, for instance fibre
>>>>>>> connectors.
>>>>>>>>>>>>>
>>>>>>>>>>>>> So I was wondering if we would need an explicit:
>>>>>>>>>>>>>       allwinner,use-internal-phy;
>>>>>>>>>>>>> boolean DT property to signal the usage of the internal PHY?
>>>>>>>>>>>>> Alternatively we could go with the negative version:
>>>>>>>>>>>>>       allwinner,disable-internal-phy;
>>>>>>>>>>>>>
>>>>>>>>>>>>> Or what about introducing a new "allwinner,internal-mii-phy"
>>>>>>> compatible
>>>>>>>>>>>>> string for the *PHY* node and use that?
>>>>>>>>>>>>>
>>>>>>>>>>>>> I just want to avoid that we introduce a binding that causes us
>>>>>>>>>>>>> headaches later. I think we can still fix this with a followup
>>>>>>> patch
>>>>>>>>>>>>> before the driver and its binding hit a release kernel.
>>>>>>>>>>>>>
>>>>>>>>>>>>> Cheers,
>>>>>>>>>>>>> Andre.
>>>>>>>>>>>>>
>>>>>>>>>>>>
>>>>>>>>>>>> I just see some patch, where "phy-mode = internal" is valid.
>>>>>>>>>>>> I will try to find a way to use it
>>>>>>>>>>>
>>>>>>>>>>> Can you provide a link?
>>>>>>>>>>
>>>>>>>>>> https://lkml.org/lkml/2017/6/23/479
>>>>>>>>>>
>>>>>>>>>>>
>>>>>>>>>>> I'm not a fan of using phy-mode for this. There's no guarantee
>>>>>>> what
>>>>>>>>>>> mode the internal PHY uses. That's what phy-mode is for.
>>>>>>>>>
>>>>>>>>> I can understand Chen-Yu's concerns, but ...
>>>>>>>>>
>>>>>>>>>> For each soc the internal PHY mode is know and setted in
>>>>>>> emac_variant/internal_phy
>>>>>>>>>> So its not a problem.
>>>>>>>>>
>>>>>>>>> that is true as well, at least for now.
>>>>>>>>>
>>>>>>>>> So while I agree that having a separate property to indicate
>>>>>>>>> the usage of the internal PHY would be nice, I am bit tempted
>>>>>>>>> to use this easier approach and piggy back on the existing
>>>>>>>>> phy-mode property.
>>>>>>>>
>>>>>>>> We're trying to fix an issue that works for now too.
>>>>>>>>
>>>>>>>> If we want to consider future weird cases, then we must
>>>>>>>> consider all of them. And the phy mode changing is definitely
>>>>>>>> not really far fetched.
>>>>>>>>
>>>>>>>> I agree with Chen-Yu, and I really feel like the compatible
>>>>>>>> solution you suggested would cover both your concerns, and
>>>>>>>> ours.
>>>>>>>
>>>>>>> So something like this?
>>>>>>> 	emac: emac@1c30000 {
>>>>>>> 	    compatible = "allwinner,sun8i-h3-emac";
>>>>>>> 	    ...
>>>>>>> 	    phy-mode = "mii";
>>>>>>> 	    phy-handle = <&int_mii_phy>;
>>>>>>> 	    ...
>>>>>>>
>>>>>>> 	    mdio: mdio {
>>>>>>>                #address-cells = <1>;
>>>>>>>                #size-cells = <0>;
>>>>>>>                int_mii_phy: ethernet-phy@1 {
>>>>>>>                    compatible = "allwinner,sun8i-h3-ephy";
>>>>>>>                    syscon = <&syscon>;
>>>>>>
>>>>>> The MAC still needs to set some bits of syscon register.
>>>>>
>>>>> Yes, the syscon property needs also to be in the MAC node, that
>>>>> was meant to be somewhere in the second "..." ;-)
>>>>>
>>>>> But now since Chen-Yu mentioned that we need to set up the PHY *first*
>>>>> to make it actually discoverable via MDIO, I wonder if we could change
>>>>> this to:
>>>>> 1) have the DT as described here
>>>>> 2) Let the dwmac-sun8i driver peek into the node referenced by
>>>>> phy-handle and check the compatible string there.
>>>>> 3) If that matches some allwinner internal PHY name, it sets up the PHY
>>>>> to make it respond when the MDIO driver queries its bus.
>>>>>
>>>>> Or can a PHY driver set itself up (since we have clocks and resets
>>>>> properties in there) *before* the MDIO bus gets scanned?
>>>>> Chen-Yu's comment in the other mail hints at that this is not easily
>>>>> possible.
>>>>
>>>> I think adding phy compatible just make things more complex.
>>>>
>>>> I think the patch series I sent early fix all problems without more
>>>> complexity since:
>>>>
>>>> - it does not add more DT stuff
>>>> - it use an already used in tree DT phy-mode "internal" (and so phy
>>>>   mode PHY_INTERFACE_MODE_INTERNAL)
>>>
>>>   - it doesn't cover all the concerns we ha>   - it uses an undocumented value, with an unclear implication
>>
>> No it's no longer undocumented since [1]
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=29b65f5f97632722bb80969377e5b0e2401fb392
>>
>> Due to the timezone difference, you guys have already managed to have
>> several exchanges, hopefully I will have a chance to review your
>> discussions a little later today.
> 
> Hello
> 
> I wait for your comment before sending my reverts patch for http://www.mail-archive.com/linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg1431579.html
> Could you confirm that internal is only meant for "non xMII internal protocol"

Yes that's what is it meant for. There are possibly two ways here:

1) assuming there is already a specific PHY driver for that internal
PHY, you should have this PHY driver set PHY_IS_INTERNAL (see bcm63xx.c
and bcm7xxx.c that do that) and so you would know that you did bind to
the correct internal PHY driver. Problem with that is if you need to
perform a particular action such that you will successfully bind to the
internal PHY (e.g: power on, reset, etc.)

2) We could create a new set of phy-mode values that are, e.g:

'internal-mii': internal MII connection to the PHY

and so on in order to cover the internal variants of those modes. I am
not sure this is strictly needed here though.
--
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

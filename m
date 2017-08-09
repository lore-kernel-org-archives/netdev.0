From: "David.Wu" <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: Re: [PATCH v3 05/11] net: stmmac: dwmac-rk: Add internal phy support
Date: Wed, 9 Aug 2017 17:38:18 +0800
Message-ID: <a9fae87c-9df5-a250-5bc1-230be4af15cd@rock-chips.com>
References: <1501654546-17292-1-git-send-email-david.wu@rock-chips.com>
 <1501654888-19514-1-git-send-email-david.wu@rock-chips.com>
 <6b1ebf64-6903-6d35-b1fc-92ec47334425@gmail.com>
 <CAGb2v65Rtw2B3Hcs4L0jTRQ2ApUduJ+Nf1W1XnqXBBmFwMaP-g@mail.gmail.com>
 <20170809084541.GB7137@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset=gbk; format=flowed
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?Q?Heiko_St=c3=bcbner?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
        Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>,
        Olof Johansson <olof-nZhT3qVonbNeoWH0uzbU5w@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Tao Huang <huangtao-TNX95d0MmH7DzftRWevZcw@public.gmane.org>, hwg-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "open list:ARM/Rockchip SoC..." <linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        wens-jdAy2FN1RRM@public.gmane.org
To: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        andrew-g2DYL2Zd6BY@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170809084541.GB7137@Red>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Corentin, Chen-Yu

ÔÚ 2017/8/9 16:45, Corentin Labbe Ð´µÀ:
> On Thu, Aug 03, 2017 at 07:06:33PM +0800, Chen-Yu Tsai wrote:
>> On Thu, Aug 3, 2017 at 1:38 AM, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>> On 08/01/2017 11:21 PM, David Wu wrote:
>>>> To make internal phy work, need to configure the phy_clock,
>>>> phy cru_reset and related registers.
>>>>
>>>> Signed-off-by: David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
>>>> ---
>>>>   .../devicetree/bindings/net/rockchip-dwmac.txt     |  6 +-
>>>>   drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 81 ++++++++++++++++++++++
>>>>   2 files changed, 86 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
>>>> index 8f42755..ec39b31 100644
>>>> --- a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
>>>> +++ b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
>>>> @@ -25,7 +25,8 @@ Required properties:
>>>>    - clock-names: One name for each entry in the clocks property.
>>>>    - phy-mode: See ethernet.txt file in the same directory.
>>>>    - pinctrl-names: Names corresponding to the numbered pinctrl states.
>>>> - - pinctrl-0: pin-control mode. can be <&rgmii_pins> or <&rmii_pins>.
>>>> + - pinctrl-0: pin-control mode. can be <&rgmii_pins>, <&rmii_pins> or led pins
>>>> +   for internal phy mode.
>>>>    - clock_in_out: For RGMII, it must be "input", means main clock(125MHz)
>>>>      is not sourced from SoC's PLL, but input from PHY; For RMII, "input" means
>>>>      PHY provides the reference clock(50MHz), "output" means GMAC provides the
>>>> @@ -40,6 +41,9 @@ Optional properties:
>>>>    - tx_delay: Delay value for TXD timing. Range value is 0~0x7F, 0x30 as default.
>>>>    - rx_delay: Delay value for RXD timing. Range value is 0~0x7F, 0x10 as default.
>>>>    - phy-supply: phandle to a regulator if the PHY needs one
>>>> + - clocks: <&cru MAC_PHY>: Clock selector for internal macphy
>>>> + - phy-is-internal: A boolean property allows us to know that MAC will connect to
>>>> +   internal phy.
>>>
>>> This is incorrect in two ways:
>>>
>>> - this is a property of the PHY, so it should be documented as such in
>>> Documentation/devicetree/bindings/net/phy.txt so other bindings can
>>> re-use it
>>>
>>> - if it was specific to your MAC you would expect a vendor prefix to
>>> this property, which is not there
>>>
>>> An alternative way to implement the external/internal logic selection
>>> would be mandate that your Ethernet PHY node have a compatible string
>>> like this:
>>>
>>> phy@0 {
>>>          compatible = "ethernet-phy-id1234.d400", "ethernet-phy-802.3-c22";
>>> };
>>>
>>> Then you don't need this phy-is-internal property, because you can
>>> locate the PHY node by the phy-handle (see more about that in a reply to
>>> patch 10) and you can determine ahead of time whether this PHY is
>>> internal or not based on its compatible string.
>>
>> This doesn't really work for us (sunxi). The "internal" PHY of the H3
>> is also available in the X-Powers AC200 combo chip, which would be
>> external. Same ID. So if someone were to be stupid and put the two
>> together, you wouldn't know which one it actually is. Generically
>> it doesn't make sense to match against the ID either. The PHY is
>> only integrated or inlined into the SoC, meaning it could be moved
>> elsewhere or even be a discreet part.
>>
>> The way I see it is more like a reversed pinmux. The system should
>> select either the internal set or external set of xMII pins to use.
>>
>> A phy-is-internal property in the PHY node would work for us. We
>> already need a PHY node to describe its clocks and resets.
>>
>> A side note to this solution is that, since the internal PHY is defined
>> at the .dtsi level, any external PHYs at the same address would need to
>> make sure to delete the property, which is kind of counterintuitive, but
>> it is how device tree works. One would want to put the internal PHY's
>> address, assuming it is configurable, on something that is rarely used.
>>
> 
> Hello David, Florian, Andrew
> 
> Could someone ack this ? or nack if you think that the chance for having two PHY id both internal and external is too low.
> Anyway, we need a choice.
> 

I think we should be specific to the situation, for us we have the 
possibility that the Mac only picks up internal PHY, so this can be 
fixed at the. DTSi level, also possible INTERNL PHY's Mac can also be 
used to connect external PHY, while cutting off the connection with the 
internal PHY, so we should define the internal PHY at the DTS level, so 
I think Florian's approach is acceptable.

> Regards
> 
> 
> 

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

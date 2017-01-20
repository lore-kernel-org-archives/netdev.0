From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: Re: [PATCH net-next v4 2/2] net: stmmac: dwmac-meson8b: make the
 RGMII TX delay configurable
Date: Fri, 20 Jan 2017 14:47:58 +0100
Message-ID: <CAFBinCBvDddU0DDcDfBRPkS+mWi61C0ON5_fneog-jnjOdevXA@mail.gmail.com>
References: <20161202233238.17561-1-martin.blumenstingl@googlemail.com>
 <20161217182119.4037-1-martin.blumenstingl@googlemail.com>
 <20161217182119.4037-3-martin.blumenstingl@googlemail.com>
 <20161218.104950.1013829528388480468.davem@davemloft.net>
 <CAFBinCDZ_mqt8q2rG6zDy8ke5sX6L+4sVYOOhWUdO3apwFiRYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, devicetree@vger.kernel.org, alexandre.torgue@st.com,
 netdev@vger.kernel.org, peppe.cavallaro@st.com, robh+dt@kernel.org,
 khilman@baylibre.com, carlo@caione.org, linux-amlogic@lists.infradead.org,
 linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAFBinCDZ_mqt8q2rG6zDy8ke5sX6L+4sVYOOhWUdO3apwFiRYw@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi David,

On Sun, Dec 18, 2016 at 5:13 PM, Martin Blumenstingl
<martin.blumenstingl@googlemail.com> wrote:
> On Sun, Dec 18, 2016 at 4:49 PM, David Miller <davem@davemloft.net> wrote:
>> From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
>> Date: Sat, 17 Dec 2016 19:21:19 +0100
>>
>>> Prior to this patch we were using a hardcoded RGMII TX clock delay of
>>> 2ns (= 1/4 cycle of the 125MHz RGMII TX clock). This value works for
>>> many boards, but unfortunately not for all (due to the way the actual
>>> circuit is designed, sometimes because the TX delay is enabled in the
>>> PHY, etc.). Making the TX delay on the MAC side configurable allows us
>>> to support all possible hardware combinations.
>>>
>>> This allows fixing a compatibility issue on some boards, where the
>>> RTL8211F PHY is configured to generate the TX delay. We can now turn
>>> off the TX delay in the MAC, because otherwise we would be applying the
>>> delay twice (which results in non-working TX traffic).
>>>
>>> Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
>>> Tested-by: Neil Armstrong <narmstrong@baylibre.com>
>>
>> Is this really the safest thing to do?
>>
>> If you say the existing hard-coded setting of 1/4 cycle works on most
>> boards, and what you're trying to do is override it with an OF
>> property value for boards where the existing setting does not work,
>> then you _must_ use a default value that corresponds to what the
>> existing code does not when you don't see this new OF property.
> it's a bit more complicated in reality: 1/4 cycle works when the TX
> delay of the RTL8211F PHY is turned off (until recently it was always
> enabled for phy-mode RGMII).
>
>> So please retain the current behavior of the 1/4 cycle TX delay
>> setting when you don't see the amlogic,tx-delay-ns property.
>>
>> I really think you risk breaking existing boards by not doing so,
>> unless you can have this patch tested on every such board that exists
>> and I don't think you really can feasibly and rigorously do that.
> there's a patch in my follow-up series which adds the 2ns to the .dts
> for all RGMII based boards: [0] (and I would keep these even if we had
> a default value, just to make it explicit and thus easier to
> understand for other people).
> however, we can add the 2ns default back (I can do this if you want -
> Rob Herring was unhappy with the missing documentation of this default
> value [1] - so note to myself: take care of that as well). but then we
> have to decide when to apply this default value: only when we're in
> RGMII mode or also in any of the RGMII_*ID modes?
could you please let me know if I should add a a fallback (2ns which
was the old hardcoded value) to the driver or if I should simply leave
it out (that's the way it is right now).
I'm fine with either way, I would just like to avoid duplicate work.
So please let me know how you prefer it.


Regards,
Martin

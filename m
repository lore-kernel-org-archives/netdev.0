From: Caesar Wang <caesar.upstream@gmail.com>
Subject: Re: [PATCH 0/6] arc_emac: fixes the emac issues oand cleanup emac
 drivers
Date: Sun, 13 Mar 2016 12:04:41 +0800
Message-ID: <56E4E6D9.8060103@gmail.com>
References: <1457693731-6966-1-git-send-email-wxt@rock-chips.com>
 <56E2CC39.6050907@cogentembedded.com> <56E2DAC4.4020105@gmail.com>
 <56E3126C.7000100@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Caesar Wang <caesar.upstream@gmail.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Heiko Stuebner <heiko@sntech.de>,
	Alexander Kochetkov <al.kochet@gmail.com>,
	Michael Turquette <mturquette@baylibre.com>,
	linux-clk@vger.kernel.org, Russell King <linux@arm.linux.org.uk>,
	zhengxing <zhengxing@rock-chips.com>,
	linux-rockchip@lists.infradead.org,
	Caesar Wang <wxt@rock-chips.com>, devicetree@vger.kernel.org,
	Pawel Moll <pawel.moll@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Rob Herring <robh+dt@kernel.org>,
	linux-arm-kernel@lists.infradead.org,
	Jiri Kosina <trivial@kernel.org>, netdev@vger.kernel.org,
	Stephen Boyd <sboyd@codeaurora.org>,
	linux-kernel@vger.kernel.org, keescook@google.com,
	"David S. Miller" <davem@davemloft.net>, leozwang@google.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-clk-owner@vger.kernel.org>
In-Reply-To: <56E3126C.7000100@cogentembedded.com>
Sender: linux-clk-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



=E5=9C=A8 2016=E5=B9=B403=E6=9C=8812=E6=97=A5 02:46, Sergei Shtylyov =E5=
=86=99=E9=81=93:
> Hello.
>
> On 03/11/2016 05:48 PM, Caesar Wang wrote:
>
> [...]
>
>>>> Hi Rob, David:
>>>> PATCH[1/6-2/6]: =3D=3D=3D=3D>
>>>> net: arc_emac: make the rockchip emac document more compatible
>>>> net: arc_emac: add phy-reset-* are optional for device tree
>>>>
>>>> The patches change the rockchip emac document for more compatible =
and
>>>> Add the phy-reset-* property for document.
>>>>
>>>> This patch adds the following property for arc_emac.
>>>>
>>>> phy-reset-* include the following:
>>>> 1) phy-reset-gpios:
>>>> The phy-reset-gpios is an optional property for arc emac device=20
>>>> tree boot.
>>>> Change the binding document to match the driver code.
>>>>
>>>> 2) phy-reset-duration:
>>>> Different boards may require different phy reset duration. Add=20
>>>> property
>>>> phy-reset-duration for device tree probe, so that the boards that =
need
>>>> a longer reset duration can specify it in their device tree.
>>>>
>>>> 3) phy-reset-active-high:
>>>> We need that for a custom hardware that needs the reverse reset=20
>>>> sequence.
>>>
>>>    Why not infer this from the "phy-reset-gpios" prop?
>>
>> See:
>> https://patchwork.kernel.org/patch/8564511/
> >
>> phy-reset-active-high : If present then the reset sequence using the=
=20
>> GPIO
>>   specified in the "phy-reset-gpios" property is reversed (H=3Dreset=
=20
>> state,
>>   L=3Doperation state).
>
>    Referring to your own suggested bindings isn't an answer. If the=20
> driver that you're copying from here (fec) had a reason to handle the=
=20
> GPIO sense with the help of an extra prop (legacy code), it doesn't=20
> mean your new driver needs to mimic this as well, AFAIU...

I know your suggestion is a fair request.

Oh, that copy from the 'freescale/fec_main.c' ....

So, The exist way was old and unwise in mainline. :(

wxt@nb:~/kernel/drivers/net/ethernet$ ag reset-gpios
micrel/ks8851.c
1427:    gpio =3D of_get_named_gpio_flags(spi->dev.of_node, "reset-gpio=
s",

arc/emac_main.c
787:    phy_reset =3D of_get_named_gpio(np, "phy-reset-gpios", 0);
797:        dev_err(dev, "failed to get phy-reset-gpios: %d\n", err);

arc/emac_main.c~
784:    phy_reset =3D of_get_named_gpio(np, "phy-reset-gpios", 0);
794:        dev_err(dev, "failed to get phy-reset-gpios: %d\n", err);

davicom/dm9000.c
1451:    reset_gpios =3D of_get_named_gpio_flags(dev->of_node,=20
"reset-gpios", 0,

freescale/fec_main.c
3206:    phy_reset =3D of_get_named_gpio(np, "phy-reset-gpios", 0);
3216:        dev_err(&pdev->dev, "failed to get phy-reset-gpios: %d\n",=
=20
err);

cadence/macb.c
2958:        int gpio =3D of_get_named_gpio(phy_node, "reset-gpios", 0)=
;

=2E..


Anyway, I will update it with your suggestion.

Thanks,


Caesar





>
>> Thanks,
>>
>> Caesar
>
> MBR, Sergei
>
>
> _______________________________________________
> Linux-rockchip mailing list
> Linux-rockchip@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-rockchip


--=20
Thanks,
Caesar


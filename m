From: Caesar Wang <caesar.upstream@gmail.com>
Subject: Re: [PATCH v3 2/9] net: arc_emac: add phy reset is optional for
 device tree
Date: Thu, 17 Mar 2016 18:02:47 +0800
Message-ID: <56EA80C7.30303@gmail.com>
References: <1457942520-12859-1-git-send-email-wxt@rock-chips.com>
 <1457942520-12859-3-git-send-email-wxt@rock-chips.com>
 <56E96656.5000101@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Caesar Wang <wxt@rock-chips.com>, Heiko Stuebner <heiko@sntech.de>,
	"David S. Miller" <davem@davemloft.net>,
	Rob Herring <robh+dt@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	devicetree@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	netdev@vger.kernel.org, Kumar Gala <galak@codeaurora.org>,
	linux-kernel@vger.kernel.org, linux-rockchip@lists.infradead.org,
	keescook@google.com, leozwang@google.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33719 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966709AbcCQKCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 06:02:54 -0400
In-Reply-To: <56E96656.5000101@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

=E5=9C=A8 2016=E5=B9=B403=E6=9C=8816=E6=97=A5 21:57, Sergei Shtylyov =E5=
=86=99=E9=81=93:
> Hello.
>
> On 3/14/2016 11:01 AM, Caesar Wang wrote:
>
>> This patch adds the following property for arc_emac.
>>
>> 1) phy-reset-gpios:
>> The phy-reset-gpio is an optional property for arc emac device tree=20
>> boot.
>> Change the binding document to match the driver code.
>>
>> 2) phy-reset-duration:
>> Different boards may require different phy reset duration. Add prope=
rty
>> phy-reset-duration for device tree probe, so that the boards that ne=
ed
>> a longer reset duration can specify it in their device tree.
>>
>> Anyway, we can add the above property for arc emac.
>>
>> Signed-off-by: Caesar Wang <wxt@rock-chips.com>
>
>   Could you have a look at drivers/net/ethernet/cadence/macb/? It=20
> seems to be the only driver which places the PHY's "reset-gpios" prop=
=20
> correctly, into the PHY subnode? I'm currently working on adding=20
> support of this prop into phylib...

I see the driver on now.


     /* Power up the PHY if there is a GPIO reset */
     phy_node =3D  of_get_next_available_child(np, NULL);
     if (phy_node) {
         int gpio =3D of_get_named_gpio(phy_node, "reset-gpios", 0);
         if (gpio_is_valid(gpio))
             bp->reset_gpio =3D gpio_to_desc(gpio);
         gpiod_set_value(bp->reset_gpio, GPIOD_OUT_HIGH);
     }
     of_node_put(phy_node);
=2E..

=46rankly, I don't like this way in device drivers.
That's seem same with the /drivers/mmc/core/pwrseq_simple.c,  power up=20
the device.
Is it not really reset hardware PHY from the gpio reset pin?  Just powe=
r up.

Of course, I hope to see and test it if you improve the PHY framework t=
o=20
support the phy reset.:-)

---

Anyway,  David had applied this series patches into net branch.

Although the clock and dts patches should be applied into Heiko branch,=
 =20
I'm glad to see David's way.

Heiko branch:
https://git.kernel.org/cgit/linux/kernel/git/mmind/linux-rockchip.git/


I wish won't destory Heiko to merge in the future.


-Caesar



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

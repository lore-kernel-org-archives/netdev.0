From: icenowy-h8G6r0blFSE@public.gmane.org
Subject: Re: [PATCH v2 3/4] net: phy: realtek: add disable RX
 internal delay mode
Date: Thu, 24 Aug 2017 16:05:54 +0800
Message-ID: <7c43220aef447e5cf21e48a9eca18535@aosc.io>
References: <20170822040400.12166-1-icenowy@aosc.io>
 <20170822040400.12166-4-icenowy@aosc.io> <20170822133906.GG24555@lunn.ch>
Reply-To: icenowy-h8G6r0blFSE@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, Corentin Labbe
 <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>, Maxime Ripard
 <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <linux-sunxi+bncBDS6XAN6ZADRBZMR7LGAKGQEQRFYWJQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20170822133906.GG24555-g2DYL2Zd6BY@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

=E5=9C=A8 2017-08-22 21:39=EF=BC=8CAndrew Lunn =E5=86=99=E9=81=93=EF=BC=9A
> On Tue, Aug 22, 2017 at 12:03:59PM +0800, Icenowy Zheng wrote:
>> From: Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
>>=20
>> Some RTL8211E chips have broken GbE function, which needs a hack to
>> fix. It's said that this fix will affect the performance on not-buggy
>> PHYs, so it should only be enabled on boards with the broken PHY.
>=20
> I would not call this a broken PHY. It is a question of board
> design. If you have shorter tracks, you need a delay. If you have long
> tracks, you don't. Hence the four RGMII modes, so you can select if
> the delay is needed or not, depending on your board design.
>=20
>> Currently only some Pine64+ boards are known to have this issue.
>=20
> Design feature.
>=20
> Please remove all reference to bug.
>=20
>> This hack is said to disable RX relay for RTL8211E according to=20
>> Realtek.
>> So implement it as RGMII-TXID mode.
>=20
> Do we know that the TX lines do have a delay after making this change?
> We need to be careful here. We will get into a mess if this is
> actually RGMII not RGMII_TXID, and somebody designs a board which
> needs RGMII-TXID.

In fact I'm not sure -- I'm even not sure that after making this change
there's no TX delay. The change is totally not documented, so I choose
to use a custom property in v1.

But Florian required me to use RGMII-TXID instead.

>=20
>> +#include <linux/of.h>
>>  #include <linux/phy.h>
>>  #include <linux/module.h>
>=20
>> +static int rtl8211e_config_init(struct phy_device *phydev)
>> +{
>> +	struct device *dev =3D &phydev->mdio.dev;
>> +	struct device_node *of_node =3D dev->of_node;
>=20
> You don't appear to use of_node, nor dev. Please remove, along with
> the header file.
>=20
>     Andrew
>=20
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--=20
You received this message because you are subscribed to the Google Groups "=
linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.

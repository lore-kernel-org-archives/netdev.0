From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8168: r8168 fixes
Date: Wed, 3 Jun 2009 21:49:33 +0200
Message-ID: <20090603194932.GA24847@electric-eye.fr.zoreil.com>
References: <b2d58cb80906030144m6cb7c848se1fe5f471b4688ed@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, edward_hsu@realtek.com
To: Nishit Shah <nsshah.82@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:48752 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750954AbZFCTrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 15:47:53 -0400
Content-Disposition: inline
In-Reply-To: <b2d58cb80906030144m6cb7c848se1fe5f471b4688ed@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nishit Shah <nsshah.82@gmail.com> :
[...]
> The following patch fixes three r8168 bugs:

Please Cc: edward_hsu@realtek.com when you send patches for the
out-of-tree r8168 driver.

> 1) vlan tag missing in transmit path. Due to incorrect assignment of
> transmit vlan tag option, driver is not able to transmit data on vlan
> interface.

The fix does not seem completely right either, see below.

> 2) compilation warning with rtl8168_powerup_pll if CONFIG_PM isn=E2=80=
=99t defined.
>=20
> 3) compilation warning with unused variable dev in rtl8168_tx_clear.
>=20
> Signed-off-by: Rajesh Modhwadiya <rajesh.modhwadiya@elitecore.com>
> Signed-off-by: Nishit Shah <nishit.shah@elitecore.com>
[...]
> --- r8168-8.011.00/src/r8168_n.c        2009-02-18 09:23:21.000000000=
 +0530
> +++ r8168-8.011.00-tmp/src/r8168_n.c    2009-05-15 01:40:57.000000000=
 +0530
> @@ -808,6 +808,8 @@
>         }
>  }
>=20
> +#ifdef CONFIG_PM
> +
>  static void
>  rtl8168_powerup_pll(struct net_device *dev)  { @@ -825,6 +827,8 @@
>         rtl8168_set_speed(dev, tp->autoneg, tp->speed, tp->duplex);  =
}
>=20
> +#endif /* CONFIG_PM */
> +
>  static void
>  rtl8168_get_wol(struct net_device *dev,
>                 struct ethtool_wolinfo *wol) @@ -4151,7 +4155,6 @@

The patch is garbled.

> rtl8168_tx_clear(struct rtl8168_private *tp)  {
>         unsigned int i;
> -       struct net_device *dev =3D tp->dev;
>=20
>         for (i =3D tp->dirty_tx; i < tp->dirty_tx + NUM_TX_DESC; i++)=
 {
>                 unsigned int entry =3D i % NUM_TX_DESC; @@ -4436,7 +4=
439,7 @@
>=20
>         tp->tx_skb[entry].len =3D len;
>         txd->addr =3D cpu_to_le64(mapping);
> -       txd->opts2 =3D cpu_to_le32(rtl8168_tx_vlan_tag(tp, skb));
> +       opts2 |=3D cpu_to_le32(rtl8168_tx_vlan_tag(tp, skb));
>=20
>         wmb();
[...]
        status2 =3D opts2;
[...]
        txd->opts2 =3D cpu_to_le32(status2);

txd->opts2 =3D cpu_to_le32( ... | cpu_to_le32(rtl8168_tx_vlan_tag(tp, s=
kb)));

-> cpu_to_le32 twice ?

--=20
Ueimor

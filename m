From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 3/3] ne-h8300: Fix regression caused during net_device_ops conversion
Date: Thu, 12 May 2011 21:16:06 +0200
Message-ID: <BANLkTik1_YpK-4X_+Axs9Zicne_zGVoGHg@mail.gmail.com>
References: <1305227500-15595-1-git-send-email-geert@linux-m68k.org>
	<1305227500-15595-4-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Russell King <linux@arm.linux.org.uk>,
	Finn Thain <fthain@telegraphics.com.au>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-m68k@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>, stable@kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305227500-15595-4-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 12, 2011 at 21:11, Geert Uytterhoeven <geert@linux-m68k.org=
> wrote:
> From: Geert Uytterhoeven <geert@chicken.sonytel.be>

Sorry, the above line is bogus. Please remove it.

> Changeset dcd39c90290297f6e6ed8a04bb20da7ac2b043c5 ("ne-h8300: conver=
t to
> net_device_ops") broke ne-h8300 by adding 8390.o to the link. That
> meant that lib8390.c was included twice, once in ne-h8300.c and once =
in
> 8390.c, subject to different macros. This patch reverts that by
> avoiding the wrappers in 8390.c.
>
> Fix based on commits 217cbfa856dc1cbc2890781626c4032d9e3ec59f ("mac83=
90:
> fix regression caused during net_device_ops conversion") and
> 4e0168fa4842e27795a75b205a510f25b62181d9 ("mac8390: fix build with
> NET_POLL_CONTROLLER").
>
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Cc: stable@kernel.org
> ---
> =C2=A0drivers/net/Makefile =C2=A0 | =C2=A0 =C2=A02 +-
> =C2=A0drivers/net/ne-h8300.c | =C2=A0 16 ++++++++--------
> =C2=A02 files changed, 9 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index 4d2f094..e5a7375 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -144,7 +144,7 @@ obj-$(CONFIG_NE3210) +=3D ne3210.o 8390.o
> =C2=A0obj-$(CONFIG_SB1250_MAC) +=3D sb1250-mac.o
> =C2=A0obj-$(CONFIG_B44) +=3D b44.o
> =C2=A0obj-$(CONFIG_FORCEDETH) +=3D forcedeth.o
> -obj-$(CONFIG_NE_H8300) +=3D ne-h8300.o 8390.o
> +obj-$(CONFIG_NE_H8300) +=3D ne-h8300.o
> =C2=A0obj-$(CONFIG_AX88796) +=3D ax88796.o
> =C2=A0obj-$(CONFIG_BCM63XX_ENET) +=3D bcm63xx_enet.o
> =C2=A0obj-$(CONFIG_FTMAC100) +=3D ftmac100.o
> diff --git a/drivers/net/ne-h8300.c b/drivers/net/ne-h8300.c
> index 30be8c6..7298a34 100644
> --- a/drivers/net/ne-h8300.c
> +++ b/drivers/net/ne-h8300.c
> @@ -167,7 +167,7 @@ static void cleanup_card(struct net_device *dev)
> =C2=A0#ifndef MODULE
> =C2=A0struct net_device * __init ne_probe(int unit)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 struct net_device *dev =3D alloc_ei_netdev();
> + =C2=A0 =C2=A0 =C2=A0 struct net_device *dev =3D ____alloc_ei_netdev=
(0);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int err;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!dev)
> @@ -197,15 +197,15 @@ static const struct net_device_ops ne_netdev_op=
s =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_open =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =3D ne_open,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_stop =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =3D ne_close,
>
> - =C2=A0 =C2=A0 =C2=A0 .ndo_start_xmit =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D=
 ei_start_xmit,
> - =C2=A0 =C2=A0 =C2=A0 .ndo_tx_timeout =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D=
 ei_tx_timeout,
> - =C2=A0 =C2=A0 =C2=A0 .ndo_get_stats =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0=3D ei_get_stats,
> - =C2=A0 =C2=A0 =C2=A0 .ndo_set_multicast_list =3D ei_set_multicast_l=
ist,
> + =C2=A0 =C2=A0 =C2=A0 .ndo_start_xmit =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D=
 __ei_start_xmit,
> + =C2=A0 =C2=A0 =C2=A0 .ndo_tx_timeout =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D=
 __ei_tx_timeout,
> + =C2=A0 =C2=A0 =C2=A0 .ndo_get_stats =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0=3D __ei_get_stats,
> + =C2=A0 =C2=A0 =C2=A0 .ndo_set_multicast_list =3D __ei_set_multicast=
_list,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_validate_addr =C2=A0 =C2=A0 =C2=A0=3D=
 eth_validate_addr,
> - =C2=A0 =C2=A0 =C2=A0 .ndo_set_mac_address =C2=A0 =C2=A0=3D eth_mac_=
addr,
> + =C2=A0 =C2=A0 =C2=A0 .ndo_set_mac_address =C2=A0 =C2=A0=3D eth_mac_=
addr,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_change_mtu =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =3D eth_change_mtu,
> =C2=A0#ifdef CONFIG_NET_POLL_CONTROLLER
> - =C2=A0 =C2=A0 =C2=A0 .ndo_poll_controller =C2=A0 =C2=A0=3D ei_poll,
> + =C2=A0 =C2=A0 =C2=A0 .ndo_poll_controller =C2=A0 =C2=A0=3D __ei_pol=
l,
> =C2=A0#endif
> =C2=A0};
>
> @@ -637,7 +637,7 @@ int init_module(void)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int err;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (this_dev =3D 0; this_dev < MAX_NE_CAR=
DS; this_dev++) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct net_device =
*dev =3D alloc_ei_netdev();
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct net_device =
*dev =3D ____alloc_ei_netdev(0);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (io[this_de=
v]) {
> --
> 1.7.0.4

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds

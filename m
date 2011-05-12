From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 2/3] hydra: Fix regression caused during net_device_ops conversion
Date: Thu, 12 May 2011 21:15:01 +0200
Message-ID: <BANLkTinjoDhQRZ+1nc2uow3bWepziGMf0g@mail.gmail.com>
References: <1305227500-15595-1-git-send-email-geert@linux-m68k.org>
	<1305227500-15595-3-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Russell King <linux@arm.linux.org.uk>,
	Finn Thain <fthain@telegraphics.com.au>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-m68k@vger.kernel.org,
	Geert Uytterhoeven <geert@chicken.sonytel.be>,
	Geert Uytterhoeven <geert@linux-m68k.org>, stable@kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305227500-15595-3-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 12, 2011 at 21:11, Geert Uytterhoeven <geert@linux-m68k.org=
> wrote:
> From: Geert Uytterhoeven <geert@chicken.sonytel.be>

Sorry, the above line is bogus. Please remove it.

> Changeset 5618f0d1193d6b051da9b59b0e32ad24397f06a4 ("hydra: convert t=
o
> net_device_ops") broke hydra by adding 8390.o to the link. That
> meant that lib8390.c was included twice, once in hydra.c and once in
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
> =C2=A0drivers/net/Makefile | =C2=A0 =C2=A02 +-
> =C2=A0drivers/net/hydra.c =C2=A0| =C2=A0 14 +++++++-------
> =C2=A02 files changed, 8 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index c64675f..4d2f094 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -231,7 +231,7 @@ obj-$(CONFIG_SGI_IOC3_ETH) +=3D ioc3-eth.o
> =C2=A0obj-$(CONFIG_DECLANCE) +=3D declance.o
> =C2=A0obj-$(CONFIG_ATARILANCE) +=3D atarilance.o
> =C2=A0obj-$(CONFIG_A2065) +=3D a2065.o
> -obj-$(CONFIG_HYDRA) +=3D hydra.o 8390.o
> +obj-$(CONFIG_HYDRA) +=3D hydra.o
> =C2=A0obj-$(CONFIG_ARIADNE) +=3D ariadne.o
> =C2=A0obj-$(CONFIG_CS89x0) +=3D cs89x0.o
> =C2=A0obj-$(CONFIG_MACSONIC) +=3D macsonic.o
> diff --git a/drivers/net/hydra.c b/drivers/net/hydra.c
> index c5ef62c..1cd481c 100644
> --- a/drivers/net/hydra.c
> +++ b/drivers/net/hydra.c
> @@ -98,15 +98,15 @@ static const struct net_device_ops hydra_netdev_o=
ps =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_open =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =3D hydra_open,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_stop =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =3D hydra_close,
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
> @@ -125,7 +125,7 @@ static int __devinit hydra_init(struct zorro_dev =
*z)
> =C2=A0 =C2=A0 =C2=A0 =C2=A00x10, 0x12, 0x14, 0x16, 0x18, 0x1a, 0x1c, =
0x1e,
> =C2=A0 =C2=A0 };
>
> - =C2=A0 =C2=A0dev =3D alloc_ei_netdev();
> + =C2=A0 =C2=A0dev =3D ____alloc_ei_netdev(0);
> =C2=A0 =C2=A0 if (!dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return -ENOMEM;
>
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

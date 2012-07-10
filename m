From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 4 0/4] Add ability to set defaultless network device MAC addresses to deterministic computed locally administered values
Date: Tue, 10 Jul 2012 14:37:51 +0200
Message-ID: <201207101437.54877.florian@openwrt.org>
References: <20120705024259.26317.16000.stgit@build.warmcat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Green <andy@warmcat.com>, linux-omap@vger.kernel.org,
	s-jan@ti.com, arnd@arndb.de, patches@linaro.org, tony@atomide.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rostedt@goodmis.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120705024259.26317.16000.stgit@build.warmcat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Le jeudi 05 juillet 2012 04:44:33, Andy Green a =E9crit :
> The following series adds some code to generate legal, locally admini=
stered
> MAC addresses from OMAP4 CPU Die ID fuse data, and then adds a helper=
 at
> net/ethernet taking care of accepting device path / MAC mapping
> registrations and running a notifier to enforce the requested MAC whe=
n the
> matching network device turns up.

This looks like something you can solve by user-space entirely. Expose =
the=20
OMAP4 CPU Die ID using a sysfs attribute, and let user-space manage the=
 MAC=20
address pool.

If you tell me you want to use this for nfsroot booting, what prevents =
you=20
from using an initramfs, assign a valid MAC to your interface and switc=
h over=20
your nfsroot once the interface setup is done?

>=20
> On PandaBoard / ES, two devices have no board-level MAC either assign=
ed by
> the manufacturer or stored on the board, the last patch in the series=
 adds
> these device paths and gets them set when the network device is regis=
tered.
>=20
> Lastly for convenient testing, there's a little patch on
> omap2plus_defconfig that will get Ethernet and WLAN up on Pandaboard.
>=20
> The patches are against today's linux-omap.
>=20
> Thanks to Tony Lindgren and Arnd Bergmann for comments leading to the
> helper in net/ethernet.
>=20
> ---
>=20
> Andy Green (4):
>       OMAP: add cpu id register to MAC address helper
>       NET ethernet introduce mac_platform helper
>       OMAP4 PANDA register ethernet and wlan for automatic mac alloca=
tion
>       config test config extending omap2plus with wl12xx etc
>=20
>=20
>  arch/arm/configs/omap2plus_defconfig   |   35 +++----
>  arch/arm/mach-omap2/Kconfig            |    1
>  arch/arm/mach-omap2/board-omap4panda.c |   30 ++++++
>  arch/arm/mach-omap2/id.c               |   39 ++++++++
>  arch/arm/mach-omap2/include/mach/id.h  |    1
>  include/net/mac-platform.h             |   39 ++++++++
>  net/Kconfig                            |    5 +
>  net/ethernet/Makefile                  |    3 +
>  net/ethernet/mac-platform.c            |  151
> ++++++++++++++++++++++++++++++++ 9 files changed, 282 insertions(+), =
22
> deletions(-)
>  create mode 100644 include/net/mac-platform.h
>  create mode 100644 net/ethernet/mac-platform.c
>=20
>=20
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--=20
=46lorian

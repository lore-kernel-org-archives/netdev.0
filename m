From: Bob Liu <lliubbo@gmail.com>
Subject: Re: [uclinux-dist-devel] [net-next v2 55/71] bfin_mac: Move the
 Analog Devices Inc driver
Date: Fri, 5 Aug 2011 13:18:50 +0800
Message-ID: <CAA_GA1ePTW30LoeMEt8m27G04tp6TTkmgM6tRjFTFN7GFvQfPQ@mail.gmail.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1312082850-24914-56-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org, sassmann@redhat.com,
	gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:48500 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753150Ab1HEFSv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 01:18:51 -0400
Received: by qwk3 with SMTP id 3so1361923qwk.19
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2011 22:18:50 -0700 (PDT)
In-Reply-To: <1312082850-24914-56-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 31, 2011 at 11:27 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> Move the Analog Devices Inc driver into drivers/net/ethernet/adi/ and
> make the necessary Kconfig and Makefile changes.
>
> CC: <uclinux-dist-devel@blackfin.uclinux.org>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Looks good for me, Thanks.

Acked-by: Bob Liu <bob.liu@analog.com>

> ---
> =C2=A0MAINTAINERS =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A02 +=
-
> =C2=A0drivers/net/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 46 --------------------
> =C2=A0drivers/net/Makefile =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A01 -
> =C2=A0drivers/net/ethernet/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0| =C2=A0 =C2=A01 +
> =C2=A0drivers/net/ethernet/Makefile =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 | =C2=A0 =C2=A01 +
> =C2=A0drivers/net/ethernet/adi/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0| =C2=A0 65 +++++++++++++++++++++++++++++
> =C2=A0drivers/net/ethernet/adi/Makefile =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=
 =C2=A0 =C2=A05 ++
> =C2=A0drivers/net/{ =3D> ethernet/adi}/bfin_mac.c | =C2=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet/adi}/bfin_mac.h | =C2=A0 =C2=A00
> =C2=A09 files changed, 73 insertions(+), 48 deletions(-)
> =C2=A0create mode 100644 drivers/net/ethernet/adi/Kconfig
> =C2=A0create mode 100644 drivers/net/ethernet/adi/Makefile
> =C2=A0rename drivers/net/{ =3D> ethernet/adi}/bfin_mac.c (100%)
> =C2=A0rename drivers/net/{ =3D> ethernet/adi}/bfin_mac.h (100%)
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index a91e8fb..83a51ad 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -1440,7 +1440,7 @@ BLACKFIN EMAC DRIVER
> =C2=A0L: =C2=A0 =C2=A0 uclinux-dist-devel@blackfin.uclinux.org
> =C2=A0W: =C2=A0 =C2=A0 http://blackfin.uclinux.org
> =C2=A0S: =C2=A0 =C2=A0 Supported
> -F: =C2=A0 =C2=A0 drivers/net/bfin_mac.*
> +F: =C2=A0 =C2=A0 drivers/net/ethernet/adi/
>
> =C2=A0BLACKFIN RTC DRIVER
> =C2=A0M: =C2=A0 =C2=A0 Mike Frysinger <vapier.adi@gmail.com>
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 61e71d0..bb4bc4b 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -252,52 +252,6 @@ config SH_ETH
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0This driver supporting CPUs are:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0- SH7710, SH77=
12, SH7763, SH7619, SH7724, and SH7757.
>
> -config BFIN_MAC
> - =C2=A0 =C2=A0 =C2=A0 tristate "Blackfin on-chip MAC support"
> - =C2=A0 =C2=A0 =C2=A0 depends on NET_ETHERNET && (BF516 || BF518 || =
BF526 || BF527 || BF536 || BF537)
> - =C2=A0 =C2=A0 =C2=A0 select CRC32
> - =C2=A0 =C2=A0 =C2=A0 select MII
> - =C2=A0 =C2=A0 =C2=A0 select PHYLIB
> - =C2=A0 =C2=A0 =C2=A0 select BFIN_MAC_USE_L1 if DMA_UNCACHED_NONE
> - =C2=A0 =C2=A0 =C2=A0 help
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 This is the driver for Blackfin on-chip=
 mac device. Say Y if you want it
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 compiled into the kernel. This driver i=
s also available as a module
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 ( =3D code which can be inserted in and=
 removed from the running kernel
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 whenever you want). The module will be =
called bfin_mac.
> -
> -config BFIN_MAC_USE_L1
> - =C2=A0 =C2=A0 =C2=A0 bool "Use L1 memory for rx/tx packets"
> - =C2=A0 =C2=A0 =C2=A0 depends on BFIN_MAC && (BF527 || BF537)
> - =C2=A0 =C2=A0 =C2=A0 default y
> - =C2=A0 =C2=A0 =C2=A0 help
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 To get maximum network performance, you=
 should use L1 memory as rx/tx buffers.
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 Say N here if you want to reserve L1 me=
mory for other uses.
> -
> -config BFIN_TX_DESC_NUM
> - =C2=A0 =C2=A0 =C2=A0 int "Number of transmit buffer packets"
> - =C2=A0 =C2=A0 =C2=A0 depends on BFIN_MAC
> - =C2=A0 =C2=A0 =C2=A0 range 6 10 if BFIN_MAC_USE_L1
> - =C2=A0 =C2=A0 =C2=A0 range 10 100
> - =C2=A0 =C2=A0 =C2=A0 default "10"
> - =C2=A0 =C2=A0 =C2=A0 help
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 Set the number of buffer packets used i=
n driver.
> -
> -config BFIN_RX_DESC_NUM
> - =C2=A0 =C2=A0 =C2=A0 int "Number of receive buffer packets"
> - =C2=A0 =C2=A0 =C2=A0 depends on BFIN_MAC
> - =C2=A0 =C2=A0 =C2=A0 range 20 100 if BFIN_MAC_USE_L1
> - =C2=A0 =C2=A0 =C2=A0 range 20 800
> - =C2=A0 =C2=A0 =C2=A0 default "20"
> - =C2=A0 =C2=A0 =C2=A0 help
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 Set the number of buffer packets used i=
n driver.
> -
> -config BFIN_MAC_USE_HWSTAMP
> - =C2=A0 =C2=A0 =C2=A0 bool "Use IEEE 1588 hwstamp"
> - =C2=A0 =C2=A0 =C2=A0 depends on BFIN_MAC && BF518
> - =C2=A0 =C2=A0 =C2=A0 default y
> - =C2=A0 =C2=A0 =C2=A0 help
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 To support the IEEE 1588 Precision Time=
 Protocol (PTP), select y here
> -
> =C2=A0config NET_NETX
> =C2=A0 =C2=A0 =C2=A0 =C2=A0tristate "NetX Ethernet support"
> =C2=A0 =C2=A0 =C2=A0 =C2=A0select MII
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index 8e6dbd7..d249d76 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -57,7 +57,6 @@ obj-$(CONFIG_EQUALIZER) +=3D eql.o
> =C2=A0obj-$(CONFIG_TUN) +=3D tun.o
> =C2=A0obj-$(CONFIG_VETH) +=3D veth.o
> =C2=A0obj-$(CONFIG_NET_NETX) +=3D netx-eth.o
> -obj-$(CONFIG_BFIN_MAC) +=3D bfin_mac.o
> =C2=A0obj-$(CONFIG_DM9000) +=3D dm9000.o
> =C2=A0obj-$(CONFIG_ENC28J60) +=3D enc28j60.o
> =C2=A0obj-$(CONFIG_ETHOC) +=3D ethoc.o
> diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kcon=
fig
> index 6b3b3dc..e087337 100644
> --- a/drivers/net/ethernet/Kconfig
> +++ b/drivers/net/ethernet/Kconfig
> @@ -15,6 +15,7 @@ source "drivers/net/ethernet/3com/Kconfig"
> =C2=A0source "drivers/net/ethernet/amd/Kconfig"
> =C2=A0source "drivers/net/ethernet/apple/Kconfig"
> =C2=A0source "drivers/net/ethernet/atheros/Kconfig"
> +source "drivers/net/ethernet/adi/Kconfig"
> =C2=A0source "drivers/net/ethernet/broadcom/Kconfig"
> =C2=A0source "drivers/net/ethernet/brocade/Kconfig"
> =C2=A0source "drivers/net/ethernet/chelsio/Kconfig"
> diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Mak=
efile
> index 2a1cbce..826db27 100644
> --- a/drivers/net/ethernet/Makefile
> +++ b/drivers/net/ethernet/Makefile
> @@ -7,6 +7,7 @@ obj-$(CONFIG_NET_VENDOR_8390) +=3D 8390/
> =C2=A0obj-$(CONFIG_NET_VENDOR_AMD) +=3D amd/
> =C2=A0obj-$(CONFIG_NET_VENDOR_APPLE) +=3D apple/
> =C2=A0obj-$(CONFIG_NET_VENDOR_ATHEROS) +=3D atheros/
> +obj-$(CONFIG_NET_BFIN) +=3D adi/
> =C2=A0obj-$(CONFIG_NET_VENDOR_BROADCOM) +=3D broadcom/
> =C2=A0obj-$(CONFIG_NET_VENDOR_BROCADE) +=3D brocade/
> =C2=A0obj-$(CONFIG_NET_VENDOR_CHELSIO) +=3D chelsio/
> diff --git a/drivers/net/ethernet/adi/Kconfig b/drivers/net/ethernet/=
adi/Kconfig
> new file mode 100644
> index 0000000..a2c8a3b
> --- /dev/null
> +++ b/drivers/net/ethernet/adi/Kconfig
> @@ -0,0 +1,65 @@
> +#
> +# Blackfin device configuration
> +#
> +
> +config NET_BFIN
> + =C2=A0 =C2=A0 =C2=A0 bool "Blackfin devices"
> + =C2=A0 =C2=A0 =C2=A0 depends on BF516 || BF518 || BF526 || BF527 ||=
 BF536 || BF537
> + =C2=A0 =C2=A0 =C2=A0 ---help---
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 If you have a network (Ethernet) card b=
elonging to this class, say Y.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 Make sure you know the name of your car=
d. Read the Ethernet-HOWTO,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 available from <http://www.tldp.org/doc=
s.html#howto>.
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 If unsure, say Y.
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 Note that the answer to this question d=
oesn't directly affect the
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 kernel: saying N will just cause the co=
nfigurator to skip all
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 the remaining Blackfin card questions. =
If you say Y, you will be
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 asked for your specific card in the fol=
lowing questions.
> +
> +config BFIN_MAC
> + =C2=A0 =C2=A0 =C2=A0 tristate "Blackfin on-chip MAC support"
> + =C2=A0 =C2=A0 =C2=A0 depends on NET_BFIN && (BF516 || BF518 || BF52=
6 || BF527 || \
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0BF536 || BF5=
37)
> + =C2=A0 =C2=A0 =C2=A0 select CRC32
> + =C2=A0 =C2=A0 =C2=A0 select MII
> + =C2=A0 =C2=A0 =C2=A0 select PHYLIB
> + =C2=A0 =C2=A0 =C2=A0 select BFIN_MAC_USE_L1 if DMA_UNCACHED_NONE
> + =C2=A0 =C2=A0 =C2=A0 ---help---
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 This is the driver for Blackfin on-chip=
 mac device. Say Y if you want
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 it compiled into the kernel. This drive=
r is also available as a
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 module ( =3D code which can be inserted=
 in and removed from the running
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 kernel whenever you want). The module w=
ill be called bfin_mac.
> +
> +config BFIN_MAC_USE_L1
> + =C2=A0 =C2=A0 =C2=A0 bool "Use L1 memory for rx/tx packets"
> + =C2=A0 =C2=A0 =C2=A0 depends on BFIN_MAC && (BF527 || BF537)
> + =C2=A0 =C2=A0 =C2=A0 default y
> + =C2=A0 =C2=A0 =C2=A0 ---help---
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 To get maximum network performance, you=
 should use L1 memory as rx/tx
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 buffers. Say N here if you want to rese=
rve L1 memory for other uses.
> +
> +config BFIN_TX_DESC_NUM
> + =C2=A0 =C2=A0 =C2=A0 int "Number of transmit buffer packets"
> + =C2=A0 =C2=A0 =C2=A0 depends on BFIN_MAC
> + =C2=A0 =C2=A0 =C2=A0 range 6 10 if BFIN_MAC_USE_L1
> + =C2=A0 =C2=A0 =C2=A0 range 10 100
> + =C2=A0 =C2=A0 =C2=A0 default "10"
> + =C2=A0 =C2=A0 =C2=A0 ---help---
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 Set the number of buffer packets used i=
n driver.
> +
> +config BFIN_RX_DESC_NUM
> + =C2=A0 =C2=A0 =C2=A0 int "Number of receive buffer packets"
> + =C2=A0 =C2=A0 =C2=A0 depends on BFIN_MAC
> + =C2=A0 =C2=A0 =C2=A0 range 20 100 if BFIN_MAC_USE_L1
> + =C2=A0 =C2=A0 =C2=A0 range 20 800
> + =C2=A0 =C2=A0 =C2=A0 default "20"
> + =C2=A0 =C2=A0 =C2=A0 ---help---
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 Set the number of buffer packets used i=
n driver.
> +
> +config BFIN_MAC_USE_HWSTAMP
> + =C2=A0 =C2=A0 =C2=A0 bool "Use IEEE 1588 hwstamp"
> + =C2=A0 =C2=A0 =C2=A0 depends on BFIN_MAC && BF518
> + =C2=A0 =C2=A0 =C2=A0 default y
> + =C2=A0 =C2=A0 =C2=A0 ---help---
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 To support the IEEE 1588 Precision Time=
 Protocol (PTP), select y here
> diff --git a/drivers/net/ethernet/adi/Makefile b/drivers/net/ethernet=
/adi/Makefile
> new file mode 100644
> index 0000000..b1fbe19
> --- /dev/null
> +++ b/drivers/net/ethernet/adi/Makefile
> @@ -0,0 +1,5 @@
> +#
> +# Makefile for the Blackfin device drivers.
> +#
> +
> +obj-$(CONFIG_BFIN_MAC) +=3D bfin_mac.o
> diff --git a/drivers/net/bfin_mac.c b/drivers/net/ethernet/adi/bfin_m=
ac.c
> similarity index 100%
> rename from drivers/net/bfin_mac.c
> rename to drivers/net/ethernet/adi/bfin_mac.c
> diff --git a/drivers/net/bfin_mac.h b/drivers/net/ethernet/adi/bfin_m=
ac.h
> similarity index 100%
> rename from drivers/net/bfin_mac.h
> rename to drivers/net/ethernet/adi/bfin_mac.h
> --
> 1.7.6
>
> _______________________________________________
> Uclinux-dist-devel mailing list
> Uclinux-dist-devel@blackfin.uclinux.org
> https://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel
>



--=20
Regards,
--Bob

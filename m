From: Jon Mason <jon.mason@myri.com>
Subject: Re: [net-next v2 17/71] myri*: Move the Myricom drivers
Date: Mon, 1 Aug 2011 12:09:36 -0500
Message-ID: <CAMaF-rOs_8=F1-nKMSR4kosNuoGUTE284MKtRvSQ-X2p5sb+rw@mail.gmail.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1312082850-24914-18-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <brice@myri.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:49864 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753008Ab1HARJh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 13:09:37 -0400
Received: by gxk21 with SMTP id 21so3567936gxk.19
        for <netdev@vger.kernel.org>; Mon, 01 Aug 2011 10:09:37 -0700 (PDT)
In-Reply-To: <1312082850-24914-18-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 30, 2011 at 10:26 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> Move the Myricom drivers into drivers/net/ethernet/myricom/ and make
> the necessary Kconfig and Makefile changes.

Acked-by: Jon Mason <mason@myri.com>

> CC: Andrew Gallatin <gallatin@myri.com>
> CC: Brice Goglin <brice@myri.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0| =A0 26 ------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 | =A0 =A01 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0| =A0 =A01 +
> =A0drivers/net/ethernet/myricom/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 |=
 =A0 42 ++++++++++++++++++++
> =A0drivers/net/ethernet/myricom/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 =A05 ++
> =A0.../net/{ =3D> ethernet/myricom}/myri10ge/Makefile =A0 | =A0 =A00
> =A0.../net/{ =3D> ethernet/myricom}/myri10ge/myri10ge.c | =A0 =A00
> =A0.../{ =3D> ethernet/myricom}/myri10ge/myri10ge_mcp.h | =A0 =A00
> =A0.../myricom}/myri10ge/myri10ge_mcp_gen_header.h =A0 =A0| =A0 =A00
> =A011 files changed, 50 insertions(+), 28 deletions(-)
> =A0create mode 100644 drivers/net/ethernet/myricom/Kconfig
> =A0create mode 100644 drivers/net/ethernet/myricom/Makefile
> =A0rename drivers/net/{ =3D> ethernet/myricom}/myri10ge/Makefile (100=
%)
> =A0rename drivers/net/{ =3D> ethernet/myricom}/myri10ge/myri10ge.c (1=
00%)
> =A0rename drivers/net/{ =3D> ethernet/myricom}/myri10ge/myri10ge_mcp.=
h (100%)
> =A0rename drivers/net/{ =3D> ethernet/myricom}/myri10ge/myri10ge_mcp_=
gen_header.h (100%)
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index ddec2eb..3423692 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -4308,7 +4308,7 @@ M: =A0 =A0 =A0 =A0Andrew Gallatin <gallatin@myr=
i.com>
> =A0L: =A0 =A0 netdev@vger.kernel.org
> =A0W: =A0 =A0 http://www.myri.com/scs/download-Myri10GE.html
> =A0S: =A0 =A0 Supported
> -F: =A0 =A0 drivers/net/myri10ge/
> +F: =A0 =A0 drivers/net/ethernet/myricom/myri10ge/
>
> =A0NATSEMI ETHERNET DRIVER (DP8381x)
> =A0M: =A0 =A0 Tim Hockin <thockin@hockin.org>
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 56c033a..38fcaea 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -1519,32 +1519,6 @@ config VXGE_DEBUG_TRACE_ALL
> =A0 =A0 =A0 =A0 =A0the vxge driver. By default only few debug trace s=
tatements are
> =A0 =A0 =A0 =A0 =A0enabled.
>
> -config MYRI10GE
> - =A0 =A0 =A0 tristate "Myricom Myri-10G Ethernet support"
> - =A0 =A0 =A0 depends on PCI && INET
> - =A0 =A0 =A0 select FW_LOADER
> - =A0 =A0 =A0 select CRC32
> - =A0 =A0 =A0 select INET_LRO
> - =A0 =A0 =A0 ---help---
> - =A0 =A0 =A0 =A0 This driver supports Myricom Myri-10G Dual Protocol=
 interface in
> - =A0 =A0 =A0 =A0 Ethernet mode. If the eeprom on your board is not r=
ecent enough,
> - =A0 =A0 =A0 =A0 you will need a newer firmware image.
> - =A0 =A0 =A0 =A0 You may get this image or more information, at:
> -
> - =A0 =A0 =A0 =A0 <http://www.myri.com/scs/download-Myri10GE.html>
> -
> - =A0 =A0 =A0 =A0 To compile this driver as a module, choose M here. =
The module
> - =A0 =A0 =A0 =A0 will be called myri10ge.
> -
> -config MYRI10GE_DCA
> - =A0 =A0 =A0 bool "Direct Cache Access (DCA) Support"
> - =A0 =A0 =A0 default y
> - =A0 =A0 =A0 depends on MYRI10GE && DCA && !(MYRI10GE=3Dy && DCA=3Dm=
)
> - =A0 =A0 =A0 ---help---
> - =A0 =A0 =A0 =A0 Say Y here if you want to use Direct Cache Access (=
DCA) in the
> - =A0 =A0 =A0 =A0 driver. =A0DCA is a method for warming the CPU cach=
e before data
> - =A0 =A0 =A0 =A0 is used, with the intent of lessening the impact of=
 cache misses.
> -
> =A0config PASEMI_MAC
> =A0 =A0 =A0 =A0tristate "PA Semi 1/10Gbit MAC"
> =A0 =A0 =A0 =A0depends on PPC_PASEMI && PCI && INET
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index 73e357e..b9e1f5a 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -151,7 +151,6 @@ obj-$(CONFIG_R8169) +=3D r8169.o
> =A0obj-$(CONFIG_IBMVETH) +=3D ibmveth.o
> =A0obj-$(CONFIG_S2IO) +=3D s2io.o
> =A0obj-$(CONFIG_VXGE) +=3D vxge/
> -obj-$(CONFIG_MYRI10GE) +=3D myri10ge/
> =A0obj-$(CONFIG_PXA168_ETH) +=3D pxa168_eth.o
> =A0obj-$(CONFIG_BFIN_MAC) +=3D bfin_mac.o
> =A0obj-$(CONFIG_DM9000) +=3D dm9000.o
> diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kcon=
fig
> index 8bbddc9..ce3040d 100644
> --- a/drivers/net/ethernet/Kconfig
> +++ b/drivers/net/ethernet/Kconfig
> @@ -21,6 +21,7 @@ source "drivers/net/ethernet/emulex/Kconfig"
> =A0source "drivers/net/ethernet/intel/Kconfig"
> =A0source "drivers/net/ethernet/i825xx/Kconfig"
> =A0source "drivers/net/ethernet/mellanox/Kconfig"
> +source "drivers/net/ethernet/myricom/Kconfig"
> =A0source "drivers/net/ethernet/qlogic/Kconfig"
> =A0source "drivers/net/ethernet/racal/Kconfig"
> =A0source "drivers/net/ethernet/sfc/Kconfig"
> diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Mak=
efile
> index e5f2954..b4dcb93 100644
> --- a/drivers/net/ethernet/Makefile
> +++ b/drivers/net/ethernet/Makefile
> @@ -12,6 +12,7 @@ obj-$(CONFIG_NET_VENDOR_EMULEX) +=3D emulex/
> =A0obj-$(CONFIG_NET_VENDOR_INTEL) +=3D intel/
> =A0obj-$(CONFIG_NET_VENDOR_I825XX) +=3D i825xx/
> =A0obj-$(CONFIG_NET_VENDOR_MELLANOX) +=3D mellanox/
> +obj-$(CONFIG_NET_VENDOR_MYRI) +=3D myricom/
> =A0obj-$(CONFIG_NET_VENDOR_QLOGIC) +=3D qlogic/
> =A0obj-$(CONFIG_NET_VENDOR_RACAL) +=3D racal/
> =A0obj-$(CONFIG_SFC) +=3D sfc/
> diff --git a/drivers/net/ethernet/myricom/Kconfig b/drivers/net/ether=
net/myricom/Kconfig
> new file mode 100644
> index 0000000..8dc4241
> --- /dev/null
> +++ b/drivers/net/ethernet/myricom/Kconfig
> @@ -0,0 +1,42 @@
> +#
> +# Myricom device configuration
> +#
> +
> +config NET_VENDOR_MYRI
> + =A0 =A0 =A0 bool "Myricom devices"
> + =A0 =A0 =A0 depends on PCI || INET
> + =A0 =A0 =A0 ---help---
> + =A0 =A0 =A0 =A0 If you have a network (Ethernet) card belonging to =
this class, say
> + =A0 =A0 =A0 =A0 Y and read the Ethernet-HOWTO, available from
> + =A0 =A0 =A0 =A0 <http://www.tldp.org/docs.html#howto>.
> +
> + =A0 =A0 =A0 =A0 Note that the answer to this question doesn't direc=
tly affect the
> + =A0 =A0 =A0 =A0 kernel: saying N will just cause the configurator t=
o skip all
> + =A0 =A0 =A0 =A0 the questions about Myricom cards. If you say Y, yo=
u will be asked for
> + =A0 =A0 =A0 =A0 your specific card in the following questions.
> +
> +config MYRI10GE
> + =A0 =A0 =A0 tristate "Myricom Myri-10G Ethernet support"
> + =A0 =A0 =A0 depends on NET_VENDOR_MYRI && PCI && INET
> + =A0 =A0 =A0 select FW_LOADER
> + =A0 =A0 =A0 select CRC32
> + =A0 =A0 =A0 select INET_LRO
> + =A0 =A0 =A0 ---help---
> + =A0 =A0 =A0 =A0 This driver supports Myricom Myri-10G Dual Protocol=
 interface in
> + =A0 =A0 =A0 =A0 Ethernet mode. If the eeprom on your board is not r=
ecent enough,
> + =A0 =A0 =A0 =A0 you will need a newer firmware image.
> + =A0 =A0 =A0 =A0 You may get this image or more information, at:
> +
> + =A0 =A0 =A0 =A0 <http://www.myri.com/scs/download-Myri10GE.html>
> +
> + =A0 =A0 =A0 =A0 To compile this driver as a module, choose M here. =
The module
> + =A0 =A0 =A0 =A0 will be called myri10ge.
> +
> +config MYRI10GE_DCA
> + =A0 =A0 =A0 bool "Direct Cache Access (DCA) Support"
> + =A0 =A0 =A0 default y
> + =A0 =A0 =A0 depends on MYRI10GE && DCA && !(MYRI10GE=3Dy && DCA=3Dm=
)
> + =A0 =A0 =A0 ---help---
> + =A0 =A0 =A0 =A0 Say Y here if you want to use Direct Cache Access (=
DCA) in the
> + =A0 =A0 =A0 =A0 driver. =A0DCA is a method for warming the CPU cach=
e before data
> + =A0 =A0 =A0 =A0 is used, with the intent of lessening the impact of=
 cache misses.
> diff --git a/drivers/net/ethernet/myricom/Makefile b/drivers/net/ethe=
rnet/myricom/Makefile
> new file mode 100644
> index 0000000..296c0a1
> --- /dev/null
> +++ b/drivers/net/ethernet/myricom/Makefile
> @@ -0,0 +1,5 @@
> +#
> +# Makefile for the Myricom network device drivers.
> +#
> +
> +obj-$(CONFIG_MYRI10GE) +=3D myri10ge/
> diff --git a/drivers/net/myri10ge/Makefile b/drivers/net/ethernet/myr=
icom/myri10ge/Makefile
> similarity index 100%
> rename from drivers/net/myri10ge/Makefile
> rename to drivers/net/ethernet/myricom/myri10ge/Makefile
> diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/ethernet/m=
yricom/myri10ge/myri10ge.c
> similarity index 100%
> rename from drivers/net/myri10ge/myri10ge.c
> rename to drivers/net/ethernet/myricom/myri10ge/myri10ge.c
> diff --git a/drivers/net/myri10ge/myri10ge_mcp.h b/drivers/net/ethern=
et/myricom/myri10ge/myri10ge_mcp.h
> similarity index 100%
> rename from drivers/net/myri10ge/myri10ge_mcp.h
> rename to drivers/net/ethernet/myricom/myri10ge/myri10ge_mcp.h
> diff --git a/drivers/net/myri10ge/myri10ge_mcp_gen_header.h b/drivers=
/net/ethernet/myricom/myri10ge/myri10ge_mcp_gen_header.h
> similarity index 100%
> rename from drivers/net/myri10ge/myri10ge_mcp_gen_header.h
> rename to drivers/net/ethernet/myricom/myri10ge/myri10ge_mcp_gen_head=
er.h
> --
> 1.7.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>

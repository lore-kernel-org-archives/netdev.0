From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH V4 net-next 8/8] net: hns3: Add HNS3 driver to kernel
 build framework & MAINTAINERS
Date: Sun, 23 Jul 2017 16:12:09 +0300
Message-ID: <20170723131209.GI3259@mtr-leonro.local>
References: <20170722220942.78852-1-salil.mehta@huawei.com>
 <20170722220942.78852-9-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="1fZJyN7nFm/tosmV"
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
        huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
        mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170722220942.78852-9-salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--1fZJyN7nFm/tosmV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Jul 22, 2017 at 11:09:42PM +0100, Salil Mehta wrote:
> This patch updates the MAINTAINERS file with HNS3 Ethernet driver
> maintainers names and other details. This also introduces the new
> Makefiles required to build the HNS3 Ethernet driver and updates
> the existing Kconfig file in the hisilicon folder.
>
> Signed-off-by: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
> Patch V3: Addressed below errors:
>  1. Intel kbuild: https://lkml.org/lkml/2017/6/14/313
>  2. Intel Kbuild: https://lkml.org/lkml/2017/6/14/636
> Patch V2: No change
> Patch V1: Initial Submit
> ---
>  MAINTAINERS                                        |  8 +++++++
>  drivers/net/ethernet/hisilicon/Kconfig             | 27 ++++++++++++++++++++++
>  drivers/net/ethernet/hisilicon/Makefile            |  1 +
>  drivers/net/ethernet/hisilicon/hns3/Makefile       |  7 ++++++
>  .../net/ethernet/hisilicon/hns3/hns3pf/Makefile    | 11 +++++++++
>  5 files changed, 54 insertions(+)
>  create mode 100644 drivers/net/ethernet/hisilicon/hns3/Makefile
>  create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/Makefile
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 297e610c9163..a22d5b86c2b7 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -6197,6 +6197,14 @@ S:	Maintained
>  F:	drivers/net/ethernet/hisilicon/
>  F:	Documentation/devicetree/bindings/net/hisilicon*.txt
>
> +HISILICON NETWORK SUBSYSTEM 3 DRIVER (HNS3)
> +M:	Yisen Zhuang <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> +M:	Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> +L:	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> +W:	http://www.hisilicon.com
> +S:	Maintained
> +F:	drivers/net/ethernet/hisilicon/hns3/
> +
>  HISILICON ROCE DRIVER
>  M:	Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>  M:	Wei Hu(Xavier) <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> diff --git a/drivers/net/ethernet/hisilicon/Kconfig b/drivers/net/ethernet/hisilicon/Kconfig
> index d11287e11371..9f8ea283c531 100644
> --- a/drivers/net/ethernet/hisilicon/Kconfig
> +++ b/drivers/net/ethernet/hisilicon/Kconfig
> @@ -76,4 +76,31 @@ config HNS_ENET
>  	  This selects the general ethernet driver for HNS.  This module make
>  	  use of any HNS AE driver, such as HNS_DSAF
>
> +config HNS3
> +	tristate "Hisilicon Network Subsystem Support HNS3 (Framework)"
> +    depends on PCI
> +	---help---
> +	  This selects the framework support for Hisilicon Network Subsystem 3.
> +	  This layer facilitates clients like ENET, RoCE and user-space ethernet
> +	  drivers(like ODP)to register with HNAE devices and their associated
> +	  operations.
> +
> +config HNS3_HCLGE
> +	tristate "Hisilicon HNS3 HCLGE Acceleration Engine & Compatibility Layer Support"
> +    depends on PCI_MSI
> +	select HNS3

IMHO it should be "depends" and not "select".

> +	---help---
> +	  This selects the HNS3_HCLGE network acceleration engine & its hardware
> +	  compatibility layer. The engine would be used in Hisilicon hip08 family of
> +	  SoCs and further upcoming SoCs.
> +
> +config HNS3_ENET
> +	tristate "Hisilicon HNS3 Ethernet Device Support"
> +    depends on 64BIT && PCI
> +	select HNS3

Ditto

> +	---help---
> +	  This selects the Ethernet Driver for Hisilicon Network Subsystem 3 for hip08
> +	  family of SoCs. This module depends upon HNAE3 driver to access the HNAE3
> +	  devices and their associated operations.
> +
>  endif # NET_VENDOR_HISILICON
> diff --git a/drivers/net/ethernet/hisilicon/Makefile b/drivers/net/ethernet/hisilicon/Makefile
> index 8661695024dc..3828c435c18f 100644
> --- a/drivers/net/ethernet/hisilicon/Makefile
> +++ b/drivers/net/ethernet/hisilicon/Makefile
> @@ -6,4 +6,5 @@ obj-$(CONFIG_HIX5HD2_GMAC) += hix5hd2_gmac.o
>  obj-$(CONFIG_HIP04_ETH) += hip04_eth.o
>  obj-$(CONFIG_HNS_MDIO) += hns_mdio.o
>  obj-$(CONFIG_HNS) += hns/
> +obj-$(CONFIG_HNS3) += hns3/
>  obj-$(CONFIG_HISI_FEMAC) += hisi_femac.o
> diff --git a/drivers/net/ethernet/hisilicon/hns3/Makefile b/drivers/net/ethernet/hisilicon/hns3/Makefile
> new file mode 100644
> index 000000000000..5e53735b2d4e
> --- /dev/null
> +++ b/drivers/net/ethernet/hisilicon/hns3/Makefile
> @@ -0,0 +1,7 @@
> +#
> +# Makefile for the HISILICON network device drivers.
> +#
> +
> +obj-$(CONFIG_HNS3) += hns3pf/
> +
> +obj-$(CONFIG_HNS3) +=hnae3.o

There is a missing space after "+="

> diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/Makefile b/drivers/net/ethernet/hisilicon/hns3/hns3pf/Makefile
> new file mode 100644
> index 000000000000..c0a92b5690a9
> --- /dev/null
> +++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/Makefile
> @@ -0,0 +1,11 @@
> +#
> +# Makefile for the HISILICON network device drivers.
> +#
> +
> +ccflags-y := -Idrivers/net/ethernet/hisilicon/hns3
> +
> +obj-$(CONFIG_HNS3_HCLGE) += hclge.o
> +hclge-objs =hclge_main.o hclge_cmd.o hclge_mdio.o hclge_tm.o

Missing space.

> +
> +obj-$(CONFIG_HNS3_ENET) += hns3.o
> +hns3-objs = hns3_enet.o hns3_ethtool.o
> --
> 2.11.0
>
>

--1fZJyN7nFm/tosmV
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAll0oKgACgkQ5GN7iDZy
WKfxkxAAzH47Z1PwposFaXzW2mJad6BompBsoc6HgLJoqH0XkoLgIoCQjElsN46M
IAl0aK2zrBTjMk+o/98dadHFIuqAHCJnaoiLeQmybxxdCe/bpicI+lgldrIKYST2
EFjydk5TJ0at1XMFM05o1T0hRUu7noSDdxASQhSCYI7Oj4yo9bisMERPc1Qlcyh5
C+6k2jO+8BKQNwQuGdf9cK5ALLpljzvu+xyJklRul6k3S2w451dxh/zSW6Ei98QH
pCAp4RHeo0cQt0+MqE3KxtQ4R1N27kcYhID42qjYsXx71OE0C7dREnNfuKRheeR9
hJv4U55ZBBIXMWz+Zbr5q4Ol7y80oXC2e2VvdF81iCoOBJNwfP3Nb9eWU+1fe3q5
dXgKUL1B7+aeLgP8zdfmXO2mf4qUjEUjaQ6QWlkKn2oN/0yQFVnWPTbPv24wczV2
Vhi6s723raGXTI5D1ggPU2NFVsvYQuXHYnvhqk6bssCiJhEwuMG0Xg6yCbm4Izfu
sA5z3opYaa5u9dhs+YzfqXORDoy8+CLqfXeFyS6VTKB8KIc6I6PAeODx49PgrvA4
sFDK5MEaP60/hAaQKH13goHuFvGZDW2IdCcSPbji4dsTbXQaXqD+NjNMw8dJBd9K
YPXOuc3XZ5rTOicKa2Y81AiHBzMTS+9lVNCraYothTDpWPBdyIY=
=4BJv
-----END PGP SIGNATURE-----

--1fZJyN7nFm/tosmV--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

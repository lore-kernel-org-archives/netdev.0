From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V4 net-next 8/8] net: hns3: Add HNS3 driver to kernel
 build framework & MAINTAINERS
Date: Thu, 27 Jul 2017 15:56:49 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B82814E@FRAEML521-MBX.china.huawei.com>
References: <20170722220942.78852-1-salil.mehta@huawei.com>
 <20170722220942.78852-9-salil.mehta@huawei.com>
 <20170723131209.GI3259@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170723131209.GI3259@mtr-leonro.local>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Leon,

> -----Original Message-----
> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
> owner@vger.kernel.org] On Behalf Of Leon Romanovsky
> Sent: Sunday, July 23, 2017 2:12 PM
> To: Salil Mehta
> Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; linux-rdma@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH V4 net-next 8/8] net: hns3: Add HNS3 driver to
> kernel build framework & MAINTAINERS
> 
> On Sat, Jul 22, 2017 at 11:09:42PM +0100, Salil Mehta wrote:
> > This patch updates the MAINTAINERS file with HNS3 Ethernet driver
> > maintainers names and other details. This also introduces the new
> > Makefiles required to build the HNS3 Ethernet driver and updates
> > the existing Kconfig file in the hisilicon folder.
> >
> > Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
> > ---
> > Patch V3: Addressed below errors:
> >  1. Intel kbuild: https://lkml.org/lkml/2017/6/14/313
> >  2. Intel Kbuild: https://lkml.org/lkml/2017/6/14/636
> > Patch V2: No change
> > Patch V1: Initial Submit
> > ---
> >  MAINTAINERS                                        |  8 +++++++
> >  drivers/net/ethernet/hisilicon/Kconfig             | 27
> ++++++++++++++++++++++
> >  drivers/net/ethernet/hisilicon/Makefile            |  1 +
> >  drivers/net/ethernet/hisilicon/hns3/Makefile       |  7 ++++++
> >  .../net/ethernet/hisilicon/hns3/hns3pf/Makefile    | 11 +++++++++
> >  5 files changed, 54 insertions(+)
> >  create mode 100644 drivers/net/ethernet/hisilicon/hns3/Makefile
> >  create mode 100644
> drivers/net/ethernet/hisilicon/hns3/hns3pf/Makefile
> >
> > diff --git a/MAINTAINERS b/MAINTAINERS
> > index 297e610c9163..a22d5b86c2b7 100644
> > --- a/MAINTAINERS
> > +++ b/MAINTAINERS
> > @@ -6197,6 +6197,14 @@ S:	Maintained
> >  F:	drivers/net/ethernet/hisilicon/
> >  F:	Documentation/devicetree/bindings/net/hisilicon*.txt
> >
> > +HISILICON NETWORK SUBSYSTEM 3 DRIVER (HNS3)
> > +M:	Yisen Zhuang <yisen.zhuang@huawei.com>
> > +M:	Salil Mehta <salil.mehta@huawei.com>
> > +L:	netdev@vger.kernel.org
> > +W:	http://www.hisilicon.com
> > +S:	Maintained
> > +F:	drivers/net/ethernet/hisilicon/hns3/
> > +
> >  HISILICON ROCE DRIVER
> >  M:	Lijun Ou <oulijun@huawei.com>
> >  M:	Wei Hu(Xavier) <xavier.huwei@huawei.com>
> > diff --git a/drivers/net/ethernet/hisilicon/Kconfig
> b/drivers/net/ethernet/hisilicon/Kconfig
> > index d11287e11371..9f8ea283c531 100644
> > --- a/drivers/net/ethernet/hisilicon/Kconfig
> > +++ b/drivers/net/ethernet/hisilicon/Kconfig
> > @@ -76,4 +76,31 @@ config HNS_ENET
> >  	  This selects the general ethernet driver for HNS.  This module
> make
> >  	  use of any HNS AE driver, such as HNS_DSAF
> >
> > +config HNS3
> > +	tristate "Hisilicon Network Subsystem Support HNS3 (Framework)"
> > +    depends on PCI
> > +	---help---
> > +	  This selects the framework support for Hisilicon Network
> Subsystem 3.
> > +	  This layer facilitates clients like ENET, RoCE and user-space
> ethernet
> > +	  drivers(like ODP)to register with HNAE devices and their
> associated
> > +	  operations.
> > +
> > +config HNS3_HCLGE
> > +	tristate "Hisilicon HNS3 HCLGE Acceleration Engine &
> Compatibility Layer Support"
> > +    depends on PCI_MSI
> > +	select HNS3
> 
> IMHO it should be "depends" and not "select".
Agreed, will fix in next patch.

Thanks
> 
> > +	---help---
> > +	  This selects the HNS3_HCLGE network acceleration engine & its
> hardware
> > +	  compatibility layer. The engine would be used in Hisilicon
> hip08 family of
> > +	  SoCs and further upcoming SoCs.
> > +
> > +config HNS3_ENET
> > +	tristate "Hisilicon HNS3 Ethernet Device Support"
> > +    depends on 64BIT && PCI
> > +	select HNS3
> 
> Ditto
Agreed, will fix in next patch.

Thanks 
> > +	---help---
> > +	  This selects the Ethernet Driver for Hisilicon Network
> Subsystem 3 for hip08
> > +	  family of SoCs. This module depends upon HNAE3 driver to access
> the HNAE3
> > +	  devices and their associated operations.
> > +
> >  endif # NET_VENDOR_HISILICON
> > diff --git a/drivers/net/ethernet/hisilicon/Makefile
> b/drivers/net/ethernet/hisilicon/Makefile
> > index 8661695024dc..3828c435c18f 100644
> > --- a/drivers/net/ethernet/hisilicon/Makefile
> > +++ b/drivers/net/ethernet/hisilicon/Makefile
> > @@ -6,4 +6,5 @@ obj-$(CONFIG_HIX5HD2_GMAC) += hix5hd2_gmac.o
> >  obj-$(CONFIG_HIP04_ETH) += hip04_eth.o
> >  obj-$(CONFIG_HNS_MDIO) += hns_mdio.o
> >  obj-$(CONFIG_HNS) += hns/
> > +obj-$(CONFIG_HNS3) += hns3/
> >  obj-$(CONFIG_HISI_FEMAC) += hisi_femac.o
> > diff --git a/drivers/net/ethernet/hisilicon/hns3/Makefile
> b/drivers/net/ethernet/hisilicon/hns3/Makefile
> > new file mode 100644
> > index 000000000000..5e53735b2d4e
> > --- /dev/null
> > +++ b/drivers/net/ethernet/hisilicon/hns3/Makefile
> > @@ -0,0 +1,7 @@
> > +#
> > +# Makefile for the HISILICON network device drivers.
> > +#
> > +
> > +obj-$(CONFIG_HNS3) += hns3pf/
> > +
> > +obj-$(CONFIG_HNS3) +=hnae3.o
> 
> There is a missing space after "+="
Will fix. thanks.

> 
> > diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/Makefile
> b/drivers/net/ethernet/hisilicon/hns3/hns3pf/Makefile
> > new file mode 100644
> > index 000000000000..c0a92b5690a9
> > --- /dev/null
> > +++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/Makefile
> > @@ -0,0 +1,11 @@
> > +#
> > +# Makefile for the HISILICON network device drivers.
> > +#
> > +
> > +ccflags-y := -Idrivers/net/ethernet/hisilicon/hns3
> > +
> > +obj-$(CONFIG_HNS3_HCLGE) += hclge.o
> > +hclge-objs =hclge_main.o hclge_cmd.o hclge_mdio.o hclge_tm.o
> 
> Missing space.
Okay. Will fix.

Thanks
> 
> > +
> > +obj-$(CONFIG_HNS3_ENET) += hns3.o
> > +hns3-objs = hns3_enet.o hns3_ethtool.o
> > --
> > 2.11.0
> >
> >

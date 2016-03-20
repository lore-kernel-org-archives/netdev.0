From: Leon Romanovsky <leon@leon.nu>
Subject: Re: [PATCH v3 2/3] IB/hns: Add HiSilicon RoCE driver support
Date: Sun, 20 Mar 2016 08:23:54 +0200
Message-ID: <20160320062354.GN25216@leon.nu>
References: <1458384658-16759-1-git-send-email-oulijun@huawei.com>
 <1458384658-16759-3-git-send-email-oulijun@huawei.com>
Reply-To: leon@leon.nu
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, jiri@mellanox.com,
	ogerlitz@mellanox.com, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	gongyangming@huawei.com, xiaokun@huawei.com,
	tangchaofei@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, yankejian@huawei.com,
	lisheng011@huawei.com, charles.chenxin@huawei.com,
	linuxarm@huawei.com
To: Lijun Ou <oulijun@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1458384658-16759-3-git-send-email-oulijun@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 19, 2016 at 06:50:57PM +0800, Lijun Ou wrote:
> The driver for HiSilicon RoCE is a platform driver.
> The driver will support multiple versions of hardware. Currently only "v1"
> for hip06 SoC is supported.
> The driver includes two parts: common driver and hardware-specific
> operations. hns_roce_v1_hw.c and hns_roce_v1_hw.h are files for
> hardware-specific operations only for v1 engine, and other files(.c and .h)
> for common algorithm and common hardware operations.
> 
> Signed-off-by: Lijun Ou <oulijun@huawei.com>
> Signed-off-by: Wei Hu(Xavier) <xavier.huwei@huawei.com>
> Signed-off-by: Znlong <zhaonenglong@huawei.com>
> ---
>  MAINTAINERS                                        |    8 +
>  drivers/infiniband/Kconfig                         |    1 +
>  drivers/infiniband/hw/Makefile                     |    1 +
>  drivers/infiniband/hw/hisilicon/hns/Kconfig        |   10 +
>  drivers/infiniband/hw/hisilicon/hns/Makefile       |    9 +
>  drivers/infiniband/hw/hisilicon/hns/hns_roce_ah.c  |  110 +
>  .../infiniband/hw/hisilicon/hns/hns_roce_alloc.c   |  239 ++
>  drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.c |  338 +++
>  drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.h |   80 +
>  .../infiniband/hw/hisilicon/hns/hns_roce_common.h  |  308 +++
>  drivers/infiniband/hw/hisilicon/hns/hns_roce_cq.c  |  436 +++
>  .../infiniband/hw/hisilicon/hns/hns_roce_device.h  |  794 ++++++
>  drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.c  |  758 ++++++
>  drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.h  |  133 +
>  drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.c |  578 ++++
>  drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.h |  112 +
>  .../infiniband/hw/hisilicon/hns/hns_roce_main.c    | 1097 ++++++++
>  drivers/infiniband/hw/hisilicon/hns/hns_roce_mr.c  |  605 +++++
>  drivers/infiniband/hw/hisilicon/hns/hns_roce_pd.c  |  124 +
>  drivers/infiniband/hw/hisilicon/hns/hns_roce_qp.c  |  841 ++++++
>  .../infiniband/hw/hisilicon/hns/hns_roce_user.h    |   31 +
>  .../infiniband/hw/hisilicon/hns/hns_roce_v1_hw.c   | 2835 ++++++++++++++++++++
>  .../infiniband/hw/hisilicon/hns/hns_roce_v1_hw.h   |  986 +++++++
>  23 files changed, 10434 insertions(+)
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/Kconfig
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/Makefile
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_ah.c
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_alloc.c
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.c
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.h
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_common.h
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_cq.c
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_device.h
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.c
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.h
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.c
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.h
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_main.c
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_mr.c
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_pd.c
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_qp.c
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_user.h
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_v1_hw.c
>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_v1_hw.h
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 2933d90..0c7fac5 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -9878,6 +9878,14 @@ W:	http://www.emulex.com
>  S:	Supported
>  F:	drivers/infiniband/hw/ocrdma/
>  
> +HISILICON ROCE DRIVER
> +M:	Wei Hu(Xavier) <xavier.huwei@huawei.com>
> +M:	Lijun Ou <oulijun@huawei.com>
> +L:	linux-rdma@vger.kernel.org
> +S:	Maintained
> +F:	drivers/infiniband/hw/hisilicon/
> +F:	Documentation/devicetree/bindings/infiniband/hisilicon-hns-roce.txt
> +
>  SFC NETWORK DRIVER
>  M:	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
>  M:	Shradha Shah <sshah@solarflare.com>
> diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
> index 8a8440c..02eca75 100644
> --- a/drivers/infiniband/Kconfig
> +++ b/drivers/infiniband/Kconfig
> @@ -73,6 +73,7 @@ source "drivers/infiniband/hw/mlx5/Kconfig"
>  source "drivers/infiniband/hw/nes/Kconfig"
>  source "drivers/infiniband/hw/ocrdma/Kconfig"
>  source "drivers/infiniband/hw/usnic/Kconfig"
> +source "drivers/infiniband/hw/hisilicon/hns/Kconfig"
>  
>  source "drivers/infiniband/ulp/ipoib/Kconfig"
>  
> diff --git a/drivers/infiniband/hw/Makefile b/drivers/infiniband/hw/Makefile
> index aded2a5..ddbbf715 100644
> --- a/drivers/infiniband/hw/Makefile
> +++ b/drivers/infiniband/hw/Makefile
> @@ -7,3 +7,4 @@ obj-$(CONFIG_MLX5_INFINIBAND)		+= mlx5/
>  obj-$(CONFIG_INFINIBAND_NES)		+= nes/
>  obj-$(CONFIG_INFINIBAND_OCRDMA)		+= ocrdma/
>  obj-$(CONFIG_INFINIBAND_USNIC)		+= usnic/
> +obj-$(CONFIG_INFINIBAND_HISILICON_HNS) 	+= hisilicon/hns/
> diff --git a/drivers/infiniband/hw/hisilicon/hns/Kconfig b/drivers/infiniband/hw/hisilicon/hns/Kconfig
> new file mode 100644
> index 0000000..e66e0aa
> --- /dev/null
> +++ b/drivers/infiniband/hw/hisilicon/hns/Kconfig
> @@ -0,0 +1,10 @@
> +config INFINIBAND_HISILICON_HNS
> +	tristate "Hisilicon Hns ROCE Driver"
> +	depends on NET_VENDOR_HISILICON
> +	depends on ARM64 && HNS && HNS_DSAF && HNS_ENET
> +	---help---
> +	  This is a ROCE/RDMA driver for the Hisilicon RoCE engine. The engine
> +	  is used in Hisilicon Hi1610 and more further ICT SoC.
> +
> +	  To compile this driver as a module, choose M here: the module
> +	  will be called roce.

"the module will be called roce" - better to call it hns-roce

> diff --git a/drivers/infiniband/hw/hisilicon/hns/Makefile b/drivers/infiniband/hw/hisilicon/hns/Makefile
> new file mode 100644
> index 0000000..bdf58ce
> --- /dev/null
> +++ b/drivers/infiniband/hw/hisilicon/hns/Makefile
> @@ -0,0 +1,9 @@
> +#
> +# Makefile for the HISILICON RoCE drivers.
> +#
> +
> +obj-$(CONFIG_INFINIBAND_HISILICON_HNS) += roce.o
> +roce-objs := hns_roce_main.o hns_roce_cmd.o hns_roce_eq.o hns_roce_pd.o \
> +	hns_roce_ah.o hns_roce_icm.o hns_roce_mr.o hns_roce_qp.o \
> +	hns_roce_cq.o hns_roce_alloc.o hns_roce_v1_hw.o

roce.o -> hns-roce.o

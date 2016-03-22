From: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v4 0/3] IB/hns: Add HiSilicon RoCE driver
Date: Tue, 22 Mar 2016 22:06:58 +0800
Message-ID: <1458655621-3618-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The HiSilicon Network Substem is a long term evolution IP which is
supposed to be used in HiSilicon ICT SoC. RoCE is a feature of hns.
The driver for HiSilicon RoCE engine is a platform driver.
The driver will support mulitple versions of hns. Currently only "v1"
for hip06 SoC is supported.

Changes v3 -> v4:
1. modify roce.o into hns-roce.o in Makefile and Kconfig file.

Changes v2 -> v3:
1. modify the formats of RoCE driver code base v2 by the experts 
reviewing. also, it used kmalloc_array instead of kmalloc, used kcalloc
instead of kzalloc, when refer to memory allocation for array
2. remove some functions without use and unconnected macros
3. modify the binding document with RoCE DT base v2 which added interrupt-names
4. redesign the port_map and si_map in hns_dsaf_roce_reset
5. add HiSilicon RoCE driver maintainers introduction in MAINTAINERS document

Changes v1 -> v2:
1. modify the formats of roce driver code by the experts reviewing
2. modify the bindings file with roce dts. add the attribute named 
interrput-names.
3. modify the way of defining port mode in hns_dsaf_main.c
4. move the Kconfig file into the hns directory and send it with roce

Lijun Ou (3):
  net: hns: Add reset function support for RoCE driver
  IB/hns: Add HiSilicon RoCE driver support
  IB/hns: Add binding document for HiSilicon RoCE driver

 .../bindings/infiniband/hisilicon-hns-roce.txt     |  107 +
 MAINTAINERS                                        |    8 +
 drivers/infiniband/Kconfig                         |    1 +
 drivers/infiniband/hw/Makefile                     |    1 +
 drivers/infiniband/hw/hisilicon/hns/Kconfig        |   10 +
 drivers/infiniband/hw/hisilicon/hns/Makefile       |    9 +
 drivers/infiniband/hw/hisilicon/hns/hns_roce_ah.c  |  110 +
 .../infiniband/hw/hisilicon/hns/hns_roce_alloc.c   |  239 ++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.c |  338 +++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.h |   80 +
 .../infiniband/hw/hisilicon/hns/hns_roce_common.h  |  308 +++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_cq.c  |  436 +++
 .../infiniband/hw/hisilicon/hns/hns_roce_device.h  |  794 ++++++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.c  |  758 ++++++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.h  |  132 +
 drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.c |  578 ++++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.h |  112 +
 .../infiniband/hw/hisilicon/hns/hns_roce_main.c    | 1097 ++++++++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_mr.c  |  605 +++++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_pd.c  |  124 +
 drivers/infiniband/hw/hisilicon/hns/hns_roce_qp.c  |  841 ++++++
 .../infiniband/hw/hisilicon/hns/hns_roce_user.h    |   31 +
 .../infiniband/hw/hisilicon/hns/hns_roce_v1_hw.c   | 2832 ++++++++++++++++++++
 .../infiniband/hw/hisilicon/hns/hns_roce_v1_hw.h   |  985 +++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |   84 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |   30 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c |   62 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |   13 +
 28 files changed, 10715 insertions(+), 10 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/infiniband/hisilicon-hns-roce.txt
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/Kconfig
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/Makefile
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_ah.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_alloc.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.h
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_common.h
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_cq.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_device.h
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.h
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.h
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_main.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_mr.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_pd.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_qp.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_user.h
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_v1_hw.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_v1_hw.h

-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

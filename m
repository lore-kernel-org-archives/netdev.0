From: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v5 00/21] Add HiSilicon RoCE driver
Date: Sat, 23 Apr 2016 18:26:38 +0800
Message-ID: <1461407219-72027-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The HiSilicon Network Substem is a long term evolution IP which is
supposed to be used in HiSilicon ICT SoCs. HNS (HiSilicon Network
Sybsystem) also has a hardware support of performing RDMA with
RoCEE.
The driver for HiSilicon RoCEE(RoCE Engine) is a platform driver and will
support mulitple versions of SOCs in future. This version of driver is 
meant to support Hip06 SoC (which confirms to RoCEEv1 hardware specifications).
 
Changes v5 -> v4:
1. redesign the patchset for RoCE modules in order to split the huge
patch into small patches.
2. fix the directory path for RoCE module. Delete the hisilicon level.
3. modify the name of roce_v1_hw into roce_hw_v1.

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

Lijun Ou (21):
  net: hns: Add reset function support for RoCE driver
  devicetree: bindings: IB: Add binding document for HiSilicon RoCE
  IB/hns: Add initial main frame driver and get cfg info
  IB/hns: Add RoCE engine reset function
  IB/hns: Add initial profile resource
  IB/hns: Add initial cmd operation
  IB/hns: Add event queue support
  IB/hns: Add icm support
  IB/hns: Add hca support
  IB/hns: Add process flow to init RoCE engine
  IB/hns: Add IB device registration function
  IB/hns: Set mtu and gid support
  IB/hns: Add interface of the protocol stack registration
  IB/hns: Add operations support for IB device and port
  IB/hns: Add PD operations support
  IB/hns: Add ah operation support
  IB/hns: Add QP operation implemention support
  IB/hns: Add CQ operation implemention support
  IB/hns: Add memory region operation support
  IB/hns: Kconfig and Makefile for RoCE module
  MAINTAINERS: Add maintainers for HiSilicon RoCE driver

 .../bindings/infiniband/hisilicon-hns-roce.txt     |  107 +
 MAINTAINERS                                        |    8 +
 drivers/infiniband/Kconfig                         |    1 +
 drivers/infiniband/hw/Makefile                     |    1 +
 drivers/infiniband/hw/hns/Kconfig                  |   10 +
 drivers/infiniband/hw/hns/Makefile                 |    9 +
 drivers/infiniband/hw/hns/hns_roce_ah.c            |  109 +
 drivers/infiniband/hw/hns/hns_roce_alloc.c         |  238 ++
 drivers/infiniband/hw/hns/hns_roce_cmd.c           |  324 +++
 drivers/infiniband/hw/hns/hns_roce_cmd.h           |   80 +
 drivers/infiniband/hw/hns/hns_roce_common.h        |  302 +++
 drivers/infiniband/hw/hns/hns_roce_cq.c            |  435 +++
 drivers/infiniband/hw/hns/hns_roce_device.h        |  731 +++++
 drivers/infiniband/hw/hns/hns_roce_eq.c            |  756 ++++++
 drivers/infiniband/hw/hns/hns_roce_eq.h            |   95 +
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c         | 2811 ++++++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_hw_v1.h         |  966 +++++++
 drivers/infiniband/hw/hns/hns_roce_icm.c           |  579 ++++
 drivers/infiniband/hw/hns/hns_roce_icm.h           |  112 +
 drivers/infiniband/hw/hns/hns_roce_main.c          | 1075 ++++++++
 drivers/infiniband/hw/hns/hns_roce_mr.c            |  599 +++++
 drivers/infiniband/hw/hns/hns_roce_pd.c            |  127 +
 drivers/infiniband/hw/hns/hns_roce_qp.c            |  835 ++++++
 drivers/infiniband/hw/hns/hns_roce_user.h          |   27 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |   89 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |   30 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c |   62 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |   16 +-
 28 files changed, 10520 insertions(+), 14 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/infiniband/hisilicon-hns-roce.txt
 create mode 100644 drivers/infiniband/hw/hns/Kconfig
 create mode 100644 drivers/infiniband/hw/hns/Makefile
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_ah.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_alloc.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_cmd.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_cmd.h
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_common.h
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_cq.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_device.h
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_eq.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_eq.h
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_hw_v1.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_hw_v1.h
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_icm.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_icm.h
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_main.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_mr.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_pd.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_qp.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_user.h

-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

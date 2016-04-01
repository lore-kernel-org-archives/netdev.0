From: Lijun Ou <oulijun@huawei.com>
Subject: [RESEND PATCH V4 0/3] IB/hns: Add HiSilicon RoCE driver
Date: Fri, 1 Apr 2016 17:21:29 +0800
Message-ID: <1459502492-19891-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <gongyangming@huawei.com>,
	<xiaokun@huawei.com>, <tangchaofei@huawei.com>,
	<oulijun@huawei.com>, <haifeng.wei@huawei.com>,
	<yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<lisheng011@huawei.com>, <charles.chenxin@huawei.com>,
	<linuxarm@huawei.com>
To: <dledford@redhat.com>, <sean.hefty@intel.com>,
	<hal.rosenstock@gmail.com>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <jiri@mellanox.com>,
	<ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:42943 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754621AbcDAKMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 06:12:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

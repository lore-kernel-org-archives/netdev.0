From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH 0/3] infiniband: IB/hns: Hisilicon RoCE support
Date: Fri, 11 Mar 2016 18:37:08 +0800
Message-ID: <1457692631-9290-1-git-send-email-oulijun@huawei.com>
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
Received: from szxga01-in.huawei.com ([58.251.152.64]:20973 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238AbcCKK1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 05:27:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Hisilicon Network Substem(hns) is a long term evolution IP which is
supposed to be used in Hisilicon ICT SoC. RoCE is a feature of hns.
The driver for Hisilicon RoCE engine is a platform driver.
The driver will support mulitple versions of hns. Currently only "v1"
for hip06 SOC is supported.


Changes v1 -> v2:
1. adjust the formats of roce driver code by the experts reviewing
2. modify the bindings file with roce dts. add the attribute named 
interrput-names.
3. modify the way of defining port mode in hns_dsaf_main.c
4. move the Kconfig file into the hns directory and send it with roce
driver code file together.


Lijun Ou (3):
  infiniband: IB/hns: add Hisilicon RoCE support
  net: hns: add Hisilicon RoCE support
  infiniband: IB/hns: add Hisilicon RoCE support with bindings

 .../bindings/infiniband/hisilicon-hns-roce.txt     |   68 +
 drivers/infiniband/Kconfig                         |    2 +-
 drivers/infiniband/hw/Makefile                     |    1 +
 drivers/infiniband/hw/hisilicon/hns/Kconfig        |   10 +
 drivers/infiniband/hw/hisilicon/hns/Makefile       |    9 +
 drivers/infiniband/hw/hisilicon/hns/hns_roce_ah.c  |  114 +
 .../infiniband/hw/hisilicon/hns/hns_roce_alloc.c   |  253 ++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.c |  354 +++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.h |  163 ++
 .../infiniband/hw/hisilicon/hns/hns_roce_common.h  |  704 +++++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_cq.c  |  454 +++
 .../infiniband/hw/hisilicon/hns/hns_roce_device.h  |  840 ++++++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.c  |  798 ++++++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.h  |  138 +
 drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.c |  608 ++++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.h |  121 +
 .../infiniband/hw/hisilicon/hns/hns_roce_main.c    | 1124 ++++++++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_mr.c  |  637 +++++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_pd.c  |  129 +
 drivers/infiniband/hw/hisilicon/hns/hns_roce_qp.c  |  890 ++++++
 .../infiniband/hw/hisilicon/hns/hns_roce_user.h    |   31 +
 .../infiniband/hw/hisilicon/hns/hns_roce_v1_hw.c   | 2992 ++++++++++++++++++++
 .../infiniband/hw/hisilicon/hns/hns_roce_v1_hw.h   | 1068 +++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |   84 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |   14 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c |   62 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |   13 +
 27 files changed, 11670 insertions(+), 11 deletions(-)
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

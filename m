From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v9 00/22] Add HiSilicon RoCE driver
Date: Wed, 1 Jun 2016 23:37:42 +0800
Message-ID: <1464795484-77395-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <gongyangming@huawei.com>,
	<xiaokun@huawei.com>, <tangchaofei@huawei.com>,
	<oulijun@huawei.com>, <haifeng.wei@huawei.com>,
	<yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<charles.chenxin@huawei.com>, <linuxarm@huawei.com>
To: <dledford@redhat.com>, <sean.hefty@intel.com>,
	<hal.rosenstock@gmail.com>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <jiri@mellanox.com>,
	<ogerlitz@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The HiSilicon Network Substem is a long term evolution IP which is
supposed to be used in HiSilicon ICT SoCs. HNS (HiSilicon Network
Sybsystem) also has a hardware support of performing RDMA with
RoCEE.
The driver for HiSilicon RoCEE(RoCE Engine) is a platform driver and
will support mulitple versions of SOCs in future. This version of driver
is meant to support Hip06 SoC(which confirms to RoCEEv1 hardware
specifications).

Changes v8 -> v9:
1. delete the definition of ADDR_SHIFT_n, use literal 12, 32 and 44 and
   add comments
2. use roce_read/roce_write/readl/write instead of roce_readl/roce_writel
3. delete the print error/debug messages for memory allocation errors
4. use exit instead of uninit, for example hw->uninit -> hw->exit
5. use roce_raw_write instead of _raw_writel in eq_set_cons_index
6. modify the label with underscore
7. adjust the indentation for the macro definitions in hns_roce_hw_v1.c
8. simplify some lines in few functions and structures.
9. adjust the alphabetic order in MAINTAINERS

Changes v7 -> v8:
1. add a verbs operation named get_port_immutable. It is an 
   independent patch.
2. add a comment for the definition of ADDR_SHIFT_n, n are 12,32
   and 44.
3. restructures the code to align with naming convention of the Linux
   according to the review of Doug Ledford.
4. modify the state for all .c and .h files.

Changes v6 -> v7:
1. modify some type of parameter, use bool replace the original type.
2. add the Signed-off-by signatures in the first patch.
3. delete the improper print sentence in hns_roce_create_eq.

Changes v5 -> v6:
1. modify the type of obj for unsigned long according the reviews, and
   modify the same questions in RoCE module.
2. fix the spelling error.
3. fix the Signed-off-by signatures.

Changes v4 -> v5:
1. redesign the patchset for RoCE modules in order to split the huge
   patch into small patches.
2. fix the directory path for RoCE module. Delete the hisilicon level.
3. modify the name of roce_v1_hw into roce_hw_v1.

Changes v3 -> v4:
1. modify roce.o into hns-roce.o in Makefile and Kconfig file.

Changes v2 -> v3:
1. modify the formats of RoCE driver code base v2 by the experts 
   reviewing. also, it used kmalloc_array instead of kmalloc, kcalloc
   instead of kzalloc, when refer to memory allocation for array
2. remove some functions without use and unconnected macros
3. modify the binding document with RoCE DT base v2 which added
   interrupt-names
4. redesign the port_map and si_map in hns_dsaf_roce_reset
5. add HiSilicon RoCE driver maintainers introduction in MAINTAINERS
   document

Changes v1 -> v2:
1. modify the formats of roce driver code by the experts reviewing
2. modify the bindings file with roce dts. add the attribute named 
   interrput-names.
3. modify the way of defining port mode in hns_dsaf_main.c
4. move the Kconfig file into the hns directory and send it with roce

Lijun Ou (22):
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
  IB/hns: Add IB device registration
  IB/hns: Set mtu and gid support
  IB/hns: Add interface of the protocol stack registration
  IB/hns: Add operations support for IB device and port
  IB/hns: Add PD operations support
  IB/hns: Add ah operations support
  IB/hns: Add QP operations support
  IB/hns: Add CQ operations support
  IB/hns: Add memory region operations support
  IB/hns: Add operation for getting immutable port
  IB/hns: Kconfig and Makefile for RoCE module
  MAINTAINERS: Add maintainers for HiSilicon RoCE driver

 .../bindings/infiniband/hisilicon-hns-roce.txt     |  107 +
 MAINTAINERS                                        |    8 +
 drivers/infiniband/Kconfig                         |    1 +
 drivers/infiniband/hw/Makefile                     |    1 +
 drivers/infiniband/hw/hns/Kconfig                  |   10 +
 drivers/infiniband/hw/hns/Makefile                 |    8 +
 drivers/infiniband/hw/hns/hns_roce_ah.c            |  132 +
 drivers/infiniband/hw/hns/hns_roce_alloc.c         |  262 ++
 drivers/infiniband/hw/hns/hns_roce_cmd.c           |  388 +++
 drivers/infiniband/hw/hns/hns_roce_cmd.h           |   84 +
 drivers/infiniband/hw/hns/hns_roce_common.h        |  325 +++
 drivers/infiniband/hw/hns/hns_roce_cq.c            |  456 ++++
 drivers/infiniband/hw/hns/hns_roce_device.h        |  748 ++++++
 drivers/infiniband/hw/hns/hns_roce_eq.c            |  768 ++++++
 drivers/infiniband/hw/hns/hns_roce_eq.h            |  131 +
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c         | 2787 ++++++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_hw_v1.h         |  981 +++++++
 drivers/infiniband/hw/hns/hns_roce_icm.c           |  602 +++++
 drivers/infiniband/hw/hns/hns_roce_icm.h           |  136 +
 drivers/infiniband/hw/hns/hns_roce_main.c          | 1107 ++++++++
 drivers/infiniband/hw/hns/hns_roce_mr.c            |  621 +++++
 drivers/infiniband/hw/hns/hns_roce_pd.c            |  150 ++
 drivers/infiniband/hw/hns/hns_roce_qp.c            |  856 ++++++
 drivers/infiniband/hw/hns/hns_roce_user.h          |   53 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |   84 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |   32 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c |   57 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |   15 +-
 28 files changed, 10900 insertions(+), 10 deletions(-)
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

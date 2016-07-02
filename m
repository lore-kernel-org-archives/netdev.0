From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v11 00/22] Add HiSilicon RoCE driver
Date: Sat, 2 Jul 2016 17:39:02 +0800
Message-ID: <1467452364-66522-1-git-send-email-oulijun@huawei.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:44788 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494AbcGBJZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 05:25:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The HiSilicon Network Substem is a long term evolution IP which is
supposed to be used in HiSilicon ICT SoCs. HNS (HiSilicon Network
Sybsystem) also has a hardware support of performing RDMA with
RoCEE.
The driver for HiSilicon RoCEE(RoCE Engine) is a platform driver and
will support mulitple versions of SOCs in future. This version of driver
is meant to support Hip06 SoC(which confirms to RoCEv1 hardware
specifications).

Changes v10 -> v11:
[1/22]:
1. modify the print description of chip don't support roce
2. remove explicit values for enums for patch series
[3/22]:
3. remove non-essential headers for patch series
4. add judgement for port_cnt is zero
5. Keep unified print style for "set mask..." vs. "No usable
   ..."
6. modify the MODULE_LICENSE
7. remove MODULE_ALIAS
[4/22]:
8. Move this line out of if-else and leave "if (enable)" part only
9. renaming the meaningful definition to 20 for patch series
10. delete extern keyword for hns_dsaf_roce_reset function
11. delete void keyword for hr_dev->hw->reset when driver removed
[5/22]:
12. remove few unnecessary variables and some lines.
13. remove the function for one line of code which will be called
    once only for patch series
[6/22]:
14. redesign the method for calculating token_mask' value
[7/22]:
15. delete hns_roce_status_to_errno
16. modify the one enum only for all patches
17. remove the spin_lock in hns_roce_cq_event function
18. add comment here that 0x10 and 0x11 in hns_roce_event struct
19. refactor hns_roce_aeq_int function and It has switch in switch
    and it is almost 200 LOCs
20. simplify the lines for err_out_free_pages branch
[8/22]:
21. remove icm and redesign it for patch series

Changes v9 -> v10:
1. delete redundant lines which it is netdevice.h in hns_roce_main.c
2. adjust the indentation for HNS_ROCE_V1_NUM_ASYNC_EQE
3. simplify the lines in hns_roce_init_qp_table function
4. add static type for hns_roce_unregister_device
5. move the call with hns_roce_unregister_device from the tenth patch to
   the eleventh patch in hns_roce_remove function
6. readjuest the alphabetic order in MAINTAINERS
7. redesigned the way for getting irq names
8. avoid the memory leakage because mr->pbl is not free in
   hns_roce_mr function
9. avoid the memory leakage because not kfree table->icm when exception
10. add the link from LKML as well whose comment in all

Changes v8 -> v9:
1. delete the definition of ADDR_SHIFT_n, use literal 12, 32 and 44 and
   add comments
2. use roce_read/roce_write/readl/write instead of roce_readl/roce_writel
3. delete the print error/debug messages for memory allocation errors
4. use exit instead of uninit, for example hw->uninit -> hw->exit
5. use roce_raw_write instead of _raw_writel in eq_set_cons_index
6. modify the label with underscore
7. adjust the indentation for the macro definitions in hns_roce_hw_v1.c
8. simplify some lines in few functions and structures
9. adjust the alphabetic order in MAINTAINERS

Changes v7 -> v8:
1. add a verbs operation named get_port_immutable. It is an 
   independent patch
2. add a comment for the definition of ADDR_SHIFT_n, n are 12,32
   and 44
3. restructures the code to align with naming convention of the Linux
   according to the review of Doug Ledford
4. modify the state for all .c and .h files

Changes v6 -> v7:
1. modify some type of parameter, use bool replace the original type
2. add the Signed-off-by signatures in the first patch
3. delete the improper print sentence in hns_roce_create_eq.

Changes v5 -> v6:
1. modify the type of obj for unsigned long according the reviews, and
   modify the same questions in RoCE module
2. fix the spelling error
3. fix the Signed-off-by signatures

Changes v4 -> v5:
1. redesign the patchset for RoCE modules in order to split the huge
   patch into small patches
2. fix the directory path for RoCE module. Delete the hisilicon level.
3. modify the name of roce_v1_hw into roce_hw_v1

Changes v3 -> v4:
1. modify roce.o into hns-roce.o in Makefile and Kconfig file

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
  IB/hns: Add hem support
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
 drivers/infiniband/hw/hns/hns_roce_ah.c            |  128 +
 drivers/infiniband/hw/hns/hns_roce_alloc.c         |  257 ++
 drivers/infiniband/hw/hns/hns_roce_cmd.c           |  371 +++
 drivers/infiniband/hw/hns/hns_roce_cmd.h           |   80 +
 drivers/infiniband/hw/hns/hns_roce_common.h        |  325 +++
 drivers/infiniband/hw/hns/hns_roce_cq.c            |  446 ++++
 drivers/infiniband/hw/hns/hns_roce_device.h        |  734 ++++++
 drivers/infiniband/hw/hns/hns_roce_eq.c            |  762 ++++++
 drivers/infiniband/hw/hns/hns_roce_eq.h            |  130 +
 drivers/infiniband/hw/hns/hns_roce_hem.c           |  476 ++++
 drivers/infiniband/hw/hns/hns_roce_hem.h           |  131 +
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c         | 2781 ++++++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_hw_v1.h         |  981 +++++++
 drivers/infiniband/hw/hns/hns_roce_main.c          | 1059 ++++++++
 drivers/infiniband/hw/hns/hns_roce_mr.c            |  614 +++++
 drivers/infiniband/hw/hns/hns_roce_pd.c            |  144 +
 drivers/infiniband/hw/hns/hns_roce_qp.c            |  855 ++++++
 drivers/infiniband/hw/hns/hns_roce_user.h          |   53 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |   84 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |   30 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c |   36 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |   15 +-
 28 files changed, 10626 insertions(+), 1 deletion(-)
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
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_hem.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_hem.h
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_hw_v1.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_hw_v1.h
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_main.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_mr.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_pd.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_qp.c
 create mode 100644 drivers/infiniband/hw/hns/hns_roce_user.h

-- 
1.9.1

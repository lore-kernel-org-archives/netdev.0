From: Ram Amrani <Ram.Amrani@cavium.com>
Subject: [RFC v2 00/11] QLogic RDMA Driver (qedr) RFC
Date: Tue, 20 Sep 2016 13:35:52 +0300
Message-ID: <1474367764-9555-1-git-send-email-Ram.Amrani@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@cavium.com>, <Michal.Kalderon@cavium.com>,
        <Yuval.Mintz@cavium.com>, <rajesh.borundia@cavium.com>,
        <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
        Ram amrani <Ram.Amrani@cavium.com>
To: <davem@davemloft.net>, <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:32897 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932281AbcITKga (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 06:36:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ram amrani <Ram.Amrani@cavium.com>

This series introduces RoCE RDMA driver for the 579xx RDMA products by Qlogic.
The RDMA support is added as an additional loadable module (qedr) over the
Ethernet qede driver.
The qedr module will support both RoCE and iWarp, although this series only
adds RoCE support.
The qed and qede drivers are enhanced with functionality required for RDMA
support.

Based on net-next 4c73195edbe3a5d7e14ea549bb261cf35c29f0cc.

The series adds on top of RFC v1:
* a check for all drivers that IB_ACCESS_MW_BIND isn't set for ib_get_dma_mr
* relocation of qedr user API to include/rdma/uapi/providers/
* removal of qedr_devlist_local
* fixed error handling in qedr_alloc_resources()
* configuration of PBL in ib_map_mr_sg() driver implementation,
  rather than post_send's IB_WR_REG_MR
* misc.: placed code in proper patch, fixed a few comments,
  removed extra parentheses

Thanks for everyone which pointed out problems in the driver.

Any review/comment is appreciated.

Yuval Mintz (1):
  qed: Add LL2

Rajesh Borundia (10):
  qedr: Add RoCE driver framework
  qedr: Add support for RoCE HW init
  qedr: Add support for user context verbs
  qedr: Add support for PD,PKEY and CQ verbs
  qedr: Add support for QP verbs
  qedr: Add support for memory registeration verbs
  qedr: Add support for data path
  qedr: Add LL2 RoCE interface
  qedr: Add GSI support
  qedr: Add events support and register IB device

Ram Amrani (1):
  IB/core: add a protection to ib_get_dma_mr

 drivers/infiniband/Kconfig                     |    2 +
 drivers/infiniband/core/verbs.c                |    3 +
 drivers/infiniband/hw/Makefile                 |    1 +
 drivers/infiniband/hw/qedr/Kconfig             |    7 +
 drivers/infiniband/hw/qedr/Makefile            |    3 +
 drivers/infiniband/hw/qedr/main.c              |  893 ++++++
 drivers/infiniband/hw/qedr/qedr.h              |  494 ++++
 drivers/infiniband/hw/qedr/qedr_cm.c           |  626 +++++
 drivers/infiniband/hw/qedr/qedr_cm.h           |   61 +
 drivers/infiniband/hw/qedr/qedr_hsi.h          |   56 +
 drivers/infiniband/hw/qedr/qedr_hsi_rdma.h     |  748 +++++
 drivers/infiniband/hw/qedr/verbs.c             | 3523 ++++++++++++++++++++++++
 drivers/infiniband/hw/qedr/verbs.h             |   75 +
 drivers/net/ethernet/qlogic/Kconfig            |    8 +
 drivers/net/ethernet/qlogic/qed/Makefile       |    2 +
 drivers/net/ethernet/qlogic/qed/qed.h          |   38 +-
 drivers/net/ethernet/qlogic/qed/qed_cxt.c      |    8 +
 drivers/net/ethernet/qlogic/qed/qed_cxt.h      |    7 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c      |  276 +-
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h  |   20 +
 drivers/net/ethernet/qlogic/qed/qed_hsi.h      |    3 +
 drivers/net/ethernet/qlogic/qed/qed_ll2.c      | 1790 ++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_ll2.h      |  316 +++
 drivers/net/ethernet/qlogic/qed/qed_main.c     |   67 +-
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |   30 +-
 drivers/net/ethernet/qlogic/qed/qed_roce.c     | 2975 ++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_roce.h     |  210 ++
 drivers/net/ethernet/qlogic/qed/qed_sp.h       |    5 +
 drivers/net/ethernet/qlogic/qed/qed_spq.c      |    8 +
 drivers/net/ethernet/qlogic/qede/Makefile      |    1 +
 drivers/net/ethernet/qlogic/qede/qede.h        |    9 +
 drivers/net/ethernet/qlogic/qede/qede_main.c   |   35 +-
 drivers/net/ethernet/qlogic/qede/qede_roce.c   |  309 +++
 include/linux/qed/common_hsi.h                 |    1 +
 include/linux/qed/qed_if.h                     |    9 +-
 include/linux/qed/qed_ll2_if.h                 |  140 +
 include/linux/qed/qed_roce_if.h                |  604 ++++
 include/linux/qed/qede_roce.h                  |   88 +
 include/linux/qed/rdma_common.h                |    1 +
 include/uapi/linux/pci_regs.h                  |    3 +
 include/uapi/rdma/providers/qedr-abi.h         |   81 +
 41 files changed, 13516 insertions(+), 20 deletions(-)
 create mode 100644 drivers/infiniband/hw/qedr/Kconfig
 create mode 100644 drivers/infiniband/hw/qedr/Makefile
 create mode 100644 drivers/infiniband/hw/qedr/main.c
 create mode 100644 drivers/infiniband/hw/qedr/qedr.h
 create mode 100644 drivers/infiniband/hw/qedr/qedr_cm.c
 create mode 100644 drivers/infiniband/hw/qedr/qedr_cm.h
 create mode 100644 drivers/infiniband/hw/qedr/qedr_hsi.h
 create mode 100644 drivers/infiniband/hw/qedr/qedr_hsi_rdma.h
 create mode 100644 drivers/infiniband/hw/qedr/verbs.c
 create mode 100644 drivers/infiniband/hw/qedr/verbs.h
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_ll2.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_ll2.h
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_roce.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_roce.h
 create mode 100644 drivers/net/ethernet/qlogic/qede/qede_roce.c
 create mode 100644 include/linux/qed/qed_ll2_if.h
 create mode 100644 include/linux/qed/qed_roce_if.h
 create mode 100644 include/linux/qed/qede_roce.h
 create mode 100644 include/uapi/rdma/providers/qedr-abi.h

-- 
1.8.3.1

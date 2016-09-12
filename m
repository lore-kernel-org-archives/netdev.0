From: Ram Amrani <Ram.Amrani@qlogic.com>
Subject: [RFC 00/11] QLogic RDMA Driver (qedr) RFC
Date: Mon, 12 Sep 2016 19:07:34 +0300
Message-ID: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Yuval.Mintz@qlogic.com>, <Ariel.Elior@qlogic.com>,
        <Michal.Kalderon@qlogic.com>, <rajesh.borundia@qlogic.com>,
        <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
        Ram Amrani <Ram.Amrani@qlogic.com>
To: <dledford@redhat.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:41312 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751882AbcILQIH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 12:08:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series introduces RoCE RDMA driver for the 579xx RDMA products by Qlogic.
The RDMA support is added as an additional loadable module (qedr) over the Ethernet qede driver.
The qedr module will support both RoCE and iWarp, although this series only adds RoCE support.
The qed and qede drivers are enhanced with functionality required for RDMA support.

Any review/comment is appreciated.

Based on net-next e19ac1578fd8eb3f7c93f2be2657deb2ccefffd7.

Rajesh Borundia (10):
  Add RoCE driver framework
  Add support for PD,PKEY and CQ verbs
  Add support for memory registeration verbs
  Add support for data path
  Add LL2 RoCE interface
  Add events support and register IB device
  Add support for RoCE HW init
  Add support for user context verbs
  Add support for QP verbs
  Add GSI support

Yuval Mintz (1):
  qed: Add LL2

 drivers/infiniband/Kconfig                     |    2 +
 drivers/infiniband/hw/Makefile                 |    1 +
 drivers/infiniband/hw/qedr/Kconfig             |    7 +
 drivers/infiniband/hw/qedr/Makefile            |    3 +
 drivers/infiniband/hw/qedr/main.c              |  907 ++++++
 drivers/infiniband/hw/qedr/qedr.h              |  494 ++++
 drivers/infiniband/hw/qedr/qedr_cm.c           |  626 +++++
 drivers/infiniband/hw/qedr/qedr_cm.h           |   61 +
 drivers/infiniband/hw/qedr/qedr_hsi.h          |   56 +
 drivers/infiniband/hw/qedr/qedr_hsi_rdma.h     |  748 +++++
 drivers/infiniband/hw/qedr/qedr_user.h         |   80 +
 drivers/infiniband/hw/qedr/verbs.c             | 3562 ++++++++++++++++++++++++
 drivers/infiniband/hw/qedr/verbs.h             |   75 +
 drivers/net/ethernet/qlogic/Kconfig            |    8 +
 drivers/net/ethernet/qlogic/qed/Makefile       |    2 +
 drivers/net/ethernet/qlogic/qed/qed.h          |   37 +-
 drivers/net/ethernet/qlogic/qed/qed_cxt.c      |    8 +
 drivers/net/ethernet/qlogic/qed/qed_cxt.h      |    7 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c      |  276 +-
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h  |   20 +
 drivers/net/ethernet/qlogic/qed/qed_hsi.h      |    3 +
 drivers/net/ethernet/qlogic/qed/qed_ll2.c      | 1790 ++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_ll2.h      |  316 +++
 drivers/net/ethernet/qlogic/qed/qed_main.c     |   67 +-
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |   29 +
 drivers/net/ethernet/qlogic/qed/qed_roce.c     | 2975 ++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_roce.h     |  210 ++
 drivers/net/ethernet/qlogic/qed/qed_sp.h       |    5 +
 drivers/net/ethernet/qlogic/qed/qed_spq.c      |    8 +
 drivers/net/ethernet/qlogic/qede/Makefile      |    1 +
 drivers/net/ethernet/qlogic/qede/qede.h        |    9 +
 drivers/net/ethernet/qlogic/qede/qede_main.c   |   35 +-
 drivers/net/ethernet/qlogic/qede/qede_roce.c   |  309 ++
 include/linux/qed/common_hsi.h                 |    1 +
 include/linux/qed/qed_if.h                     |    9 +-
 include/linux/qed/qed_ll2_if.h                 |  140 +
 include/linux/qed/qed_roce_if.h                |  604 ++++
 include/linux/qed/qede_roce.h                  |   88 +
 include/linux/qed/rdma_common.h                |    1 +
 include/uapi/linux/pci_regs.h                  |    3 +
 40 files changed, 13564 insertions(+), 19 deletions(-)
 create mode 100644 drivers/infiniband/hw/qedr/Kconfig
 create mode 100644 drivers/infiniband/hw/qedr/Makefile
 create mode 100644 drivers/infiniband/hw/qedr/main.c
 create mode 100644 drivers/infiniband/hw/qedr/qedr.h
 create mode 100644 drivers/infiniband/hw/qedr/qedr_cm.c
 create mode 100644 drivers/infiniband/hw/qedr/qedr_cm.h
 create mode 100644 drivers/infiniband/hw/qedr/qedr_hsi.h
 create mode 100644 drivers/infiniband/hw/qedr/qedr_hsi_rdma.h
 create mode 100644 drivers/infiniband/hw/qedr/qedr_user.h
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

-- 
1.8.3.1

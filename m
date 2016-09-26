From: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [RFC v3 00/11] QLogic RDMA Driver (qedr) RFC
Date: Mon, 26 Sep 2016 17:16:36 +0300
Message-ID: <1474899407-12635-1-git-send-email-Ram.Amrani@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <rajesh.borundia-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This series introduces RoCE RDMA driver for the 579xx RDMA products by Qlogic.
The RDMA support is added as an additional loadable module (qedr) over the
Ethernet qede driver.
The qedr module will support both RoCE and iWarp, although this series only
adds RoCE support.
The qed and qede drivers are enhanced with functionality required for RDMA
support.

Based on net-next 4c73195edbe3a5d7e14ea549bb261cf35c29f0cc.

The series adds on top of RFC v2:
* fix licensing header to dual license
* remove 'debug' module paramter and make use of pr_debug
* relocation of qedr user API to include/rdma/uapi/
* use the __u32/64 in uapi and include types.h
* advance ABI version (since shifting to __u32/64 changed the ABI)
* remove the check for all drivers that IB_ACCESS_MW_BIND isn't set 
  in ib_get_dma_mr. It will be sent in a dedicated patch.
* misc.: fixed typos, removed redundant includes 

For RFC v2 visit http://marc.info/?l=linux-rdma&m=147436779328618&w=2

Thanks for everyone which pointed out problems in the driver.

Any review/comment is appreciated.

Yuval Mintz (1):
  IB/qed: Add LL2

Rajesh Borundia (10):
  IB/qedr: Add RoCE driver framework
  IB/qedr: Add support for RoCE HW init
  IB/qedr: Add support for user context verbs
  IB/qedr: Add support for PD,PKEY and CQ verbs
  IB/qedr: Add support for QP verbs
  IB/qedr: Add support for memory registeration verbs
  IB/qedr: Add support for data path
  IB/qedr: Add LL2 RoCE interface
  IB/qedr: Add GSI support
  IB/qedr: Add events support and register IB device

 drivers/infiniband/Kconfig                     |    2 +
 drivers/infiniband/hw/Makefile                 |    1 +
 drivers/infiniband/hw/qedr/Kconfig             |    7 +
 drivers/infiniband/hw/qedr/Makefile            |    3 +
 drivers/infiniband/hw/qedr/main.c              |  888 ++++++
 drivers/infiniband/hw/qedr/qedr.h              |  498 ++++
 drivers/infiniband/hw/qedr/qedr_cm.c           |  636 +++++
 drivers/infiniband/hw/qedr/qedr_cm.h           |   61 +
 drivers/infiniband/hw/qedr/qedr_hsi.h          |   56 +
 drivers/infiniband/hw/qedr/qedr_hsi_rdma.h     |  748 +++++
 drivers/infiniband/hw/qedr/verbs.c             | 3561 ++++++++++++++++++++++++
 drivers/infiniband/hw/qedr/verbs.h             |  101 +
 drivers/net/ethernet/qlogic/Kconfig            |    8 +
 drivers/net/ethernet/qlogic/qed/Makefile       |    2 +
 drivers/net/ethernet/qlogic/qed/qed.h          |   38 +-
 drivers/net/ethernet/qlogic/qed/qed_cxt.c      |    8 +
 drivers/net/ethernet/qlogic/qed/qed_cxt.h      |    7 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c      |  276 +-
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h  |   20 +
 drivers/net/ethernet/qlogic/qed/qed_hsi.h      |    3 +
 drivers/net/ethernet/qlogic/qed/qed_ll2.c      | 1792 ++++++++++++
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
 drivers/net/ethernet/qlogic/qede/qede_roce.c   |  309 ++
 include/linux/qed/common_hsi.h                 |    1 +
 include/linux/qed/qed_if.h                     |    9 +-
 include/linux/qed/qed_ll2_if.h                 |  139 +
 include/linux/qed/qed_roce_if.h                |  604 ++++
 include/linux/qed/qede_roce.h                  |   88 +
 include/linux/qed/rdma_common.h                |    1 +
 include/uapi/linux/pci_regs.h                  |    3 +
 include/uapi/rdma/qedr-abi.h                   |  107 +
 41 files changed, 13616 insertions(+), 20 deletions(-)
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
 create mode 100644 include/uapi/rdma/qedr-abi.h

-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

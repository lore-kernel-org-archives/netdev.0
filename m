From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 00/12] qed*: Driver updates
Date: Sun, 1 Jan 2017 13:56:59 +0200
Message-ID: <1483271831-25890-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:53869 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755047AbdAAL6B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:58:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The more interesting changes in this series include:
  - Restructuring of the qede files - qede_main.c has grown big and this
    series splits it into 3 parts [patches #2 and #3].
  - Some significant changes in the API through which RSS indirection
    table gets configured [#8].
  - Support for ndo_set_vf_trust() [#9] which would regulate which VFs
    are allowed to use promisc/multi-promisc mode.

It also contains various minor changes to qed/qede, as well as
non-functional changes [#1, #12] to complement other changes.

Hi Dave,

Please consider applying this series to `net-next'.

Thanks,
Yuval

Manish Chopra (1):
  qede - mark SKB as encapsulated

Ram Amrani (1):
  qed: conserve qed RDMA resources when !QEDR

Yuval Mintz (10):
  qed*: Update to dual-license
  qede: Break datapath logic into its own file
  qede: Split filtering logic to its own file
  qed*: Change maximal number of queues
  qede: Postpone reallocation until NAPI end
  qede: Remove unnecessary datapath dereference
  qed*: RSS indirection based on queue-handles
  qed*: Add support for ndo_set_vf_trust
  qed: Support Multicast on Tx-switching
  qed*: Advance driver version to 8.10.10.20.

 drivers/net/ethernet/qlogic/qed/qed.h              |   34 +-
 drivers/net/ethernet/qlogic/qed/qed_cxt.c          |   32 +-
 drivers/net/ethernet/qlogic/qed/qed_cxt.h          |   34 +-
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c         |   32 +-
 drivers/net/ethernet/qlogic/qed/qed_dcbx.h         |   32 +-
 drivers/net/ethernet/qlogic/qed/qed_dev.c          |   32 +-
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h      |   34 +-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h          |   32 +-
 drivers/net/ethernet/qlogic/qed/qed_hw.c           |   32 +-
 drivers/net/ethernet/qlogic/qed/qed_hw.h           |   32 +-
 .../net/ethernet/qlogic/qed/qed_init_fw_funcs.c    |   32 +-
 drivers/net/ethernet/qlogic/qed/qed_init_ops.c     |   32 +-
 drivers/net/ethernet/qlogic/qed/qed_init_ops.h     |   34 +-
 drivers/net/ethernet/qlogic/qed/qed_int.c          |   32 +-
 drivers/net/ethernet/qlogic/qed/qed_int.h          |   34 +-
 drivers/net/ethernet/qlogic/qed/qed_iscsi.c        |   32 +-
 drivers/net/ethernet/qlogic/qed/qed_iscsi.h        |   32 +-
 drivers/net/ethernet/qlogic/qed/qed_l2.c           |  303 ++-
 drivers/net/ethernet/qlogic/qed/qed_l2.h           |   60 +-
 drivers/net/ethernet/qlogic/qed/qed_ll2.c          |   31 +-
 drivers/net/ethernet/qlogic/qed/qed_ll2.h          |   31 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c         |   43 +-
 drivers/net/ethernet/qlogic/qed/qed_mcp.c          |   36 +-
 drivers/net/ethernet/qlogic/qed/qed_mcp.h          |   34 +-
 drivers/net/ethernet/qlogic/qed/qed_ooo.c          |   32 +-
 drivers/net/ethernet/qlogic/qed/qed_ooo.h          |   32 +-
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h     |   32 +-
 drivers/net/ethernet/qlogic/qed/qed_roce.c         |    2 +-
 drivers/net/ethernet/qlogic/qed/qed_roce.h         |    2 +-
 drivers/net/ethernet/qlogic/qed/qed_selftest.c     |   32 +
 drivers/net/ethernet/qlogic/qed/qed_sp.h           |   34 +-
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c  |   32 +-
 drivers/net/ethernet/qlogic/qed/qed_spq.c          |   32 +-
 drivers/net/ethernet/qlogic/qed/qed_sriov.c        |  242 +-
 drivers/net/ethernet/qlogic/qed/qed_sriov.h        |   41 +-
 drivers/net/ethernet/qlogic/qed/qed_vf.c           |   44 +-
 drivers/net/ethernet/qlogic/qed/qed_vf.h           |   32 +-
 drivers/net/ethernet/qlogic/qede/Makefile          |    2 +-
 drivers/net/ethernet/qlogic/qede/qede.h            |   83 +-
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c    |  114 +-
 drivers/net/ethernet/qlogic/qede/qede_filter.c     |  759 ++++++
 drivers/net/ethernet/qlogic/qede/qede_fp.c         | 1691 +++++++++++++
 drivers/net/ethernet/qlogic/qede/qede_main.c       | 2617 ++------------------
 drivers/net/ethernet/qlogic/qede/qede_roce.c       |    2 +-
 include/linux/qed/common_hsi.h                     |   33 +-
 include/linux/qed/eth_common.h                     |   32 +-
 include/linux/qed/iscsi_common.h                   |   32 +-
 include/linux/qed/qed_chain.h                      |   34 +-
 include/linux/qed/qed_eth_if.h                     |   34 +-
 include/linux/qed/qed_if.h                         |   35 +-
 include/linux/qed/qed_iov_if.h                     |   34 +-
 include/linux/qed/qed_iscsi_if.h                   |   32 +-
 include/linux/qed/qed_ll2_if.h                     |   31 +-
 include/linux/qed/qed_roce_if.h                    |    2 +-
 include/linux/qed/qede_roce.h                      |    2 +-
 include/linux/qed/rdma_common.h                    |   32 +-
 include/linux/qed/roce_common.h                    |   32 +-
 include/linux/qed/storage_common.h                 |   32 +-
 include/linux/qed/tcp_common.h                     |   32 +-
 59 files changed, 4522 insertions(+), 2856 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qede/qede_filter.c
 create mode 100644 drivers/net/ethernet/qlogic/qede/qede_fp.c

-- 
1.9.3

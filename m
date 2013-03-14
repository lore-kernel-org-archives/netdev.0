From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH v2 net-next 00/22] Add support for Chelsio T5 adapter
Date: Thu, 14 Mar 2013 20:38:46 +0530
Message-ID: <1363273748-25330-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	JBottomley@parallels.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	naresh@chelsio.com, divy@chelsio.com, santosh@chelsio.com,
	arvindb@chelsio.com, abhishek@chelsio.com, vipul@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:26451 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756720Ab3CNPO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 11:14:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

This patch series adds support for Chelsio's T5 adapter. It also adds support
for new features of T5. It adds these in cxgb4, cxgb4vf, RDMA/cxgb4 and
csiostor drivers.

Chelsio's T5 asic moves the architecture into 40GbE speeds. T5 is a 10/40GbE
controller with full offload support of a complete Unified Wire solution
comprising NIC, Virtualization, TOE, iWARP RDMA and FCoE.

T5 supports all the offload, virtualization and switching capabilities of the
existing T4 and adds some new features. The patch series does basic
intialization for T5 in each driver. The patch series implements a low
latency Write Combining work request path in cxgb4 and RDMA/cxgb4 driver for
T5. It supports new T5 feature DSGL in RDMA/cxgb4 driver which enables direct
DMA by HW to memory region PBL arrays and fast register PBL arrays from host
memory. It adds support for dumping T5 registers, T5's debugfs support and
enables doorbell drop recovery only for T4 in cxgb4 driver.

To facilitate addition of support in csiostor for future adapters, a new
framework for adapter specific operations has been defined. Consequently, T4
and T5 specific operations are now separated into different files. One of the
csiostor patches also includes common bug fixes.

We are submitting changes in all the drivers for T5 in one series since there
are common changes in cxgb4 driver which are required by all the ULDs and
csiostor. This way we can avoid build failures, build dependencies and ensure
smooth integration.

We request to merge this patch series via David Miller's net-next tree. We are
copying respective maintainers of all the drivers for reviewing the changes.
Kindly let us know in case of any review comments.

We have successfully carried out networking, virtualization, iWARP and storage
related stress tests on this patch series.

Thanks,
Vipul Pandya

v2: Replaced #ifdef with portable interface wmb in ring_tx_db

Arvind Bhushan (4):
  csiostor: Segregate T4 adapter operations.
  csiostor: Add T5 adapter operations.
  csiostor: Header file modifications for chip support and bug fixes.
  csiostor: Cleanup chip specific operations.

Santosh Rastapur (11):
  cxgb4: Add register definations for T5
  cxgb4: Add macros, structures and inline functions for T5
  cxgb4: Initialize T5
  cxgb4: Dump T5 registers
  cxgb4: Add T5 write combining support
  cxgb4: Enable doorbell drop recovery only for T4 adapter
  cxgb4: Add T5 debugfs support
  cxgb4: Add T5 PCI ids
  cxgb4: Update driver version and description
  cxgb4: Disable SR-IOV support for PF4-7 for T5
  cxgb4vf: Add support for Chelsio T5 adapter

Vipul Pandya (7):
  RDMA/cxgb4: Add Support for Chelsio T5 adapter
  RDMA/cxgb4: Turn off db coalescing when RDMA QPs are in use.
  RDMA/cxgb4: Add module_params to enable DB FC & Coalescing on T5
  RDMA/cxgb4: Use DSGLs for fastreg and adapter memory writes for T5.
  RDMA/cxgb4: Map pbl buffers for dma if using DSGL.
  RDMA/cxgb4: Bump tcam_full stat and WR reply timeout
  RDMA/cxgb4: Fix onchip queue support for T5

 drivers/infiniband/hw/cxgb4/cm.c                   |   66 ++-
 drivers/infiniband/hw/cxgb4/device.c               |   34 +-
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h             |   14 +-
 drivers/infiniband/hw/cxgb4/mem.c                  |  155 ++++-
 drivers/infiniband/hw/cxgb4/provider.c             |   15 +-
 drivers/infiniband/hw/cxgb4/qp.c                   |  113 ++-
 drivers/infiniband/hw/cxgb4/t4.h                   |   11 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   55 ++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  778 ++++++++++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |    3 +
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |   89 ++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  256 ++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |    1 -
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h        |   53 ++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   98 +++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |    2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h     |    1 +
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |   35 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |    8 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |   24 +
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |   14 +-
 drivers/scsi/csiostor/Makefile                     |    3 +-
 drivers/scsi/csiostor/csio_hw.c                    |  559 +++-----------
 drivers/scsi/csiostor/csio_hw.h                    |   47 +-
 drivers/scsi/csiostor/csio_hw_chip.h               |  175 +++++
 drivers/scsi/csiostor/csio_hw_t4.c                 |  403 ++++++++++
 drivers/scsi/csiostor/csio_hw_t5.c                 |  397 ++++++++++
 drivers/scsi/csiostor/csio_init.c                  |   48 +-
 drivers/scsi/csiostor/csio_init.h                  |   29 +-
 drivers/scsi/csiostor/csio_lnode.h                 |    2 +-
 drivers/scsi/csiostor/csio_rnode.c                 |   10 +-
 drivers/scsi/csiostor/csio_rnode.h                 |    2 +-
 drivers/scsi/csiostor/csio_wr.c                    |   60 +-
 33 files changed, 2819 insertions(+), 741 deletions(-)
 create mode 100644 drivers/scsi/csiostor/csio_hw_chip.h
 create mode 100644 drivers/scsi/csiostor/csio_hw_t4.c
 create mode 100644 drivers/scsi/csiostor/csio_hw_t5.c

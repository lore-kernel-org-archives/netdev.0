From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: [v6 PATCH 0/8] csiostor: Chelsio FCoE offload driver submission
Date: Thu, 15 Nov 2012 22:41:16 +0530
Message-ID: <1352999484-17812-1-git-send-email-naresh@chelsio.com>
Cc: netdev@vger.kernel.org, naresh@chelsio.com, chethan@chelsio.com
To: JBottomley@parallels.com, linux-scsi@vger.kernel.org,
	dm@chelsio.com, leedom@chelsio.com
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the initial submission of the Chelsio FCoE offload driver (csiostor)
to the upstream kernel. This driver currently supports FCoE offload
functionality over Chelsio T4-based 10Gb Converged Network Adapters.

The following patches contain the driver sources for csiostor driver and
updates to firmware/hardware header files shared between csiostor,
cxgb4 (Chelsio T4-based NIC driver) and cxgb4vf (Chelsio T4-based Virtual
Function NIC driver). The csiostor driver is dependent on these
header updates. These patches have been generated against scsi 'misc' branch.

csiostor is a low level SCSI driver that interfaces with PCI, SCSI midlayer and
FC transport subsystems. This driver claims the FCoE PCIe function on
Chelsio Converged Network Adapters. It relies on firmware events for slow path
operations like discovery, thereby offloading session management. The driver
programs firmware via Work Request interfaces for fast path I/O offload
features.

v6 has changes to make csiostor work with cxgb4 header files post 3.6 merge, as
well as a few bug fixes in csiostor.

Here is the brief description of patches:
[v6 PATCH 1/8]: Updates to header files shared between cxgb4, cxgb4vf and
                csiostor.
[v6 PATCH 2/8]: Header files part 1.
[v6 PATCH 3/8]: Header files part 2.
[v6 PATCH 4/8]: Driver initialization and Work Request services.
[v6 PATCH 5/8]: FC transport interfaces and mailbox services.
[v6 PATCH 6/8]: Local and remote port state tracking functionality.
[v6 PATCH 7/8]: Interrupt handling and fast path I/O functionality.
[v6 PATCH 8/8]: Hardware interface, Makefile and Kconfig changes.

Naresh Kumar Inna (8):
  cxgb4/cxgb4vf: Chelsio FCoE offload driver submission (common header
    updates).
  csiostor: Chelsio FCoE offload driver submission (headers part 1).
  csiostor: Chelsio FCoE offload driver submission (headers part 2).
  csiostor: Chelsio FCoE offload driver submission (sources part 1).
  csiostor: Chelsio FCoE offload driver submission (sources part 2).
  csiostor: Chelsio FCoE offload driver submission (sources part 3).
  csiostor: Chelsio FCoE offload driver submission (sources part 4).
  csiostor: Chelsio FCoE offload driver submission (sources part 5).

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   10 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |    6 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |   20 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |    1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |   36 +-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |   41 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c      |    8 +-
 drivers/scsi/Kconfig                            |    1 +
 drivers/scsi/Makefile                           |    1 +
 drivers/scsi/csiostor/Kconfig                   |   19 +
 drivers/scsi/csiostor/Makefile                  |   11 +
 drivers/scsi/csiostor/csio_attr.c               |  796 ++++
 drivers/scsi/csiostor/csio_defs.h               |  121 +
 drivers/scsi/csiostor/csio_hw.c                 | 4395 +++++++++++++++++++++++
 drivers/scsi/csiostor/csio_hw.h                 |  667 ++++
 drivers/scsi/csiostor/csio_init.c               | 1274 +++++++
 drivers/scsi/csiostor/csio_init.h               |  158 +
 drivers/scsi/csiostor/csio_isr.c                |  624 ++++
 drivers/scsi/csiostor/csio_lnode.c              | 2133 +++++++++++
 drivers/scsi/csiostor/csio_lnode.h              |  255 ++
 drivers/scsi/csiostor/csio_mb.c                 | 1770 +++++++++
 drivers/scsi/csiostor/csio_mb.h                 |  278 ++
 drivers/scsi/csiostor/csio_rnode.c              |  912 +++++
 drivers/scsi/csiostor/csio_rnode.h              |  141 +
 drivers/scsi/csiostor/csio_scsi.c               | 2555 +++++++++++++
 drivers/scsi/csiostor/csio_scsi.h               |  342 ++
 drivers/scsi/csiostor/csio_wr.c                 | 1632 +++++++++
 drivers/scsi/csiostor/csio_wr.h                 |  512 +++
 drivers/scsi/csiostor/t4fw_api_stor.h           |  578 +++
 29 files changed, 19268 insertions(+), 29 deletions(-)
 create mode 100644 drivers/scsi/csiostor/Kconfig
 create mode 100644 drivers/scsi/csiostor/Makefile
 create mode 100644 drivers/scsi/csiostor/csio_attr.c
 create mode 100644 drivers/scsi/csiostor/csio_defs.h
 create mode 100644 drivers/scsi/csiostor/csio_hw.c
 create mode 100644 drivers/scsi/csiostor/csio_hw.h
 create mode 100644 drivers/scsi/csiostor/csio_init.c
 create mode 100644 drivers/scsi/csiostor/csio_init.h
 create mode 100644 drivers/scsi/csiostor/csio_isr.c
 create mode 100644 drivers/scsi/csiostor/csio_lnode.c
 create mode 100644 drivers/scsi/csiostor/csio_lnode.h
 create mode 100644 drivers/scsi/csiostor/csio_mb.c
 create mode 100644 drivers/scsi/csiostor/csio_mb.h
 create mode 100644 drivers/scsi/csiostor/csio_rnode.c
 create mode 100644 drivers/scsi/csiostor/csio_rnode.h
 create mode 100644 drivers/scsi/csiostor/csio_scsi.c
 create mode 100644 drivers/scsi/csiostor/csio_scsi.h
 create mode 100644 drivers/scsi/csiostor/csio_wr.c
 create mode 100644 drivers/scsi/csiostor/csio_wr.h
 create mode 100644 drivers/scsi/csiostor/t4fw_api_stor.h


From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: [PATCH 0/8] csiostor: Chelsio FCoE offload driver submission
Date: Fri, 24 Aug 2012 03:57:45 +0530
Message-ID: <1345760873-12101-1-git-send-email-naresh@chelsio.com>
Cc: netdev@vger.kernel.org, naresh@chelsio.com, chethan@chelsio.com
To: JBottomley@parallels.com, linux-scsi@vger.kernel.org,
	dm@chelsio.com
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the initial submission of the Chelsio FCoE offload driver (csiostor)
to the upstream kernel. This driver currently supports FCoE offload
functionality over Chelsio T4-based 10Gb Converged Network Adapters.

The following patches contain the driver sources for csiostor driver and
updates to firmware/hardware header files shared between csiostor and
cxgb4 (Chelsio T4-based NIC driver). The csiostor driver is dependent on these
header updates. These patches have been generated against scsi 'misc' branch.

csiostor is a low level SCSI driver that interfaces with PCI, SCSI midlayer and
FC transport subsystems. This driver claims the FCoE PCIe function on the
Chelsio Converged Network Adapter. It relies on firmware events for slow path
operations like discovery, thereby offloading session management. The driver
programs firmware via Work Request interfaces for fast path I/O offload
features.

Here is the brief description of patches:
[PATCH 1/8]: Hardware interface, Makefile and Kconfig changes.
[PATCH 2/8]: Driver initialization and Work Request services.
[PATCH 3/8]: FC transport interfaces and mailbox services.
[PATCH 4/8]: Local and remote port state tracking functionality.
[PATCH 5/8]: Interrupt handling and fast path I/O functionality.
[PATCH 6/8]: Header files part 1.
[PATCH 7/8]: Header files part 2.
[PATCH 8/8]: Updates to header files shared between cxgb4 and csiostor.

Naresh Kumar Inna (8):
  csiostor: Chelsio FCoE offload driver submission (sources part 1).
  csiostor: Chelsio FCoE offload driver submission (sources part 2).
  csiostor: Chelsio FCoE offload driver submission (sources part 3).
  csiostor: Chelsio FCoE offload driver submission (sources part 4).
  csiostor: Chelsio FCoE offload driver submission (sources part 5).
  csiostor: Chelsio FCoE offload driver submission (headers part 1).
  csiostor: Chelsio FCoE offload driver submission (headers part 2).
  cxgb4: Chelsio FCoE offload driver submission (cxgb4 common header
    updates).

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |   10 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |   16 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |    1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |   69 +-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |  104 +-
 drivers/scsi/Kconfig                            |    1 +
 drivers/scsi/Makefile                           |    1 +
 drivers/scsi/csiostor/Kconfig                   |   20 +
 drivers/scsi/csiostor/Makefile                  |   11 +
 drivers/scsi/csiostor/csio_attr.c               |  808 +++++
 drivers/scsi/csiostor/csio_defs.h               |  143 +
 drivers/scsi/csiostor/csio_fcoe_proto.h         |  843 +++++
 drivers/scsi/csiostor/csio_hw.c                 | 4385 +++++++++++++++++++++++
 drivers/scsi/csiostor/csio_hw.h                 |  668 ++++
 drivers/scsi/csiostor/csio_init.c               | 1392 +++++++
 drivers/scsi/csiostor/csio_init.h               |  158 +
 drivers/scsi/csiostor/csio_isr.c                |  631 ++++
 drivers/scsi/csiostor/csio_lnode.c              | 2151 +++++++++++
 drivers/scsi/csiostor/csio_lnode.h              |  244 ++
 drivers/scsi/csiostor/csio_mb.c                 | 1768 +++++++++
 drivers/scsi/csiostor/csio_mb.h                 |  278 ++
 drivers/scsi/csiostor/csio_rnode.c              |  889 +++++
 drivers/scsi/csiostor/csio_rnode.h              |  142 +
 drivers/scsi/csiostor/csio_scsi.c               | 2498 +++++++++++++
 drivers/scsi/csiostor/csio_scsi.h               |  332 ++
 drivers/scsi/csiostor/csio_wr.c                 | 1634 +++++++++
 drivers/scsi/csiostor/csio_wr.h                 |  519 +++
 drivers/scsi/csiostor/t4fw_api_stor.h           |  578 +++
 29 files changed, 20264 insertions(+), 32 deletions(-)
 create mode 100644 drivers/scsi/csiostor/Kconfig
 create mode 100644 drivers/scsi/csiostor/Makefile
 create mode 100644 drivers/scsi/csiostor/csio_attr.c
 create mode 100644 drivers/scsi/csiostor/csio_defs.h
 create mode 100644 drivers/scsi/csiostor/csio_fcoe_proto.h
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


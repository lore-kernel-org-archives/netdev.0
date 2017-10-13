From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next v2 0/8] cxgb4: add support to get hardware debug logs via ethtool
Date: Fri, 13 Oct 2017 18:48:12 +0530
Message-ID: <cover.1507899723.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, ganeshgr@chelsio.com, nirranjan@chelsio.com,
        indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:33974 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753258AbdJMNTb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 09:19:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches add support to collect hardware debug logs
via ethtool --get-dump facility.

Currently supports:

Memory dumps - Collects on-chip EDC0 and EDC1 dumps.
Hardware dumps - Collects firmware and hardware dumps.

Patch 1 adds ethtool set/get dump data.  It also adds template header
that precedes dump data.  This template header gives additional
information needed for extracting and decoding the collected dump
data.

Patch 2 adds base to collect dumps.  Also collects regdump.

Patch 3 collects on-chip EDC0 and EDC1 memory dumps.

Patch 4 collects firmware mbox log and device log.

Patch 5 updates base API for accessing TP indirect registers.

Patch 6 collects hardware TP module dump.

Patch 7 collects hardware SGE, PCIE, PM, UP CIM, MA, and HMA
module dumps.

Patch 8 collects hardware IBQ and OBQ dump.

Thanks,
Rahul

---
v2:
- Prefix symbols that pollute global namespace in files starting
  with cxgb4_* with "cxgb4_"
- Prefix symbols that pollute global namespace in files starting
  with cudbg_* with "cudbg_"
- Make cudbg_collect_mem_info() static.

Rahul Lakkireddy (8):
  cxgb4: implement ethtool dump data operations
  cxgb4: collect register dump
  cxgb4: collect on-chip memory dump
  cxgb4: collect firmware mbox and device log dump
  cxgb4: update API for TP indirect register access
  cxgb4: collect TP dump
  cxgb4: collect hardware module dumps
  cxgb4: collect IBQ and OBQ dumps

 drivers/net/ethernet/chelsio/cxgb4/Makefile        |   3 +-
 drivers/net/ethernet/chelsio/cxgb4/cudbg_common.c  |  54 ++
 drivers/net/ethernet/chelsio/cxgb4/cudbg_entity.h  | 181 +++++
 drivers/net/ethernet/chelsio/cxgb4/cudbg_if.h      |  69 ++
 drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c     | 867 +++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h     | 103 +++
 .../net/ethernet/chelsio/cxgb4/cudbg_lib_common.h  |  81 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  41 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c   | 296 +++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.h   |  44 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  13 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c |  70 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   7 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 332 +++++---
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   2 +
 15 files changed, 2021 insertions(+), 142 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cudbg_common.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cudbg_entity.h
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cudbg_if.h
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cudbg_lib_common.h
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.h

-- 
2.14.1

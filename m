From: Michal Kalderon <Michal.Kalderon@cavium.com>
Subject: [PATCH net-next 00/12] qed: Add iWARP support for QL4xxxx
Date: Sun, 2 Jul 2017 10:29:20 +0300
Message-ID: <1498980572-29519-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michal Kalderon <Michal.Kalderon@cavium.com>
To: <michal.kalderon@cavium.com>, <ram.amrani@cavium.com>,
        <yuval.mintz@cavium.com>, <ariel.elior@cavium.com>,
        <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>, <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0082.outbound.protection.outlook.com ([104.47.33.82]:8256
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751664AbdGBHao (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 2 Jul 2017 03:30:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds iWARP support to our QL4xxxx networking adapters.
The code changes span across qed and qedr drivers, but this series contains
changes to qed only. Once the series is accepted, the qedr series will
be submitted to the rdma tree.
There is one additional qed patch which enables the iWARP, this patch is
delayed until the qedr series will be accepted. 

The patches were previously sent as an RFC, and these are the first 12
patches in the RFC series:
https://www.spinics.net/lists/linux-rdma/msg51416.html

This series was tested and built against net-next.

MAINTAINERS file is not updated in this PATCH as there is a pending patch
for qedr driver update https://patchwork.kernel.org/patch/9752761.

Michal Kalderon (12):
  qed: Introduce iWARP personality
  qed: Implement iWARP initialization, teardown and qp operations
  qed: Rename some ll2 related defines
  qed: Add iWARP support in ll2 connections
  qed: iWARP CM - setup a ll2 connection for handling SYN packets
  qed: iWARP CM add listener functions and initial SYN processing
  qed: iWARP CM add passive side connect
  qed: iWARP CM add active side connect
  qed: iWARP implement disconnect flows
  qed: iWARP CM add error handling
  qed: Add iWARP protocol support in context allocation
  qed: Add iWARP support for physical queue allocation

 drivers/net/ethernet/qlogic/qed/Makefile    |    2 +-
 drivers/net/ethernet/qlogic/qed/qed.h       |   30 +-
 drivers/net/ethernet/qlogic/qed/qed_cxt.c   |   21 +-
 drivers/net/ethernet/qlogic/qed/qed_dev.c   |   36 +-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h   |    1 +
 drivers/net/ethernet/qlogic/qed/qed_iwarp.c | 2409 +++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_iwarp.h |  189 +++
 drivers/net/ethernet/qlogic/qed/qed_l2.c    |   16 +-
 drivers/net/ethernet/qlogic/qed/qed_ll2.c   |   42 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c  |   17 +-
 drivers/net/ethernet/qlogic/qed/qed_rdma.c  |  139 +-
 drivers/net/ethernet/qlogic/qed/qed_rdma.h  |    5 +
 drivers/net/ethernet/qlogic/qed/qed_roce.c  |   20 +
 drivers/net/ethernet/qlogic/qed/qed_sp.h    |    7 +-
 include/linux/qed/common_hsi.h              |    4 +-
 include/linux/qed/iwarp_common.h            |   53 +
 include/linux/qed/qed_ll2_if.h              |    3 +-
 include/linux/qed/qed_rdma_if.h             |  114 ++
 18 files changed, 3008 insertions(+), 100 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_iwarp.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_iwarp.h
 create mode 100644 include/linux/qed/iwarp_common.h

-- 
1.8.3.1

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 0/5] qed: QM & ILT changes
Date: Mon, 3 Apr 2017 12:21:08 +0300
Message-ID: <1491211273-10910-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:51511 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752580AbdDCJV6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 05:21:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series introduces several changes and improvements to existing
queue manager and ILT configurations done during initialization.
Notice some of the patches are actually future fixes, I.e., bugs that
can't be triggered with exisiting driver but are needed for some future
functionality.

Patch #1 refactors the configuration of the hardware's queue manager,
which is quite messy today. This contains most of the bulk [code-wise]
in the series.

Patch #2, #3 fix Timers related ILT configurations that are yet to
affect qed in existing scenarios.

Patch #4 reduces needless ILT lines wasted for RoCE configurations.

Patch #5 allows RoCE partitions to manage with less memory regions
[important, e.g., for Multi-function parititions with RoCE support].

Dave,

Please consider applying this series to 'net-next'.

Thanks,
Yuval

Ariel Elior (1):
  qed: Revise QM cofiguration

Michal Kalderon (1):
  qed: Fix TM block ILT allocation

Ram Amrani (1):
  qed: Manage with less memory regions for RoCE

Yuval Mintz (2):
  qed: Correct TM ILT lines in presence of VFs
  qed: RoCE doesn't need to use SRC

 drivers/net/ethernet/qlogic/qed/qed.h       |  43 +-
 drivers/net/ethernet/qlogic/qed/qed_cxt.c   | 163 ++++--
 drivers/net/ethernet/qlogic/qed/qed_cxt.h   |  15 +-
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c  |  14 +-
 drivers/net/ethernet/qlogic/qed/qed_dev.c   | 782 ++++++++++++++++++++++------
 drivers/net/ethernet/qlogic/qed/qed_fcoe.c  |   8 +-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h   |  11 +-
 drivers/net/ethernet/qlogic/qed/qed_hw.c    |  52 --
 drivers/net/ethernet/qlogic/qed/qed_hw.h    |   3 -
 drivers/net/ethernet/qlogic/qed/qed_int.c   |   3 +-
 drivers/net/ethernet/qlogic/qed/qed_iscsi.c |  17 +-
 drivers/net/ethernet/qlogic/qed/qed_l2.c    |   5 +-
 drivers/net/ethernet/qlogic/qed/qed_ll2.c   |  15 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c  |   1 -
 drivers/net/ethernet/qlogic/qed/qed_roce.c  |  12 +-
 drivers/net/ethernet/qlogic/qed/qed_spq.c   |  15 +-
 drivers/net/ethernet/qlogic/qed/qed_sriov.c |   8 +-
 include/linux/qed/qed_if.h                  |   1 -
 18 files changed, 817 insertions(+), 351 deletions(-)

-- 
1.9.3

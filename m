From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 00/10] qed*: Bug fixes
Date: Sun, 19 Feb 2017 15:26:13 +0200
Message-ID: <1487510783-19919-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:54322 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751564AbdBSN0h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 08:26:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

The 3 first patches here are a repost of
("qed: RoCE infrastructure fixes"). The fourth is an additional
RoCE-related infrastructure fix, and the latter contain various fixes
to qed/qede.

Notice patch #10 will create a conflict when net and net-next would
be merged [although its fix is quite trivial].

Please consider applying these to `net'.

Thanks,
Yuval

Ram Amrani (4):
  qed: Release CQ resource under lock on failure
  qed: Read queue state before releasing buffer
  qed: Don't free a QP more than once
  qed: Reserve doorbell BAR space for all present CPUs

Sudarsana Reddy Kalluru (1):
  qede: Prevent index problems in loopback test

Yuval Mintz (5):
  qede: Initialize lock and slowpath workqueue early
  qede: Free netdevice only after stoping slowpath
  qed: Reflect PF link when initializing VF
  qed: Don't allocate SBs using main PTT
  qed*: Fix link indication race

 drivers/net/ethernet/qlogic/qed/qed_dev.c       |  2 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c      | 27 ++++++--
 drivers/net/ethernet/qlogic/qed/qed_mcp.c       | 18 +++--
 drivers/net/ethernet/qlogic/qed/qed_mcp.h       |  6 ++
 drivers/net/ethernet/qlogic/qed/qed_roce.c      | 63 +++++++++--------
 drivers/net/ethernet/qlogic/qed/qed_sriov.c     | 90 ++++++++++++++-----------
 drivers/net/ethernet/qlogic/qed/qed_sriov.h     |  1 +
 drivers/net/ethernet/qlogic/qed/qed_vf.c        |  3 +
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c |  6 +-
 drivers/net/ethernet/qlogic/qede/qede_main.c    | 24 ++++---
 10 files changed, 151 insertions(+), 89 deletions(-)

-- 
1.9.3

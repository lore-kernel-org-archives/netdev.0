From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 0/7] qed: Fixes series
Date: Tue, 14 Mar 2017 15:25:57 +0200
Message-ID: <1489497964-13734-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:39028 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751958AbdCNN0N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 09:26:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This address several different issues in qed.
The more significant portions:

Patch #1 would cause timeout when qedr utilizes the highest
CIDs availble for it [or when future qede adapters would utilize
queues in some constellations].

Patch #4 fixes a leak of mapped addresses; When iommu is enabled,
offloaded storage protocols might eventually run out of resources
and fail to map additional buffers.

Patches #6,#7 were missing in the initial iSCSI infrastructure
submissions, and would hamper qedi's stability when it reaches
out-of-order scenarios.

Dave,

Please consider applying these to 'net'.

Thanks,
Yuval

Ram Amrani (2):
  qed: Align CIDs according to DORQ requirement
  qed: Fix interrupt flags on Rx LL2

Tomer Tayar (1):
  qed: Prevent creation of too-big u32-chains

Yuval Mintz (4):
  qed: Fix mapping leak on LL2 rx flow
  qed: Free previous connections when releasing iSCSI
  qed: Correct out-of-bound access in OOO history
  qed: Enable iSCSI Out-of-Order

 drivers/net/ethernet/qlogic/qed/qed_cxt.c   |  3 ++-
 drivers/net/ethernet/qlogic/qed/qed_dev.c   |  5 ++---
 drivers/net/ethernet/qlogic/qed/qed_iscsi.c | 31 +++++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_ll2.c   | 11 ++++++----
 drivers/net/ethernet/qlogic/qed/qed_ooo.c   |  2 ++
 5 files changed, 44 insertions(+), 8 deletions(-)

-- 
1.9.3

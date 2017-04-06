From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 0/8] qed: Misc cleanups and fixes
Date: Thu, 6 Apr 2017 15:58:27 +0300
Message-ID: <1491483515-13502-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:53175 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753213AbdDFM7D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 08:59:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patches #1 and #2 revolve around register access performed by driver;
The first merely adds some debug, while the second does some fixing
of incorrect PTT usage as well as preventing issues similar to those
fixed by 6f437d431930 ("qed: Don't use attention PTT for configuring BW").

Patch #3 better configures HW for architecture where cacheline isn't 64B.

Patches #4-#8 all affect iSCSI related functionaility - 
adding statistics information [both to driver & management firmware],
passing information on number of resources to qedi, and simplifying
the Out-of-order implementation in SW.

Dave,

Please consider applying this series to `net-next'.

Thanks,
Yuval

Michal Kalderon (1):
  qed: Make OOO archipelagos into an array

Rahul Verma (1):
  qed: Don't use main-ptt in unrelated flows

Tomer Tayar (1):
  qed: Something about cache-lines

Yuval Mintz (5):
  qed: Warn PTT usage by wrong hw-function
  qed: Don't close the OUT_EN during init
  qed: Add missing stat for new isles
  qed: Inform qedi the number of possible CQs
  qed: Provide iSCSI statistics to management

 drivers/net/ethernet/qlogic/qed/qed.h          |   3 +-
 drivers/net/ethernet/qlogic/qed/qed_cxt.c      |   8 +-
 drivers/net/ethernet/qlogic/qed/qed_cxt.h      |   9 +-
 drivers/net/ethernet/qlogic/qed/qed_dev.c      | 137 ++++++++++++++++++-------
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h  |   8 +-
 drivers/net/ethernet/qlogic/qed/qed_fcoe.c     |  10 +-
 drivers/net/ethernet/qlogic/qed/qed_hw.c       |   7 ++
 drivers/net/ethernet/qlogic/qed/qed_iscsi.c    |  33 ++++++
 drivers/net/ethernet/qlogic/qed/qed_iscsi.h    |  14 ++-
 drivers/net/ethernet/qlogic/qed/qed_l2.c       |  14 ++-
 drivers/net/ethernet/qlogic/qed/qed_ll2.c      |  49 ++++++---
 drivers/net/ethernet/qlogic/qed/qed_main.c     |   5 +
 drivers/net/ethernet/qlogic/qed/qed_ooo.c      | 102 +++++-------------
 drivers/net/ethernet/qlogic/qed/qed_ooo.h      |   6 +-
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |   1 +
 drivers/net/ethernet/qlogic/qed/qed_spq.c      |  20 +++-
 include/linux/qed/qed_iscsi_if.h               |   2 +
 17 files changed, 275 insertions(+), 153 deletions(-)

-- 
1.9.3

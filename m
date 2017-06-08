From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 0/8] qed*: Light L2 updates
Date: Thu, 8 Jun 2017 19:13:15 +0300
Message-ID: <20170608161323.7597-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <Michal.Kalderon@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0086.outbound.protection.outlook.com ([104.47.38.86]:9488
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751504AbdFHQNl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Jun 2017 12:13:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series does a major overhaul of the LL2 logic in qed.
The single biggest change done here is in #5 where we're changing
the API qed provides for LL2 [both internally in case of storage and
externally in case of RoCE] to become callback-based to allow cleaner
scalability in preperation to the future iWARP submission which would
aadd additional flavors of LL2. It's also the only patch in series
to modify !qed logic [qedr].

Patches prior to that mostly deal with refactoring LL2 code,
encapsulating varaious parameters into structure and re-ordering
of LL2 code. The latter patches add some small missing bits of LL2
ffunctionality.

Dave,

Please consider applying this series to `net-next'.

Thanks,
Yuval

Michal Kalderon (1):
  qed*: LL2 callback operations

Yuval Mintz (7):
  qed: LL2 to use packed information for tx
  qed: Revise ll2 Rx completion
  qed: Cleaner seperation of LL2 inputs
  qed: LL2 code relocations
  qed: No need for LL2 frags indication
  qed: Call rx_release_cb() when flushing LL2
  qed: collect GSI port statistics

 drivers/infiniband/hw/qedr/main.c          |   6 +-
 drivers/infiniband/hw/qedr/qedr.h          |   2 +
 drivers/infiniband/hw/qedr/qedr_cm.c       | 238 ++++++--
 drivers/net/ethernet/qlogic/qed/qed.h      |   1 -
 drivers/net/ethernet/qlogic/qed/qed_ll2.c  | 882 +++++++++++++++--------------
 drivers/net/ethernet/qlogic/qed/qed_ll2.h  | 113 +---
 drivers/net/ethernet/qlogic/qed/qed_roce.c | 295 +---------
 drivers/net/ethernet/qlogic/qed/qed_roce.h |  43 --
 include/linux/qed/qed_ll2_if.h             | 126 +++++
 include/linux/qed/qed_roce_if.h            |  80 +--
 10 files changed, 842 insertions(+), 944 deletions(-)

-- 
2.9.4

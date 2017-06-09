From: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2 net-next 0/8] qed*: Light L2 updates
Date: Fri, 9 Jun 2017 17:13:17 +0300
Message-ID: <20170609141325.20547-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

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

Changes from previous versions
------------------------------
 - V2 - Change layout of strucutres introduced in #1, #2
        to mend gaps due to alignment.

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
 include/linux/qed/qed_ll2_if.h             | 128 +++++
 include/linux/qed/qed_roce_if.h            |  80 +--
 10 files changed, 844 insertions(+), 944 deletions(-)

-- 
2.9.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 0/4] qed*: File split and rename towards iWARP support
Date: Wed, 21 Jun 2017 16:22:42 +0300
Message-ID: <1498051366-22988-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch series makes a few more infrastructure changes towards adding
iWARP support. Hopefully this is the last infrastructure change
prior to the iWARP RFC.

Patch #1-3 take care of taking all the common iWARP/RoCE code out of
qed_roce.[ch] and placing it in qed_rdma.[ch]
Patch #4 renames the roce interface file as it is common for
RoCE and iWARP. This patch touches qedr as well.


Michal Kalderon (4):
  qed: Cleanup qed_roce before duplicating it
  qed: Duplicate qed_roce.[ch] to qed_rdma.[ch]
  qed: Split rdma content between qed_rdma and qed_roce
  qed*: Rename qed_roce_if.h to qed_rdma_if.h

 drivers/infiniband/hw/qedr/qedr.h                  |    2 +-
 drivers/infiniband/hw/qedr/qedr_cm.c               |    2 +-
 drivers/net/ethernet/qlogic/qed/Makefile           |    2 +-
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c         |    2 +-
 drivers/net/ethernet/qlogic/qed/qed_dev.c          |    2 +-
 drivers/net/ethernet/qlogic/qed/qed_ll2.c          |    2 +-
 drivers/net/ethernet/qlogic/qed/qed_rdma.c         | 1722 ++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_rdma.h         |  201 +++
 drivers/net/ethernet/qlogic/qed/qed_roce.c         | 1711 +------------------
 drivers/net/ethernet/qlogic/qed/qed_roce.h         |  151 +-
 drivers/net/ethernet/qlogic/qed/qed_spq.c          |    2 +-
 include/linux/qed/{qed_roce_if.h => qed_rdma_if.h} |    4 +-
 12 files changed, 1963 insertions(+), 1840 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_rdma.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_rdma.h
 rename include/linux/qed/{qed_roce_if.h => qed_rdma_if.h} (99%)

-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

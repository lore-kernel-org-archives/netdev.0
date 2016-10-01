From: Yuval Mintz <Yuval.Mintz-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH net-next 0/7] qed*: Add qedr infrastructure support
Date: Sat, 1 Oct 2016 21:59:54 +0300
Message-ID: <1475348401-31392-1-git-send-email-Yuval.Mintz@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <Ram.Amrani-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        <Michal.Kalderon-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        <Ariel.Elior-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Yuval Mintz <Yuval.Mintz-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In the last couple of weeks we've been sending RFCs for the qedr
driver - the RoCE driver for QLogic FastLinQ 4xxxx line of adapters.
Latest RFC can be found at [1].

At Doug's advice [2], we've decided to split the series into two:
 - first part contains the qed backbone that's necessary for all the
configurations relating to the qedr driver, as well as the qede
infrastructure that is used for communication between the qedr and qede.
 - Second part consists of the actual qedr driver and introduces almost
no changes to qed/qede.

This is the first of said two parts. The second half would be sent
later this week.

The only 'oddity' in the devision are the Kconfig options - 
As this series introduces both LL2 and QEDR-based logic in qed/qede,
I wanted to add the CONFIG_INFINIBAND_QEDR option here [with default n].
Otherwise, a lot of the code introduced would be dead-code [won't even
be compiled] until qedr is accepted.
As a result I've placed the config option in an odd place - under
qlogic's Kconfig. The second series would then remove that option
and add it in its correct place under the infiniband Kconfig.
[I'm fine with pushing it there to begin with, but I didn't want to
'contaminate' non-qlogic configuration files with half-baked options].

Dave - I don't think you were E-mailed with Doug's suggestion.
I think the notion was to have the two halves accepted side-by-side,
but actually the first has no dependency issues, so it's also
possible to simply take this first to net-next, and push the qedr
into rdma once it's merged. But it's basically up to you and Doug;
We'd align with whatever suits you best.

Thanks [ & Enjoy Tokyo, everyone],
Yuval

For reference:
 - [1] https://www.spinics.net/lists/linux-rdma/msg41087.html
 - [2] https://www.spinics.net/lists/linux-rdma/msg41194.html

Ram Amrani (6):
  qede: Add qedr framework
  qed: Add support for RoCE hw init
  qed: PD,PKEY and CQ verb support
  qed: Add support for QP verbs
  qed: Add support for memory registeration verbs
  qed: Add RoCE ll2 & GSI support

Yuval Mintz (1):
  qed: Add Light L2 support

 drivers/net/ethernet/qlogic/Kconfig            |   14 +
 drivers/net/ethernet/qlogic/qed/Makefile       |    2 +
 drivers/net/ethernet/qlogic/qed/qed.h          |   43 +-
 drivers/net/ethernet/qlogic/qed/qed_cxt.c      |    8 +
 drivers/net/ethernet/qlogic/qed/qed_cxt.h      |    7 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c      |  274 ++-
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h  |   20 +
 drivers/net/ethernet/qlogic/qed/qed_hsi.h      |    3 +
 drivers/net/ethernet/qlogic/qed/qed_ll2.c      | 1792 ++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_ll2.h      |  316 +++
 drivers/net/ethernet/qlogic/qed/qed_main.c     |   67 +-
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |   30 +-
 drivers/net/ethernet/qlogic/qed/qed_roce.c     | 2954 ++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_roce.h     |  216 ++
 drivers/net/ethernet/qlogic/qed/qed_sp.h       |    5 +
 drivers/net/ethernet/qlogic/qed/qed_spq.c      |    8 +
 drivers/net/ethernet/qlogic/qed/qed_sriov.c    |    4 +-
 drivers/net/ethernet/qlogic/qed/qed_vf.c       |    2 +-
 drivers/net/ethernet/qlogic/qede/Makefile      |    1 +
 drivers/net/ethernet/qlogic/qede/qede.h        |    9 +
 drivers/net/ethernet/qlogic/qede/qede_main.c   |   35 +-
 drivers/net/ethernet/qlogic/qede/qede_roce.c   |  314 +++
 include/linux/qed/common_hsi.h                 |    1 +
 include/linux/qed/qed_if.h                     |    9 +-
 include/linux/qed/qed_ll2_if.h                 |  139 ++
 include/linux/qed/qed_roce_if.h                |  604 +++++
 include/linux/qed/qede_roce.h                  |   88 +
 include/linux/qed/rdma_common.h                |    1 +
 28 files changed, 6944 insertions(+), 22 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_ll2.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_ll2.h
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_roce.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_roce.h
 create mode 100644 drivers/net/ethernet/qlogic/qede/qede_roce.c
 create mode 100644 include/linux/qed/qed_ll2_if.h
 create mode 100644 include/linux/qed/qed_roce_if.h
 create mode 100644 include/linux/qed/qede_roce.h

-- 
1.9.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

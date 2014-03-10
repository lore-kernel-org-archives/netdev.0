From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCHv5 net-next 00/31] Misc. fixes for cxgb4 and iw_cxgb4
Date: Mon, 10 Mar 2014 22:37:57 +0530
Message-ID: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi All,

This patch series provides miscelleneous fixes for Chelsio T4/T5 adapters
related to cxgb4 related to sge and mtu. And includes DB Drop avoidance
and other misc. fixes on iw-cxgb4.

The patches series is created against David Miller's 'net-next' tree.
And includes patches on cxgb4 and iw_cxgb4 driver.

We would like to request this patch series to get merged via David Miller's
'net-next' tree.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks

V5:
   Dropped patch "cxgb4: use spinlock_irqsave/spinlock_irqrestore for db lock".
   save/restore spinlock variants are not required - thanks to review by
   David Miller.
V4:
   Fixed review comments given by Sergei Shtylyov, Joe Perches, Or Gerlitz.
   And, dropped un-used module_params based on comment from Ben Hutchings.
   Also adds a new patch ("cxgb4: Calculate len properly for LSO
   path") which fixes regression.
V3:
   Fixed warnings reported by checkpatch.pl --strict & use networking code
   multi-line comments. Also includes fixes based on review comments given by
   Sergei Shtylyov.
V2:
   Dont drop existing module parameters.
   (cxgb4/iw_cxgb4: Doorbell Drop Avoidance Bug Fixes.)


Hariprasad Shenai (1):
  iw_cxgb4: Use pr_warn_ratelimited

Kumar Sanghvi (5):
  cxgb4: Fix some small bugs in t4_sge_init_soft() when our Page Size is
    64KB
  cxgb4: Add code to dump SGE registers when hitting idma hangs
  cxgb4: Rectify emitting messages about SGE Ingress DMA channels being
    potentially stuck
  cxgb4: Updates for T5 SGE's Egress Congestion Threshold
  cxgb4: Calculate len properly for LSO path

Steve Wise (25):
  iw_cxgb4: cap CQ size at T4_MAX_IQ_SIZE
  iw_cxgb4: Allow loopback connections
  iw_cxgb4: release neigh entry in error paths
  iw_cxgb4: Treat CPL_ERR_KEEPALV_NEG_ADVICE as negative advice
  cxgb4/iw_cxgb4: Doorbell Drop Avoidance Bug Fixes
  iw_cxgb4: use the BAR2/WC path for kernel QPs and T5 devices
  iw_cxgb4: Fix incorrect BUG_ON conditions
  iw_cxgb4: Mind the sq_sig_all/sq_sig_type QP attributes
  iw_cxgb4: default peer2peer mode to 1
  iw_cxgb4: save the correct map length for fast_reg_page_lists
  iw_cxgb4: don't leak skb in c4iw_uld_rx_handler()
  iw_cxgb4: fix possible memory leak in RX_PKT processing
  iw_cxgb4: ignore read reponse type 1 CQEs
  iw_cxgb4: connect_request_upcall fixes
  iw_cxgb4: adjust tcp snd/rcv window based on link speed
  iw_cxgb4: update snd_seq when sending MPA messages
  iw_cxgb4: lock around accept/reject downcalls
  iw_cxgb4: drop RX_DATA packets if the endpoint is gone
  iw_cxgb4: rx_data() needs to hold the ep mutex
  iw_cxgb4: endpoint timeout fixes
  iw_cxgb4: rmb() after reading valid gen bit
  iw_cxgb4: wc_wmb() needed after DB writes
  iw_cxgb4: SQ flush fix
  iw_cxgb4: minor fixes
  iw_cxgb4: Max fastreg depth depends on DSGL support

 drivers/infiniband/hw/cxgb4/cm.c                | 269 +++++++++++++++++-------
 drivers/infiniband/hw/cxgb4/cq.c                |  54 +++--
 drivers/infiniband/hw/cxgb4/device.c            | 239 +++++++++++++--------
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h          |  17 +-
 drivers/infiniband/hw/cxgb4/mem.c               |  18 +-
 drivers/infiniband/hw/cxgb4/provider.c          |  46 +++-
 drivers/infiniband/hw/cxgb4/qp.c                | 216 ++++++++++---------
 drivers/infiniband/hw/cxgb4/resource.c          |  10 +-
 drivers/infiniband/hw/cxgb4/t4.h                |  78 ++++++-
 drivers/infiniband/hw/cxgb4/user.h              |   5 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  11 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  77 ++++---
 drivers/net/ethernet/chelsio/cxgb4/sge.c        | 130 +++++++++---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 106 ++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |   2 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |   9 +
 16 files changed, 909 insertions(+), 378 deletions(-)

-- 
1.8.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

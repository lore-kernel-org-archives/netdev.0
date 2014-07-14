From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCHv2 net-next 0/4] Misc. fixes for iw_cxgb4
Date: Mon, 14 Jul 2014 21:34:50 +0530
Message-ID: <1405353894-17495-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch series adds support to determine ingress padding boundary at runtime.
Advertise a larger max read queue depth for qps, and gather the resource limits
from fw and use them to avoid exhausting all the resources and display TPTE on
errors and add support for work request logging feature.

The patches series is created against 'net-next' tree.
And includes patches on cxgb4 and iw_cxgb4 driver.

Since this patch-series contains changes which are dependent on commit id
fc5ab02 ("cxgb4: Replaced the backdoor mechanism to access the HW memory with
PCIe Window method") we would like to request this patch series to get merged
via David Miller's 'net-next' tree.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments. 

V2:
 Optimized alloc_ird function, and several other changes related to debug prints
 based on review comments given by Yann Droneaud.

Hariprasad Shenai (4):
  iw_cxgb4: Detect Ing. Padding Boundary at run-time
  cxgb4/iw_cxgb4: use firmware ord/ird resource limits
  cxgb4/iw_cxgb4: display TPTE on errors
  cxgb4/iw_cxgb4: work request logging feature

 drivers/infiniband/hw/cxgb4/cm.c                |   80 +++++++---
 drivers/infiniband/hw/cxgb4/cq.c                |    8 +-
 drivers/infiniband/hw/cxgb4/device.c            |  188 ++++++++++++++++++++++-
 drivers/infiniband/hw/cxgb4/ev.c                |   55 ++++++-
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h          |   38 +++++-
 drivers/infiniband/hw/cxgb4/provider.c          |   10 +-
 drivers/infiniband/hw/cxgb4/qp.c                |   76 ++++++++--
 drivers/infiniband/hw/cxgb4/t4.h                |   16 +--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |    3 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  100 ++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |    7 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |    6 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |    2 +
 13 files changed, 528 insertions(+), 61 deletions(-)

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

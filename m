From: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH V3 0/4] Add IPv6 support for iWARP
Date: Thu,  4 Jul 2013 16:10:43 +0530
Message-ID: <1372934447-16556-1-git-send-email-vipul@chelsio.com>
Cc: roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	tatyana.e.nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi All,

This patch series adds IPv6 support for iWARP. It enables Chelsio's T4 and T5
adapters to transmitt RDMA traffic over IPv6 address. It adds new apis and cpl
messages in cxgb4 to support IPv6 operations and uses them in RDMA/cxgb4.

The patch series  modifies the type of local_addr and remote_addr fields in
struct iw_cm_id from struct sockaddr_in to struct sockaddr_storage to hold IPv6
and IPv4 addresses uniformly. It changes the references of local_addr and
remote_addr in RDMA/cxgb4, RDMA/cxgb3, RDMA/nes and amso drivers such that build
failure is avoided.

We would like to submit this patch series via Roland's infiniband tree for-next
branch.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks,
Vipul Pandya

V2: Used local variables instead of typecasting in patch 1/4.
V3: Removed dereferencing ep before initializing it in patch 4/4.

Steve Wise (1):
  RDMA/cma: Add IPv6 support for iWARP.

Vipul Pandya (3):
  cxgb4: Add routines to create and remove listening IPv6 servers
  cxgb4: Add CLIP support to store compressed IPv6 address
  RDMA/cxgb4: Add support for active and passive open connection with
    IPv6 address

 drivers/infiniband/core/cma.c                   |  44 +-
 drivers/infiniband/hw/amso1100/c2_ae.c          |  18 +-
 drivers/infiniband/hw/amso1100/c2_cm.c          |  16 +-
 drivers/infiniband/hw/cxgb3/iwch_cm.c           |  46 +-
 drivers/infiniband/hw/cxgb4/cm.c                | 844 ++++++++++++++++--------
 drivers/infiniband/hw/cxgb4/device.c            | 116 +++-
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h          |   4 +-
 drivers/infiniband/hw/nes/nes_cm.c              | 150 +++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |   1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 288 +++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |   5 +
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |  17 +-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |  23 +
 include/rdma/iw_cm.h                            |   8 +-
 14 files changed, 1136 insertions(+), 444 deletions(-)

-- 
1.8.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

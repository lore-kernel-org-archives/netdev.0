From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next 0/4] Adds support for CIQ and other misc. fixes for rdma/cxgb4
Date: Fri,  6 Jun 2014 21:40:41 +0530
Message-ID: <1402071045-14854-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi All,

This patch series adds support to allocate and use IQs specifically for
indirect interrupts, adds fixes to align ISS for iWARP connections & fixes
related to tcp snd/rvd window for Chelsio T4/T5 adapters on iw_cxgb4.
Also changes Interrupt Holdoff Packet Count threshold of response queues for
cxgb4 driver.

The patches series is created against 'net-next' tree.
And includes patches on cxgb4 and iw_cxgb4 driver.

Since this patch-series contains cxgb4 and iw_cxgb4 patches, we would like to
request this patch series to get merged via David Miller's 'net-next' tree.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks 

Hariprasad Shenai (4):
  iw_cxgb4: Allocate and use IQs specifically for indirect interrupts
  iw_cxgb4: Choose appropriate hw mtu index and ISS for iWARP
    connections
  iw_cxgb4: don't truncate the recv window size
  cxgb4: Change default Interrupt Holdoff Packet Count Threshold

 drivers/infiniband/hw/cxgb4/cm.c                |  127 +++++++++++--
 drivers/infiniband/hw/cxgb4/cq.c                |    7 +-
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h          |    2 +
 drivers/infiniband/hw/cxgb4/provider.c          |    2 +-
 drivers/infiniband/hw/cxgb4/t4.h                |    1 +
 drivers/infiniband/hw/cxgb4/t4fw_ri_api.h       |    1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |   14 ++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  236 +++++++++++++++++++----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |    7 +
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |    5 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h      |    1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |   10 +
 12 files changed, 356 insertions(+), 57 deletions(-)

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

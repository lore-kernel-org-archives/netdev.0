From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCHv2 net-next 0/3]  RDMA/cxgb4,cxgb4vf,cxgb4i,csiostor: Cleanup macros
Date: Tue,  4 Nov 2014 08:20:54 +0530
Message-ID: <1415069457-22277-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	praveenm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

This series moves the debugfs code to a new file debugfs.c and cleans up
macros/register defines.

It's not really the "hardware" which generates these hardware constant symbolic
macros/register defines of course, it's scripts developed by the hardware team.
Various patches have ended up changing the style of the symbolic macros/register
defines and some of them used the macros/register defines that matches the
output of the script from the hardware team.

As a result, the current kernel.org files are a mix of different macro styles.
Since this macro/register defines is used by five different drivers, a
few patch series have ended up adding duplicate macro/register define entries
with different styles. This makes these register define/macro files a complete
mess and we want to make them clean and consistent.

Will post few more series so that we can cover all the macros so that they all
follow the same style to be consistent.

The patches series is created against 'net-next' tree.
And includes patches on cxgb4, cxgb4vf, iw_cxgb4, csiostor and cxgb4i driver.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks

V2: Changes the description and cover-letter content to answer David Miller's
question

Hariprasad Shenai (3):
  cxgb4: Add cxgb4_debugfs.c, move all debugfs code to new file
  cxgb4: Cleanup macros so they follow the same style and look
    consistent
  cxgb4: Cleanup macros so they follow the same style and look
    consistent, part 2

 drivers/infiniband/hw/cxgb4/cm.c                   |   56 +++---
 drivers/infiniband/hw/cxgb4/cq.c                   |    8 +-
 drivers/infiniband/hw/cxgb4/mem.c                  |   14 +-
 drivers/infiniband/hw/cxgb4/qp.c                   |   26 ++--
 drivers/net/ethernet/chelsio/cxgb4/Makefile        |    1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    3 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h     |    6 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  158 ++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h |   52 ++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  173 +++++---------------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |   15 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |   32 ++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  127 +++++++-------
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   72 +++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |  142 ++++++++++++----
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |   32 ++--
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |    2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |  150 +++++++++---------
 drivers/scsi/csiostor/csio_attr.c                  |    8 +-
 drivers/scsi/csiostor/csio_hw.c                    |   14 +-
 drivers/scsi/csiostor/csio_hw_t4.c                 |   15 +-
 drivers/scsi/csiostor/csio_hw_t5.c                 |   21 ++-
 drivers/scsi/csiostor/csio_init.c                  |    6 +-
 drivers/scsi/csiostor/csio_lnode.c                 |   18 +-
 drivers/scsi/csiostor/csio_mb.c                    |  172 ++++++++++----------
 drivers/scsi/csiostor/csio_scsi.c                  |   24 ++--
 drivers/scsi/csiostor/csio_wr.h                    |    2 +-
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c                 |   35 ++--
 28 files changed, 816 insertions(+), 568 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

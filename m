From: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH v2 net-next 17/22] RDMA/cxgb4: Bump tcam_full stat and WR reply timeout
Date: Thu, 14 Mar 2013 20:39:03 +0530
Message-ID: <1363273748-25330-18-git-send-email-vipul@chelsio.com>
References: <1363273748-25330-1-git-send-email-vipul@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	naresh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	arvindb-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, abhishek-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1363273748-25330-1-git-send-email-vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Always bump the tcam_full stat. Also, bump wr reply timeout to 30 seconds.

Signed-off-by: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
v2: Replaced #ifdef with portable interface wmb in ring_tx_db

 drivers/infiniband/hw/cxgb4/cm.c       |    2 +-
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 272bf78..8dcc84f 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -1693,9 +1693,9 @@ static int act_open_rpl(struct c4iw_dev *dev, struct sk_buff *skb)
 	case CPL_ERR_CONN_TIMEDOUT:
 		break;
 	case CPL_ERR_TCAM_FULL:
+		dev->rdev.stats.tcam_full++;
 		if (dev->rdev.lldi.enable_fw_ofld_conn) {
 			mutex_lock(&dev->rdev.stats.lock);
-			dev->rdev.stats.tcam_full++;
 			mutex_unlock(&dev->rdev.stats.lock);
 			send_fw_act_open_req(ep,
 					     GET_TID_TID(GET_AOPEN_ATID(
diff --git a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
index 08e406c..485183a 100644
--- a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
+++ b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
@@ -162,7 +162,7 @@ static inline int c4iw_num_stags(struct c4iw_rdev *rdev)
 	return min((int)T4_MAX_NUM_STAG, (int)(rdev->lldi.vr->stag.size >> 5));
 }
 
-#define C4IW_WR_TO (10*HZ)
+#define C4IW_WR_TO (30*HZ)
 
 struct c4iw_wr_wait {
 	struct completion completion;
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

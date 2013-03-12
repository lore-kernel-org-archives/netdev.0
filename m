From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH net-next 17/22] RDMA/cxgb4: Bump tcam_full stat and WR reply timeout
Date: Tue, 12 Mar 2013 17:16:29 +0530
Message-ID: <1363088794-31453-18-git-send-email-vipul@chelsio.com>
References: <1363088794-31453-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	JBottomley@parallels.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	naresh@chelsio.com, divy@chelsio.com, santosh@chelsio.com,
	arvindb@chelsio.com, abhishek@chelsio.com,
	Vipul Pandya <vipul@chelsio.com>
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:24044 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932928Ab3CLLxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 07:53:45 -0400
In-Reply-To: <1363088794-31453-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Always bump the tcam_full stat. Also, bump wr reply timeout to 30 seconds.

Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
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

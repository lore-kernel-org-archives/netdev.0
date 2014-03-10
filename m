From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv5 net-next 08/31] iw_cxgb4: release neigh entry in error paths
Date: Mon, 10 Mar 2014 22:38:05 +0530
Message-ID: <1394471308-4304-9-git-send-email-hariprasad@chelsio.com>
References: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, nirranjan@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:11602 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754146AbaCJRRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:17:21 -0400
In-Reply-To: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

Always release the neigh entry in rx_pkt().

Based on original work by Santosh Rastapur <santosh@chelsio.com>.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/cm.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 360807e..74a2250 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -3350,10 +3350,9 @@ static int rx_pkt(struct c4iw_dev *dev, struct sk_buff *skb)
 	if (!e) {
 		pr_err("%s - failed to allocate l2t entry!\n",
 		       __func__);
-		goto free_dst;
+		goto free_neigh;
 	}
 
-	neigh_release(neigh);
 	step = dev->rdev.lldi.nrxq / dev->rdev.lldi.nchan;
 	rss_qid = dev->rdev.lldi.rxq_ids[pi->port_id * step];
 	window = (__force u16) htons((__force u16)tcph->window);
@@ -3373,6 +3372,8 @@ static int rx_pkt(struct c4iw_dev *dev, struct sk_buff *skb)
 			      tcph->source, ntohl(tcph->seq), filter, window,
 			      rss_qid, pi->port_id);
 	cxgb4_l2t_release(e);
+free_neigh:
+	neigh_release(neigh);
 free_dst:
 	dst_release(dst);
 reject:
-- 
1.8.4

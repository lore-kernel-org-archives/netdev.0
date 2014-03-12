From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv6 net-next 08/31] iw_cxgb4: release neigh entry
Date: Wed, 12 Mar 2014 21:20:23 +0530
Message-ID: <1394639446-6504-9-git-send-email-hariprasad@chelsio.com>
References: <1394639446-6504-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, nirranjan@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:13238 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755304AbaCLP7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 11:59:18 -0400
In-Reply-To: <1394639446-6504-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

Always release the neigh entry in rx_pkt().

Based on original work by Santosh Rastapur <santosh@chelsio.com>.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/cm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 360807e..2b2af96 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -3347,13 +3347,13 @@ static int rx_pkt(struct c4iw_dev *dev, struct sk_buff *skb)
 		pi = (struct port_info *)netdev_priv(pdev);
 		tx_chan = cxgb4_port_chan(pdev);
 	}
+	neigh_release(neigh);
 	if (!e) {
 		pr_err("%s - failed to allocate l2t entry!\n",
 		       __func__);
 		goto free_dst;
 	}
 
-	neigh_release(neigh);
 	step = dev->rdev.lldi.nrxq / dev->rdev.lldi.nchan;
 	rss_qid = dev->rdev.lldi.rxq_ids[pi->port_id * step];
 	window = (__force u16) htons((__force u16)tcph->window);
-- 
1.8.4

From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv6 net-next 06/31] iw_cxgb4: cap CQ size at T4_MAX_IQ_SIZE
Date: Wed, 12 Mar 2014 21:20:21 +0530
Message-ID: <1394639446-6504-7-git-send-email-hariprasad@chelsio.com>
References: <1394639446-6504-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, nirranjan@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:24568 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752262AbaCLP7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 11:59:11 -0400
In-Reply-To: <1394639446-6504-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/cq.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/cxgb4/cq.c b/drivers/infiniband/hw/cxgb4/cq.c
index 88de3aa..c0673ac 100644
--- a/drivers/infiniband/hw/cxgb4/cq.c
+++ b/drivers/infiniband/hw/cxgb4/cq.c
@@ -881,7 +881,7 @@ struct ib_cq *c4iw_create_cq(struct ib_device *ibdev, int entries,
 	/*
 	 * Make actual HW queue 2x to avoid cdix_inc overflows.
 	 */
-	hwentries = entries * 2;
+	hwentries = min(entries * 2, T4_MAX_IQ_SIZE);
 
 	/*
 	 * Make HW queue at least 64 entries so GTS updates aren't too
-- 
1.8.4

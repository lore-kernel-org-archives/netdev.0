From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 06/31] iw_cxgb4: cap CQ size at T4_MAX_IQ_SIZE.
Date: Mon,  3 Mar 2014 12:10:50 +0530
Message-ID: <1393828875-13452-7-git-send-email-hariprasad@chelsio.com>
References: <1393828875-13452-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, kumaras@chelsio.com,
	dm@chelsio.com, swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, hariprasad@chelsio.com, nirranjan@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:9524 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753606AbaCCGmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 01:42:47 -0500
In-Reply-To: <1393828875-13452-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/cq.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

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
1.7.1

From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv4 net-next 24/32] iw_cxgb4: drop RX_DATA packets if the endpoint is gone
Date: Fri,  7 Mar 2014 16:03:21 +0530
Message-ID: <1394188409-9739-25-git-send-email-hariprasad@chelsio.com>
References: <1394188409-9739-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, santosh@chelsio.com,
	dm@chelsio.com, kumaras@chelsio.com, swise@opengridcomputing.com,
	leedom@chelsio.com, nirranjan@chelsio.com, hariprasad@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:26770 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752048AbaCGKnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 05:43:04 -0500
In-Reply-To: <1394188409-9739-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/cm.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index f4a9ebe..e7c6dfd 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -1544,6 +1544,8 @@ static int rx_data(struct c4iw_dev *dev, struct sk_buff *skb)
 	__u8 status = hdr->status;
 
 	ep = lookup_tid(t, tid);
+	if (!ep)
+		return 0;
 	PDBG("%s ep %p tid %u dlen %u\n", __func__, ep, ep->hwtid, dlen);
 	skb_pull(skb, sizeof(*hdr));
 	skb_trim(skb, dlen);
-- 
1.8.4

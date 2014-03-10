From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv5 net-next 16/31] iw_cxgb4: don't leak skb in c4iw_uld_rx_handler()
Date: Mon, 10 Mar 2014 22:38:13 +0530
Message-ID: <1394471308-4304-17-git-send-email-hariprasad@chelsio.com>
References: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, nirranjan@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:19199 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754189AbaCJRRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:17:51 -0400
In-Reply-To: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/device.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/device.c b/drivers/infiniband/hw/cxgb4/device.c
index 9ba3012..73d6226 100644
--- a/drivers/infiniband/hw/cxgb4/device.c
+++ b/drivers/infiniband/hw/cxgb4/device.c
@@ -924,11 +924,13 @@ static int c4iw_uld_rx_handler(void *handle, const __be64 *rsp,
 	}
 
 	opcode = *(u8 *)rsp;
-	if (c4iw_handlers[opcode])
+	if (c4iw_handlers[opcode]) {
 		c4iw_handlers[opcode](dev, skb);
-	else
+	} else {
 		pr_info("%s no handler opcode 0x%x...\n", __func__,
 		       opcode);
+		kfree_skb(skb);
+	}
 
 	return 0;
 nomem:
-- 
1.8.4

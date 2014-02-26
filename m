From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 16/31] iw_cxgb4: don't leak skb in c4iw_uld_rx_handler().
Date: Wed, 26 Feb 2014 20:36:55 +0530
Message-ID: <1393427230-14532-17-git-send-email-hariprasad@chelsio.com>
References: <1393427230-14532-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, kumaras@chelsio.com,
	dm@chelsio.com, swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, hariprasad@chelsio.com, nirranjan@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:12105 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753258AbaBZPJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 10:09:13 -0500
In-Reply-To: <1393427230-14532-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/device.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/device.c b/drivers/infiniband/hw/cxgb4/device.c
index 38a1b38..b3bf057 100644
--- a/drivers/infiniband/hw/cxgb4/device.c
+++ b/drivers/infiniband/hw/cxgb4/device.c
@@ -926,9 +926,11 @@ static int c4iw_uld_rx_handler(void *handle, const __be64 *rsp,
 	opcode = *(u8 *)rsp;
 	if (c4iw_handlers[opcode])
 		c4iw_handlers[opcode](dev, skb);
-	else
+	else {
 		pr_info("%s no handler opcode 0x%x...\n", __func__,
 		       opcode);
+		kfree_skb(skb);
+	}
 
 	return 0;
 nomem:
-- 
1.7.1

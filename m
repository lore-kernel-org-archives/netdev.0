From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 2/4] net: qualcomm: rmnet: Always assign rmnet dev in deaggregation path
Date: Tue, 24 Oct 2017 22:55:27 -0600
Message-ID: <1508907329-1077-3-git-send-email-subashab@codeaurora.org>
References: <1508907329-1077-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:43296 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751289AbdJYEzt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 00:55:49 -0400
In-Reply-To: <1508907329-1077-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rmnet device needs to assigned for all packets in the
deaggregation path based on the mux id, so the check is not needed.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
index 5dd186d..1ea9783 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
@@ -83,8 +83,7 @@ static void rmnet_set_skb_proto(struct sk_buff *skb)
 	if (!ep)
 		goto free_skb;
 
-	if (port->ingress_data_format & RMNET_INGRESS_FORMAT_DEMUXING)
-		skb->dev = ep->egress_dev;
+	skb->dev = ep->egress_dev;
 
 	/* Subtract MAP header */
 	skb_pull(skb, sizeof(struct rmnet_map_header));
-- 
1.9.1

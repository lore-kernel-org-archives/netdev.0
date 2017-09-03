From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 2/6] net: qualcomm: rmnet: Remove the unused endpoint -1
Date: Sat,  2 Sep 2017 23:30:42 -0600
Message-ID: <1504416646-9527-3-git-send-email-subashab@codeaurora.org>
References: <1504416646-9527-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Dan Williams <dcbw@redhat.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:42644 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751196AbdICFbw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 01:31:52 -0400
In-Reply-To: <1504416646-9527-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was used only in the original patch series where the IOCTLs were
present and is no longer in use.

Fixes: ceed73a2cf4a ("drivers: net: ethernet: qualcomm: rmnet: Initial implementation")
Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Cc: Dan Williams <dcbw@redhat.com>
---
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c | 14 +++-----------
 1 file changed, 3 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
index e836d26..3ca98ec 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
@@ -42,7 +42,6 @@
  */
 
 /* Local Definitions and Declarations */
-#define RMNET_LOCAL_LOGICAL_ENDPOINT -1
 
 struct rmnet_walk_data {
 	struct net_device *real_dev;
@@ -89,10 +88,7 @@ static int rmnet_is_real_dev_registered(const struct net_device *real_dev)
 		if (!r)
 			return NULL;
 
-		if (config_id == RMNET_LOCAL_LOGICAL_ENDPOINT)
-			ep = &r->local_ep;
-		else
-			ep = &r->muxed_ep[config_id];
+		ep = &r->muxed_ep[config_id];
 	}
 
 	return ep;
@@ -182,10 +178,7 @@ static int __rmnet_set_endpoint_config(struct net_device *dev, int config_id,
 		return -EINVAL;
 
 	memcpy(dev_ep, ep, sizeof(struct rmnet_endpoint));
-	if (config_id == RMNET_LOCAL_LOGICAL_ENDPOINT)
-		dev_ep->mux_id = 0;
-	else
-		dev_ep->mux_id = config_id;
+	dev_ep->mux_id = config_id;
 
 	return 0;
 }
@@ -199,8 +192,7 @@ static int rmnet_set_endpoint_config(struct net_device *dev,
 	netdev_dbg(dev, "id %d mode %d dev %s\n",
 		   config_id, rmnet_mode, egress_dev->name);
 
-	if (config_id < RMNET_LOCAL_LOGICAL_ENDPOINT ||
-	    config_id >= RMNET_MAX_LOGICAL_EP)
+	if (config_id >= RMNET_MAX_LOGICAL_EP)
 		return -EINVAL;
 
 	/* This config is cleared on every set, so its ok to not
-- 
1.9.1

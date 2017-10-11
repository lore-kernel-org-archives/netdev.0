From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net 5/7] net: qualcomm: rmnet: Remove duplicate setting of rmnet_devices
Date: Tue, 10 Oct 2017 18:20:27 -0600
Message-ID: <1507681229-27861-6-git-send-email-subashab@codeaurora.org>
References: <1507681229-27861-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:43792 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756669AbdJKAVP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 20:21:15 -0400
In-Reply-To: <1507681229-27861-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rmnet_devices information is already stored in muxed_ep, so
storing this in rmnet_devices[] again is redundant.

Fixes: ceed73a2cf4a ("drivers: net: ethernet: qualcomm: rmnet: Initial implementation")
Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h | 1 -
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c    | 8 ++++----
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
index c5f5c6d..123ccf4 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
@@ -33,7 +33,6 @@ struct rmnet_port {
 	struct rmnet_endpoint muxed_ep[RMNET_MAX_LOGICAL_EP];
 	u32 ingress_data_format;
 	u32 egress_data_format;
-	struct net_device *rmnet_devices[RMNET_MAX_LOGICAL_EP];
 	u8 nr_rmnet_devs;
 	u8 rmnet_mode;
 };
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
index 4ca59a4..8b8497b 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
@@ -105,12 +105,12 @@ int rmnet_vnd_newlink(u8 id, struct net_device *rmnet_dev,
 	struct rmnet_priv *priv;
 	int rc;
 
-	if (port->rmnet_devices[id])
+	if (port->muxed_ep[id].egress_dev)
 		return -EINVAL;
 
 	rc = register_netdevice(rmnet_dev);
 	if (!rc) {
-		port->rmnet_devices[id] = rmnet_dev;
+		port->muxed_ep[id].egress_dev = rmnet_dev;
 		port->nr_rmnet_devs++;
 
 		rmnet_dev->rtnl_link_ops = &rmnet_link_ops;
@@ -127,10 +127,10 @@ int rmnet_vnd_newlink(u8 id, struct net_device *rmnet_dev,
 
 int rmnet_vnd_dellink(u8 id, struct rmnet_port *port)
 {
-	if (id >= RMNET_MAX_LOGICAL_EP || !port->rmnet_devices[id])
+	if (id >= RMNET_MAX_LOGICAL_EP || !port->muxed_ep[id].egress_dev)
 		return -EINVAL;
 
-	port->rmnet_devices[id] = NULL;
+	port->muxed_ep[id].egress_dev = NULL;
 	port->nr_rmnet_devs--;
 	return 0;
 }
-- 
1.9.1

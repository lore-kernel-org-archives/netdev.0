From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 3/6] net: qualcomm: rmnet: Move the device creation log
Date: Sat,  2 Sep 2017 23:30:43 -0600
Message-ID: <1504416646-9527-4-git-send-email-subashab@codeaurora.org>
References: <1504416646-9527-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:42702 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751159AbdICFby (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 01:31:54 -0400
In-Reply-To: <1504416646-9527-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current log is not very useful as it does not log the device
name since it it is prior to registration -

(unnamed net_device) (uninitialized): Setting up device

Modify to log after the device registration -

rmnet1: rmnet dev created

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
index 0e0001b..7c73052 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
@@ -73,8 +73,6 @@ static int rmnet_vnd_change_mtu(struct net_device *rmnet_dev, int new_mtu)
  */
 void rmnet_vnd_setup(struct net_device *rmnet_dev)
 {
-	netdev_dbg(rmnet_dev, "Setting up device %s\n", rmnet_dev->name);
-
 	rmnet_dev->netdev_ops = &rmnet_vnd_ops;
 	rmnet_dev->mtu = RMNET_DFLT_PACKET_SIZE;
 	rmnet_dev->needed_headroom = RMNET_NEEDED_HEADROOM;
@@ -105,6 +103,7 @@ int rmnet_vnd_newlink(u8 id, struct net_device *rmnet_dev,
 		r->rmnet_devices[id] = rmnet_dev;
 		r->nr_rmnet_devs++;
 		rmnet_dev->rtnl_link_ops = &rmnet_link_ops;
+		netdev_dbg(rmnet_dev, "rmnet dev created\n");
 	}
 
 	return rc;
-- 
1.9.1

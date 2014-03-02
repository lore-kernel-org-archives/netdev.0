From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 1/2] b44: add calls to phy_{start,stop}
Date: Sun,  2 Mar 2014 17:29:33 +0100
Message-ID: <1393777774-7400-1-git-send-email-hauke@hauke-m.de>
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:56391 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750890AbaCBQ3n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Mar 2014 11:29:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When support for external phys was added to b44, the calls to start and
stop the phy were missing in the mac driver. This adds the calls to
phy_start() and phy_stop().

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/b44.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 1f7b5aa..e8046e1 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -1484,6 +1484,10 @@ static int b44_open(struct net_device *dev)
 	add_timer(&bp->timer);
 
 	b44_enable_ints(bp);
+
+	if (bp->flags & B44_FLAG_EXTERNAL_PHY)
+		phy_start(bp->phydev);
+
 	netif_start_queue(dev);
 out:
 	return err;
@@ -1646,6 +1650,9 @@ static int b44_close(struct net_device *dev)
 
 	netif_stop_queue(dev);
 
+	if (bp->flags & B44_FLAG_EXTERNAL_PHY)
+		phy_stop(bp->phydev);
+
 	napi_disable(&bp->napi);
 
 	del_timer_sync(&bp->timer);
-- 
1.7.10.4

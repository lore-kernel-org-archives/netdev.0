From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next 9/24] bnx2x: use bnx2x_reload_if_running
Date: Tue, 14 Jun 2011 14:33:30 +0300
Message-ID: <201106141433.31289.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2356 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756043Ab1FNLeQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 07:34:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c     |    2 +-
 drivers/net/bnx2x/bnx2x_cmn.h     |    3 +++
 drivers/net/bnx2x/bnx2x_ethtool.c |    8 +-------
 3 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index dabfec0..c020dfc 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -2808,7 +2808,7 @@ alloc_err:
 
 }
 
-static int bnx2x_reload_if_running(struct net_device *dev)
+int bnx2x_reload_if_running(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index b01f737..09f2d3d 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -377,6 +377,9 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev);
 /* select_queue callback */
 u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb);
 
+/* reload helper */
+int bnx2x_reload_if_running(struct net_device *dev);
+
 int bnx2x_change_mac_addr(struct net_device *dev, void *p);
 
 /* NAPI poll Rx part */
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index 10b17f6..382e03c 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -1216,7 +1216,6 @@ static int bnx2x_set_ringparam(struct net_device *dev,
 			       struct ethtool_ringparam *ering)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	int rc = 0;
 
 	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
 		printk(KERN_ERR "Handling parity error recovery. Try again later\n");
@@ -1233,12 +1232,7 @@ static int bnx2x_set_ringparam(struct net_device *dev,
 	bp->rx_ring_size = ering->rx_pending;
 	bp->tx_ring_size = ering->tx_pending;
 
-	if (netif_running(dev)) {
-		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
-		rc = bnx2x_nic_load(bp, LOAD_NORMAL);
-	}
-
-	return rc;
+	return bnx2x_reload_if_running(dev);
 }
 
 static void bnx2x_get_pauseparam(struct net_device *dev,
-- 
1.7.2.2



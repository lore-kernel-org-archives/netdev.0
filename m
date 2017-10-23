From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4vf: Fix netdev_features flag
Date: Mon, 23 Oct 2017 15:33:30 +0530
Message-ID: <1508753010-10643-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com, venkatesh@chelsio.com,
        Arjun Vynipadath <arjun@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:27724 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751200AbdJWKDr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 06:03:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjun Vynipadath <arjun@chelsio.com>

GRO is not supported by Chelsio HW when rx_csum is disabled.
Update the netdev features flag when rx_csum is modified.

Signed-off-by: Arjun Vynipadath <arjun@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 8996ebb..d6d26bf 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2762,6 +2762,16 @@ static int enable_msix(struct adapter *adapter)
 	return 0;
 }
 
+static netdev_features_t cxgb4vf_fix_features(struct net_device *dev,
+					      netdev_features_t features)
+{
+	/* Disable GRO, if RX_CSUM is disabled */
+	if (!(features & NETIF_F_RXCSUM))
+		features &= ~NETIF_F_GRO;
+
+	return features;
+}
+
 static const struct net_device_ops cxgb4vf_netdev_ops	= {
 	.ndo_open		= cxgb4vf_open,
 	.ndo_stop		= cxgb4vf_stop,
@@ -2777,6 +2787,7 @@ static const struct net_device_ops cxgb4vf_netdev_ops	= {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= cxgb4vf_poll_controller,
 #endif
+	.ndo_fix_features	= cxgb4vf_fix_features,
 };
 
 /*
-- 
2.1.0

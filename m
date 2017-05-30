From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: Fix netdev_features flag
Date: Tue, 30 May 2017 13:30:24 +0530
Message-ID: <1496131224-11688-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com,
        Arjun Vynipadath <arjun@chelsio.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:32577 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750890AbdE3IAd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 04:00:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjun Vynipadath <arjun@chelsio.com>

GRO is not supported by Chelsio HW when rx_csum is disabled.
Update the netdev features flag when rx_csum is modified.

Signed-off-by: Arjun Vynipadath <arjun@chelsio.com>
Signed-off-by: Steve Wise <swise@opengridcomputing.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 06c3414..8c69046 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2727,6 +2727,16 @@ static int cxgb_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 	return -EOPNOTSUPP;
 }
 
+static netdev_features_t cxgb_fix_features(struct net_device *dev,
+					   netdev_features_t features)
+{
+	/* Disable GRO, if RX_CSUM is disabled */
+	if (!(features & NETIF_F_RXCSUM))
+		features &= ~NETIF_F_GRO;
+
+	return features;
+}
+
 static const struct net_device_ops cxgb4_netdev_ops = {
 	.ndo_open             = cxgb_open,
 	.ndo_stop             = cxgb_close,
@@ -2748,6 +2758,7 @@ static const struct net_device_ops cxgb4_netdev_ops = {
 #endif /* CONFIG_CHELSIO_T4_FCOE */
 	.ndo_set_tx_maxrate   = cxgb_set_tx_maxrate,
 	.ndo_setup_tc         = cxgb_setup_tc,
+	.ndo_fix_features     = cxgb_fix_features,
 };
 
 #ifdef CONFIG_PCI_IOV
-- 
2.1.0

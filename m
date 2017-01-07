From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/2] net: remove useless memset's in drivers get_stats64
Date: Fri,  6 Jan 2017 19:12:53 -0800
Message-ID: <20170107031253.2739-2-sthemmin@microsoft.com>
References: <20170107031253.2739-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:36473 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932504AbdAGDNE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 22:13:04 -0500
Received: by mail-pg0-f43.google.com with SMTP id f188so257387737pgc.3
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 19:13:03 -0800 (PST)
In-Reply-To: <20170107031253.2739-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In dev_get_stats() the statistic structure storage has already been
zeroed. Therefore network drivers do not need to call memset() again.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
Found while reviewing earlier patch

 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 1 -
 drivers/net/ethernet/broadcom/bnxt/bnxt.c        | 2 --
 drivers/net/ethernet/intel/e1000e/netdev.c       | 1 -
 3 files changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 45f2204e6695..de59db6c5841 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1462,7 +1462,6 @@ static void xgene_enet_get_stats64(
 	struct xgene_enet_desc_ring *ring;
 	int i;
 
-	memset(stats, 0, sizeof(struct rtnl_link_stats64));
 	for (i = 0; i < pdata->txq_cnt; i++) {
 		ring = pdata->tx_ring[i];
 		if (ring) {
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index e5f458396e1a..7bd2a85694dd 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5885,8 +5885,6 @@ bnxt_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	u32 i;
 	struct bnxt *bp = netdev_priv(dev);
 
-	memset(stats, 0, sizeof(struct rtnl_link_stats64));
-
 	if (!bp->bnapi)
 		return;
 
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index bd09e5f79742..db23c9c85964 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5925,7 +5925,6 @@ void e1000e_get_stats64(struct net_device *netdev,
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	memset(stats, 0, sizeof(struct rtnl_link_stats64));
 	spin_lock(&adapter->stats64_lock);
 	e1000e_update_stats(adapter);
 	/* Fill out the OS statistics structure */
-- 
2.11.0

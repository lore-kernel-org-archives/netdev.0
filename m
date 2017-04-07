From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next 02/14] net: cxgb3: Use net_device_stats from struct net_device
Date: Fri,  7 Apr 2017 10:17:27 +0200
Message-ID: <20170407081739.5243-3-tklauser@distanz.ch>
References: <20170407081739.5243-1-tklauser@distanz.ch>
Cc: Santosh Raspatur <santosh@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:34546 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755312AbdDGIR4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 04:17:56 -0400
In-Reply-To: <20170407081739.5243-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a private copy of struct net_device_stats in
struct port_info, use stats from struct net_device.

Cc: Santosh Raspatur <santosh@chelsio.com>
Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/chelsio/cxgb3/adapter.h    | 1 -
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c | 2 +-
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/adapter.h b/drivers/net/ethernet/chelsio/cxgb3/adapter.h
index 8b395b537330..087ff0ffb597 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/adapter.h
+++ b/drivers/net/ethernet/chelsio/cxgb3/adapter.h
@@ -72,7 +72,6 @@ struct port_info {
 	struct cphy phy;
 	struct cmac mac;
 	struct link_config link_config;
-	struct net_device_stats netstats;
 	int activity;
 	__be32 iscsi_ipv4addr;
 	struct iscsi_config iscsic;
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index d76491676b51..2ff6bd139c96 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -1489,7 +1489,7 @@ static struct net_device_stats *cxgb_get_stats(struct net_device *dev)
 {
 	struct port_info *pi = netdev_priv(dev);
 	struct adapter *adapter = pi->adapter;
-	struct net_device_stats *ns = &pi->netstats;
+	struct net_device_stats *ns = &dev->stats;
 	const struct mac_stats *pstats;
 
 	spin_lock(&adapter->stats_lock);
-- 
2.12.2

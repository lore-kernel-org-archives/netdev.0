From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next 01/14] net: cxgb: Use net_device_stats from struct net_device
Date: Fri,  7 Apr 2017 10:17:26 +0200
Message-ID: <20170407081739.5243-2-tklauser@distanz.ch>
References: <20170407081739.5243-1-tklauser@distanz.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:34510 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755312AbdDGIRq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 04:17:46 -0400
In-Reply-To: <20170407081739.5243-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a private copy of struct net_device_stats in struct
port_info, use stats from struct net_device.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/chelsio/cxgb/common.h | 1 -
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c  | 2 +-
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb/common.h b/drivers/net/ethernet/chelsio/cxgb/common.h
index 6916c62f2487..94b9482f14a5 100644
--- a/drivers/net/ethernet/chelsio/cxgb/common.h
+++ b/drivers/net/ethernet/chelsio/cxgb/common.h
@@ -223,7 +223,6 @@ struct port_info {
 	struct cmac *mac;
 	struct cphy *phy;
 	struct link_config link_config;
-	struct net_device_stats netstats;
 };
 
 struct sge;
diff --git a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
index d8aff7a4b3c7..8623be13bf86 100644
--- a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
+++ b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
@@ -296,7 +296,7 @@ static struct net_device_stats *t1_get_stats(struct net_device *dev)
 {
 	struct adapter *adapter = dev->ml_priv;
 	struct port_info *p = &adapter->port[dev->if_port];
-	struct net_device_stats *ns = &p->netstats;
+	struct net_device_stats *ns = &dev->stats;
 	const struct cmac_statistics *pstats;
 
 	/* Do a full update of the MAC stats */
-- 
2.12.2

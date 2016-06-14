From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/3] cxgb4/cxgb4vf: Synchronize all MAC addresses
Date: Tue, 14 Jun 2016 14:39:32 +0530
Message-ID: <1465895372-21101-4-git-send-email-hariprasad@chelsio.com>
References: <1465895372-21101-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.32.117.8] ([12.32.117.8]:31429 "EHLO
	stargate3.asicdesigners.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751899AbcFNJER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 05:04:17 -0400
In-Reply-To: <1465895372-21101-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even if interface is in Promiscuous mode/Allmulti mode synchronize
MAC addresses.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c     | 7 ++-----
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c | 8 ++------
 2 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 6ce4344ea6fb..c45de49dc963 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -461,11 +461,8 @@ static int set_rxmode(struct net_device *dev, int mtu, bool sleep_ok)
 	struct port_info *pi = netdev_priv(dev);
 	struct adapter *adapter = pi->adapter;
 
-	if (!(dev->flags & IFF_PROMISC)) {
-		__dev_uc_sync(dev, cxgb4_mac_sync, cxgb4_mac_unsync);
-		if (!(dev->flags & IFF_ALLMULTI))
-			__dev_mc_sync(dev, cxgb4_mac_sync, cxgb4_mac_unsync);
-	}
+	__dev_uc_sync(dev, cxgb4_mac_sync, cxgb4_mac_unsync);
+	__dev_mc_sync(dev, cxgb4_mac_sync, cxgb4_mac_unsync);
 
 	return t4_set_rxmode(adapter, adapter->mbox, pi->viid, mtu,
 			     (dev->flags & IFF_PROMISC) ? 1 : 0,
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 04fc6f6d1e25..8d9b2cb74aa2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -937,12 +937,8 @@ static int set_rxmode(struct net_device *dev, int mtu, bool sleep_ok)
 {
 	struct port_info *pi = netdev_priv(dev);
 
-	if (!(dev->flags & IFF_PROMISC)) {
-		__dev_uc_sync(dev, cxgb4vf_mac_sync, cxgb4vf_mac_unsync);
-		if (!(dev->flags & IFF_ALLMULTI))
-			__dev_mc_sync(dev, cxgb4vf_mac_sync,
-				      cxgb4vf_mac_unsync);
-	}
+	__dev_uc_sync(dev, cxgb4vf_mac_sync, cxgb4vf_mac_unsync);
+	__dev_mc_sync(dev, cxgb4vf_mac_sync, cxgb4vf_mac_unsync);
 	return t4vf_set_rxmode(pi->adapter, pi->viid, -1,
 			       (dev->flags & IFF_PROMISC) != 0,
 			       (dev->flags & IFF_ALLMULTI) != 0,
-- 
2.3.4

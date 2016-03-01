From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 5/5] cxgb4vf: Remove dead functions collect_netdev_[um]c_list_addrs
Date: Tue,  1 Mar 2016 17:19:36 +0530
Message-ID: <1456832976-12840-6-git-send-email-hariprasad@chelsio.com>
References: <1456832976-12840-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, nirranjan@chelsio.com, leedom@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:26408 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753337AbcCALq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 06:46:58 -0500
In-Reply-To: <1456832976-12840-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    | 46 ----------------------
 1 file changed, 46 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 5d989e4c42dc..91857b81009e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -862,52 +862,6 @@ static struct net_device_stats *cxgb4vf_get_stats(struct net_device *dev)
 	return ns;
 }
 
-/*
- * Collect up to maxaddrs worth of a netdevice's unicast addresses, starting
- * at a specified offset within the list, into an array of addrss pointers and
- * return the number collected.
- */
-static inline unsigned int collect_netdev_uc_list_addrs(const struct net_device *dev,
-							const u8 **addr,
-							unsigned int offset,
-							unsigned int maxaddrs)
-{
-	unsigned int index = 0;
-	unsigned int naddr = 0;
-	const struct netdev_hw_addr *ha;
-
-	for_each_dev_addr(dev, ha)
-		if (index++ >= offset) {
-			addr[naddr++] = ha->addr;
-			if (naddr >= maxaddrs)
-				break;
-		}
-	return naddr;
-}
-
-/*
- * Collect up to maxaddrs worth of a netdevice's multicast addresses, starting
- * at a specified offset within the list, into an array of addrss pointers and
- * return the number collected.
- */
-static inline unsigned int collect_netdev_mc_list_addrs(const struct net_device *dev,
-							const u8 **addr,
-							unsigned int offset,
-							unsigned int maxaddrs)
-{
-	unsigned int index = 0;
-	unsigned int naddr = 0;
-	const struct netdev_hw_addr *ha;
-
-	netdev_for_each_mc_addr(ha, dev)
-		if (index++ >= offset) {
-			addr[naddr++] = ha->addr;
-			if (naddr >= maxaddrs)
-				break;
-		}
-	return naddr;
-}
-
 static inline int cxgb4vf_set_addr_hash(struct port_info *pi)
 {
 	struct adapter *adapter = pi->adapter;
-- 
2.3.4

From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next] cxgb4: fix for new ndo_get_stats64 signature
Date: Wed,  7 Jul 2010 19:11:25 -0700
Message-ID: <1278555085-17074-1-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:13700 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127Ab0GHCTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 22:19:10 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o682JAha029882
	for <netdev@vger.kernel.org>; Wed, 7 Jul 2010 19:19:11 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The change to ndo_get_stats64 in "net: fix 64 bit counters on 32 bit arches"
missed cxgb4.  Fix it.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 55a720e..2619997 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -2601,12 +2601,12 @@ static int cxgb_close(struct net_device *dev)
 	return t4_enable_vi(adapter, 0, pi->viid, false, false);
 }
 
-static struct rtnl_link_stats64 *cxgb_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *cxgb_get_stats(struct net_device *dev,
+						struct rtnl_link_stats64 *ns)
 {
 	struct port_stats stats;
 	struct port_info *p = netdev_priv(dev);
 	struct adapter *adapter = p->adapter;
-	struct rtnl_link_stats64 *ns = &dev->stats64;
 
 	spin_lock(&adapter->stats_lock);
 	t4_get_port_stats(adapter, p->tx_chan, &stats);
-- 
1.5.4


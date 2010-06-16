From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 5/9] cxgb4: switch to 64 bit inteface statistics
Date: Wed, 16 Jun 2010 15:01:12 -0700
Message-ID: <1276725676-31514-6-git-send-email-dm@chelsio.com>
References: <1276725676-31514-1-git-send-email-dm@chelsio.com>
 <1276725676-31514-2-git-send-email-dm@chelsio.com>
 <1276725676-31514-3-git-send-email-dm@chelsio.com>
 <1276725676-31514-4-git-send-email-dm@chelsio.com>
 <1276725676-31514-5-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6188 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759323Ab0FPWBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 18:01:18 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5GM1IkM032127
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 15:01:18 -0700
In-Reply-To: <1276725676-31514-5-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement ndo_get_stats64, remove ndo_get_stats.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index baf4f0a..6bfe7d6 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -2527,12 +2527,12 @@ static int cxgb_close(struct net_device *dev)
 	return t4_enable_vi(adapter, 0, pi->viid, false, false);
 }
 
-static struct net_device_stats *cxgb_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *cxgb_get_stats(struct net_device *dev)
 {
 	struct port_stats stats;
 	struct port_info *p = netdev_priv(dev);
 	struct adapter *adapter = p->adapter;
-	struct net_device_stats *ns = &dev->stats;
+	struct rtnl_link_stats64 *ns = &dev->stats64;
 
 	spin_lock(&adapter->stats_lock);
 	t4_get_port_stats(adapter, p->tx_chan, &stats);
@@ -2675,7 +2675,7 @@ static const struct net_device_ops cxgb4_netdev_ops = {
 	.ndo_open             = cxgb_open,
 	.ndo_stop             = cxgb_close,
 	.ndo_start_xmit       = t4_eth_xmit,
-	.ndo_get_stats        = cxgb_get_stats,
+	.ndo_get_stats64      = cxgb_get_stats,
 	.ndo_set_rx_mode      = cxgb_set_rxmode,
 	.ndo_set_mac_address  = cxgb_set_mac_addr,
 	.ndo_validate_addr    = eth_validate_addr,
-- 
1.5.4


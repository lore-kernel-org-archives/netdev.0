From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next] cxgb4: drop phys_id interface and implement the newer set_phys_id
Date: Fri,  8 Apr 2011 13:01:34 -0700
Message-ID: <1302292894-18629-1-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:16694 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757833Ab1DHUBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 16:01:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 5352c8a..0af9c9f 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -1336,15 +1336,20 @@ static int restart_autoneg(struct net_device *dev)
 	return 0;
 }
 
-static int identify_port(struct net_device *dev, u32 data)
+static int identify_port(struct net_device *dev,
+			 enum ethtool_phys_id_state state)
 {
+	unsigned int val;
 	struct adapter *adap = netdev2adap(dev);
 
-	if (data == 0)
-		data = 2;     /* default to 2 seconds */
+	if (state == ETHTOOL_ID_ACTIVE)
+		val = 0xffff;
+	else if (state == ETHTOOL_ID_INACTIVE)
+		val = 0;
+	else
+		return -EINVAL;
 
-	return t4_identify_port(adap, adap->fn, netdev2pinfo(dev)->viid,
-				data * 5);
+	return t4_identify_port(adap, adap->fn, netdev2pinfo(dev)->viid, val);
 }
 
 static unsigned int from_fw_linkcaps(unsigned int type, unsigned int caps)
@@ -2011,7 +2016,7 @@ static struct ethtool_ops cxgb_ethtool_ops = {
 	.set_sg            = ethtool_op_set_sg,
 	.get_link          = ethtool_op_get_link,
 	.get_strings       = get_strings,
-	.phys_id           = identify_port,
+	.set_phys_id       = identify_port,
 	.nway_reset        = restart_autoneg,
 	.get_sset_count    = get_sset_count,
 	.get_ethtool_stats = get_stats,
-- 
1.7.3.4


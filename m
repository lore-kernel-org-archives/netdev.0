From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next] cxgb4vf: drop phys_id interface and implement the newer set_phys_id
Date: Fri,  8 Apr 2011 13:05:00 -0700
Message-ID: <1302293100-18724-1-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23184 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757800Ab1DHUFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 16:05:02 -0400
Received: from tom.asicdesigners.com (tom.asicdesigners.com [10.192.167.168])
	by stargate.chelsio.com (8.13.1/8.13.1) with ESMTP id p38K51QB016017
	for <netdev@vger.kernel.org>; Fri, 8 Apr 2011 13:05:01 -0700
Received: from tom.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by tom.asicdesigners.com (8.14.4/8.14.3) with ESMTP id p38K509T018754
	for <netdev@vger.kernel.org>; Fri, 8 Apr 2011 13:05:02 -0700
Received: (from dm@localhost)
	by tom.asicdesigners.com (8.14.4/8.14.4/Submit) id p38K50GJ018752
	for netdev@vger.kernel.org; Fri, 8 Apr 2011 13:05:00 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4vf/cxgb4vf_main.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index 6aad64d..b0d037e 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -1352,11 +1352,20 @@ static int cxgb4vf_set_rx_csum(struct net_device *dev, u32 csum)
 /*
  * Identify the port by blinking the port's LED.
  */
-static int cxgb4vf_phys_id(struct net_device *dev, u32 id)
+static int cxgb4vf_phys_id(struct net_device *dev,
+			   enum ethtool_phys_id_state state)
 {
+	unsigned int val;
 	struct port_info *pi = netdev_priv(dev);
 
-	return t4vf_identify_port(pi->adapter, pi->viid, 5);
+	if (state == ETHTOOL_ID_ACTIVE)
+		val = 0xffff;
+	else if (state == ETHTOOL_ID_INACTIVE)
+		val = 0;
+	else
+		return -EINVAL;
+
+	return t4vf_identify_port(pi->adapter, pi->viid, val);
 }
 
 /*
@@ -1588,7 +1597,7 @@ static struct ethtool_ops cxgb4vf_ethtool_ops = {
 	.set_sg			= ethtool_op_set_sg,
 	.get_link		= ethtool_op_get_link,
 	.get_strings		= cxgb4vf_get_strings,
-	.phys_id		= cxgb4vf_phys_id,
+	.set_phys_id		= cxgb4vf_phys_id,
 	.get_sset_count		= cxgb4vf_get_sset_count,
 	.get_ethtool_stats	= cxgb4vf_get_ethtool_stats,
 	.get_regs_len		= cxgb4vf_get_regs_len,
-- 
1.7.3.4


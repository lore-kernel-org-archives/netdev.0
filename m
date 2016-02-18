From: Kan Liang <kan.liang@intel.com>
Subject: [PATCH V6 7/8] i40e/ethtool: support coalesce getting by queue
Date: Thu, 18 Feb 2016 07:39:55 -0500
Message-ID: <1455799196-8947-8-git-send-email-kan.liang@intel.com>
References: <1455799196-8947-1-git-send-email-kan.liang@intel.com>
Cc: andi@firstfloor.org, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, f.fainelli@gmail.com,
	alexander.duyck@gmail.com, jeffrey.t.kirsher@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net, decot@googlers.com, Kan Liang <kan.liang@intel.com>
To: netdev@vger.kernel.org, davem@davemloft.net, bwh@kernel.org,
	ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56241 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1947323AbcBRUAR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 15:00:17 -0500
In-Reply-To: <1455799196-8947-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

This patch implements get_per_queue_coalesce for i40e driver.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 5fe566e..899fa87 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1901,6 +1901,12 @@ static int i40e_get_coalesce(struct net_device *netdev,
 	return __i40e_get_coalesce(netdev, ec, -1);
 }
 
+static int i40e_get_per_queue_coalesce(struct net_device *netdev, u32 queue,
+				       struct ethtool_coalesce *ec)
+{
+	return __i40e_get_coalesce(netdev, ec, queue);
+}
+
 static void i40e_set_itr_per_queue(struct i40e_vsi *vsi,
 				   struct ethtool_coalesce *ec,
 				   int queue)
@@ -2890,6 +2896,7 @@ static const struct ethtool_ops i40e_ethtool_ops = {
 	.get_ts_info		= i40e_get_ts_info,
 	.get_priv_flags		= i40e_get_priv_flags,
 	.set_priv_flags		= i40e_set_priv_flags,
+	.get_per_queue_coalesce	= i40e_get_per_queue_coalesce,
 };
 
 void i40e_set_ethtool_ops(struct net_device *netdev)
-- 
1.8.3.1

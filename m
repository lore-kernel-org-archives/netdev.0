From: kan.liang@intel.com
Subject: [PATCH V3 5/6] i40e/ethtool: support coalesce getting by queue
Date: Thu, 14 Jan 2016 09:08:06 -0500
Message-ID: <1452780487-10581-5-git-send-email-kan.liang@intel.com>
References: <1452780487-10581-1-git-send-email-kan.liang@intel.com>
Cc: jesse.brandeburg@intel.com, andi@firstfloor.org,
	f.fainelli@gmail.com, alexander.duyck@gmail.com,
	jeffrey.t.kirsher@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net, ben@decadent.org.uk,
	Kan Liang <kan.liang@intel.com>
To: netdev@vger.kernel.org, davem@davemloft.net, bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:31404 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756577AbcANV1D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jan 2016 16:27:03 -0500
In-Reply-To: <1452780487-10581-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

This patch implements get_per_queue_coalesce for i40e driver.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---

Changes since V1:
 - Correct the way to find the vector for specific queue.

Changes since V2:
 - Move the code per queue coalesce getting to patch 4.

 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 26ad7bd..2fe878d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1894,6 +1894,12 @@ static int i40e_get_coalesce(struct net_device *netdev,
 	return __i40e_get_coalesce(netdev, ec, -1);
 }
 
+static int i40e_get_per_queue_coalesce(struct net_device *netdev, int queue,
+				       struct ethtool_coalesce *ec)
+{
+	return __i40e_get_coalesce(netdev, ec, queue);
+}
+
 static void i40e_set_itr_per_queue(struct i40e_vsi *vsi,
 				   struct ethtool_coalesce *ec,
 				   int queue)
@@ -2858,6 +2864,7 @@ static const struct ethtool_ops i40e_ethtool_ops = {
 	.get_ts_info		= i40e_get_ts_info,
 	.get_priv_flags		= i40e_get_priv_flags,
 	.set_priv_flags		= i40e_set_priv_flags,
+	.get_per_queue_coalesce	= i40e_get_per_queue_coalesce,
 };
 
 void i40e_set_ethtool_ops(struct net_device *netdev)
-- 
1.8.3.1

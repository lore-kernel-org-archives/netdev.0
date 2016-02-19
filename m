From: Kan Liang <kan.liang@intel.com>
Subject: [PATCH V7 8/8] i40e/ethtool: support coalesce setting by queue
Date: Fri, 19 Feb 2016 09:24:06 -0500
Message-ID: <1455891846-12271-9-git-send-email-kan.liang@intel.com>
References: <1455891846-12271-1-git-send-email-kan.liang@intel.com>
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
Received: from mga03.intel.com ([134.134.136.65]:48161 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757327AbcBSVoW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 16:44:22 -0500
In-Reply-To: <1455891846-12271-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

This patch implements set_per_queue_coalesce for i40e driver.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index dd572ab..784b165 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2035,6 +2035,12 @@ static int i40e_set_coalesce(struct net_device *netdev,
 	return __i40e_set_coalesce(netdev, ec, -1);
 }
 
+static int i40e_set_per_queue_coalesce(struct net_device *netdev, u32 queue,
+				       struct ethtool_coalesce *ec)
+{
+	return __i40e_set_coalesce(netdev, ec, queue);
+}
+
 /**
  * i40e_get_rss_hash_opts - Get RSS hash Input Set for each flow type
  * @pf: pointer to the physical function struct
@@ -2921,6 +2927,7 @@ static const struct ethtool_ops i40e_ethtool_ops = {
 	.get_priv_flags		= i40e_get_priv_flags,
 	.set_priv_flags		= i40e_set_priv_flags,
 	.get_per_queue_coalesce	= i40e_get_per_queue_coalesce,
+	.set_per_queue_coalesce	= i40e_set_per_queue_coalesce,
 };
 
 void i40e_set_ethtool_ops(struct net_device *netdev)
-- 
1.8.3.1

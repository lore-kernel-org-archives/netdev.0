From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] i40e: remove hardcode of stats struct size in ethtool
Date: Wed, 21 May 2014 05:01:08 -0700
Message-ID: <1400673673-31626-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:21049 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752379AbaEUMBa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 08:01:30 -0400
In-Reply-To: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Base the queue stats length on the queue stats struct rather than
assuming it is 2 fields.  This is in prep for adding data fields
which are configuration dependent.

Change-ID: I937f471f389d2e0f8cec733960c5d9a06b14f3ec
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index a89b3c6..7f3d342 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -122,8 +122,9 @@ static struct i40e_stats i40e_gstrings_stats[] = {
 };
 
 #define I40E_QUEUE_STATS_LEN(n) \
-  ((((struct i40e_netdev_priv *)netdev_priv((n)))->vsi->num_queue_pairs + \
-    ((struct i40e_netdev_priv *)netdev_priv((n)))->vsi->num_queue_pairs) * 2)
+	(((struct i40e_netdev_priv *)netdev_priv((n)))->vsi->num_queue_pairs \
+	    * 2 /* Tx and Rx together */                                     \
+	    * (sizeof(struct i40e_queue_stats) / sizeof(u64)))
 #define I40E_GLOBAL_STATS_LEN	ARRAY_SIZE(i40e_gstrings_stats)
 #define I40E_NETDEV_STATS_LEN   ARRAY_SIZE(i40e_gstrings_net_stats)
 #define I40E_VSI_STATS_LEN(n)   (I40E_NETDEV_STATS_LEN + \
-- 
1.9.0

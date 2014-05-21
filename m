From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40evf: Use macro param for ethtool stats
Date: Wed, 21 May 2014 05:01:03 -0700
Message-ID: <1400673673-31626-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Ben Hutchings <ben@decadent.org.uk>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20362 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752331AbaEUMB1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 08:01:27 -0400
In-Reply-To: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Use a macro parameter for ethtool stats instead of just assuming
that a valid netdev variable exists. Suggested by Ben Hutchings.

CC: Ben Hutchings <ben@decadent.org.uk>
Change-ID: I66681698573c1549f95fdea310149d8a7e96a60f
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index 2638dfa..3566e73 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -59,10 +59,12 @@ static const struct i40evf_stats i40evf_gstrings_stats[] = {
 };
 
 #define I40EVF_GLOBAL_STATS_LEN ARRAY_SIZE(i40evf_gstrings_stats)
-#define I40EVF_QUEUE_STATS_LEN \
+#define I40EVF_QUEUE_STATS_LEN(_dev) \
 	(((struct i40evf_adapter *) \
-		netdev_priv(netdev))->vsi_res->num_queue_pairs * 4)
-#define I40EVF_STATS_LEN (I40EVF_GLOBAL_STATS_LEN + I40EVF_QUEUE_STATS_LEN)
+		netdev_priv(_dev))->vsi_res->num_queue_pairs \
+		  * 2 * (sizeof(struct i40e_queue_stats) / sizeof(u64)))
+#define I40EVF_STATS_LEN(_dev) \
+	(I40EVF_GLOBAL_STATS_LEN + I40EVF_QUEUE_STATS_LEN(_dev))
 
 /**
  * i40evf_get_settings - Get Link Speed and Duplex settings
@@ -97,9 +99,9 @@ static int i40evf_get_settings(struct net_device *netdev,
 static int i40evf_get_sset_count(struct net_device *netdev, int sset)
 {
 	if (sset == ETH_SS_STATS)
-		return I40EVF_STATS_LEN;
+		return I40EVF_STATS_LEN(netdev);
 	else
-		return -ENOTSUPP;
+		return -EINVAL;
 }
 
 /**
-- 
1.9.0

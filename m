From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/2] i40e: fix stats offsets
Date: Thu, 22 Oct 2015 18:15:52 -0700
Message-ID: <1445562953-47496-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445562953-47496-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15283 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965481AbbJWBP4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2015 21:15:56 -0400
In-Reply-To: <1445562953-47496-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The code was setting up stats that were not being initialized.
This caused several counters to be displayed incorrectly, due
to indexing beyond the array of strings when printing stats.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index e972b5e..13a5d4c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1344,6 +1344,12 @@ static void i40e_get_ethtool_stats(struct net_device *netdev,
 			data[i++] = (i40e_gstrings_veb_stats[j].sizeof_stat ==
 				     sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 		}
+		for (j = 0; j < I40E_MAX_TRAFFIC_CLASS; j++) {
+			data[i++] = veb->tc_stats.tc_tx_packets[j];
+			data[i++] = veb->tc_stats.tc_tx_bytes[j];
+			data[i++] = veb->tc_stats.tc_rx_packets[j];
+			data[i++] = veb->tc_stats.tc_rx_bytes[j];
+		}
 	}
 	for (j = 0; j < I40E_GLOBAL_STATS_LEN; j++) {
 		p = (char *)pf + i40e_gstrings_stats[j].stat_offset;
-- 
2.4.3

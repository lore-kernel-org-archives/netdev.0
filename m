From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/13] i40e: add xcast stats for port
Date: Fri,  6 Jun 2014 02:04:18 -0700
Message-ID: <1402045462-10304-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5101 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752659AbaFFJFb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jun 2014 05:05:31 -0400
In-Reply-To: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add the missing unicast, multicast, and broadcast stats for the port.

Change-ID: Ifc366d7b7745f70eaac9d00eeb0694eb9ec076a9
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |  6 ++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 26 ++++++++++++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index d910b88..df3917b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -104,6 +104,12 @@ static int i40e_add_fdir_ethtool(struct i40e_vsi *vsi,
 static struct i40e_stats i40e_gstrings_stats[] = {
 	I40E_PF_STAT("rx_bytes", stats.eth.rx_bytes),
 	I40E_PF_STAT("tx_bytes", stats.eth.tx_bytes),
+	I40E_PF_STAT("rx_unicast", stats.eth.rx_unicast),
+	I40E_PF_STAT("tx_unicast", stats.eth.tx_unicast),
+	I40E_PF_STAT("rx_multicast", stats.eth.rx_multicast),
+	I40E_PF_STAT("tx_multicast", stats.eth.tx_multicast),
+	I40E_PF_STAT("rx_broadcast", stats.eth.rx_broadcast),
+	I40E_PF_STAT("tx_broadcast", stats.eth.tx_broadcast),
 	I40E_PF_STAT("tx_errors", stats.eth.tx_errors),
 	I40E_PF_STAT("rx_dropped", stats.eth.rx_discards),
 	I40E_PF_STAT("tx_dropped", stats.eth.tx_discards),
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 726eceb..e9cd9bb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -854,11 +854,37 @@ static void i40e_update_pf_stats(struct i40e_pf *pf)
 			   pf->stat_offsets_loaded,
 			   &osd->eth.tx_discards,
 			   &nsd->eth.tx_discards);
+
+	i40e_stat_update48(hw, I40E_GLPRT_UPRCH(hw->port),
+			   I40E_GLPRT_UPRCL(hw->port),
+			   pf->stat_offsets_loaded,
+			   &osd->eth.rx_unicast,
+			   &nsd->eth.rx_unicast);
 	i40e_stat_update48(hw, I40E_GLPRT_MPRCH(hw->port),
 			   I40E_GLPRT_MPRCL(hw->port),
 			   pf->stat_offsets_loaded,
 			   &osd->eth.rx_multicast,
 			   &nsd->eth.rx_multicast);
+	i40e_stat_update48(hw, I40E_GLPRT_BPRCH(hw->port),
+			   I40E_GLPRT_BPRCL(hw->port),
+			   pf->stat_offsets_loaded,
+			   &osd->eth.rx_broadcast,
+			   &nsd->eth.rx_broadcast);
+	i40e_stat_update48(hw, I40E_GLPRT_UPTCH(hw->port),
+			   I40E_GLPRT_UPTCL(hw->port),
+			   pf->stat_offsets_loaded,
+			   &osd->eth.tx_unicast,
+			   &nsd->eth.tx_unicast);
+	i40e_stat_update48(hw, I40E_GLPRT_MPTCH(hw->port),
+			   I40E_GLPRT_MPTCL(hw->port),
+			   pf->stat_offsets_loaded,
+			   &osd->eth.tx_multicast,
+			   &nsd->eth.tx_multicast);
+	i40e_stat_update48(hw, I40E_GLPRT_BPTCH(hw->port),
+			   I40E_GLPRT_BPTCL(hw->port),
+			   pf->stat_offsets_loaded,
+			   &osd->eth.tx_broadcast,
+			   &nsd->eth.tx_broadcast);
 
 	i40e_stat_update32(hw, I40E_GLPRT_TDOLD(hw->port),
 			   pf->stat_offsets_loaded,
-- 
1.9.3

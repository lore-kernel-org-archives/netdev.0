From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e: print port stats only on partition 1
Date: Sat,  7 Mar 2015 07:03:16 -0800
Message-ID: <1425740603-11280-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425740603-11280-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:38815 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750698AbbCGPD3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Mar 2015 10:03:29 -0500
In-Reply-To: <1425740603-11280-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Only print the port and veb stats if this is the first partition
of a multiplexed port.

Change-ID: I7ce0c323cdee5cfd2e54d8bea5b0b9102987e671
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index e045de1..01c811c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1224,7 +1224,7 @@ static int i40e_get_sset_count(struct net_device *netdev, int sset)
 	case ETH_SS_TEST:
 		return I40E_TEST_LEN;
 	case ETH_SS_STATS:
-		if (vsi == pf->vsi[pf->lan_vsi]) {
+		if (vsi == pf->vsi[pf->lan_vsi] && pf->hw.partition_id == 1) {
 			int len = I40E_PF_STATS_LEN(netdev);
 
 			if (pf->lan_veb != I40E_NO_VEB)
@@ -1297,7 +1297,7 @@ static void i40e_get_ethtool_stats(struct net_device *netdev,
 		i += 2;
 	}
 	rcu_read_unlock();
-	if (vsi != pf->vsi[pf->lan_vsi])
+	if (vsi != pf->vsi[pf->lan_vsi] || pf->hw.partition_id != 1)
 		return;
 
 	if (pf->lan_veb != I40E_NO_VEB) {
@@ -1370,7 +1370,7 @@ static void i40e_get_strings(struct net_device *netdev, u32 stringset,
 			snprintf(p, ETH_GSTRING_LEN, "rx-%u.rx_bytes", i);
 			p += ETH_GSTRING_LEN;
 		}
-		if (vsi != pf->vsi[pf->lan_vsi])
+		if (vsi != pf->vsi[pf->lan_vsi] || pf->hw.partition_id != 1)
 			return;
 
 		if (pf->lan_veb != I40E_NO_VEB) {
-- 
1.9.3

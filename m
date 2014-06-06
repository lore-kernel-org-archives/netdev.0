From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/13] i40e: add vsi x-cast stats
Date: Fri,  6 Jun 2014 02:04:17 -0700
Message-ID: <1402045462-10304-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5078 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752661AbaFFJFc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jun 2014 05:05:32 -0400
In-Reply-To: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add VSI HW stats for unicast, multicast, and broadcast for Rx and Tx.
Stop printing the netdev multicast value because it doesn't include Tx
and would be confusing.

Change-ID: I08278b6657e7c838fd29a4a1f305f78fe1b150be
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 7f03b23..d910b88 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -58,7 +58,6 @@ static const struct i40e_stats i40e_gstrings_net_stats[] = {
 	I40E_NETDEV_STAT(tx_errors),
 	I40E_NETDEV_STAT(rx_dropped),
 	I40E_NETDEV_STAT(tx_dropped),
-	I40E_NETDEV_STAT(multicast),
 	I40E_NETDEV_STAT(collisions),
 	I40E_NETDEV_STAT(rx_length_errors),
 	I40E_NETDEV_STAT(rx_crc_errors),
@@ -80,9 +79,13 @@ static const struct i40e_stats i40e_gstrings_veb_stats[] = {
 };
 
 static const struct i40e_stats i40e_gstrings_misc_stats[] = {
-	I40E_VSI_STAT("rx_unknown_protocol", eth_stats.rx_unknown_protocol),
+	I40E_VSI_STAT("rx_unicast", eth_stats.rx_unicast),
+	I40E_VSI_STAT("tx_unicast", eth_stats.tx_unicast),
+	I40E_VSI_STAT("rx_multicast", eth_stats.rx_multicast),
+	I40E_VSI_STAT("tx_multicast", eth_stats.tx_multicast),
 	I40E_VSI_STAT("rx_broadcast", eth_stats.rx_broadcast),
 	I40E_VSI_STAT("tx_broadcast", eth_stats.tx_broadcast),
+	I40E_VSI_STAT("rx_unknown_protocol", eth_stats.rx_unknown_protocol),
 };
 
 static int i40e_add_fdir_ethtool(struct i40e_vsi *vsi,
-- 
1.9.3

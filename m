From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] net/fm10k: Avoid double setting of NETIF_F_SG for the HW encapsulation feature mask
Date: Thu, 22 Jan 2015 18:37:06 -0800
Message-ID: <1421980631-1955-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421980631-1955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:16347 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754010AbbAWChU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 21:37:20 -0500
In-Reply-To: <1421980631-1955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

The networking core does it for the driver during registration time.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 945b35d..cfde8ba 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1414,13 +1414,12 @@ struct net_device *fm10k_alloc_netdev(void)
 	dev->vlan_features |= dev->features;
 
 	/* configure tunnel offloads */
-	dev->hw_enc_features = NETIF_F_IP_CSUM |
-			       NETIF_F_TSO |
-			       NETIF_F_TSO6 |
-			       NETIF_F_TSO_ECN |
-			       NETIF_F_GSO_UDP_TUNNEL |
-			       NETIF_F_IPV6_CSUM |
-			       NETIF_F_SG;
+	dev->hw_enc_features |= NETIF_F_IP_CSUM |
+				NETIF_F_TSO |
+				NETIF_F_TSO6 |
+				NETIF_F_TSO_ECN |
+				NETIF_F_GSO_UDP_TUNNEL |
+				NETIF_F_IPV6_CSUM;
 
 	/* we want to leave these both on as we cannot disable VLAN tag
 	 * insertion or stripping on the hardware since it is contained
-- 
1.9.3

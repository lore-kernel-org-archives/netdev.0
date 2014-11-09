From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next] net/fm10k: Avoid double setting of NETIF_F_SG for the HW encapsulation feature mask
Date: Sun,  9 Nov 2014 10:13:42 +0200
Message-ID: <1415520822-11922-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:49649 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750769AbaKIIN5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Nov 2014 03:13:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The networking core does it for the driver during registration time.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---

changes from v0:
 - set alignment to be per the request of Matthew Vick


 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 8811364..14882dc 100644
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
+			        NETIF_F_TSO |
+			        NETIF_F_TSO6 |
+			        NETIF_F_TSO_ECN |
+			        NETIF_F_GSO_UDP_TUNNEL |
+			        NETIF_F_IPV6_CSUM;
 
 	/* we want to leave these both on as we cannot disable VLAN tag
 	 * insertion or stripping on the hardware since it is contained
-- 
1.7.1

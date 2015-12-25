From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/9] ixgbe: Clean up redundancy in hw_enc_features
Date: Thu, 24 Dec 2015 21:29:52 -0800
Message-ID: <1451021396-68858-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1451021396-68858-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55539 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753335AbbLYF37 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Dec 2015 00:29:59 -0500
In-Reply-To: <1451021396-68858-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Clean up minor redundancy in the setting of hw_enc_features that
makes it appears that X550 uniquely has more encapsulation features
than other devices. The driver only supports one more feature, so
make it look that way. No longer set NETIF_F_SG since that is set
by the register_netdev call. Thanks to Alex Duyck for noticing this
slight confusion.

Reported-by: Alexander Duyck <aduyck@mirantis.com>
Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index c5c0fb4..ea9537d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9015,8 +9015,7 @@ skip_sriov:
 	netdev->vlan_features |= NETIF_F_IPV6_CSUM;
 	netdev->vlan_features |= NETIF_F_SG;
 
-	netdev->hw_enc_features |= NETIF_F_SG | NETIF_F_IP_CSUM |
-				   NETIF_F_IPV6_CSUM;
+	netdev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
 
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 	netdev->priv_flags |= IFF_SUPP_NOFCS;
@@ -9025,9 +9024,7 @@ skip_sriov:
 	switch (adapter->hw.mac.type) {
 	case ixgbe_mac_X550:
 	case ixgbe_mac_X550EM_x:
-		netdev->hw_enc_features |= NETIF_F_RXCSUM |
-					   NETIF_F_IP_CSUM |
-					   NETIF_F_IPV6_CSUM;
+		netdev->hw_enc_features |= NETIF_F_RXCSUM;
 		break;
 	default:
 		break;
-- 
2.5.0

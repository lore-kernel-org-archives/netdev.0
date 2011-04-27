From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 09/12] ixgbe: enable SCTP checksum offload for X540
Date: Wed, 27 Apr 2011 02:34:48 -0700
Message-ID: <1303896891-16006-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1303896891-16006-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:38651 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756032Ab1D0JfA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2011 05:35:00 -0400
In-Reply-To: <1303896891-16006-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

X540 supports SCTP checksum offload so enable it.  It was overlooked when X540
support was initially added to the driver.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 227a9b4..a7da5d9 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -7361,8 +7361,14 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	netdev->features |= NETIF_F_TSO6;
 	netdev->features |= NETIF_F_GRO;
 
-	if (adapter->hw.mac.type == ixgbe_mac_82599EB)
+	switch (adapter->hw.mac.type) {
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
 		netdev->features |= NETIF_F_SCTP_CSUM;
+		break;
+	default:
+		break;
+	}
 
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;
-- 
1.7.4.4


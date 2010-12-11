From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 13/27] ixgbe: fix ntuple support
Date: Fri, 10 Dec 2010 22:19:00 -0800
Message-ID: <1292048354-22076-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1292048354-22076-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jesse Gross <jesse@nicira.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.emeryville.ca.mail.comcast.net ([76.96.27.227]:35437
	"EHLO qmta12.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751506Ab0LKGTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 01:19:22 -0500
To: davem@davemloft.net
In-Reply-To: <1292048354-22076-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

commit f62bbb5e62c6e4a91fb222d22bc46e8d4d7e59ef
ixgbe: Update ixgbe to use new vlan accleration.

removed ETH_FLAG_NTUPLE from the supported flags.

This patch puts it back on to allow for setting ntuple via ethtool.

CC: Jesse Gross <jesse@nicira.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 90a740d..f2245ac 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2202,7 +2202,7 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 	need_reset = (data & ETH_FLAG_RXVLAN) !=
 		     (netdev->features & NETIF_F_HW_VLAN_RX);
 
-	rc = ethtool_op_set_flags(netdev, data, ETH_FLAG_LRO |
+	rc = ethtool_op_set_flags(netdev, data, ETH_FLAG_LRO | ETH_FLAG_NTUPLE |
 					ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN);
 	if (rc)
 		return rc;
-- 
1.7.3.2


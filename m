From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/10] ixgbe: add check for supported modes
Date: Mon, 29 Aug 2011 01:41:07 -0700
Message-ID: <1314607268-26958-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1314607268-26958-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:35742 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753330Ab1H2IlT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Aug 2011 04:41:19 -0400
In-Reply-To: <1314607268-26958-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

When setting advertised speed/duplex with ethtool.

Also cleaned up the comment since we also support 100/F.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 82d4244..9c12b35 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -324,12 +324,16 @@ static int ixgbe_set_settings(struct net_device *netdev,
 
 	if ((hw->phy.media_type == ixgbe_media_type_copper) ||
 	    (hw->phy.multispeed_fiber)) {
-		/* 10000/copper and 1000/copper must autoneg
-		 * this function does not support any duplex forcing, but can
-		 * limit the advertising of the adapter to only 10000 or 1000 */
+		/*
+		 * this function does not support duplex forcing, but can
+		 * limit the advertising of the adapter to the specified speed
+		 */
 		if (ecmd->autoneg == AUTONEG_DISABLE)
 			return -EINVAL;
 
+		if (ecmd->advertising & ~ecmd->supported)
+			return -EINVAL;
+
 		old = hw->phy.autoneg_advertised;
 		advertised = 0;
 		if (ecmd->advertising & ADVERTISED_10000baseT_Full)
-- 
1.7.6

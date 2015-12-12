From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/12] ixgbe: do not report 2.5 Gbps as supported
Date: Sat, 12 Dec 2015 03:14:50 -0800
Message-ID: <1449918890-145243-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449918890-145243-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:14272 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752326AbbLLLPE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Dec 2015 06:15:04 -0500
In-Reply-To: <1449918890-145243-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Some X550 devices can connect at 2.5Gbps during fail-over, but only
with certain link partners. Also setting the advertised speed will
not work so we do not report it as supported to avoid confusion.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index d681273..1ed4c9a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -166,8 +166,6 @@ static int ixgbe_get_settings(struct net_device *netdev,
 	/* set the supported link speeds */
 	if (supported_link & IXGBE_LINK_SPEED_10GB_FULL)
 		ecmd->supported |= SUPPORTED_10000baseT_Full;
-	if (supported_link & IXGBE_LINK_SPEED_2_5GB_FULL)
-		ecmd->supported |= SUPPORTED_2500baseX_Full;
 	if (supported_link & IXGBE_LINK_SPEED_1GB_FULL)
 		ecmd->supported |= SUPPORTED_1000baseT_Full;
 	if (supported_link & IXGBE_LINK_SPEED_100_FULL)
@@ -179,8 +177,6 @@ static int ixgbe_get_settings(struct net_device *netdev,
 			ecmd->advertising |= ADVERTISED_100baseT_Full;
 		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_10GB_FULL)
 			ecmd->advertising |= ADVERTISED_10000baseT_Full;
-		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_2_5GB_FULL)
-			ecmd->advertising |= ADVERTISED_2500baseX_Full;
 		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_1GB_FULL)
 			ecmd->advertising |= ADVERTISED_1000baseT_Full;
 	} else {
-- 
2.5.0

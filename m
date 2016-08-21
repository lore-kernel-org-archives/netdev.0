From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/6] ixgbe: report correct media type for KR, KX and KX4 interfaces
Date: Sat, 20 Aug 2016 20:22:17 -0700
Message-ID: <1471749742-7080-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471749742-7080-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Veola Nazareth <veola.nazareth@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:24499 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751936AbcHUDWY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 Aug 2016 23:22:24 -0400
In-Reply-To: <1471749742-7080-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veola Nazareth <veola.nazareth@intel.com>

ethtool reports backplane type interfaces as 1000/10000baseT link modes.
This has been corrected to report the media as KR, KX or KX4 based on the
backplane interface present.

Signed-off-by: Veola Nazareth <veola.nazareth@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 0d7209e..9547191 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -193,7 +193,9 @@ static int ixgbe_get_settings(struct net_device *netdev,
 	if (supported_link & IXGBE_LINK_SPEED_10GB_FULL)
 		ecmd->supported |= ixgbe_get_supported_10gtypes(hw);
 	if (supported_link & IXGBE_LINK_SPEED_1GB_FULL)
-		ecmd->supported |= SUPPORTED_1000baseT_Full;
+		ecmd->supported |= (ixgbe_isbackplane(hw->phy.media_type)) ?
+				   SUPPORTED_1000baseKX_Full :
+				   SUPPORTED_1000baseT_Full;
 	if (supported_link & IXGBE_LINK_SPEED_100_FULL)
 		ecmd->supported |= ixgbe_isbackplane(hw->phy.media_type) ?
 				   SUPPORTED_1000baseKX_Full :
-- 
2.7.4

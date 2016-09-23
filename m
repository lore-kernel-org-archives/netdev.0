From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/10] ixgbe: Indicate support for pause frames in all cases
Date: Fri, 23 Sep 2016 00:51:37 -0700
Message-ID: <1474617103-59530-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474617103-59530-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:27953 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752652AbcIWHvr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 03:51:47 -0400
In-Reply-To: <1474617103-59530-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

All the MACs supported by ixgbe support pause frames, so indicate
that support in ethtool. Also set advertising according to requested
mode.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 9547191..730a99f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -313,6 +313,25 @@ static int ixgbe_get_settings(struct net_device *netdev,
 		break;
 	}
 
+	/* Indicate pause support */
+	ecmd->supported |= SUPPORTED_Pause;
+
+	switch (hw->fc.requested_mode) {
+	case ixgbe_fc_full:
+		ecmd->advertising |= ADVERTISED_Pause;
+		break;
+	case ixgbe_fc_rx_pause:
+		ecmd->advertising |= ADVERTISED_Pause |
+				     ADVERTISED_Asym_Pause;
+		break;
+	case ixgbe_fc_tx_pause:
+		ecmd->advertising |= ADVERTISED_Asym_Pause;
+		break;
+	default:
+		ecmd->advertising &= ~(ADVERTISED_Pause |
+				       ADVERTISED_Asym_Pause);
+	}
+
 	if (netif_carrier_ok(netdev)) {
 		switch (adapter->link_speed) {
 		case IXGBE_LINK_SPEED_10GB_FULL:
-- 
2.7.4

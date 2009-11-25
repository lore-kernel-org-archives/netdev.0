From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/2] ixgbe: Display currently attached PHY
	through ethtool
Date: Wed, 25 Nov 2009 02:11:54 -0800
Message-ID: <20091125101153.24430.45252.stgit@localhost.localdomain>
References: <20091125101128.24430.89112.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net, jeff@garzik.org, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.westchester.pa.mail.comcast.net ([76.96.59.212]:43349
	"EHLO QMTA14.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758557AbZKYKMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 05:12:09 -0500
In-Reply-To: <20091125101128.24430.89112.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

This patch extends the ethtool interface to display what PHY
is currently connected to a NIC.  The results can be viewed in
ethtool ethX output.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |   50 +++++++++++++++++++++++++++++++++++++
 1 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 84ab4db..ec59c53 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -205,6 +205,56 @@ static int ixgbe_get_settings(struct net_device *netdev,
 		ecmd->autoneg = AUTONEG_DISABLE;
 	}
 
+	/* Get PHY type */
+	switch (adapter->hw.phy.type) {
+	case ixgbe_phy_tn:
+	case ixgbe_phy_cu_unknown:
+		/* Copper 10G-BASET */
+		ecmd->port = PORT_TP;
+		break;
+	case ixgbe_phy_qt:
+		ecmd->port = PORT_FIBRE;
+		break;
+	case ixgbe_phy_nl:
+	case ixgbe_phy_tw_tyco:
+	case ixgbe_phy_tw_unknown:
+	case ixgbe_phy_sfp_ftl:
+	case ixgbe_phy_sfp_avago:
+	case ixgbe_phy_sfp_intel:
+	case ixgbe_phy_sfp_unknown:
+		switch (adapter->hw.phy.sfp_type) {
+		/* SFP+ devices, further checking needed */
+		case ixgbe_sfp_type_da_cu:
+		case ixgbe_sfp_type_da_cu_core0:
+		case ixgbe_sfp_type_da_cu_core1:
+			ecmd->port = PORT_DA;
+			break;
+		case ixgbe_sfp_type_sr:
+		case ixgbe_sfp_type_lr:
+		case ixgbe_sfp_type_srlr_core0:
+		case ixgbe_sfp_type_srlr_core1:
+			ecmd->port = PORT_FIBRE;
+			break;
+		case ixgbe_sfp_type_not_present:
+			ecmd->port = PORT_NONE;
+			break;
+		case ixgbe_sfp_type_unknown:
+		default:
+			ecmd->port = PORT_OTHER;
+			break;
+		}
+		break;
+	case ixgbe_phy_xaui:
+		ecmd->port = PORT_NONE;
+		break;
+	case ixgbe_phy_unknown:
+	case ixgbe_phy_generic:
+	case ixgbe_phy_sfp_unsupported:
+	default:
+		ecmd->port = PORT_OTHER;
+		break;
+	}
+
 	hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
 	if (link_up) {
 		ecmd->speed = (link_speed == IXGBE_LINK_SPEED_10GB_FULL) ?


From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/18] ixgbe: Add small packet padding support for X550
Date: Wed, 23 Sep 2015 23:59:34 -0700
Message-ID: <1443077981-55791-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443077981-55791-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36281 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932638AbbIXG7t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 02:59:49 -0400
In-Reply-To: <1443077981-55791-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

This patch sets RDRXCTL.PSP when the driver is in SRIOV mode which
enables padding of small packets.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 3 +++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h | 1 +
 2 files changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a10728c..81cbca4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3804,6 +3804,9 @@ static void ixgbe_setup_rdrxctl(struct ixgbe_adapter *adapter)
 		break;
 	case ixgbe_mac_X550:
 	case ixgbe_mac_X550EM_x:
+		if (adapter->num_vfs)
+			rdrxctl |= IXGBE_RDRXCTL_PSP;
+		/* fall through for older HW */
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
 		/* Disable RSC for ACK packets */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 998cfb9..939c90c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -1193,6 +1193,7 @@ struct ixgbe_thermal_sensor_data {
 /* RDRXCTL Bit Masks */
 #define IXGBE_RDRXCTL_RDMTS_1_2     0x00000000 /* Rx Desc Min Threshold Size */
 #define IXGBE_RDRXCTL_CRCSTRIP      0x00000002 /* CRC Strip */
+#define IXGBE_RDRXCTL_PSP           0x00000004 /* Pad small packet */
 #define IXGBE_RDRXCTL_MVMEN         0x00000020
 #define IXGBE_RDRXCTL_DMAIDONE      0x00000008 /* DMA init cycle done */
 #define IXGBE_RDRXCTL_AGGDIS        0x00010000 /* Aggregation disable */
-- 
2.4.3

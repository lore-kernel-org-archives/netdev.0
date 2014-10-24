From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/9] i40e: Add 10GBaseT support
Date: Thu, 23 Oct 2014 21:10:04 -0700
Message-ID: <1414123806-20049-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1414123806-20049-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:19277 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751751AbaJXEKR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2014 00:10:17 -0400
In-Reply-To: <1414123806-20049-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Add driver support for 10GBaseT device.

Change-ID: I4be6ed847ac0bddd220b9878a95c523b32038174
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c  |  1 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 33 ++++++++++++++++++++++----
 drivers/net/ethernet/intel/i40e/i40e_main.c    |  4 ++++
 drivers/net/ethernet/intel/i40e/i40e_type.h    |  1 +
 4 files changed, 34 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index c23e377..c49416c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -50,6 +50,7 @@ static i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 		case I40E_DEV_ID_QSFP_A:
 		case I40E_DEV_ID_QSFP_B:
 		case I40E_DEV_ID_QSFP_C:
+		case I40E_DEV_ID_10G_BASE_T:
 			hw->mac.type = I40E_MAC_XL710;
 			break;
 		case I40E_DEV_ID_VF:
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 1dda467..12adc08 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -264,6 +264,14 @@ static int i40e_get_settings(struct net_device *netdev,
 			ecmd->supported = SUPPORTED_10000baseKR_Full;
 			ecmd->advertising = ADVERTISED_10000baseKR_Full;
 			break;
+		case I40E_DEV_ID_10G_BASE_T:
+			ecmd->supported = SUPPORTED_10000baseT_Full |
+					  SUPPORTED_1000baseT_Full |
+					  SUPPORTED_100baseT_Full;
+			ecmd->advertising = ADVERTISED_10000baseT_Full |
+					    ADVERTISED_1000baseT_Full |
+					    ADVERTISED_100baseT_Full;
+			break;
 		default:
 			/* all the rest are 10G/1G */
 			ecmd->supported = SUPPORTED_10000baseT_Full |
@@ -322,9 +330,13 @@ static int i40e_get_settings(struct net_device *netdev,
 	case I40E_PHY_TYPE_10GBASE_CR1:
 	case I40E_PHY_TYPE_10GBASE_T:
 		ecmd->supported = SUPPORTED_Autoneg |
-				  SUPPORTED_10000baseT_Full;
+				  SUPPORTED_10000baseT_Full |
+				  SUPPORTED_1000baseT_Full |
+				  SUPPORTED_100baseT_Full;
 		ecmd->advertising = ADVERTISED_Autoneg |
-				    ADVERTISED_10000baseT_Full;
+				    ADVERTISED_10000baseT_Full |
+				    ADVERTISED_1000baseT_Full |
+				    ADVERTISED_100baseT_Full;
 		break;
 	case I40E_PHY_TYPE_XAUI:
 	case I40E_PHY_TYPE_XFI:
@@ -335,14 +347,22 @@ static int i40e_get_settings(struct net_device *netdev,
 	case I40E_PHY_TYPE_1000BASE_KX:
 	case I40E_PHY_TYPE_1000BASE_T:
 		ecmd->supported = SUPPORTED_Autoneg |
-				  SUPPORTED_1000baseT_Full;
+				  SUPPORTED_10000baseT_Full |
+				  SUPPORTED_1000baseT_Full |
+				  SUPPORTED_100baseT_Full;
 		ecmd->advertising = ADVERTISED_Autoneg |
-				    ADVERTISED_1000baseT_Full;
+				    ADVERTISED_10000baseT_Full |
+				    ADVERTISED_1000baseT_Full |
+				    ADVERTISED_100baseT_Full;
 		break;
 	case I40E_PHY_TYPE_100BASE_TX:
 		ecmd->supported = SUPPORTED_Autoneg |
+				  SUPPORTED_10000baseT_Full |
+				  SUPPORTED_1000baseT_Full |
 				  SUPPORTED_100baseT_Full;
 		ecmd->advertising = ADVERTISED_Autoneg |
+				    ADVERTISED_10000baseT_Full |
+				    ADVERTISED_1000baseT_Full |
 				    ADVERTISED_100baseT_Full;
 		break;
 	case I40E_PHY_TYPE_SGMII:
@@ -426,6 +446,9 @@ no_valid_phy_type:
 		case I40E_LINK_SPEED_1GB:
 			ethtool_cmd_speed_set(ecmd, SPEED_1000);
 			break;
+		case I40E_LINK_SPEED_100MB:
+			ethtool_cmd_speed_set(ecmd, SPEED_100);
+			break;
 		default:
 			break;
 		}
@@ -528,7 +551,7 @@ static int i40e_set_settings(struct net_device *netdev,
 		}
 		/* If autoneg is currently enabled */
 		if (hw->phy.link_info.an_info & I40E_AQ_AN_COMPLETED) {
-			config.abilities = abilities.abilities |
+			config.abilities = abilities.abilities &
 					   ~I40E_AQ_PHY_ENABLE_AN;
 			change = true;
 		}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 1fbbe11..9d36d10 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -74,6 +74,7 @@ static const struct pci_device_id i40e_pci_tbl[] = {
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_QSFP_A), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_QSFP_B), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_QSFP_C), 0},
+	{PCI_VDEVICE(INTEL, I40E_DEV_ID_10G_BASE_T), 0},
 	/* required last entry */
 	{0, }
 };
@@ -4449,6 +4450,9 @@ static void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
 	case I40E_LINK_SPEED_1GB:
 		strlcpy(speed, "1000 Mbps", SPEED_SIZE);
 		break;
+	case I40E_LINK_SPEED_100MB:
+		strncpy(speed, "100 Mbps", SPEED_SIZE);
+		break;
 	default:
 		break;
 	}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index ce04d90..3a237c3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -43,6 +43,7 @@
 #define I40E_DEV_ID_QSFP_A		0x1583
 #define I40E_DEV_ID_QSFP_B		0x1584
 #define I40E_DEV_ID_QSFP_C		0x1585
+#define I40E_DEV_ID_10G_BASE_T		0x1586
 #define I40E_DEV_ID_VF			0x154C
 #define I40E_DEV_ID_VF_HV		0x1571
 
-- 
1.9.3

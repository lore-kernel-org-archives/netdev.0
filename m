From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 2/7] netxen: add new board types
Date: Fri,  1 Aug 2008 03:14:56 -0700
Message-ID: <1217585701-13958-3-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:42824 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752985AbYHAKPF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2008 06:15:05 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add couple of new board configurations based on NX3031 chip.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h         |    6 +++++-
 drivers/net/netxen/netxen_nic_ethtool.c |    2 ++
 drivers/net/netxen/netxen_nic_hw.c      |    3 +++
 drivers/net/netxen/netxen_nic_main.c    |    6 ++++++
 4 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index ac710c3..22f9042 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -507,6 +507,8 @@ typedef enum {
 	NETXEN_BRDTYPE_P3_10000_BASE_T = 0x0027,
 	NETXEN_BRDTYPE_P3_XG_LOM = 0x0028,
 	NETXEN_BRDTYPE_P3_4_GB_MM = 0x0029,
+	NETXEN_BRDTYPE_P3_10G_SFP_CT = 0x002a,
+	NETXEN_BRDTYPE_P3_10G_SFP_QT = 0x002b,
 	NETXEN_BRDTYPE_P3_10G_CX4 = 0x0031,
 	NETXEN_BRDTYPE_P3_10G_XFP = 0x0032
 
@@ -1501,7 +1503,9 @@ static const struct netxen_brdinfo netxen_boards[] = {
 	{NETXEN_BRDTYPE_P3_10G_SFP_PLUS, 2, "Dual XGb SFP+ LP"},
 	{NETXEN_BRDTYPE_P3_10000_BASE_T, 1, "XGB 10G BaseT LP"},
 	{NETXEN_BRDTYPE_P3_XG_LOM,  2, "Dual XGb LOM"},
-	{NETXEN_BRDTYPE_P3_4_GB_MM, 4, "Quad GB - March Madness"},
+	{NETXEN_BRDTYPE_P3_4_GB_MM, 4, "NX3031 Gigabit Ethernet"},
+	{NETXEN_BRDTYPE_P3_10G_SFP_CT, 2, "NX3031 10 Gigabit Ethernet"},
+	{NETXEN_BRDTYPE_P3_10G_SFP_QT, 2, "Quanta Dual XGb SFP+"},
 	{NETXEN_BRDTYPE_P3_10G_CX4, 2, "Reference Dual CX4 Option"},
 	{NETXEN_BRDTYPE_P3_10G_XFP, 1, "Reference Single XFP Option"}
 };
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index f9b933e..4ad3e08 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -207,6 +207,8 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		break;
 	case NETXEN_BRDTYPE_P2_SB31_10G:
 	case NETXEN_BRDTYPE_P3_10G_SFP_PLUS:
+	case NETXEN_BRDTYPE_P3_10G_SFP_CT:
+	case NETXEN_BRDTYPE_P3_10G_SFP_QT:
 	case NETXEN_BRDTYPE_P3_10G_XFP:
 		ecmd->supported |= SUPPORTED_FIBRE;
 		ecmd->advertising |= ADVERTISED_FIBRE;
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 008a6e7..d0c6935 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -2016,6 +2016,8 @@ int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 	case NETXEN_BRDTYPE_P3_10G_CX4_LP:
 	case NETXEN_BRDTYPE_P3_IMEZ:
 	case NETXEN_BRDTYPE_P3_10G_SFP_PLUS:
+	case NETXEN_BRDTYPE_P3_10G_SFP_CT:
+	case NETXEN_BRDTYPE_P3_10G_SFP_QT:
 	case NETXEN_BRDTYPE_P3_10G_XFP:
 	case NETXEN_BRDTYPE_P3_10000_BASE_T:
 
@@ -2034,6 +2036,7 @@ int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 	default:
 		printk("%s: Unknown(%x)\n", netxen_nic_driver_name,
 		       boardinfo->board_type);
+		rv = -ENODEV;
 		break;
 	}
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 7b8688e..153b391 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -284,6 +284,8 @@ static void netxen_check_options(struct netxen_adapter *adapter)
 	case NETXEN_BRDTYPE_P3_10G_CX4_LP:
 	case NETXEN_BRDTYPE_P3_IMEZ:
 	case NETXEN_BRDTYPE_P3_10G_SFP_PLUS:
+	case NETXEN_BRDTYPE_P3_10G_SFP_QT:
+	case NETXEN_BRDTYPE_P3_10G_SFP_CT:
 	case NETXEN_BRDTYPE_P3_10G_XFP:
 	case NETXEN_BRDTYPE_P3_10000_BASE_T:
 		adapter->msix_supported = !!use_msi_x;
@@ -301,6 +303,10 @@ static void netxen_check_options(struct netxen_adapter *adapter)
 	case NETXEN_BRDTYPE_P3_REF_QG:
 	case NETXEN_BRDTYPE_P3_4_GB:
 	case NETXEN_BRDTYPE_P3_4_GB_MM:
+		adapter->msix_supported = 0;
+		adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_10G;
+		break;
+
 	case NETXEN_BRDTYPE_P2_SB35_4G:
 	case NETXEN_BRDTYPE_P2_SB31_2G:
 		adapter->msix_supported = 0;
-- 
1.5.4.3


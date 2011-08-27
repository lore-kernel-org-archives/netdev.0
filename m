From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/6] e1000e: convert to netdev features/hw_features API
Date: Sat, 27 Aug 2011 00:09:26 -0700
Message-ID: <1314428971-7676-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1314428971-7676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:2448 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750916Ab1H0HJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Aug 2011 03:09:34 -0400
In-Reply-To: <1314428971-7676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bruce Allan <bruce.w.allan@intel.com>

Private rx_csum flags are now duplicate of netdev->features &
NETIF_F_RXCSUM.  Remove those duplicates and use the net_device_ops
ndo_set_features.  This is based on the original patch submitted by
Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>

Cc: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/80003es2lan.c |    1 -
 drivers/net/ethernet/intel/e1000e/82571.c       |    5 --
 drivers/net/ethernet/intel/e1000e/e1000.h       |    3 +-
 drivers/net/ethernet/intel/e1000e/ethtool.c     |   88 ---------------=
--------
 drivers/net/ethernet/intel/e1000e/ich8lan.c     |    5 --
 drivers/net/ethernet/intel/e1000e/netdev.c      |   49 ++++++++++---
 6 files changed, 38 insertions(+), 113 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/80003es2lan.c b/drivers/=
net/ethernet/intel/e1000e/80003es2lan.c
index e4f4225..b754433 100644
--- a/drivers/net/ethernet/intel/e1000e/80003es2lan.c
+++ b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
@@ -1498,7 +1498,6 @@ struct e1000_info e1000_es2_info =3D {
 				  | FLAG_HAS_JUMBO_FRAMES
 				  | FLAG_HAS_WOL
 				  | FLAG_APME_IN_CTRL3
-				  | FLAG_RX_CSUM_ENABLED
 				  | FLAG_HAS_CTRLEXT_ON_LOAD
 				  | FLAG_RX_NEEDS_RESTART /* errata */
 				  | FLAG_TARC_SET_BIT_ZERO /* errata */
diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/et=
hernet/intel/e1000e/82571.c
index 536b3a5..2d4dc53 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -2019,7 +2019,6 @@ struct e1000_info e1000_82571_info =3D {
 				  | FLAG_HAS_JUMBO_FRAMES
 				  | FLAG_HAS_WOL
 				  | FLAG_APME_IN_CTRL3
-				  | FLAG_RX_CSUM_ENABLED
 				  | FLAG_HAS_CTRLEXT_ON_LOAD
 				  | FLAG_HAS_SMART_POWER_DOWN
 				  | FLAG_RESET_OVERWRITES_LAA /* errata */
@@ -2041,7 +2040,6 @@ struct e1000_info e1000_82572_info =3D {
 				  | FLAG_HAS_JUMBO_FRAMES
 				  | FLAG_HAS_WOL
 				  | FLAG_APME_IN_CTRL3
-				  | FLAG_RX_CSUM_ENABLED
 				  | FLAG_HAS_CTRLEXT_ON_LOAD
 				  | FLAG_TARC_SPEED_MODE_BIT, /* errata */
 	.flags2			=3D FLAG2_DISABLE_ASPM_L1 /* errata 13 */
@@ -2059,7 +2057,6 @@ struct e1000_info e1000_82573_info =3D {
 	.flags			=3D FLAG_HAS_HW_VLAN_FILTER
 				  | FLAG_HAS_WOL
 				  | FLAG_APME_IN_CTRL3
-				  | FLAG_RX_CSUM_ENABLED
 				  | FLAG_HAS_SMART_POWER_DOWN
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_SWSM_ON_LOAD,
@@ -2080,7 +2077,6 @@ struct e1000_info e1000_82574_info =3D {
 				  | FLAG_HAS_JUMBO_FRAMES
 				  | FLAG_HAS_WOL
 				  | FLAG_APME_IN_CTRL3
-				  | FLAG_RX_CSUM_ENABLED
 				  | FLAG_HAS_SMART_POWER_DOWN
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_CTRLEXT_ON_LOAD,
@@ -2100,7 +2096,6 @@ struct e1000_info e1000_82583_info =3D {
 	.flags			=3D FLAG_HAS_HW_VLAN_FILTER
 				  | FLAG_HAS_WOL
 				  | FLAG_APME_IN_CTRL3
-				  | FLAG_RX_CSUM_ENABLED
 				  | FLAG_HAS_SMART_POWER_DOWN
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_JUMBO_FRAMES
diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/et=
hernet/intel/e1000e/e1000.h
index fa72052..1b15d1f 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -440,12 +440,11 @@ struct e1000_info {
 #define FLAG_LSC_GIG_SPEED_DROP           (1 << 25)
 #define FLAG_SMART_POWER_DOWN             (1 << 26)
 #define FLAG_MSI_ENABLED                  (1 << 27)
-#define FLAG_RX_CSUM_ENABLED              (1 << 28)
+/* reserved (1 << 28) */
 #define FLAG_TSO_FORCE                    (1 << 29)
 #define FLAG_RX_RESTART_NOW               (1 << 30)
 #define FLAG_MSI_TEST_FAILED              (1 << 31)
=20
-/* CRC Stripping defines */
 #define FLAG2_CRC_STRIPPING               (1 << 0)
 #define FLAG2_HAS_PHY_WAKEUP              (1 << 1)
 #define FLAG2_IS_DISCARDING               (1 << 2)
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/=
ethernet/intel/e1000e/ethtool.c
index e0cbd6a..d96d0b0 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -367,59 +367,6 @@ out:
 	return retval;
 }
=20
-static u32 e1000_get_rx_csum(struct net_device *netdev)
-{
-	struct e1000_adapter *adapter =3D netdev_priv(netdev);
-	return adapter->flags & FLAG_RX_CSUM_ENABLED;
-}
-
-static int e1000_set_rx_csum(struct net_device *netdev, u32 data)
-{
-	struct e1000_adapter *adapter =3D netdev_priv(netdev);
-
-	if (data)
-		adapter->flags |=3D FLAG_RX_CSUM_ENABLED;
-	else
-		adapter->flags &=3D ~FLAG_RX_CSUM_ENABLED;
-
-	if (netif_running(netdev))
-		e1000e_reinit_locked(adapter);
-	else
-		e1000e_reset(adapter);
-	return 0;
-}
-
-static u32 e1000_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_HW_CSUM) !=3D 0;
-}
-
-static int e1000_set_tx_csum(struct net_device *netdev, u32 data)
-{
-	if (data)
-		netdev->features |=3D NETIF_F_HW_CSUM;
-	else
-		netdev->features &=3D ~NETIF_F_HW_CSUM;
-
-	return 0;
-}
-
-static int e1000_set_tso(struct net_device *netdev, u32 data)
-{
-	struct e1000_adapter *adapter =3D netdev_priv(netdev);
-
-	if (data) {
-		netdev->features |=3D NETIF_F_TSO;
-		netdev->features |=3D NETIF_F_TSO6;
-	} else {
-		netdev->features &=3D ~NETIF_F_TSO;
-		netdev->features &=3D ~NETIF_F_TSO6;
-	}
-
-	adapter->flags |=3D FLAG_TSO_FORCE;
-	return 0;
-}
-
 static u32 e1000_get_msglevel(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter =3D netdev_priv(netdev);
@@ -2014,31 +1961,6 @@ static void e1000_get_strings(struct net_device =
*netdev, u32 stringset,
 	}
 }
=20
-static int e1000e_set_flags(struct net_device *netdev, u32 data)
-{
-	struct e1000_adapter *adapter =3D netdev_priv(netdev);
-	bool need_reset =3D false;
-	int rc;
-
-	need_reset =3D (data & ETH_FLAG_RXVLAN) !=3D
-		     (netdev->features & NETIF_F_HW_VLAN_RX);
-
-	rc =3D ethtool_op_set_flags(netdev, data, ETH_FLAG_RXVLAN |
-				  ETH_FLAG_TXVLAN);
-
-	if (rc)
-		return rc;
-
-	if (need_reset) {
-		if (netif_running(netdev))
-			e1000e_reinit_locked(adapter);
-		else
-			e1000e_reset(adapter);
-	}
-
-	return 0;
-}
-
 static const struct ethtool_ops e1000_ethtool_ops =3D {
 	.get_settings		=3D e1000_get_settings,
 	.set_settings		=3D e1000_set_settings,
@@ -2058,14 +1980,6 @@ static const struct ethtool_ops e1000_ethtool_op=
s =3D {
 	.set_ringparam		=3D e1000_set_ringparam,
 	.get_pauseparam		=3D e1000_get_pauseparam,
 	.set_pauseparam		=3D e1000_set_pauseparam,
-	.get_rx_csum		=3D e1000_get_rx_csum,
-	.set_rx_csum		=3D e1000_set_rx_csum,
-	.get_tx_csum		=3D e1000_get_tx_csum,
-	.set_tx_csum		=3D e1000_set_tx_csum,
-	.get_sg			=3D ethtool_op_get_sg,
-	.set_sg			=3D ethtool_op_set_sg,
-	.get_tso		=3D ethtool_op_get_tso,
-	.set_tso		=3D e1000_set_tso,
 	.self_test		=3D e1000_diag_test,
 	.get_strings		=3D e1000_get_strings,
 	.set_phys_id		=3D e1000_set_phys_id,
@@ -2073,8 +1987,6 @@ static const struct ethtool_ops e1000_ethtool_ops=
 =3D {
 	.get_sset_count		=3D e1000e_get_sset_count,
 	.get_coalesce		=3D e1000_get_coalesce,
 	.set_coalesce		=3D e1000_set_coalesce,
-	.get_flags		=3D ethtool_op_get_flags,
-	.set_flags		=3D e1000e_set_flags,
 };
=20
 void e1000e_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/=
ethernet/intel/e1000e/ich8lan.c
index 54add27..3fc3acc 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -4058,7 +4058,6 @@ struct e1000_info e1000_ich8_info =3D {
 	.mac			=3D e1000_ich8lan,
 	.flags			=3D FLAG_HAS_WOL
 				  | FLAG_IS_ICH
-				  | FLAG_RX_CSUM_ENABLED
 				  | FLAG_HAS_CTRLEXT_ON_LOAD
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_FLASH
@@ -4076,7 +4075,6 @@ struct e1000_info e1000_ich9_info =3D {
 	.flags			=3D FLAG_HAS_JUMBO_FRAMES
 				  | FLAG_IS_ICH
 				  | FLAG_HAS_WOL
-				  | FLAG_RX_CSUM_ENABLED
 				  | FLAG_HAS_CTRLEXT_ON_LOAD
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_ERT
@@ -4095,7 +4093,6 @@ struct e1000_info e1000_ich10_info =3D {
 	.flags			=3D FLAG_HAS_JUMBO_FRAMES
 				  | FLAG_IS_ICH
 				  | FLAG_HAS_WOL
-				  | FLAG_RX_CSUM_ENABLED
 				  | FLAG_HAS_CTRLEXT_ON_LOAD
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_ERT
@@ -4113,7 +4110,6 @@ struct e1000_info e1000_pch_info =3D {
 	.mac			=3D e1000_pchlan,
 	.flags			=3D FLAG_IS_ICH
 				  | FLAG_HAS_WOL
-				  | FLAG_RX_CSUM_ENABLED
 				  | FLAG_HAS_CTRLEXT_ON_LOAD
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_FLASH
@@ -4133,7 +4129,6 @@ struct e1000_info e1000_pch2_info =3D {
 	.mac			=3D e1000_pch2lan,
 	.flags			=3D FLAG_IS_ICH
 				  | FLAG_HAS_WOL
-				  | FLAG_RX_CSUM_ENABLED
 				  | FLAG_HAS_CTRLEXT_ON_LOAD
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_FLASH
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/e=
thernet/intel/e1000e/netdev.c
index 9742bc6..4f66999 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3069,7 +3069,7 @@ static void e1000_configure_rx(struct e1000_adapt=
er *adapter)
=20
 	/* Enable Receive Checksum Offload for TCP and UDP */
 	rxcsum =3D er32(RXCSUM);
-	if (adapter->flags & FLAG_RX_CSUM_ENABLED) {
+	if (adapter->netdev->features & NETIF_F_RXCSUM) {
 		rxcsum |=3D E1000_RXCSUM_TUOFL;
=20
 		/*
@@ -5860,6 +5860,26 @@ static void e1000_eeprom_checks(struct e1000_ada=
pter *adapter)
 	}
 }
=20
+static int e1000_set_features(struct net_device *netdev, u32 features)
+{
+	struct e1000_adapter *adapter =3D netdev_priv(netdev);
+	u32 changed =3D features ^ netdev->features;
+
+	if (changed & (NETIF_F_TSO | NETIF_F_TSO6))
+		adapter->flags |=3D FLAG_TSO_FORCE;
+
+	if (!(changed & (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX |
+			 NETIF_F_RXCSUM)))
+		return 0;
+
+	if (netif_running(netdev))
+		e1000e_reinit_locked(adapter);
+	else
+		e1000e_reset(adapter);
+
+	return 0;
+}
+
 static const struct net_device_ops e1000e_netdev_ops =3D {
 	.ndo_open		=3D e1000_open,
 	.ndo_stop		=3D e1000_close,
@@ -5877,6 +5897,7 @@ static const struct net_device_ops e1000e_netdev_=
ops =3D {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	=3D e1000_netpoll,
 #endif
+	.ndo_set_features =3D e1000_set_features,
 };
=20
 /**
@@ -6036,21 +6057,25 @@ static int __devinit e1000_probe(struct pci_dev=
 *pdev,
 	if (e1000_check_reset_block(&adapter->hw))
 		e_info("PHY reset is blocked due to SOL/IDER session.\n");
=20
-	netdev->features =3D NETIF_F_SG |
-			   NETIF_F_HW_CSUM |
-			   NETIF_F_HW_VLAN_TX |
-			   NETIF_F_HW_VLAN_RX;
+	/* Set initial default active device features */
+	netdev->features =3D (NETIF_F_SG |
+			    NETIF_F_HW_VLAN_RX |
+			    NETIF_F_HW_VLAN_TX |
+			    NETIF_F_TSO |
+			    NETIF_F_TSO6 |
+			    NETIF_F_RXCSUM |
+			    NETIF_F_HW_CSUM);
+
+	/* Set user-changeable features (subset of all device features) */
+	netdev->hw_features =3D netdev->features;
=20
 	if (adapter->flags & FLAG_HAS_HW_VLAN_FILTER)
 		netdev->features |=3D NETIF_F_HW_VLAN_FILTER;
=20
-	netdev->features |=3D NETIF_F_TSO;
-	netdev->features |=3D NETIF_F_TSO6;
-
-	netdev->vlan_features |=3D NETIF_F_TSO;
-	netdev->vlan_features |=3D NETIF_F_TSO6;
-	netdev->vlan_features |=3D NETIF_F_HW_CSUM;
-	netdev->vlan_features |=3D NETIF_F_SG;
+	netdev->vlan_features |=3D (NETIF_F_SG |
+				  NETIF_F_TSO |
+				  NETIF_F_TSO6 |
+				  NETIF_F_HW_CSUM);
=20
 	if (pci_using_dac) {
 		netdev->features |=3D NETIF_F_HIGHDMA;
--=20
1.7.6

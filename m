From: raj@tardy.cup.hp.com (Rick Jones)
Subject: [PATCH net-next] Sweep the last of the active .get_drvinfo floors under ethernet/
Date: Mon, 14 Nov 2011 10:13:25 -0800 (PST)
Message-ID: <20111114181325.217C72900307@tardy>
To: <netdev@vger.kernel.org>, "Christian Benvenuti" <benve@cisco.com>,
	"Roopa Prabhu" <roprabhu@cisco.com>,
	"David Wang" <dwang2@cisco.com>,
	<e1000-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:2627 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753018Ab1KNSN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 13:13:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>

This round of floor sweeping converts strncpy calls in various .get_drvinfo
routines to the preferred strlcpy.  It also does a modicum of other
cleaning in those routines.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

Compile tested only.

 drivers/net/ethernet/cisco/enic/enic_main.c      |    8 ++++----
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c |   13 +++++++------
 drivers/net/ethernet/intel/e1000e/ethtool.c      |   16 +++++++---------
 drivers/net/ethernet/intel/igb/igb_ethtool.c     |   15 ++++++---------
 drivers/net/ethernet/intel/igbvf/ethtool.c       |   12 +++++++-----
 drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c   |   11 +++++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   16 ++++++----------
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c  |   11 +++++++----
 drivers/net/ethernet/sun/cassini.c               |    7 +++----
 9 files changed, 54 insertions(+), 55 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index c3786fd..1fe5df0 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -217,11 +217,11 @@ static void enic_get_drvinfo(struct net_device *netdev,
 
 	enic_dev_fw_info(enic, &fw_info);
 
-	strncpy(drvinfo->driver, DRV_NAME, sizeof(drvinfo->driver));
-	strncpy(drvinfo->version, DRV_VERSION, sizeof(drvinfo->version));
-	strncpy(drvinfo->fw_version, fw_info->fw_version,
+	strlcpy(drvinfo->driver, DRV_NAME, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, DRV_VERSION, sizeof(drvinfo->version));
+	strlcpy(drvinfo->fw_version, fw_info->fw_version,
 		sizeof(drvinfo->fw_version));
-	strncpy(drvinfo->bus_info, pci_name(enic->pdev),
+	strlcpy(drvinfo->bus_info, pci_name(enic->pdev),
 		sizeof(drvinfo->bus_info));
 }
 
diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index 2b223ac..63faec6 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -515,14 +515,15 @@ static void e1000_get_drvinfo(struct net_device *netdev,
 			      struct ethtool_drvinfo *drvinfo)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	char firmware_version[32];
 
-	strncpy(drvinfo->driver,  e1000_driver_name, 32);
-	strncpy(drvinfo->version, e1000_driver_version, 32);
+	strlcpy(drvinfo->driver,  e1000_driver_name,
+		sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, e1000_driver_version,
+		sizeof(drvinfo->version));
 
-	sprintf(firmware_version, "N/A");
-	strncpy(drvinfo->fw_version, firmware_version, 32);
-	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
+	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
+	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
+		sizeof(drvinfo->bus_info));
 	drvinfo->regdump_len = e1000_get_regs_len(netdev);
 	drvinfo->eedump_len = e1000_get_eeprom_len(netdev);
 }
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 69c9d21..6d8f0ed 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -579,26 +579,24 @@ static void e1000_get_drvinfo(struct net_device *netdev,
 			      struct ethtool_drvinfo *drvinfo)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	char firmware_version[32];
 
-	strncpy(drvinfo->driver,  e1000e_driver_name,
-		sizeof(drvinfo->driver) - 1);
+	strlcpy(drvinfo->driver,  e1000e_driver_name,
+		sizeof(drvinfo->driver));
 	strncpy(drvinfo->version, e1000e_driver_version,
-		sizeof(drvinfo->version) - 1);
+		sizeof(drvinfo->version));
 
 	/*
 	 * EEPROM image version # is reported as firmware version # for
 	 * PCI-E controllers
 	 */
-	snprintf(firmware_version, sizeof(firmware_version), "%d.%d-%d",
+	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
+		"%d.%d-%d",
 		(adapter->eeprom_vers & 0xF000) >> 12,
 		(adapter->eeprom_vers & 0x0FF0) >> 4,
 		(adapter->eeprom_vers & 0x000F));
 
-	strncpy(drvinfo->fw_version, firmware_version,
-		sizeof(drvinfo->fw_version) - 1);
-	strncpy(drvinfo->bus_info, pci_name(adapter->pdev),
-		sizeof(drvinfo->bus_info) - 1);
+	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
+		sizeof(drvinfo->bus_info));
 	drvinfo->regdump_len = e1000_get_regs_len(netdev);
 	drvinfo->eedump_len = e1000_get_eeprom_len(netdev);
 }
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 43873eb..e9335ef 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -673,25 +673,22 @@ static void igb_get_drvinfo(struct net_device *netdev,
 			    struct ethtool_drvinfo *drvinfo)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
-	char firmware_version[32];
 	u16 eeprom_data;
 
-	strncpy(drvinfo->driver,  igb_driver_name, sizeof(drvinfo->driver) - 1);
-	strncpy(drvinfo->version, igb_driver_version,
-		sizeof(drvinfo->version) - 1);
+	strlcpy(drvinfo->driver,  igb_driver_name, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, igb_driver_version, sizeof(drvinfo->version));
 
 	/* EEPROM image version # is reported as firmware version # for
 	 * 82575 controllers */
 	adapter->hw.nvm.ops.read(&adapter->hw, 5, 1, &eeprom_data);
-	sprintf(firmware_version, "%d.%d-%d",
+	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
+		"%d.%d-%d",
 		(eeprom_data & 0xF000) >> 12,
 		(eeprom_data & 0x0FF0) >> 4,
 		eeprom_data & 0x000F);
 
-	strncpy(drvinfo->fw_version, firmware_version,
-		sizeof(drvinfo->fw_version) - 1);
-	strncpy(drvinfo->bus_info, pci_name(adapter->pdev),
-		sizeof(drvinfo->bus_info) - 1);
+	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
+		sizeof(drvinfo->bus_info));
 	drvinfo->n_stats = IGB_STATS_LEN;
 	drvinfo->testinfo_len = IGB_TEST_LEN;
 	drvinfo->regdump_len = igb_get_regs_len(netdev);
diff --git a/drivers/net/ethernet/intel/igbvf/ethtool.c b/drivers/net/ethernet/intel/igbvf/ethtool.c
index 2c25858..e60f1c6 100644
--- a/drivers/net/ethernet/intel/igbvf/ethtool.c
+++ b/drivers/net/ethernet/intel/igbvf/ethtool.c
@@ -191,12 +191,14 @@ static void igbvf_get_drvinfo(struct net_device *netdev,
                               struct ethtool_drvinfo *drvinfo)
 {
 	struct igbvf_adapter *adapter = netdev_priv(netdev);
-	char firmware_version[32] = "N/A";
 
-	strncpy(drvinfo->driver,  igbvf_driver_name, 32);
-	strncpy(drvinfo->version, igbvf_driver_version, 32);
-	strncpy(drvinfo->fw_version, firmware_version, 32);
-	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
+	strlcpy(drvinfo->driver,  igbvf_driver_name, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, igbvf_driver_version,
+		sizeof(drvinfo->version));
+	strlcpy(drvinfo->fw_version, "N/A",
+		sizeof(drvinfo->fw_version));
+	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
+		sizeof(drvinfo->bus_info));
 	drvinfo->regdump_len = igbvf_get_regs_len(netdev);
 	drvinfo->eedump_len = igbvf_get_eeprom_len(netdev);
 }
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c b/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
index 9dfce7d..96fcb0e 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
@@ -473,10 +473,13 @@ ixgb_get_drvinfo(struct net_device *netdev,
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
-	strncpy(drvinfo->driver,  ixgb_driver_name, 32);
-	strncpy(drvinfo->version, ixgb_driver_version, 32);
-	strncpy(drvinfo->fw_version, "N/A", 32);
-	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
+	strlcpy(drvinfo->driver,  ixgb_driver_name,
+		sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, ixgb_driver_version,
+		sizeof(drvinfo->version));
+	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
+	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
+		sizeof(drvinfo->bus_info));
 	drvinfo->n_stats = IXGB_STATS_LEN;
 	drvinfo->regdump_len = ixgb_get_regs_len(netdev);
 	drvinfo->eedump_len = ixgb_get_eeprom_len(netdev);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 70d58c3..91f871b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -888,23 +888,19 @@ static void ixgbe_get_drvinfo(struct net_device *netdev,
                               struct ethtool_drvinfo *drvinfo)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	char firmware_version[32];
 	u32 nvm_track_id;
 
-	strncpy(drvinfo->driver, ixgbe_driver_name,
-	        sizeof(drvinfo->driver) - 1);
-	strncpy(drvinfo->version, ixgbe_driver_version,
-	        sizeof(drvinfo->version) - 1);
+	strlcpy(drvinfo->driver, ixgbe_driver_name, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, ixgbe_driver_version,
+		sizeof(drvinfo->version));
 
 	nvm_track_id = (adapter->eeprom_verh << 16) |
 			adapter->eeprom_verl;
-	snprintf(firmware_version, sizeof(firmware_version), "0x%08x",
+	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version), "0x%08x",
 		 nvm_track_id);
 
-	strncpy(drvinfo->fw_version, firmware_version,
-		sizeof(drvinfo->fw_version) - 1);
-	strncpy(drvinfo->bus_info, pci_name(adapter->pdev),
-		sizeof(drvinfo->bus_info) - 1);
+	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
+		sizeof(drvinfo->bus_info));
 	drvinfo->n_stats = IXGBE_STATS_LEN;
 	drvinfo->testinfo_len = IXGBE_TEST_LEN;
 	drvinfo->regdump_len = ixgbe_get_regs_len(netdev);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 74e2a2a..ee637a2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -45,13 +45,16 @@ mlx4_en_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
 
-	strncpy(drvinfo->driver, DRV_NAME, 32);
-	strncpy(drvinfo->version, DRV_VERSION " (" DRV_RELDATE ")", 32);
-	sprintf(drvinfo->fw_version, "%d.%d.%d",
+	strlcpy(drvinfo->driver, DRV_NAME, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, DRV_VERSION " (" DRV_RELDATE ")",
+		sizeof(drvinfo->version));
+	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
+		"%d.%d.%d",
 		(u16) (mdev->dev->caps.fw_ver >> 32),
 		(u16) ((mdev->dev->caps.fw_ver >> 16) & 0xffff),
 		(u16) (mdev->dev->caps.fw_ver & 0xffff));
-	strncpy(drvinfo->bus_info, pci_name(mdev->dev->pdev), 32);
+	strlcpy(drvinfo->bus_info, pci_name(mdev->dev->pdev),
+		sizeof(drvinfo->bus_info));
 	drvinfo->n_stats = 0;
 	drvinfo->regdump_len = 0;
 	drvinfo->eedump_len = 0;
diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index fd40988..f10665f 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -4532,10 +4532,9 @@ static void cas_set_multicast(struct net_device *dev)
 static void cas_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	struct cas *cp = netdev_priv(dev);
-	strncpy(info->driver, DRV_MODULE_NAME, ETHTOOL_BUSINFO_LEN);
-	strncpy(info->version, DRV_MODULE_VERSION, ETHTOOL_BUSINFO_LEN);
-	info->fw_version[0] = '\0';
-	strncpy(info->bus_info, pci_name(cp->pdev), ETHTOOL_BUSINFO_LEN);
+	strlcpy(info->driver, DRV_MODULE_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_MODULE_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(cp->pdev), sizeof(info->bus_info));
 	info->regdump_len = cp->casreg_len < CAS_MAX_REGS ?
 		cp->casreg_len : CAS_MAX_REGS;
 	info->n_stats = CAS_NUM_STAT_KEYS;

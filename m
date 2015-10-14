From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next] drivers/net: get rid of unnecessary initializations in .get_drvinfo()
Date: Wed, 14 Oct 2015 18:27:52 +0200
Message-ID: <1444840072-21313-1-git-send-email-ivecera@redhat.com>
Cc: bwh@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35817 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753982AbbJNQ1z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 12:27:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many drivers initialize uselessly n_priv_flags, n_stats, testinfo_len,
eedump_len & regdump_len fields in their .get_drvinfo() ethtool op.
It's not necessary as these fields is filled in ethtool_get_drvinfo().

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/infiniband/hw/nes/nes_nic.c                     | 3 ---
 drivers/net/ethernet/aeroflex/greth.c                   | 2 --
 drivers/net/ethernet/amd/au1000_eth.c                   | 1 -
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c            | 1 -
 drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c      | 4 ----
 drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c      | 4 ----
 drivers/net/ethernet/atheros/atlx/atl1.c                | 1 -
 drivers/net/ethernet/atheros/atlx/atl2.c                | 4 ----
 drivers/net/ethernet/broadcom/bcm63xx_enet.c            | 2 --
 drivers/net/ethernet/broadcom/bcmsysport.c              | 1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c     | 4 ----
 drivers/net/ethernet/broadcom/genet/bcmgenet.c          | 1 -
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c      | 1 -
 drivers/net/ethernet/dec/tulip/de2104x.c                | 1 -
 drivers/net/ethernet/emulex/benet/be_ethtool.c          | 3 ---
 drivers/net/ethernet/freescale/gianfar_ethtool.c        | 2 --
 drivers/net/ethernet/freescale/ucc_geth_ethtool.c       | 2 --
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c        | 1 -
 drivers/net/ethernet/ibm/emac/core.c                    | 1 -
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c        | 2 --
 drivers/net/ethernet/intel/e1000e/ethtool.c             | 2 --
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c        | 4 ----
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c          | 1 -
 drivers/net/ethernet/intel/igb/igb_ethtool.c            | 4 ----
 drivers/net/ethernet/intel/igbvf/ethtool.c              | 2 --
 drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c          | 3 ---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c        | 3 ---
 drivers/net/ethernet/marvell/mv643xx_eth.c              | 1 -
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c         | 3 ---
 drivers/net/ethernet/neterion/s2io.c                    | 2 --
 drivers/net/ethernet/neterion/vxge/vxge-ethtool.c       | 4 ----
 drivers/net/ethernet/octeon/octeon_mgmt.c               | 4 ----
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c | 1 -
 drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c | 2 --
 drivers/net/ethernet/qlogic/qla3xxx.c                   | 2 --
 drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c         | 7 -------
 drivers/net/ethernet/realtek/8139too.c                  | 1 -
 drivers/net/ethernet/sun/cassini.c                      | 3 ---
 drivers/net/ethernet/tehuti/tehuti.c                    | 5 -----
 drivers/net/ethernet/ti/cpmac.c                         | 1 -
 drivers/net/ethernet/ti/cpsw.c                          | 1 -
 drivers/net/ethernet/ti/tlan.c                          | 1 -
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c       | 1 -
 drivers/net/fjes/fjes_ethtool.c                         | 2 --
 drivers/net/usb/asix_common.c                           | 1 -
 drivers/net/usb/dm9601.c                                | 1 -
 drivers/net/usb/mcs7830.c                               | 1 -
 drivers/net/usb/sr9800.c                                | 1 -
 drivers/net/vmxnet3/vmxnet3_ethtool.c                   | 4 ----
 drivers/net/wireless/ipw2x00/ipw2200.c                  | 1 -
 50 files changed, 110 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 70acda9..6a0bdfa 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -1325,9 +1325,6 @@ static void nes_netdev_get_drvinfo(struct net_device *netdev,
 		 "%u.%u", nesadapter->firmware_version >> 16,
 		 nesadapter->firmware_version & 0x000000ff);
 	strlcpy(drvinfo->version, DRV_VERSION, sizeof(drvinfo->version));
-	drvinfo->testinfo_len = 0;
-	drvinfo->eedump_len = 0;
-	drvinfo->regdump_len = 0;
 }
 
 
diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index ae89de7..20bf55d 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1141,8 +1141,6 @@ static void greth_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *in
 	strlcpy(info->version, "revision: 1.0", sizeof(info->version));
 	strlcpy(info->bus_info, greth->dev->bus->name, sizeof(info->bus_info));
 	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
-	info->eedump_len = 0;
-	info->regdump_len = sizeof(struct greth_regs);
 }
 
 static void greth_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index cb367cc..5330bcb 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -714,7 +714,6 @@ au1000_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 	snprintf(info->bus_info, sizeof(info->bus_info), "%s %d", DRV_NAME,
 		 aup->mac_id);
-	info->regdump_len = 0;
 }
 
 static void au1000_set_msglevel(struct net_device *dev, u32 value)
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
index 204fb3a..6040293 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
@@ -375,7 +375,6 @@ static void xgbe_get_drvinfo(struct net_device *netdev,
 		 XGMAC_GET_BITS(hw_feat->version, MAC_VR, USERVER),
 		 XGMAC_GET_BITS(hw_feat->version, MAC_VR, DEVID),
 		 XGMAC_GET_BITS(hw_feat->version, MAC_VR, SNPSVER));
-	drvinfo->n_stats = XGBE_STATS_COUNT;
 }
 
 static u32 xgbe_get_msglevel(struct net_device *netdev)
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c b/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
index 48694c2..872b7ab 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
@@ -233,10 +233,6 @@ static void atl1c_get_drvinfo(struct net_device *netdev,
 		sizeof(drvinfo->version));
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
-	drvinfo->n_stats = 0;
-	drvinfo->testinfo_len = 0;
-	drvinfo->regdump_len = atl1c_get_regs_len(netdev);
-	drvinfo->eedump_len = atl1c_get_eeprom_len(netdev);
 }
 
 static void atl1c_get_wol(struct net_device *netdev,
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c b/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c
index 1be072f..8e3dbd4 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c
@@ -316,10 +316,6 @@ static void atl1e_get_drvinfo(struct net_device *netdev,
 	strlcpy(drvinfo->fw_version, "L1e", sizeof(drvinfo->fw_version));
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
-	drvinfo->n_stats = 0;
-	drvinfo->testinfo_len = 0;
-	drvinfo->regdump_len = atl1e_get_regs_len(netdev);
-	drvinfo->eedump_len = atl1e_get_eeprom_len(netdev);
 }
 
 static void atl1e_get_wol(struct net_device *netdev,
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index eca1d11..529bca7 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -3388,7 +3388,6 @@ static void atl1_get_drvinfo(struct net_device *netdev,
 		sizeof(drvinfo->version));
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
-	drvinfo->eedump_len = ATL1_EEDUMP_LEN;
 }
 
 static void atl1_get_wol(struct net_device *netdev,
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index 46a5353..8f76f45 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -2030,10 +2030,6 @@ static void atl2_get_drvinfo(struct net_device *netdev,
 	strlcpy(drvinfo->fw_version, "L2", sizeof(drvinfo->fw_version));
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
-	drvinfo->n_stats = 0;
-	drvinfo->testinfo_len = 0;
-	drvinfo->regdump_len = atl2_get_regs_len(netdev);
-	drvinfo->eedump_len = atl2_get_eeprom_len(netdev);
 }
 
 static void atl2_get_wol(struct net_device *netdev,
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index a7f2cc3..95af75d 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1333,7 +1333,6 @@ static void bcm_enet_get_drvinfo(struct net_device *netdev,
 		sizeof(drvinfo->version));
 	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
 	strlcpy(drvinfo->bus_info, "bcm63xx", sizeof(drvinfo->bus_info));
-	drvinfo->n_stats = BCM_ENET_STATS_LEN;
 }
 
 static int bcm_enet_get_sset_count(struct net_device *netdev,
@@ -2597,7 +2596,6 @@ static void bcm_enetsw_get_drvinfo(struct net_device *netdev,
 	strncpy(drvinfo->version, bcm_enet_driver_version, 32);
 	strncpy(drvinfo->fw_version, "N/A", 32);
 	strncpy(drvinfo->bus_info, "bcm63xx", 32);
-	drvinfo->n_stats = BCM_ENETSW_STATS_LEN;
 }
 
 static void bcm_enetsw_get_ethtool_stats(struct net_device *netdev,
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index f1b5364..8581063 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -287,7 +287,6 @@ static void bcm_sysport_get_drvinfo(struct net_device *dev,
 	strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
 	strlcpy(info->version, "0.1", sizeof(info->version));
 	strlcpy(info->bus_info, "platform", sizeof(info->bus_info));
-	info->n_stats = BCM_SYSPORT_STATS_LEN;
 }
 
 static u32 bcm_sysport_get_msglvl(struct net_device *dev)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index aeb7ce6..a2bc531 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1090,10 +1090,6 @@ static void bnx2x_get_drvinfo(struct net_device *dev,
 	bnx2x_fill_fw_str(bp, info->fw_version, sizeof(info->fw_version));
 
 	strlcpy(info->bus_info, pci_name(bp->pdev), sizeof(info->bus_info));
-	info->n_stats = BNX2X_NUM_STATS;
-	info->testinfo_len = BNX2X_NUM_TESTS(bp);
-	info->eedump_len = bp->common.flash_size;
-	info->regdump_len = bnx2x_get_regs_len(dev);
 }
 
 static void bnx2x_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 1a3988f..410995c 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -793,7 +793,6 @@ static void bcmgenet_get_drvinfo(struct net_device *dev,
 {
 	strlcpy(info->driver, "bcmgenet", sizeof(info->driver));
 	strlcpy(info->version, "v2.0", sizeof(info->version));
-	info->n_stats = BCMGENET_STATS_LEN;
 }
 
 static int bcmgenet_get_sset_count(struct net_device *dev, int string_set)
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 29f3308..245c063 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -153,7 +153,6 @@ lio_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
 	strncpy(drvinfo->fw_version, oct->fw_info.liquidio_firmware_version,
 		ETHTOOL_FWVERS_LEN);
 	strncpy(drvinfo->bus_info, pci_name(oct->pci_dev), 32);
-	drvinfo->regdump_len = OCT_ETHTOOL_REGDUMP_LEN;
 }
 
 static void
diff --git a/drivers/net/ethernet/dec/tulip/de2104x.c b/drivers/net/ethernet/dec/tulip/de2104x.c
index a02ecc4..cadcee6 100644
--- a/drivers/net/ethernet/dec/tulip/de2104x.c
+++ b/drivers/net/ethernet/dec/tulip/de2104x.c
@@ -1597,7 +1597,6 @@ static void de_get_drvinfo (struct net_device *dev,struct ethtool_drvinfo *info)
 	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 	strlcpy(info->bus_info, pci_name(de->pdev), sizeof(info->bus_info));
-	info->eedump_len = DE_EEPROM_SIZE;
 }
 
 static int de_get_regs_len(struct net_device *dev)
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 2c9ed17..f4cb8e4 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -234,9 +234,6 @@ static void be_get_drvinfo(struct net_device *netdev,
 
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
-	drvinfo->testinfo_len = 0;
-	drvinfo->regdump_len = 0;
-	drvinfo->eedump_len = 0;
 }
 
 static u32 lancer_cmd_get_file_len(struct be_adapter *adapter, u8 *file_name)
diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index fb7f8d6..928ca2b 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -182,8 +182,6 @@ static void gfar_gdrvinfo(struct net_device *dev,
 		sizeof(drvinfo->version));
 	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
 	strlcpy(drvinfo->bus_info, "N/A", sizeof(drvinfo->bus_info));
-	drvinfo->regdump_len = 0;
-	drvinfo->eedump_len = 0;
 }
 
 
diff --git a/drivers/net/ethernet/freescale/ucc_geth_ethtool.c b/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
index cc83350..89714f5 100644
--- a/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
+++ b/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
@@ -351,8 +351,6 @@ uec_get_drvinfo(struct net_device *netdev,
 	strlcpy(drvinfo->version, DRV_VERSION, sizeof(drvinfo->version));
 	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
 	strlcpy(drvinfo->bus_info, "QUICC ENGINE", sizeof(drvinfo->bus_info));
-	drvinfo->eedump_len = 0;
-	drvinfo->regdump_len = uec_get_regs_len(netdev);
 }
 
 #ifdef CONFIG_PM
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 2550208..7d58918 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -682,7 +682,6 @@ static void hns_nic_get_drvinfo(struct net_device *net_dev,
 	drvinfo->bus_info[ETHTOOL_BUSINFO_LEN - 1] = '\0';
 
 	strncpy(drvinfo->fw_version, "N/A", ETHTOOL_FWVERS_LEN);
-	drvinfo->eedump_len = 0;
 }
 
 /**
diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index b60a34d..5d7db6c 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -2204,7 +2204,6 @@ static void emac_ethtool_get_drvinfo(struct net_device *ndev,
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 	snprintf(info->bus_info, sizeof(info->bus_info), "PPC 4xx EMAC-%d %s",
 		 dev->cell_index, dev->ofdev->dev.of_node->full_name);
-	info->regdump_len = emac_ethtool_get_regs_len(ndev);
 }
 
 static const struct ethtool_ops emac_ethtool_ops = {
diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index 4270ad2..83e557c 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -559,8 +559,6 @@ static void e1000_get_drvinfo(struct net_device *netdev,
 
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
-	drvinfo->regdump_len = e1000_get_regs_len(netdev);
-	drvinfo->eedump_len = e1000_get_eeprom_len(netdev);
 }
 
 static void e1000_get_ringparam(struct net_device *netdev,
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index ad6daa6..6cab1f3 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -648,8 +648,6 @@ static void e1000_get_drvinfo(struct net_device *netdev,
 
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
-	drvinfo->regdump_len = e1000_get_regs_len(netdev);
-	drvinfo->eedump_len = e1000_get_eeprom_len(netdev);
 }
 
 static void e1000_get_ringparam(struct net_device *netdev,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 4ef2fbd..813c4e6 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -515,10 +515,6 @@ static void fm10k_get_drvinfo(struct net_device *dev,
 		sizeof(info->version) - 1);
 	strncpy(info->bus_info, pci_name(interface->pdev),
 		sizeof(info->bus_info) - 1);
-
-	info->n_stats = fm10k_get_sset_count(dev, ETH_SS_STATS);
-
-	info->regdump_len = fm10k_get_regs_len(dev);
 }
 
 static void fm10k_get_pauseparam(struct net_device *dev,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 148f614..d5ad902 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1091,7 +1091,6 @@ static void i40e_get_drvinfo(struct net_device *netdev,
 		sizeof(drvinfo->fw_version));
 	strlcpy(drvinfo->bus_info, pci_name(pf->pdev),
 		sizeof(drvinfo->bus_info));
-	drvinfo->n_priv_flags = I40E_PRIV_FLAGS_STR_LEN;
 }
 
 static void i40e_get_ringparam(struct net_device *netdev,
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 7426276..2529bc6 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -842,10 +842,6 @@ static void igb_get_drvinfo(struct net_device *netdev,
 		sizeof(drvinfo->fw_version));
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
-	drvinfo->n_stats = IGB_STATS_LEN;
-	drvinfo->testinfo_len = IGB_TEST_LEN;
-	drvinfo->regdump_len = igb_get_regs_len(netdev);
-	drvinfo->eedump_len = igb_get_eeprom_len(netdev);
 }
 
 static void igb_get_ringparam(struct net_device *netdev,
diff --git a/drivers/net/ethernet/intel/igbvf/ethtool.c b/drivers/net/ethernet/intel/igbvf/ethtool.c
index c6996fe..b74ce53 100644
--- a/drivers/net/ethernet/intel/igbvf/ethtool.c
+++ b/drivers/net/ethernet/intel/igbvf/ethtool.c
@@ -196,8 +196,6 @@ static void igbvf_get_drvinfo(struct net_device *netdev,
 		sizeof(drvinfo->version));
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
-	drvinfo->regdump_len = igbvf_get_regs_len(netdev);
-	drvinfo->eedump_len = igbvf_get_eeprom_len(netdev);
 }
 
 static void igbvf_get_ringparam(struct net_device *netdev,
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c b/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
index b311e9e..d2b29b4 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
@@ -479,9 +479,6 @@ ixgb_get_drvinfo(struct net_device *netdev,
 		sizeof(drvinfo->version));
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
-	drvinfo->n_stats = IXGB_STATS_LEN;
-	drvinfo->regdump_len = ixgb_get_regs_len(netdev);
-	drvinfo->eedump_len = ixgb_get_eeprom_len(netdev);
 }
 
 static void
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 94c4912..d681273 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -943,9 +943,6 @@ static void ixgbe_get_drvinfo(struct net_device *netdev,
 
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
-	drvinfo->n_stats = IXGBE_STATS_LEN;
-	drvinfo->testinfo_len = IXGBE_TEST_LEN;
-	drvinfo->regdump_len = ixgbe_get_regs_len(netdev);
 }
 
 static void ixgbe_get_ringparam(struct net_device *netdev,
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index c78ae18..603d29d 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1586,7 +1586,6 @@ static void mv643xx_eth_get_drvinfo(struct net_device *dev,
 		sizeof(drvinfo->version));
 	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
 	strlcpy(drvinfo->bus_info, "platform", sizeof(drvinfo->bus_info));
-	drvinfo->n_stats = ARRAY_SIZE(mv643xx_eth_stats);
 }
 
 static int mv643xx_eth_nway_reset(struct net_device *dev)
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index f79d812..ddb5541 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -95,9 +95,6 @@ mlx4_en_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 		(u16) (mdev->dev->caps.fw_ver & 0xffff));
 	strlcpy(drvinfo->bus_info, pci_name(mdev->dev->persist->pdev),
 		sizeof(drvinfo->bus_info));
-	drvinfo->n_stats = 0;
-	drvinfo->regdump_len = 0;
-	drvinfo->eedump_len = 0;
 }
 
 static const char mlx4_en_priv_flags[][ETH_GSTRING_LEN] = {
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 2d1b942..9ba9758 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -5389,8 +5389,6 @@ static void s2io_ethtool_gdrvinfo(struct net_device *dev,
 	strlcpy(info->driver, s2io_driver_name, sizeof(info->driver));
 	strlcpy(info->version, s2io_driver_version, sizeof(info->version));
 	strlcpy(info->bus_info, pci_name(sp->pdev), sizeof(info->bus_info));
-	info->regdump_len = XENA_REG_SPACE;
-	info->eedump_len = XENA_EEPROM_SPACE;
 }
 
 /**
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-ethtool.c b/drivers/net/ethernet/neterion/vxge/vxge-ethtool.c
index be916eb..9a29670 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-ethtool.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-ethtool.c
@@ -105,10 +105,6 @@ static void vxge_ethtool_gdrvinfo(struct net_device *dev,
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 	strlcpy(info->fw_version, vdev->fw_version, sizeof(info->fw_version));
 	strlcpy(info->bus_info, pci_name(vdev->pdev), sizeof(info->bus_info));
-	info->regdump_len = sizeof(struct vxge_hw_vpath_reg)
-				* vdev->no_of_vpath;
-
-	info->n_stats = STAT_LEN;
 }
 
 /**
diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
index 7bf9c02..c177c7c 100644
--- a/drivers/net/ethernet/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
@@ -1344,10 +1344,6 @@ static void octeon_mgmt_get_drvinfo(struct net_device *netdev,
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
 	strlcpy(info->bus_info, "N/A", sizeof(info->bus_info));
-	info->n_stats = 0;
-	info->testinfo_len = 0;
-	info->regdump_len = 0;
-	info->eedump_len = 0;
 }
 
 static int octeon_mgmt_get_settings(struct net_device *netdev,
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
index f6fcf74..b19be7c 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
@@ -164,7 +164,6 @@ static void pch_gbe_get_drvinfo(struct net_device *netdev,
 	strlcpy(drvinfo->version, pch_driver_version, sizeof(drvinfo->version));
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
-	drvinfo->regdump_len = pch_gbe_get_regs_len(netdev);
 }
 
 /**
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
index 87e073c6..f903446 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
@@ -93,8 +93,6 @@ netxen_nic_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
-	drvinfo->regdump_len = NETXEN_NIC_REGS_LEN;
-	drvinfo->eedump_len = netxen_nic_get_eeprom_len(dev);
 }
 
 static int
diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index 4847713..b09a6b8 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -1736,8 +1736,6 @@ static void ql_get_drvinfo(struct net_device *ndev,
 		sizeof(drvinfo->version));
 	strlcpy(drvinfo->bus_info, pci_name(qdev->pdev),
 		sizeof(drvinfo->bus_info));
-	drvinfo->regdump_len = 0;
-	drvinfo->eedump_len = 0;
 }
 
 static u32 ql_get_msglevel(struct net_device *ndev)
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
index c3c514e..5dade1f 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
@@ -415,13 +415,6 @@ static void ql_get_drvinfo(struct net_device *ndev,
 		 (qdev->fw_rev_id & 0x000000ff));
 	strlcpy(drvinfo->bus_info, pci_name(qdev->pdev),
 		sizeof(drvinfo->bus_info));
-	drvinfo->n_stats = 0;
-	drvinfo->testinfo_len = 0;
-	if (!test_bit(QL_FRC_COREDUMP, &qdev->flags))
-		drvinfo->regdump_len = sizeof(struct ql_mpi_coredump);
-	else
-		drvinfo->regdump_len = sizeof(struct ql_reg_dump);
-	drvinfo->eedump_len = 0;
 }
 
 static void ql_get_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 78bb4ce..ef668d3 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -2388,7 +2388,6 @@ static void rtl8139_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *
 	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 	strlcpy(info->bus_info, pci_name(tp->pci_dev), sizeof(info->bus_info));
-	info->regdump_len = tp->regs_len;
 }
 
 static int rtl8139_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index 6ce9731..062bce9 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -4529,9 +4529,6 @@ static void cas_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info
 	strlcpy(info->driver, DRV_MODULE_NAME, sizeof(info->driver));
 	strlcpy(info->version, DRV_MODULE_VERSION, sizeof(info->version));
 	strlcpy(info->bus_info, pci_name(cp->pdev), sizeof(info->bus_info));
-	info->regdump_len = cp->casreg_len < CAS_MAX_REGS ?
-		cp->casreg_len : CAS_MAX_REGS;
-	info->n_stats = CAS_NUM_STAT_KEYS;
 }
 
 static int cas_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index a9cac84..14c9d1b 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -2182,11 +2182,6 @@ bdx_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
 	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
 	strlcpy(drvinfo->bus_info, pci_name(priv->pdev),
 		sizeof(drvinfo->bus_info));
-
-	drvinfo->n_stats = ((priv->stats_flag) ? ARRAY_SIZE(bdx_stat_names) : 0);
-	drvinfo->testinfo_len = 0;
-	drvinfo->regdump_len = 0;
-	drvinfo->eedump_len = 0;
 }
 
 /*
diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index cba3d9f..77d26fe 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -899,7 +899,6 @@ static void cpmac_get_drvinfo(struct net_device *dev,
 	strlcpy(info->driver, "cpmac", sizeof(info->driver));
 	strlcpy(info->version, CPMAC_VERSION, sizeof(info->version));
 	snprintf(info->bus_info, sizeof(info->bus_info), "%s", "cpmac");
-	info->regdump_len = 0;
 }
 
 static const struct ethtool_ops cpmac_ethtool_ops = {
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 75584cc..3b75adf 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1784,7 +1784,6 @@ static void cpsw_get_drvinfo(struct net_device *ndev,
 	strlcpy(info->driver, "cpsw", sizeof(info->driver));
 	strlcpy(info->version, "1.0", sizeof(info->version));
 	strlcpy(info->bus_info, priv->pdev->name, sizeof(info->bus_info));
-	info->regdump_len = cpsw_get_regs_len(ndev);
 }
 
 static u32 cpsw_get_msglevel(struct net_device *ndev)
diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index 691ec93..a274cd4 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -791,7 +791,6 @@ static void tlan_get_drvinfo(struct net_device *dev,
 			sizeof(info->bus_info));
 	else
 		strlcpy(info->bus_info, "EISA",	sizeof(info->bus_info));
-	info->eedump_len = TLAN_EEPROM_SIZE;
 }
 
 static int tlan_get_eeprom_len(struct net_device *dev)
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index d95f9aa..4684644 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1135,7 +1135,6 @@ static void axienet_ethtools_get_drvinfo(struct net_device *ndev,
 {
 	strlcpy(ed->driver, DRIVER_NAME, sizeof(ed->driver));
 	strlcpy(ed->version, DRIVER_VERSION, sizeof(ed->version));
-	ed->regdump_len = sizeof(u32) * AXIENET_REGS_N;
 }
 
 /**
diff --git a/drivers/net/fjes/fjes_ethtool.c b/drivers/net/fjes/fjes_ethtool.c
index 0119dd1..9c218e1 100644
--- a/drivers/net/fjes/fjes_ethtool.c
+++ b/drivers/net/fjes/fjes_ethtool.c
@@ -105,8 +105,6 @@ static void fjes_get_drvinfo(struct net_device *netdev,
 	strlcpy(drvinfo->fw_version, "none", sizeof(drvinfo->fw_version));
 	snprintf(drvinfo->bus_info, sizeof(drvinfo->bus_info),
 		 "platform:%s", plat_dev->name);
-	drvinfo->regdump_len = 0;
-	drvinfo->eedump_len = 0;
 }
 
 static int fjes_get_settings(struct net_device *netdev,
diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index a186b0a..bd9acff 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -588,7 +588,6 @@ void asix_get_drvinfo(struct net_device *net, struct ethtool_drvinfo *info)
 	usbnet_get_drvinfo(net, info);
 	strlcpy(info->driver, DRIVER_NAME, sizeof(info->driver));
 	strlcpy(info->version, DRIVER_VERSION, sizeof(info->version));
-	info->eedump_len = AX_EEPROM_LEN;
 }
 
 int asix_set_mac_address(struct net_device *net, void *p)
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 6e9c344..0b4bdd3 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -258,7 +258,6 @@ static void dm9601_get_drvinfo(struct net_device *net,
 {
 	/* Inherit standard device info */
 	usbnet_get_drvinfo(net, info);
-	info->eedump_len = DM_EEPROM_LEN;
 }
 
 static u32 dm9601_get_link(struct net_device *net)
diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index 82d844a..4f345bd 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -445,7 +445,6 @@ static int mcs7830_get_regs_len(struct net_device *net)
 static void mcs7830_get_drvinfo(struct net_device *net, struct ethtool_drvinfo *drvinfo)
 {
 	usbnet_get_drvinfo(net, drvinfo);
-	drvinfo->regdump_len = mcs7830_get_regs_len(net);
 }
 
 static void mcs7830_get_regs(struct net_device *net, struct ethtool_regs *regs, void *data)
diff --git a/drivers/net/usb/sr9800.c b/drivers/net/usb/sr9800.c
index 953de13..3a78b5f 100644
--- a/drivers/net/usb/sr9800.c
+++ b/drivers/net/usb/sr9800.c
@@ -477,7 +477,6 @@ static void sr_get_drvinfo(struct net_device *net,
 	usbnet_get_drvinfo(net, info);
 	strncpy(info->driver, DRIVER_NAME, sizeof(info->driver));
 	strncpy(info->version, DRIVER_VERSION, sizeof(info->version));
-	info->eedump_len = data->eeprom_len;
 }
 
 static u32 sr_get_link(struct net_device *net)
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index a681569..9ba11d7 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -214,10 +214,6 @@ vmxnet3_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
 
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
-	drvinfo->n_stats = vmxnet3_get_sset_count(netdev, ETH_SS_STATS);
-	drvinfo->testinfo_len = 0;
-	drvinfo->eedump_len   = 0;
-	drvinfo->regdump_len  = vmxnet3_get_regs_len(netdev);
 }
 
 
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 39f3e6f..ed0adaf 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -10470,7 +10470,6 @@ static void ipw_ethtool_get_drvinfo(struct net_device *dev,
 		 vers, date);
 	strlcpy(info->bus_info, pci_name(p->pci_dev),
 		sizeof(info->bus_info));
-	info->eedump_len = IPW_EEPROM_IMAGE_SIZE;
 }
 
 static u32 ipw_ethtool_get_link(struct net_device *dev)
-- 
2.4.9

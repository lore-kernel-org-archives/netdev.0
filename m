From: raj@tardy.cup.hp.com (Rick Jones)
Subject: [PATCH net-next] Sweep away N/A fw_version
	dustbunnies from the .get_drvinfo routine of a number of drivers
Date: Mon, 21 Nov 2011 12:54:05 -0800 (PST)
Message-ID: <20111121205405.A0FF1290041F@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, "Jay Cliburn" <jcliburn@gmail.com>,
	"Chris Snook" <chris.snook@gmail.com>, "Divy Le Ray" <divy@chelsio.com>,
	"Dimitris Michailidis" <dm@chelsio.com>,
	<e1000-
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>

Per discussion with Ben Hutchings and David Miller, go through and
remove assignments of "N/A" to fw_version in various drivers'
.get_drvinfo routines.  While there clean-up some use of bare
constants and such.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

Compiled only.



 drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c |    1 -
 drivers/net/ethernet/atheros/atlx/atl1.c           |    1 -
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c          |    1 -
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c    |    5 +----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |    4 +---
 drivers/net/ethernet/intel/e100.c                  |    1 -
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c   |    1 -
 drivers/net/ethernet/intel/igbvf/ethtool.c         |    2 --
 drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c     |    1 -
 drivers/net/ethernet/intel/ixgbevf/ethtool.c       |   10 +++++-----
 drivers/net/ethernet/marvell/skge.c                |    1 -
 drivers/net/ethernet/marvell/sky2.c                |    1 -
 .../ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c    |    1 -
 drivers/net/ethernet/qlogic/qla3xxx.c              |    1 -
 drivers/net/tun.c                                  |    1 -
 drivers/net/veth.c                                 |    1 -
 drivers/net/vmxnet3/vmxnet3_ethtool.c              |    5 -----
 17 files changed, 7 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c b/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
index 7be884d..0a9326a 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
@@ -232,7 +232,6 @@ static void atl1c_get_drvinfo(struct net_device *netdev,
 	strlcpy(drvinfo->driver,  atl1c_driver_name, sizeof(drvinfo->driver));
 	strlcpy(drvinfo->version, atl1c_driver_version,
 		sizeof(drvinfo->version));
-	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
 	drvinfo->n_stats = 0;
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 33a4e35..9bd2049 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -3365,7 +3365,6 @@ static void atl1_get_drvinfo(struct net_device *netdev,
 	strlcpy(drvinfo->driver, ATLX_DRIVER_NAME, sizeof(drvinfo->driver));
 	strlcpy(drvinfo->version, ATLX_DRIVER_VERSION,
 		sizeof(drvinfo->version));
-	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
 	drvinfo->eedump_len = ATL1_EEDUMP_LEN;
diff --git a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
index a971796..1d17c92 100644
--- a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
+++ b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
@@ -436,7 +436,6 @@ static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 
 	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
-	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
 	strlcpy(info->bus_info, pci_name(adapter->pdev),
 		sizeof(info->bus_info));
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index 63ffaa7..857cc25 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -1580,9 +1580,7 @@ static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 	strlcpy(info->bus_info, pci_name(adapter->pdev),
 		sizeof(info->bus_info));
-	if (!fw_vers)
-		strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
-	else {
+	if (fw_vers)
 		snprintf(info->fw_version, sizeof(info->fw_version),
 			 "%s %u.%u.%u TP %u.%u.%u",
 			 G_FW_VERSION_TYPE(fw_vers) ? "T" : "N",
@@ -1592,7 +1590,6 @@ static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 			 G_TP_VERSION_MAJOR(tp_vers),
 			 G_TP_VERSION_MINOR(tp_vers),
 			 G_TP_VERSION_MICRO(tp_vers));
-	}
 }
 
 static void get_strings(struct net_device *dev, u32 stringset, u8 * data)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index fd6d460..a34e7ce 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1007,9 +1007,7 @@ static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 	strlcpy(info->bus_info, pci_name(adapter->pdev),
 		sizeof(info->bus_info));
 
-	if (!adapter->params.fw_vers)
-		strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
-	else
+	if (adapter->params.fw_vers)
 		snprintf(info->fw_version, sizeof(info->fw_version),
 			"%u.%u.%u.%u, TP %u.%u.%u.%u",
 			FW_HDR_FW_VER_MAJOR_GET(adapter->params.fw_vers),
diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 4600327..9436397 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2378,7 +2378,6 @@ static void e100_get_drvinfo(struct net_device *netdev,
 	struct nic *nic = netdev_priv(netdev);
 	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
-	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
 	strlcpy(info->bus_info, pci_name(nic->pdev),
 		sizeof(info->bus_info));
 }
diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index 63faec6..3103f0b 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -521,7 +521,6 @@ static void e1000_get_drvinfo(struct net_device *netdev,
 	strlcpy(drvinfo->version, e1000_driver_version,
 		sizeof(drvinfo->version));
 
-	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
 	drvinfo->regdump_len = e1000_get_regs_len(netdev);
diff --git a/drivers/net/ethernet/intel/igbvf/ethtool.c b/drivers/net/ethernet/intel/igbvf/ethtool.c
index e60f1c6..7b600a1 100644
--- a/drivers/net/ethernet/intel/igbvf/ethtool.c
+++ b/drivers/net/ethernet/intel/igbvf/ethtool.c
@@ -195,8 +195,6 @@ static void igbvf_get_drvinfo(struct net_device *netdev,
 	strlcpy(drvinfo->driver,  igbvf_driver_name, sizeof(drvinfo->driver));
 	strlcpy(drvinfo->version, igbvf_driver_version,
 		sizeof(drvinfo->version));
-	strlcpy(drvinfo->fw_version, "N/A",
-		sizeof(drvinfo->fw_version));
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
 	drvinfo->regdump_len = igbvf_get_regs_len(netdev);
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c b/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
index 96fcb0e..dbb7dd2 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
@@ -477,7 +477,6 @@ ixgb_get_drvinfo(struct net_device *netdev,
 		sizeof(drvinfo->driver));
 	strlcpy(drvinfo->version, ixgb_driver_version,
 		sizeof(drvinfo->version));
-	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
 	drvinfo->n_stats = IXGB_STATS_LEN;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index 149fa52..dc8e651 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -267,11 +267,11 @@ static void ixgbevf_get_drvinfo(struct net_device *netdev,
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 
-	strlcpy(drvinfo->driver, ixgbevf_driver_name, 32);
-	strlcpy(drvinfo->version, ixgbevf_driver_version, 32);
-
-	strlcpy(drvinfo->fw_version, "N/A", 4);
-	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
+	strlcpy(drvinfo->driver, ixgbevf_driver_name, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, ixgbevf_driver_version,
+		sizeof(drvinfo->version));
+	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
+		sizeof(drvinfo->bus_info));
 }
 
 static void ixgbevf_get_ringparam(struct net_device *netdev,
diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 3943f5f..d957b2c 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -396,7 +396,6 @@ static void skge_get_drvinfo(struct net_device *dev,
 
 	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
-	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
 	strlcpy(info->bus_info, pci_name(skge->hw->pdev),
 		sizeof(info->bus_info));
 }
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 7db6e36..e3856b2 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -3625,7 +3625,6 @@ static void sky2_get_drvinfo(struct net_device *dev,
 
 	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
-	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
 	strlcpy(info->bus_info, pci_name(sky2->hw->pdev),
 		sizeof(info->bus_info));
 }
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
index 0063194..ac4e72d 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
@@ -163,7 +163,6 @@ static void pch_gbe_get_drvinfo(struct net_device *netdev,
 
 	strlcpy(drvinfo->driver, KBUILD_MODNAME, sizeof(drvinfo->driver));
 	strlcpy(drvinfo->version, pch_driver_version, sizeof(drvinfo->version));
-	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
 	drvinfo->regdump_len = pch_gbe_get_regs_len(netdev);
diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index 9416f29..7931531 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -1738,7 +1738,6 @@ static void ql_get_drvinfo(struct net_device *ndev,
 	strlcpy(drvinfo->driver, ql3xxx_driver_name, sizeof(drvinfo->driver));
 	strlcpy(drvinfo->version, ql3xxx_driver_version,
 		sizeof(drvinfo->version));
-	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
 	strlcpy(drvinfo->bus_info, pci_name(qdev->pdev),
 		sizeof(drvinfo->bus_info));
 	drvinfo->regdump_len = 0;
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 3dd13d6..93c5d72 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1592,7 +1592,6 @@ static void tun_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info
 
 	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
-	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
 
 	switch (tun->flags & TUN_TYPE_MASK) {
 	case TUN_TUN_DEV:
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index b576812..49f4667 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -68,7 +68,6 @@ static void veth_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *inf
 {
 	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
-	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
 }
 
 static void veth_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index 77f7234..b492ee1 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -202,14 +202,9 @@ vmxnet3_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
 
 	strlcpy(drvinfo->driver, vmxnet3_driver_name, sizeof(drvinfo->driver));
-	drvinfo->driver[sizeof(drvinfo->driver) - 1] = '\0';
 
 	strlcpy(drvinfo->version, VMXNET3_DRIVER_VERSION_REPORT,
 		sizeof(drvinfo->version));
-	drvinfo->driver[sizeof(drvinfo->version) - 1] = '\0';
-
-	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
-	drvinfo->fw_version[sizeof(drvinfo->fw_version) - 1] = '\0';
 
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		ETHTOOL_BUSINFO_LEN);

------------------------------------------------------------------------------
All the data continuously generated in your IT infrastructure 
contains a definitive record of customers, application performance, 
security threats, fraudulent activity, and more. Splunk takes this 
data and makes sense of it. IT sense. And common sense.
http://p.sf.net/sfu/splunk-novd2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

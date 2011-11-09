From: raj@tardy.cup.hp.com (Rick Jones)
Subject: [PATCH net-next] Sweep additional floors of strcpy in .get_drvinfo routines
Date: Wed,  9 Nov 2011 11:58:07 -0800 (PST)
Message-ID: <20111109195807.440D229004BE@tardy>
To: <netdev@vger.kernel.org>, "Don Fry" <pcnet32@frontier.com>,
	"Divy Le Ray" <divy@chelsio.com>,
	"Dimitris Michailidis" <dm@chelsio.com>,
	"Casey Leedom" <leedom@chelsio.com>,
	<e1000-dev
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:20219 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756565Ab1KIT6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 14:58:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>

Perform another round of floor sweeping, converting the .get_drvinfo
routines of additional drivers from strcpy to strlcpy along with
some conversion of sprintf to snprintf.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

Compile tested only.

 drivers/net/ethernet/amd/amd8111e.c                |    9 +++++----
 drivers/net/ethernet/amd/pcnet32.c                 |   10 ++++++----
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c          |    9 +++++----
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c    |    9 +++++----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |    9 +++++----
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    7 ++++---
 drivers/net/ethernet/intel/e100.c                  |    9 +++++----
 drivers/net/ethernet/jme.c                         |    6 +++---
 drivers/net/ethernet/micrel/ksz884x.c              |    7 ++++---
 .../ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c    |    9 +++++----
 drivers/net/ethernet/sis/sis190.c                  |    7 ++++---
 drivers/net/ethernet/sis/sis900.c                  |    7 ++++---
 drivers/net/ethernet/sun/niu.c                     |    9 +++++----
 drivers/net/ethernet/sun/sungem.c                  |    6 +++---
 drivers/net/ethernet/sun/sunhme.c                  |    9 +++++----
 drivers/net/ethernet/via/via-rhine.c               |    6 +++---
 drivers/net/ethernet/via/via-velocity.c            |    6 +++---
 17 files changed, 74 insertions(+), 60 deletions(-)

diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index a9745f4..a388118 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -1412,10 +1412,11 @@ static void amd8111e_get_drvinfo(struct net_device* dev, struct ethtool_drvinfo
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	struct pci_dev *pci_dev = lp->pci_dev;
-	strcpy (info->driver, MODULE_NAME);
-	strcpy (info->version, MODULE_VERS);
-	sprintf(info->fw_version,"%u",chip_version);
-	strcpy (info->bus_info, pci_name(pci_dev));
+	strlcpy(info->driver, MODULE_NAME, sizeof(info->driver));
+	strlcpy(info->version, MODULE_VERS, sizeof(info->version));
+	snprintf(info->fw_version, sizeof(info->fw_version),
+		"%u", chip_version);
+	strlcpy(info->bus_info, pci_name(pci_dev), sizeof(info->bus_info));
 }
 
 static int amd8111e_get_regs_len(struct net_device *dev)
diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index f92bc6e..20e6dab 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -711,12 +711,14 @@ static void pcnet32_get_drvinfo(struct net_device *dev,
 {
 	struct pcnet32_private *lp = netdev_priv(dev);
 
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 	if (lp->pci_dev)
-		strcpy(info->bus_info, pci_name(lp->pci_dev));
+		strlcpy(info->bus_info, pci_name(lp->pci_dev),
+			sizeof(info->bus_info));
 	else
-		sprintf(info->bus_info, "VLB 0x%lx", dev->base_addr);
+		snprintf(info->bus_info, sizeof(info->bus_info),
+			"VLB 0x%lx", dev->base_addr);
 }
 
 static u32 pcnet32_get_link(struct net_device *dev)
diff --git a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
index ca26d97..26d0fd2 100644
--- a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
+++ b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
@@ -434,10 +434,11 @@ static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	struct adapter *adapter = dev->ml_priv;
 
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	strcpy(info->fw_version, "N/A");
-	strcpy(info->bus_info, pci_name(adapter->pdev));
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
+	strlcpy(info->bus_info, pci_name(adapter->pdev),
+		sizeof(info->bus_info));
 }
 
 static int get_sset_count(struct net_device *dev, int sset)
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index 4d15c8f..053560d 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -1576,11 +1576,12 @@ static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 	t3_get_tp_version(adapter, &tp_vers);
 	spin_unlock(&adapter->stats_lock);
 
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	strcpy(info->bus_info, pci_name(adapter->pdev));
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(adapter->pdev),
+		sizeof(info->bus_info));
 	if (!fw_vers)
-		strcpy(info->fw_version, "N/A");
+		strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
 	else {
 		snprintf(info->fw_version, sizeof(info->fw_version),
 			 "%s %u.%u.%u TP %u.%u.%u",
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 4c8f42a..48ffe11 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1002,12 +1002,13 @@ static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	struct adapter *adapter = netdev2adap(dev);
 
-	strcpy(info->driver, KBUILD_MODNAME);
-	strcpy(info->version, DRV_VERSION);
-	strcpy(info->bus_info, pci_name(adapter->pdev));
+	strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(adapter->pdev),
+		sizeof(info->bus_info));
 
 	if (!adapter->params.fw_vers)
-		strcpy(info->fw_version, "N/A");
+		strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
 	else
 		snprintf(info->fw_version, sizeof(info->fw_version),
 			"%u.%u.%u.%u, TP %u.%u.%u.%u",
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index da9072b..ee81d8e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -1203,9 +1203,10 @@ static void cxgb4vf_get_drvinfo(struct net_device *dev,
 {
 	struct adapter *adapter = netdev2adap(dev);
 
-	strcpy(drvinfo->driver, KBUILD_MODNAME);
-	strcpy(drvinfo->version, DRV_VERSION);
-	strcpy(drvinfo->bus_info, pci_name(to_pci_dev(dev->dev.parent)));
+	strlcpy(drvinfo->driver, KBUILD_MODNAME, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, DRV_VERSION, sizeof(drvinfo->version));
+	strlcpy(drvinfo->bus_info, pci_name(to_pci_dev(dev->dev.parent)),
+		sizeof(drvinfo->bus_info));
 	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
 		 "%u.%u.%u.%u, TP %u.%u.%u.%u",
 		 FW_HDR_FW_VER_MAJOR_GET(adapter->params.dev.fwrev),
diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 5a2fdf7..4600327 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2376,10 +2376,11 @@ static void e100_get_drvinfo(struct net_device *netdev,
 	struct ethtool_drvinfo *info)
 {
 	struct nic *nic = netdev_priv(netdev);
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	strcpy(info->fw_version, "N/A");
-	strcpy(info->bus_info, pci_name(nic->pdev));
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
+	strlcpy(info->bus_info, pci_name(nic->pdev),
+		sizeof(info->bus_info));
 }
 
 #define E100_PHY_REGS 0x1C
diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 7becff1..7d88c7c 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -2292,9 +2292,9 @@ jme_get_drvinfo(struct net_device *netdev,
 {
 	struct jme_adapter *jme = netdev_priv(netdev);
 
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	strcpy(info->bus_info, pci_name(jme->pdev));
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(jme->pdev), sizeof(info->bus_info));
 }
 
 static int
diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index 7ece990..3b67fe6 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -6093,9 +6093,10 @@ static void netdev_get_drvinfo(struct net_device *dev,
 	struct dev_priv *priv = netdev_priv(dev);
 	struct dev_info *hw_priv = priv->adapter;
 
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	strcpy(info->bus_info, pci_name(hw_priv->pdev));
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(hw_priv->pdev),
+		sizeof(info->bus_info));
 }
 
 /**
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
index 8c80271..0063194 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
@@ -161,10 +161,11 @@ static void pch_gbe_get_drvinfo(struct net_device *netdev,
 {
 	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
 
-	strcpy(drvinfo->driver, KBUILD_MODNAME);
-	strcpy(drvinfo->version, pch_driver_version);
-	strcpy(drvinfo->fw_version, "N/A");
-	strcpy(drvinfo->bus_info, pci_name(adapter->pdev));
+	strlcpy(drvinfo->driver, KBUILD_MODNAME, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, pch_driver_version, sizeof(drvinfo->version));
+	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
+	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
+		sizeof(drvinfo->bus_info));
 	drvinfo->regdump_len = pch_gbe_get_regs_len(netdev);
 }
 
diff --git a/drivers/net/ethernet/sis/sis190.c b/drivers/net/ethernet/sis/sis190.c
index 1b4658c..220e982 100644
--- a/drivers/net/ethernet/sis/sis190.c
+++ b/drivers/net/ethernet/sis/sis190.c
@@ -1760,9 +1760,10 @@ static void sis190_get_drvinfo(struct net_device *dev,
 {
 	struct sis190_private *tp = netdev_priv(dev);
 
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	strcpy(info->bus_info, pci_name(tp->pci_dev));
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(tp->pci_dev),
+		sizeof(info->bus_info));
 }
 
 static int sis190_get_regs_len(struct net_device *dev)
diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index a184abc..c8efc70 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -1991,9 +1991,10 @@ static void sis900_get_drvinfo(struct net_device *net_dev,
 {
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
 
-	strcpy (info->driver, SIS900_MODULE_NAME);
-	strcpy (info->version, SIS900_DRV_VERSION);
-	strcpy (info->bus_info, pci_name(sis_priv->pci_dev));
+	strlcpy(info->driver, SIS900_MODULE_NAME, sizeof(info->driver));
+	strlcpy(info->version, SIS900_DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(sis_priv->pci_dev),
+		sizeof(info->bus_info));
 }
 
 static u32 sis900_get_msglevel(struct net_device *net_dev)
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 73c7081..3ebeb9d 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -6823,12 +6823,13 @@ static void niu_get_drvinfo(struct net_device *dev,
 	struct niu *np = netdev_priv(dev);
 	struct niu_vpd *vpd = &np->vpd;
 
-	strcpy(info->driver, DRV_MODULE_NAME);
-	strcpy(info->version, DRV_MODULE_VERSION);
-	sprintf(info->fw_version, "%d.%d",
+	strlcpy(info->driver, DRV_MODULE_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_MODULE_VERSION, sizeof(info->version));
+	snprintf(info->fw_version, sizeof(info->fw_version), "%d.%d",
 		vpd->fcode_major, vpd->fcode_minor);
 	if (np->parent->plat_type != PLAT_TYPE_NIU)
-		strcpy(info->bus_info, pci_name(np->pdev));
+		strlcpy(info->bus_info, pci_name(np->pdev),
+			sizeof(info->bus_info));
 }
 
 static int niu_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index ceab215..31441a8 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -2517,9 +2517,9 @@ static void gem_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info
 {
 	struct gem *gp = netdev_priv(dev);
 
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	strcpy(info->bus_info, pci_name(gp->pdev));
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(gp->pdev), sizeof(info->bus_info));
 }
 
 static int gem_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index cf14ab9..eebd52f 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -2457,11 +2457,11 @@ static void hme_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info
 {
 	struct happy_meal *hp = netdev_priv(dev);
 
-	strcpy(info->driver, "sunhme");
-	strcpy(info->version, "2.02");
+	strlcpy(info->driver, "sunhme", sizeof(info->driver));
+	strlcpy(info->version, "2.02", sizeof(info->version));
 	if (hp->happy_flags & HFLAG_PCI) {
 		struct pci_dev *pdev = hp->happy_dev;
-		strcpy(info->bus_info, pci_name(pdev));
+		strlcpy(info->bus_info, pci_name(pdev), sizeof(info->bus_info));
 	}
 #ifdef CONFIG_SBUS
 	else {
@@ -2469,7 +2469,8 @@ static void hme_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info
 		struct platform_device *op = hp->happy_dev;
 		regs = of_get_property(op->dev.of_node, "regs", NULL);
 		if (regs)
-			sprintf(info->bus_info, "SBUS:%d",
+			snprintf(info->bus_info, sizeof(info->bus_info),
+				"SBUS:%d",
 				regs->which_io);
 	}
 #endif
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index f34dd99..5587ecd 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -2009,9 +2009,9 @@ static void netdev_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *i
 {
 	struct rhine_private *rp = netdev_priv(dev);
 
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	strcpy(info->bus_info, pci_name(rp->pdev));
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(rp->pdev), sizeof(info->bus_info));
 }
 
 static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index 4535d7c..59bb5fd 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -3270,9 +3270,9 @@ static int velocity_set_settings(struct net_device *dev,
 static void velocity_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
-	strcpy(info->driver, VELOCITY_NAME);
-	strcpy(info->version, VELOCITY_VERSION);
-	strcpy(info->bus_info, pci_name(vptr->pdev));
+	strlcpy(info->driver, VELOCITY_NAME, sizeof(info->driver));
+	strlcpy(info->version, VELOCITY_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(vptr->pdev), sizeof(info->bus_info));
 }
 
 static void velocity_ethtool_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)

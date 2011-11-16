From: raj@tardy.cup.hp.com (Rick Jones)
Subject: [PATCH net-next] sweep-up some straglers in strlcpy conversion of .get_drvinfo routines
Date: Tue, 15 Nov 2011 16:59:53 -0800 (PST)
Message-ID: <20111116005953.E05A42900404@tardy>
To: <netdev@vger.kernel.org>, "Nicolas Pitre" <nico@fluxnic.net>,
	"Giuseppe Cavallaro" <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0187.atlanta.hp.com ([15.193.32.64]:46860 "EHLO
	g6t0187.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756943Ab1KPBKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 20:10:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>

Convert some remaining straglers' .get_drvinfo routines to use strlcpy
rather than strcpy/strncpy.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

Compile tested only.  This leaves drivers/net/wireless (there was a patch
sent to linux-wireless) and drivers/net/usb, along with anything that 
does not get compiled for an amd_64 flavor kernel.

 drivers/net/ethernet/amd/nmclan_cs.c               |    7 ++++---
 drivers/net/ethernet/fujitsu/fmvj18x_cs.c          |    7 ++++---
 drivers/net/ethernet/intel/e1000e/ethtool.c        |    2 +-
 drivers/net/ethernet/smsc/smc91c92_cs.c            |    4 ++--
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    5 +++--
 drivers/net/tun.c                                  |   10 +++++-----
 drivers/net/veth.c                                 |    6 +++---

diff --git a/drivers/net/ethernet/amd/nmclan_cs.c b/drivers/net/ethernet/amd/nmclan_cs.c
index 3accd5d..3d7be5a 100644
--- a/drivers/net/ethernet/amd/nmclan_cs.c
+++ b/drivers/net/ethernet/amd/nmclan_cs.c
@@ -822,9 +822,10 @@ static int mace_close(struct net_device *dev)
 static void netdev_get_drvinfo(struct net_device *dev,
 			       struct ethtool_drvinfo *info)
 {
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	sprintf(info->bus_info, "PCMCIA 0x%lx", dev->base_addr);
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	snprintf(info->bus_info, sizeof(info->bus_info),
+		"PCMCIA 0x%lx", dev->base_addr);
 }
 
 static const struct ethtool_ops netdev_ethtool_ops = {
diff --git a/drivers/net/ethernet/fujitsu/fmvj18x_cs.c b/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
index 1541675..ee84b47 100644
--- a/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
+++ b/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
@@ -1058,9 +1058,10 @@ static void fjn_rx(struct net_device *dev)
 static void netdev_get_drvinfo(struct net_device *dev,
 			       struct ethtool_drvinfo *info)
 {
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	sprintf(info->bus_info, "PCMCIA 0x%lx", dev->base_addr);
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	snprintf(info->bus_info, sizeof(info->bus_info),
+		"PCMCIA 0x%lx", dev->base_addr);
 }
 
 static const struct ethtool_ops netdev_ethtool_ops = {
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 6d8f0ed..fb2c28e 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -582,7 +582,7 @@ static void e1000_get_drvinfo(struct net_device *netdev,
 
 	strlcpy(drvinfo->driver,  e1000e_driver_name,
 		sizeof(drvinfo->driver));
-	strncpy(drvinfo->version, e1000e_driver_version,
+	strlcpy(drvinfo->version, e1000e_driver_version,
 		sizeof(drvinfo->version));
 
 	/*
diff --git a/drivers/net/ethernet/smsc/smc91c92_cs.c b/drivers/net/ethernet/smsc/smc91c92_cs.c
index cbfa981..ada927a 100644
--- a/drivers/net/ethernet/smsc/smc91c92_cs.c
+++ b/drivers/net/ethernet/smsc/smc91c92_cs.c
@@ -1909,8 +1909,8 @@ static int check_if_running(struct net_device *dev)
 
 static void smc_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 }
 
 static int smc_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index e8eff09..c18ca59 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -185,9 +185,10 @@ static void stmmac_ethtool_getdrvinfo(struct net_device *dev,
 	struct stmmac_priv *priv = netdev_priv(dev);
 
 	if (priv->plat->has_gmac)
-		strcpy(info->driver, GMAC_ETHTOOL_NAME);
+		strlcpy(info->driver, GMAC_ETHTOOL_NAME, sizeof(info->driver));
 	else
-		strcpy(info->driver, MAC100_ETHTOOL_NAME);
+		strlcpy(info->driver, MAC100_ETHTOOL_NAME,
+			sizeof(info->driver));
 
 	strcpy(info->version, DRV_MODULE_VERSION);
 	info->fw_version[0] = '\0';
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 7bea9c6..8592523 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1589,16 +1589,16 @@ static void tun_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info
 {
 	struct tun_struct *tun = netdev_priv(dev);
 
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	strcpy(info->fw_version, "N/A");
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
 
 	switch (tun->flags & TUN_TYPE_MASK) {
 	case TUN_TUN_DEV:
-		strcpy(info->bus_info, "tun");
+		strlcpy(info->bus_info, "tun", sizeof(info->bus_info));
 		break;
 	case TUN_TAP_DEV:
-		strcpy(info->bus_info, "tap");
+		strlcpy(info->bus_info, "tap", sizeof(info->bus_info));
 		break;
 	}
 }
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 726c790..d32a75f 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -66,9 +66,9 @@ static int veth_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static void veth_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	strcpy(info->fw_version, "N/A");
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
 }
 
 static void veth_get_strings(struct net_device *dev, u32 stringset, u8 *buf)

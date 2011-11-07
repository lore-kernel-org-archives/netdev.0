From: raj@tardy.cup.hp.com (Rick Jones)
Subject: [PATCH net-next] sweep the floors and convert some .get_drvinfo routines to strlcpy
Date: Mon,  7 Nov 2011 13:56:49 -0800 (PST)
Message-ID: <20111107215649.95F372900440@tardy>
To: <netdev@vger.kernel.org>, "David Dillow" <dave@thedillows.org>,
	"Steffen Klassert" <klassert@mathematik.tu-chemnitz.de>,
	"Ion Badulescu" <ionut@badula.org>,
	"Jay Cliburn" <jcliburn@gm
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:45457 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752544Ab1KGV46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 16:56:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>

Per the mention made by Ben Hutchings that strlcpy is now the preferred
string copy routine for a .get_drvinfo routine, do a bit of floor
sweeping and convert some of the as-yet unconverted ethernet drivers to
it.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

Compile tested only

 drivers/net/ethernet/3com/3c589_cs.c               |    7 ++++---
 drivers/net/ethernet/3com/3c59x.c                  |   12 +++++++-----
 drivers/net/ethernet/3com/typhoon.c                |   16 +++++++++-------
 drivers/net/ethernet/8390/ne2k-pci.c               |    6 +++---
 drivers/net/ethernet/adaptec/starfire.c            |    6 +++---
 drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c |   10 ++++++----
 drivers/net/ethernet/atheros/atlx/atl2.c           |   10 ++++++----
 drivers/net/ethernet/broadcom/bnx2.c               |    8 ++++----
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    8 ++++----
 drivers/net/ethernet/broadcom/tg3.c                |    8 ++++----
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c    |   11 ++++++-----
 drivers/net/ethernet/dec/tulip/de2104x.c           |    6 +++---
 drivers/net/ethernet/dec/tulip/dmfe.c              |    7 ++++---
 drivers/net/ethernet/dec/tulip/tulip_core.c        |    6 +++---
 drivers/net/ethernet/dec/tulip/uli526x.c           |    7 ++++---
 drivers/net/ethernet/dec/tulip/winbond-840.c       |    6 +++---
 drivers/net/ethernet/dlink/sundance.c              |    6 +++---
 drivers/net/ethernet/dnet.c                        |    6 +++---
 drivers/net/ethernet/emulex/benet/be_ethtool.c     |    7 ++++---
 drivers/net/ethernet/fealnx.c                      |    6 +++---
 drivers/net/ethernet/i825xx/eepro.c                |    7 ++++---
 drivers/net/ethernet/marvell/mv643xx_eth.c         |    9 +++++----
 drivers/net/ethernet/marvell/skge.c                |    9 +++++----
 drivers/net/ethernet/marvell/sky2.c                |    9 +++++----
 drivers/net/ethernet/natsemi/natsemi.c             |    6 +++---
 drivers/net/ethernet/natsemi/ns83820.c             |    6 +++---
 drivers/net/ethernet/neterion/s2io.c               |    8 ++++----
 drivers/net/ethernet/nvidia/forcedeth.c            |    6 +++---
 .../ethernet/qlogic/netxen/netxen_nic_ethtool.c    |   12 ++++++++----
 drivers/net/ethernet/qlogic/qla3xxx.c              |   10 ++++++----
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   13 ++++++++-----
 drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c    |   11 +++++++----
 drivers/net/ethernet/realtek/8139cp.c              |    6 +++---
 drivers/net/ethernet/realtek/8139too.c             |    6 +++---
 drivers/net/ethernet/realtek/r8169.c               |   10 +++++-----
 drivers/net/ethernet/smsc/epic100.c                |    6 +++---
 drivers/net/ethernet/smsc/smsc9420.c               |    7 ++++---
 drivers/net/ethernet/xircom/xirc2ps_cs.c           |    2 +-
 38 files changed, 166 insertions(+), 136 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c589_cs.c b/drivers/net/ethernet/3com/3c589_cs.c
index 972f80e..5e91602 100644
--- a/drivers/net/ethernet/3com/3c589_cs.c
+++ b/drivers/net/ethernet/3com/3c589_cs.c
@@ -468,9 +468,10 @@ static void tc589_reset(struct net_device *dev)
 static void netdev_get_drvinfo(struct net_device *dev,
 			       struct ethtool_drvinfo *info)
 {
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	sprintf(info->bus_info, "PCMCIA 0x%lx", dev->base_addr);
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	snprintf(info->bus_info, sizeof(info->bus_info) - 1,
+		"PCMCIA 0x%lx", dev->base_addr);
 }
 
 static const struct ethtool_ops netdev_ethtool_ops = {
diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index b42c06b..b480a4bb 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -2929,15 +2929,17 @@ static void vortex_get_drvinfo(struct net_device *dev,
 {
 	struct vortex_private *vp = netdev_priv(dev);
 
-	strcpy(info->driver, DRV_NAME);
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
 	if (VORTEX_PCI(vp)) {
-		strcpy(info->bus_info, pci_name(VORTEX_PCI(vp)));
+		strlcpy(info->bus_info, pci_name(VORTEX_PCI(vp)),
+			sizeof(info->bus_info));
 	} else {
 		if (VORTEX_EISA(vp))
-			strcpy(info->bus_info, dev_name(vp->gendev));
+			strlcpy(info->bus_info, dev_name(vp->gendev),
+				sizeof(info->bus_info));
 		else
-			sprintf(info->bus_info, "EISA 0x%lx %d",
-					dev->base_addr, dev->irq);
+			snprintf(info->bus_info, sizeof(info->bus_info) - 1,
+				"EISA 0x%lx %d", dev->base_addr, dev->irq);
 	}
 }
 
diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index 20ea075..d87e992 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -988,21 +988,23 @@ typhoon_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 
 	smp_rmb();
 	if(tp->card_state == Sleeping) {
-		strcpy(info->fw_version, "Sleep image");
+		strlcpy(info->fw_version, "Sleep image",
+			sizeof(info->fw_version));
 	} else {
 		INIT_COMMAND_WITH_RESPONSE(&xp_cmd, TYPHOON_CMD_READ_VERSIONS);
 		if(typhoon_issue_command(tp, 1, &xp_cmd, 3, xp_resp) < 0) {
-			strcpy(info->fw_version, "Unknown runtime");
+			strlcpy(info->fw_version, "Unknown runtime",
+				sizeof(info->fw_version));
 		} else {
 			u32 sleep_ver = le32_to_cpu(xp_resp[0].parm2);
-			snprintf(info->fw_version, 32, "%02x.%03x.%03x",
-				 sleep_ver >> 24, (sleep_ver >> 12) & 0xfff,
-				 sleep_ver & 0xfff);
+			snprintf(info->fw_version, sizeof(info->fw_version) - 1,
+				"%02x.%03x.%03x", sleep_ver >> 24,
+				(sleep_ver >> 12) & 0xfff, sleep_ver & 0xfff);
 		}
 	}
 
-	strcpy(info->driver, KBUILD_MODNAME);
-	strcpy(info->bus_info, pci_name(pci_dev));
+	strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
+	strlcpy(info->bus_info, pci_name(pci_dev), sizeof(info->bus_info));
 }
 
 static int
diff --git a/drivers/net/ethernet/8390/ne2k-pci.c b/drivers/net/ethernet/8390/ne2k-pci.c
index 3992342..3fab04a 100644
--- a/drivers/net/ethernet/8390/ne2k-pci.c
+++ b/drivers/net/ethernet/8390/ne2k-pci.c
@@ -639,9 +639,9 @@ static void ne2k_pci_get_drvinfo(struct net_device *dev,
 	struct ei_device *ei = netdev_priv(dev);
 	struct pci_dev *pci_dev = (struct pci_dev *) ei->priv;
 
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	strcpy(info->bus_info, pci_name(pci_dev));
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(pci_dev), sizeof(info->bus_info));
 }
 
 static const struct ethtool_ops ne2k_pci_ethtool_ops = {
diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index 6d9f691..a446e25 100644
--- a/drivers/net/ethernet/adaptec/starfire.c
+++ b/drivers/net/ethernet/adaptec/starfire.c
@@ -1842,9 +1842,9 @@ static int check_if_running(struct net_device *dev)
 static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	struct netdev_private *np = netdev_priv(dev);
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	strcpy(info->bus_info, pci_name(np->pci_dev));
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(np->pci_dev), sizeof(info->bus_info));
 }
 
 static int get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c b/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c
index 6269438..6e61f9f 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c
@@ -310,10 +310,12 @@ static void atl1e_get_drvinfo(struct net_device *netdev,
 {
 	struct atl1e_adapter *adapter = netdev_priv(netdev);
 
-	strncpy(drvinfo->driver,  atl1e_driver_name, 32);
-	strncpy(drvinfo->version, atl1e_driver_version, 32);
-	strncpy(drvinfo->fw_version, "L1e", 32);
-	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
+	strlcpy(drvinfo->driver,  atl1e_driver_name, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, atl1e_driver_version,
+		sizeof(drvinfo->version));
+	strlcpy(drvinfo->fw_version, "L1e", sizeof(drvinfo->fw_version));
+	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
+		sizeof(drvinfo->bus_info));
 	drvinfo->n_stats = 0;
 	drvinfo->testinfo_len = 0;
 	drvinfo->regdump_len = atl1e_get_regs_len(netdev);
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index 1feae59..db3f430 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -2049,10 +2049,12 @@ static void atl2_get_drvinfo(struct net_device *netdev,
 {
 	struct atl2_adapter *adapter = netdev_priv(netdev);
 
-	strncpy(drvinfo->driver,  atl2_driver_name, 32);
-	strncpy(drvinfo->version, atl2_driver_version, 32);
-	strncpy(drvinfo->fw_version, "L2", 32);
-	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
+	strlcpy(drvinfo->driver,  atl2_driver_name, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, atl2_driver_version,
+		sizeof(drvinfo->version));
+	strlcpy(drvinfo->fw_version, "L2", sizeof(drvinfo->fw_version));
+	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
+		sizeof(drvinfo->bus_info));
 	drvinfo->n_stats = 0;
 	drvinfo->testinfo_len = 0;
 	drvinfo->regdump_len = atl2_get_regs_len(netdev);
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 965c723..32d1f92 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -6873,10 +6873,10 @@ bnx2_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	struct bnx2 *bp = netdev_priv(dev);
 
-	strcpy(info->driver, DRV_MODULE_NAME);
-	strcpy(info->version, DRV_MODULE_VERSION);
-	strcpy(info->bus_info, pci_name(bp->pdev));
-	strcpy(info->fw_version, bp->fw_version);
+	strlcpy(info->driver, DRV_MODULE_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_MODULE_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(bp->pdev), sizeof(info->bus_info));
+	strlcpy(info->fw_version, bp->fw_version, sizeof(info->fw_version));
 }
 
 #define BNX2_REGDUMP_LEN		(32 * 1024)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 1a6e37c..e5c4934 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -760,8 +760,8 @@ static void bnx2x_get_drvinfo(struct net_device *dev,
 	struct bnx2x *bp = netdev_priv(dev);
 	u8 phy_fw_ver[PHY_FW_VER_LEN];
 
-	strcpy(info->driver, DRV_MODULE_NAME);
-	strcpy(info->version, DRV_MODULE_VERSION);
+	strlcpy(info->driver, DRV_MODULE_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_MODULE_VERSION, sizeof(info->version));
 
 	phy_fw_ver[0] = '\0';
 	if (bp->port.pmf) {
@@ -772,14 +772,14 @@ static void bnx2x_get_drvinfo(struct net_device *dev,
 		bnx2x_release_phy_lock(bp);
 	}
 
-	strncpy(info->fw_version, bp->fw_ver, 32);
+	strlcpy(info->fw_version, bp->fw_ver, sizeof(info->fw_version));
 	snprintf(info->fw_version + strlen(bp->fw_ver), 32 - strlen(bp->fw_ver),
 		 "bc %d.%d.%d%s%s",
 		 (bp->common.bc_ver & 0xff0000) >> 16,
 		 (bp->common.bc_ver & 0xff00) >> 8,
 		 (bp->common.bc_ver & 0xff),
 		 ((phy_fw_ver[0] != '\0') ? " phy " : ""), phy_fw_ver);
-	strcpy(info->bus_info, pci_name(bp->pdev));
+	strlcpy(info->bus_info, pci_name(bp->pdev), sizeof(info->bus_info));
 	info->n_stats = BNX2X_NUM_STATS;
 	info->testinfo_len = BNX2X_NUM_TESTS;
 	info->eedump_len = bp->common.flash_size;
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 161cbbb..66ec183 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -10419,10 +10419,10 @@ static void tg3_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info
 {
 	struct tg3 *tp = netdev_priv(dev);
 
-	strcpy(info->driver, DRV_MODULE_NAME);
-	strcpy(info->version, DRV_MODULE_VERSION);
-	strcpy(info->fw_version, tp->fw_ver);
-	strcpy(info->bus_info, pci_name(tp->pdev));
+	strlcpy(info->driver, DRV_MODULE_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_MODULE_VERSION, sizeof(info->version));
+	strlcpy(info->fw_version, tp->fw_ver, sizeof(info->fw_version));
+	strlcpy(info->bus_info, pci_name(tp->pdev), sizeof(info->bus_info));
 }
 
 static void tg3_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
index fd3dcc1..38d5c66 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
@@ -296,8 +296,8 @@ bnad_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
 	struct bfa_ioc_attr *ioc_attr;
 	unsigned long flags;
 
-	strcpy(drvinfo->driver, BNAD_NAME);
-	strcpy(drvinfo->version, BNAD_VERSION);
+	strlcpy(drvinfo->driver, BNAD_NAME, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, BNAD_VERSION, sizeof(drvinfo->version));
 
 	ioc_attr = kzalloc(sizeof(*ioc_attr), GFP_KERNEL);
 	if (ioc_attr) {
@@ -305,12 +305,13 @@ bnad_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
 		bfa_nw_ioc_get_attr(&bnad->bna.ioceth.ioc, ioc_attr);
 		spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
-		strncpy(drvinfo->fw_version, ioc_attr->adapter_attr.fw_ver,
-			sizeof(drvinfo->fw_version) - 1);
+		strlcpy(drvinfo->fw_version, ioc_attr->adapter_attr.fw_ver,
+			sizeof(drvinfo->fw_version));
 		kfree(ioc_attr);
 	}
 
-	strncpy(drvinfo->bus_info, pci_name(bnad->pcidev), ETHTOOL_BUSINFO_LEN);
+	strlcpy(drvinfo->bus_info, pci_name(bnad->pcidev),
+		sizeof(drvinfo->bus_info));
 }
 
 static void
diff --git a/drivers/net/ethernet/dec/tulip/de2104x.c b/drivers/net/ethernet/dec/tulip/de2104x.c
index 1427739..1eb46a0 100644
--- a/drivers/net/ethernet/dec/tulip/de2104x.c
+++ b/drivers/net/ethernet/dec/tulip/de2104x.c
@@ -1598,9 +1598,9 @@ static void de_get_drvinfo (struct net_device *dev,struct ethtool_drvinfo *info)
 {
 	struct de_private *de = netdev_priv(dev);
 
-	strcpy (info->driver, DRV_NAME);
-	strcpy (info->version, DRV_VERSION);
-	strcpy (info->bus_info, pci_name(de->pdev));
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(de->pdev), sizeof(info->bus_info));
 	info->eedump_len = DE_EEPROM_SIZE;
 }
 
diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
index 17b11ee..51f7542 100644
--- a/drivers/net/ethernet/dec/tulip/dmfe.c
+++ b/drivers/net/ethernet/dec/tulip/dmfe.c
@@ -1085,10 +1085,11 @@ static void dmfe_ethtool_get_drvinfo(struct net_device *dev,
 {
 	struct dmfe_board_info *np = netdev_priv(dev);
 
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 	if (np->pdev)
-		strcpy(info->bus_info, pci_name(np->pdev));
+		strlcpy(info->bus_info, pci_name(np->pdev),
+			sizeof(info->bus_info));
 	else
 		sprintf(info->bus_info, "EISA 0x%lx %d",
 			dev->base_addr, dev->irq);
diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index 011f67c..5b12966 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -874,9 +874,9 @@ static struct net_device_stats *tulip_get_stats(struct net_device *dev)
 static void tulip_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	struct tulip_private *np = netdev_priv(dev);
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	strcpy(info->bus_info, pci_name(np->pdev));
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(np->pdev), sizeof(info->bus_info));
 }
 
 
diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index 7a44a7a..48b0b65 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -960,10 +960,11 @@ static void netdev_get_drvinfo(struct net_device *dev,
 {
 	struct uli526x_board_info *np = netdev_priv(dev);
 
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 	if (np->pdev)
-		strcpy(info->bus_info, pci_name(np->pdev));
+		strlcpy(info->bus_info, pci_name(np->pdev),
+			sizeof(info->bus_info));
 	else
 		sprintf(info->bus_info, "EISA 0x%lx %d",
 			dev->base_addr, dev->irq);
diff --git a/drivers/net/ethernet/dec/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
index 4d01219..52da7b2 100644
--- a/drivers/net/ethernet/dec/tulip/winbond-840.c
+++ b/drivers/net/ethernet/dec/tulip/winbond-840.c
@@ -1390,9 +1390,9 @@ static void netdev_get_drvinfo (struct net_device *dev, struct ethtool_drvinfo *
 {
 	struct netdev_private *np = netdev_priv(dev);
 
-	strcpy (info->driver, DRV_NAME);
-	strcpy (info->version, DRV_VERSION);
-	strcpy (info->bus_info, pci_name(np->pci_dev));
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(np->pci_dev), sizeof(info->bus_info));
 }
 
 static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
diff --git a/drivers/net/ethernet/dlink/sundance.c b/drivers/net/ethernet/dlink/sundance.c
index dcd7f7a..28a3a9b 100644
--- a/drivers/net/ethernet/dlink/sundance.c
+++ b/drivers/net/ethernet/dlink/sundance.c
@@ -1634,9 +1634,9 @@ static int check_if_running(struct net_device *dev)
 static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	struct netdev_private *np = netdev_priv(dev);
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	strcpy(info->bus_info, pci_name(np->pci_dev));
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(np->pci_dev), sizeof(info->bus_info));
 }
 
 static int get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index c1063d1..d94b968 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -804,9 +804,9 @@ static int dnet_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 static void dnet_get_drvinfo(struct net_device *dev,
 			     struct ethtool_drvinfo *info)
 {
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	strcpy(info->bus_info, "0");
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, "0", sizeof(info->bus_info));
 }
 
 static const struct ethtool_ops dnet_ethtool_ops = {
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index bf8153e..1ad7a28 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -127,8 +127,8 @@ static void be_get_drvinfo(struct net_device *netdev,
 	memset(fw_on_flash, 0 , sizeof(fw_on_flash));
 	be_cmd_get_fw_ver(adapter, adapter->fw_ver, fw_on_flash);
 
-	strcpy(drvinfo->driver, DRV_NAME);
-	strcpy(drvinfo->version, DRV_VER);
+	strlcpy(drvinfo->driver, DRV_NAME, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, DRV_VER, sizeof(drvinfo->version));
 	strncpy(drvinfo->fw_version, adapter->fw_ver, FW_VER_LEN);
 	if (memcmp(adapter->fw_ver, fw_on_flash, FW_VER_LEN) != 0) {
 		strcat(drvinfo->fw_version, " [");
@@ -136,7 +136,8 @@ static void be_get_drvinfo(struct net_device *netdev,
 		strcat(drvinfo->fw_version, "]");
 	}
 
-	strcpy(drvinfo->bus_info, pci_name(adapter->pdev));
+	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
+		sizeof(drvinfo->bus_info));
 	drvinfo->testinfo_len = 0;
 	drvinfo->regdump_len = 0;
 	drvinfo->eedump_len = 0;
diff --git a/drivers/net/ethernet/fealnx.c b/drivers/net/ethernet/fealnx.c
index 61d2bdd..c82d444 100644
--- a/drivers/net/ethernet/fealnx.c
+++ b/drivers/net/ethernet/fealnx.c
@@ -1818,9 +1818,9 @@ static void netdev_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *i
 {
 	struct netdev_private *np = netdev_priv(dev);
 
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	strcpy(info->bus_info, pci_name(np->pci_dev));
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(np->pci_dev), sizeof(info->bus_info));
 }
 
 static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
diff --git a/drivers/net/ethernet/i825xx/eepro.c b/drivers/net/ethernet/i825xx/eepro.c
index 067c460..9cc8bc1 100644
--- a/drivers/net/ethernet/i825xx/eepro.c
+++ b/drivers/net/ethernet/i825xx/eepro.c
@@ -1726,9 +1726,10 @@ static int eepro_ethtool_get_settings(struct net_device *dev,
 static void eepro_ethtool_get_drvinfo(struct net_device *dev,
 					struct ethtool_drvinfo *drvinfo)
 {
-	strcpy(drvinfo->driver, DRV_NAME);
-	strcpy(drvinfo->version, DRV_VERSION);
-	sprintf(drvinfo->bus_info, "ISA 0x%lx", dev->base_addr);
+	strlcpy(drvinfo->driver, DRV_NAME, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, DRV_VERSION, sizeof(drvinfo->version));
+	snprintf(drvinfo->bus_info, sizeof(drvinfo->bus_info) - 1,
+		"ISA 0x%lx", dev->base_addr);
 }
 
 static const struct ethtool_ops eepro_ethtool_ops = {
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 194a031..f6b4304 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1502,10 +1502,11 @@ mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 static void mv643xx_eth_get_drvinfo(struct net_device *dev,
 				    struct ethtool_drvinfo *drvinfo)
 {
-	strncpy(drvinfo->driver,  mv643xx_eth_driver_name, 32);
-	strncpy(drvinfo->version, mv643xx_eth_driver_version, 32);
-	strncpy(drvinfo->fw_version, "N/A", 32);
-	strncpy(drvinfo->bus_info, "platform", 32);
+	strlcpy(drvinfo->driver, mv643xx_eth_driver_name, sizeof(info->driver));
+	strlcpy(drvinfo->version, mv643xx_eth_driver_version,
+		sizeof(info->version));
+	strlcpy(drvinfo->fw_version, "N/A", sizeof(info->fw_version));
+	strlcpy(drvinfo->bus_info, "platform", sizeof(info->bus_info));
 	drvinfo->n_stats = ARRAY_SIZE(mv643xx_eth_stats);
 }
 
diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index c7b6083..3943f5f 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -394,10 +394,11 @@ static void skge_get_drvinfo(struct net_device *dev,
 {
 	struct skge_port *skge = netdev_priv(dev);
 
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	strcpy(info->fw_version, "N/A");
-	strcpy(info->bus_info, pci_name(skge->hw->pdev));
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
+	strlcpy(info->bus_info, pci_name(skge->hw->pdev),
+		sizeof(info->bus_info));
 }
 
 static const struct skge_stat {
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 7b083c4..439a099 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -3634,10 +3634,11 @@ static void sky2_get_drvinfo(struct net_device *dev,
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	strcpy(info->fw_version, "N/A");
-	strcpy(info->bus_info, pci_name(sky2->hw->pdev));
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
+	strlcpy(info->bus_info, pci_name(sky2->hw->pdev),
+		sizeof(info->bus_info));
 }
 
 static const struct sky2_stat {
diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index 6ca047a..ac7b16b 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -2555,9 +2555,9 @@ static void set_rx_mode(struct net_device *dev)
 static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	struct netdev_private *np = netdev_priv(dev);
-	strncpy(info->driver, DRV_NAME, ETHTOOL_BUSINFO_LEN);
-	strncpy(info->version, DRV_VERSION, ETHTOOL_BUSINFO_LEN);
-	strncpy(info->bus_info, pci_name(np->pci_dev), ETHTOOL_BUSINFO_LEN);
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(np->pci_dev), sizeof(info->bus_info));
 }
 
 static int get_regs_len(struct net_device *dev)
diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
index 2b8f64d..c24b46c 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -1364,9 +1364,9 @@ static int ns83820_set_settings(struct net_device *ndev,
 static void ns83820_get_drvinfo(struct net_device *ndev, struct ethtool_drvinfo *info)
 {
 	struct ns83820 *dev = PRIV(ndev);
-	strcpy(info->driver, "ns83820");
-	strcpy(info->version, VERSION);
-	strcpy(info->bus_info, pci_name(dev->pci_dev));
+	strlcpy(info->driver, "ns83820", sizeof(info->driver));
+	strlcpy(info->version, VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(dev->pci_dev), sizeof(info->bus_info));
 }
 
 static u32 ns83820_get_link(struct net_device *ndev)
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index c27fb3d..e6c90a5 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -5391,10 +5391,10 @@ static void s2io_ethtool_gdrvinfo(struct net_device *dev,
 {
 	struct s2io_nic *sp = netdev_priv(dev);
 
-	strncpy(info->driver, s2io_driver_name, sizeof(info->driver));
-	strncpy(info->version, s2io_driver_version, sizeof(info->version));
-	strncpy(info->fw_version, "", sizeof(info->fw_version));
-	strncpy(info->bus_info, pci_name(sp->pdev), sizeof(info->bus_info));
+	strlcpy(info->driver, s2io_driver_name, sizeof(info->driver));
+	strlcpy(info->version, s2io_driver_version, sizeof(info->version));
+	strlcpy(info->fw_version, "", sizeof(info->fw_version));
+	strlcpy(info->bus_info, pci_name(sp->pdev), sizeof(info->bus_info));
 	info->regdump_len = XENA_REG_SPACE;
 	info->eedump_len = XENA_EEPROM_SPACE;
 }
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 1e37eb9..09dd896 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -3926,9 +3926,9 @@ static void nv_do_stats_poll(unsigned long data)
 static void nv_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	struct fe_priv *np = netdev_priv(dev);
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, FORCEDETH_VERSION);
-	strcpy(info->bus_info, pci_name(np->pci_dev));
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, FORCEDETH_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(np->pci_dev), sizeof(info->bus_info));
 }
 
 static void nv_get_wol(struct net_device *dev, struct ethtool_wolinfo *wolinfo)
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
index e09ea83..556e80b 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
@@ -83,14 +83,18 @@ netxen_nic_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 	u32 fw_minor = 0;
 	u32 fw_build = 0;
 
-	strncpy(drvinfo->driver, netxen_nic_driver_name, 32);
-	strncpy(drvinfo->version, NETXEN_NIC_LINUX_VERSIONID, 32);
+	strlcpy(drvinfo->driver, netxen_nic_driver_name,
+		sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, NETXEN_NIC_LINUX_VERSIONID,
+		sizeof(drvinfo->version));
 	fw_major = NXRD32(adapter, NETXEN_FW_VERSION_MAJOR);
 	fw_minor = NXRD32(adapter, NETXEN_FW_VERSION_MINOR);
 	fw_build = NXRD32(adapter, NETXEN_FW_VERSION_SUB);
-	sprintf(drvinfo->fw_version, "%d.%d.%d", fw_major, fw_minor, fw_build);
+	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version) - 1,
+		"%d.%d.%d", fw_major, fw_minor, fw_build);
 
-	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
+	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
+		sizeof(drvinfo->bus_info));
 	drvinfo->regdump_len = NETXEN_NIC_REGS_LEN;
 	drvinfo->eedump_len = netxen_nic_get_eeprom_len(dev);
 }
diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index a4bdff4..9416f29 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -1735,10 +1735,12 @@ static void ql_get_drvinfo(struct net_device *ndev,
 			   struct ethtool_drvinfo *drvinfo)
 {
 	struct ql3_adapter *qdev = netdev_priv(ndev);
-	strncpy(drvinfo->driver, ql3xxx_driver_name, 32);
-	strncpy(drvinfo->version, ql3xxx_driver_version, 32);
-	strncpy(drvinfo->fw_version, "N/A", 32);
-	strncpy(drvinfo->bus_info, pci_name(qdev->pdev), 32);
+	strlcpy(drvinfo->driver, ql3xxx_driver_name, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, ql3xxx_driver_version,
+		sizeof(drvinfo->version));
+	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
+	strlcpy(drvinfo->bus_info, pci_name(qdev->pdev),
+		sizeof(drvinfo->bus_info));
 	drvinfo->regdump_len = 0;
 	drvinfo->eedump_len = 0;
 }
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 5d8bec2..b406c9e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -140,11 +140,14 @@ qlcnic_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 	fw_major = QLCRD32(adapter, QLCNIC_FW_VERSION_MAJOR);
 	fw_minor = QLCRD32(adapter, QLCNIC_FW_VERSION_MINOR);
 	fw_build = QLCRD32(adapter, QLCNIC_FW_VERSION_SUB);
-	sprintf(drvinfo->fw_version, "%d.%d.%d", fw_major, fw_minor, fw_build);
-
-	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
-	strlcpy(drvinfo->driver, qlcnic_driver_name, 32);
-	strlcpy(drvinfo->version, QLCNIC_LINUX_VERSIONID, 32);
+	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version) - 1,
+		"%d.%d.%d", fw_major, fw_minor, fw_build);
+
+	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
+		sizeof(drvinfo->bus_info));
+	strlcpy(drvinfo->driver, qlcnic_driver_name, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, QLCNIC_LINUX_VERSIONID,
+		sizeof(drvinfo->version));
 }
 
 static int
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
index 9b67bfe..08ec103 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
@@ -366,13 +366,16 @@ static void ql_get_drvinfo(struct net_device *ndev,
 			   struct ethtool_drvinfo *drvinfo)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
-	strncpy(drvinfo->driver, qlge_driver_name, 32);
-	strncpy(drvinfo->version, qlge_driver_version, 32);
-	snprintf(drvinfo->fw_version, 32, "v%d.%d.%d",
+	strlcpy(drvinfo->driver, qlge_driver_name, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, qlge_driver_version,
+		sizeof(drvinfo->version));
+	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version) - 1,
+		 "v%d.%d.%d",
 		 (qdev->fw_rev_id & 0x00ff0000) >> 16,
 		 (qdev->fw_rev_id & 0x0000ff00) >> 8,
 		 (qdev->fw_rev_id & 0x000000ff));
-	strncpy(drvinfo->bus_info, pci_name(qdev->pdev), 32);
+	strlcpy(drvinfo->bus_info, pci_name(qdev->pdev),
+		sizeof(drvinfo->bus_info));
 	drvinfo->n_stats = 0;
 	drvinfo->testinfo_len = 0;
 	if (!test_bit(QL_FRC_COREDUMP, &qdev->flags))
diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index ee5da92..6cfc5dc 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -1319,9 +1319,9 @@ static void cp_get_drvinfo (struct net_device *dev, struct ethtool_drvinfo *info
 {
 	struct cp_private *cp = netdev_priv(dev);
 
-	strcpy (info->driver, DRV_NAME);
-	strcpy (info->version, DRV_VERSION);
-	strcpy (info->bus_info, pci_name(cp->pdev));
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(cp->pdev), sizeof(info->bus_info));
 }
 
 static void cp_get_ringparam(struct net_device *dev,
diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 4d6b254..d9c7227 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -2330,9 +2330,9 @@ static int rtl8139_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 static void rtl8139_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	strcpy(info->bus_info, pci_name(tp->pci_dev));
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(tp->pci_dev), sizeof(info->bus_info));
 	info->regdump_len = tp->regs_len;
 }
 
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 92b45f0..3422cc9 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1404,12 +1404,12 @@ static void rtl8169_get_drvinfo(struct net_device *dev,
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct rtl_fw *rtl_fw = tp->rtl_fw;
 
-	strcpy(info->driver, MODULENAME);
-	strcpy(info->version, RTL8169_VERSION);
-	strcpy(info->bus_info, pci_name(tp->pci_dev));
+	strlcpy(info->driver, MODULENAME, sizeof(info->driver));
+	strlcpy(info->version, RTL8169_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(tp->pci_dev), sizeof(info->bus_info));
 	BUILD_BUG_ON(sizeof(info->fw_version) < sizeof(rtl_fw->version));
-	strcpy(info->fw_version, IS_ERR_OR_NULL(rtl_fw) ? "N/A" :
-	       rtl_fw->version);
+	strlcpy(info->fw_version, IS_ERR_OR_NULL(rtl_fw) ? "N/A" :
+	       rtl_fw->version, sizeof(info->fw_version));
 }
 
 static int rtl8169_get_regs_len(struct net_device *dev)
diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
index 0a5dfb8..2c077ce 100644
--- a/drivers/net/ethernet/smsc/epic100.c
+++ b/drivers/net/ethernet/smsc/epic100.c
@@ -1414,9 +1414,9 @@ static void netdev_get_drvinfo (struct net_device *dev, struct ethtool_drvinfo *
 {
 	struct epic_private *np = netdev_priv(dev);
 
-	strcpy (info->driver, DRV_NAME);
-	strcpy (info->version, DRV_VERSION);
-	strcpy (info->bus_info, pci_name(np->pci_dev));
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(np->pci_dev), sizeof(info->bus_info));
 }
 
 static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index 4f15680..58b76ae 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -278,9 +278,10 @@ static void smsc9420_ethtool_get_drvinfo(struct net_device *netdev,
 {
 	struct smsc9420_pdata *pd = netdev_priv(netdev);
 
-	strcpy(drvinfo->driver, DRV_NAME);
-	strcpy(drvinfo->bus_info, pci_name(pd->pdev));
-	strcpy(drvinfo->version, DRV_VERSION);
+	strlcpy(drvinfo->driver, DRV_NAME, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->bus_info, pci_name(pd->pdev),
+		sizeof(drvinfo->bus_info));
+	strlcpy(drvinfo->version, DRV_VERSION, sizeof(drvinfo->version));
 }
 
 static u32 smsc9420_ethtool_get_msglevel(struct net_device *netdev)
diff --git a/drivers/net/ethernet/xircom/xirc2ps_cs.c b/drivers/net/ethernet/xircom/xirc2ps_cs.c
index bbe8b7d..33979c3 100644
--- a/drivers/net/ethernet/xircom/xirc2ps_cs.c
+++ b/drivers/net/ethernet/xircom/xirc2ps_cs.c
@@ -1411,7 +1411,7 @@ do_open(struct net_device *dev)
 static void netdev_get_drvinfo(struct net_device *dev,
 			       struct ethtool_drvinfo *info)
 {
-	strcpy(info->driver, "xirc2ps_cs");
+	strlcpy(info->driver, "xirc2ps_cs", sizeof(info->driver));
 	sprintf(info->bus_info, "PCMCIA 0x%lx", dev->base_addr);
 }
 

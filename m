From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH 2/2] Rename get_property to of_get_property: drivers
Date: Tue, 1 May 2007 13:54:02 +1000
Message-ID: <20070501135402.db795c41.sfr@canb.auug.org.au>
References: <20070501135132.f6546878.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	ppc-dev <linuxppc-dev@ozlabs.org>, paulus@samba.org,
	"David S. Miller" <davem@davemloft.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:39788 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423794AbXEAEMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 00:12:18 -0400
In-Reply-To: <20070501135132.f6546878.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These are all the remaining instances of get_property.  Simple rename of
get_property to of_get_property.

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/ata/sata_svw.c                 |    2 +-
 drivers/char/agp/uninorth-agp.c        |    2 +-
 drivers/char/briq_panel.c              |    2 +-
 drivers/char/tpm/tpm_atmel.h           |    2 +-
 drivers/hwmon/ams/ams-core.c           |    2 +-
 drivers/hwmon/ams/ams-i2c.c            |    2 +-
 drivers/hwmon/ams/ams-pmu.c            |    2 +-
 drivers/ide/ppc/pmac.c                 |    4 ++--
 drivers/infiniband/hw/ehca/ehca_main.c |    2 +-
 drivers/mtd/maps/physmap_of.c          |    8 ++++----
 drivers/net/bmac.c                     |    5 +++--
 drivers/net/ehea/ehea_main.c           |    6 +++---
 drivers/net/mace.c                     |    4 ++--
 drivers/net/pasemi_mac.c               |    2 +-
 drivers/net/spider_net.c               |    4 ++--
 drivers/net/sungem.c                   |    2 +-
 drivers/net/sungem_phy.c               |    2 +-
 drivers/net/ucc_geth.c                 |   18 +++++++++---------
 drivers/net/ucc_geth_mii.c             |    4 ++--
 drivers/pci/hotplug/rpaphp_core.c      |   10 +++++-----
 drivers/scsi/ibmvscsi/ibmvstgt.c       |    8 ++++----
 drivers/scsi/ibmvscsi/rpa_vscsi.c      |    4 ++--
 drivers/scsi/mac53c94.c                |    2 +-
 drivers/scsi/mesh.c                    |    2 +-
 drivers/serial/mpc52xx_uart.c          |    2 +-
 drivers/serial/of_serial.c             |    4 ++--
 drivers/serial/pmac_zilog.c            |    6 +++---
 drivers/video/aty/radeon_base.c        |    6 +++---
 drivers/video/aty/radeon_monitor.c     |   11 ++++++-----
 drivers/video/aty/radeon_pm.c          |    2 +-
 drivers/video/nvidia/nv_of.c           |    8 ++++----
 drivers/video/offb.c                   |   28 ++++++++++++++--------------
 drivers/video/riva/fbdev.c             |    4 ++--
 33 files changed, 87 insertions(+), 85 deletions(-)

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --git a/drivers/ata/sata_svw.c b/drivers/ata/sata_svw.c
index cc07aac..1724673 100644
--- a/drivers/ata/sata_svw.c
+++ b/drivers/ata/sata_svw.c
@@ -288,7 +288,7 @@ static int k2_sata_proc_info(struct Scsi_Host *shost, char *page, char **start,
 	/* Match it to a port node */
 	index = (ap == ap->host->ports[0]) ? 0 : 1;
 	for (np = np->child; np != NULL; np = np->sibling) {
-		const u32 *reg = get_property(np, "reg", NULL);
+		const u32 *reg = of_get_property(np, "reg", NULL);
 		if (!reg)
 			continue;
 		if (index == *reg)
diff --git a/drivers/char/agp/uninorth-agp.c b/drivers/char/agp/uninorth-agp.c
index 91b0621..42c0a60 100644
--- a/drivers/char/agp/uninorth-agp.c
+++ b/drivers/char/agp/uninorth-agp.c
@@ -613,7 +613,7 @@ static int __devinit agp_uninorth_probe(struct pci_dev *pdev,
 		uninorth_node = of_find_node_by_name(NULL, "u3");
 	}
 	if (uninorth_node) {
-		const int *revprop = get_property(uninorth_node,
+		const int *revprop = of_get_property(uninorth_node,
 				"device-rev", NULL);
 		if (revprop != NULL)
 			uninorth_rev = *revprop & 0x3f;
diff --git a/drivers/char/briq_panel.c b/drivers/char/briq_panel.c
index c70d52a..ed53f54 100644
--- a/drivers/char/briq_panel.c
+++ b/drivers/char/briq_panel.c
@@ -206,7 +206,7 @@ static int __init briq_panel_init(void)
 	const char *machine;
 	int i;
 
-	machine = get_property(root, "model", NULL);
+	machine = of_get_property(root, "model", NULL);
 	if (!machine || strncmp(machine, "TotalImpact,BRIQ-1", 18) != 0) {
 		of_node_put(root);
 		return -ENODEV;
diff --git a/drivers/char/tpm/tpm_atmel.h b/drivers/char/tpm/tpm_atmel.h
index 3c85200..377bc60 100644
--- a/drivers/char/tpm/tpm_atmel.h
+++ b/drivers/char/tpm/tpm_atmel.h
@@ -52,7 +52,7 @@ static void __iomem * atmel_get_base_addr(unsigned long *base, int *region_size)
 		return NULL;
 	}
 
-	reg = get_property(dn, "reg", &reglen);
+	reg = of_get_property(dn, "reg", &reglen);
 	naddrc = of_n_addr_cells(dn);
 	nsizec = of_n_size_cells(dn);
 
diff --git a/drivers/hwmon/ams/ams-core.c b/drivers/hwmon/ams/ams-core.c
index f5ebad5..93b963f 100644
--- a/drivers/hwmon/ams/ams-core.c
+++ b/drivers/hwmon/ams/ams-core.c
@@ -144,7 +144,7 @@ int ams_sensor_attach(void)
 	const u32 *prop;
 
 	/* Get orientation */
-	prop = get_property(ams_info.of_node, "orientation", NULL);
+	prop = of_get_property(ams_info.of_node, "orientation", NULL);
 	if (!prop)
 		return -ENODEV;
 	ams_info.orient1 = *prop;
diff --git a/drivers/hwmon/ams/ams-i2c.c b/drivers/hwmon/ams/ams-i2c.c
index 485d333..ccd5cef 100644
--- a/drivers/hwmon/ams/ams-i2c.c
+++ b/drivers/hwmon/ams/ams-i2c.c
@@ -276,7 +276,7 @@ int __init ams_i2c_init(struct device_node *np)
 	ams_info.bustype = BUS_I2C;
 
 	/* look for bus either using "reg" or by path */
-	prop = get_property(ams_info.of_node, "reg", NULL);
+	prop = of_get_property(ams_info.of_node, "reg", NULL);
 	if (!prop) {
 		result = -ENODEV;
 
diff --git a/drivers/hwmon/ams/ams-pmu.c b/drivers/hwmon/ams/ams-pmu.c
index 1b01c21..9463e97 100644
--- a/drivers/hwmon/ams/ams-pmu.c
+++ b/drivers/hwmon/ams/ams-pmu.c
@@ -160,7 +160,7 @@ int __init ams_pmu_init(struct device_node *np)
 	ams_info.bustype = BUS_HOST;
 
 	/* Get PMU command, should be 0x4e, but we can never know */
-	prop = get_property(ams_info.of_node, "reg", NULL);
+	prop = of_get_property(ams_info.of_node, "reg", NULL);
 	if (!prop) {
 		result = -ENODEV;
 		goto exit;
diff --git a/drivers/ide/ppc/pmac.c b/drivers/ide/ppc/pmac.c
index 071a030..774bfd3 100644
--- a/drivers/ide/ppc/pmac.c
+++ b/drivers/ide/ppc/pmac.c
@@ -1175,14 +1175,14 @@ pmac_ide_setup_device(pmac_ide_hwif_t *pmif, ide_hwif_t *hwif)
 		pmif->broken_dma = 1;
 	}
 
-	bidp = get_property(np, "AAPL,bus-id", NULL);
+	bidp = of_get_property(np, "AAPL,bus-id", NULL);
 	pmif->aapl_bus_id =  bidp ? *bidp : 0;
 
 	/* Get cable type from device-tree */
 	if (pmif->kind == controller_kl_ata4 || pmif->kind == controller_un_ata6
 	    || pmif->kind == controller_k2_ata6
 	    || pmif->kind == controller_sh_ata6) {
-		const char* cable = get_property(np, "cable-type", NULL);
+		const char* cable = of_get_property(np, "cable-type", NULL);
 		if (cable && !strncmp(cable, "80-", 3))
 			pmif->cable_80 = 1;
 	}
diff --git a/drivers/infiniband/hw/ehca/ehca_main.c b/drivers/infiniband/hw/ehca/ehca_main.c
index 4700085..50e4265 100644
--- a/drivers/infiniband/hw/ehca/ehca_main.c
+++ b/drivers/infiniband/hw/ehca/ehca_main.c
@@ -569,7 +569,7 @@ static int __devinit ehca_probe(struct ibmebus_dev *dev,
 	struct ib_pd *ibpd;
 	int ret;
 
-	handle = get_property(dev->ofdev.node, "ibm,hca-handle", NULL);
+	handle = of_get_property(dev->ofdev.node, "ibm,hca-handle", NULL);
 	if (!handle) {
 		ehca_gen_err("Cannot get eHCA handle for adapter: %s.",
 			     dev->ofdev.node->full_name);
diff --git a/drivers/mtd/maps/physmap_of.c b/drivers/mtd/maps/physmap_of.c
index 7efe744..72107dc 100644
--- a/drivers/mtd/maps/physmap_of.c
+++ b/drivers/mtd/maps/physmap_of.c
@@ -48,7 +48,7 @@ static int parse_flash_partitions(struct device_node *node,
 	const  u32  *part;
 	const  char *name;
 
-	part = get_property(node, "partitions", &plen);
+	part = of_get_property(node, "partitions", &plen);
 	if (part == NULL)
 		goto err;
 
@@ -59,7 +59,7 @@ static int parse_flash_partitions(struct device_node *node,
 		goto err;
 	}
 
-	name = get_property(node, "partition-names", &plen);
+	name = of_get_property(node, "partition-names", &plen);
 
 	for (i = 0; i < retval; i++) {
 		(*parts)[i].offset = *part++;
@@ -153,7 +153,7 @@ static int __devinit of_physmap_probe(struct of_device *dev, const struct of_dev
 		goto err_out;
 	}
 
-	width = get_property(dp, "bank-width", NULL);
+	width = of_get_property(dp, "bank-width", NULL);
 	if (width == NULL) {
 		dev_err(&dev->dev, "Can't get the flash bank width!\n");
 		err = -EINVAL;
@@ -174,7 +174,7 @@ static int __devinit of_physmap_probe(struct of_device *dev, const struct of_dev
 
 	simple_map_init(&info->map);
 
-	of_probe = get_property(dp, "probe-type", NULL);
+	of_probe = of_get_property(dp, "probe-type", NULL);
 	if (of_probe == NULL) {
 		probe_type = rom_probe_types;
 		for (; info->mtd == NULL && *probe_type != NULL; probe_type++)
diff --git a/drivers/net/bmac.c b/drivers/net/bmac.c
index 4612725..9b8d7d9 100644
--- a/drivers/net/bmac.c
+++ b/drivers/net/bmac.c
@@ -1260,9 +1260,10 @@ static int __devinit bmac_probe(struct macio_dev *mdev, const struct of_device_i
 		printk(KERN_ERR "BMAC: can't use, need 3 addrs and 3 intrs\n");
 		return -ENODEV;
 	}
-	prop_addr = get_property(macio_get_of_node(mdev), "mac-address", NULL);
+	prop_addr = of_get_property(macio_get_of_node(mdev),
+			"mac-address", NULL);
 	if (prop_addr == NULL) {
-		prop_addr = get_property(macio_get_of_node(mdev),
+		prop_addr = of_get_property(macio_get_of_node(mdev),
 				"local-mac-address", NULL);
 		if (prop_addr == NULL) {
 			printk(KERN_ERR "BMAC: Can't get mac-address\n");
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 519bb9f..a1bd2d8 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -2609,7 +2609,7 @@ static int ehea_setup_ports(struct ehea_adapter *adapter)
 	lhea_dn = adapter->ebus_dev->ofdev.node;
 	while ((eth_dn = of_get_next_child(lhea_dn, eth_dn))) {
 
-		dn_log_port_id = get_property(eth_dn, "ibm,hea-port-no",
+		dn_log_port_id = of_get_property(eth_dn, "ibm,hea-port-no",
 						    NULL);
 		if (!dn_log_port_id) {
 			ehea_error("bad device node: eth_dn name=%s",
@@ -2649,7 +2649,7 @@ static struct device_node *ehea_get_eth_dn(struct ehea_adapter *adapter,
 	lhea_dn = adapter->ebus_dev->ofdev.node;
 	while ((eth_dn = of_get_next_child(lhea_dn, eth_dn))) {
 
-		dn_log_port_id = get_property(eth_dn, "ibm,hea-port-no",
+		dn_log_port_id = of_get_property(eth_dn, "ibm,hea-port-no",
 						    NULL);
 		if (dn_log_port_id)
 			if (*dn_log_port_id == logical_port_id)
@@ -2790,7 +2790,7 @@ static int __devinit ehea_probe_adapter(struct ibmebus_dev *dev,
 
 	adapter->ebus_dev = dev;
 
-	adapter_handle = get_property(dev->ofdev.node, "ibm,hea-handle",
+	adapter_handle = of_get_property(dev->ofdev.node, "ibm,hea-handle",
 					    NULL);
 	if (adapter_handle)
 		adapter->handle = *adapter_handle;
diff --git a/drivers/net/mace.c b/drivers/net/mace.c
index b3bd623..52b9332 100644
--- a/drivers/net/mace.c
+++ b/drivers/net/mace.c
@@ -110,9 +110,9 @@ static int __devinit mace_probe(struct macio_dev *mdev, const struct of_device_i
 		return -ENODEV;
 	}
 
-	addr = get_property(mace, "mac-address", NULL);
+	addr = of_get_property(mace, "mac-address", NULL);
 	if (addr == NULL) {
-		addr = get_property(mace, "local-mac-address", NULL);
+		addr = of_get_property(mace, "local-mac-address", NULL);
 		if (addr == NULL) {
 			printk(KERN_ERR "Can't get mac-address for MACE %s\n",
 			       mace->full_name);
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 76fe9dd..07eb9b2 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -80,7 +80,7 @@ static int pasemi_get_mac_addr(struct pasemi_mac *mac)
 		return -ENOENT;
 	}
 
-	maddr = get_property(dn, "mac-address", NULL);
+	maddr = of_get_property(dn, "mac-address", NULL);
 	if (maddr == NULL) {
 		dev_warn(&pdev->dev,
 			 "no mac address in device tree, not configuring\n");
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 230da14..c15e972 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -1830,7 +1830,7 @@ try_host_fw:
 	if (!dn)
 		goto out_err;
 
-	fw_prop = get_property(dn, "firmware", &fw_size);
+	fw_prop = of_get_property(dn, "firmware", &fw_size);
 	if (!fw_prop)
 		goto out_err;
 
@@ -2236,7 +2236,7 @@ spider_net_setup_netdev(struct spider_net_card *card)
 	if (!dn)
 		return -EIO;
 
-	mac = get_property(dn, "local-mac-address", NULL);
+	mac = of_get_property(dn, "local-mac-address", NULL);
 	if (!mac)
 		return -EIO;
 	memcpy(addr.sa_data, mac, ETH_ALEN);
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 5da7321..4328038 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -2903,7 +2903,7 @@ static int __devinit gem_get_device_address(struct gem *gp)
 	struct net_device *dev = gp->dev;
 	const unsigned char *addr;
 
-	addr = get_property(gp->of_node, "local-mac-address", NULL);
+	addr = of_get_property(gp->of_node, "local-mac-address", NULL);
 	if (addr == NULL) {
 #ifdef CONFIG_SPARC
 		addr = idprom->id_ethaddr;
diff --git a/drivers/net/sungem_phy.c b/drivers/net/sungem_phy.c
index 56a110c..61843fd 100644
--- a/drivers/net/sungem_phy.c
+++ b/drivers/net/sungem_phy.c
@@ -451,7 +451,7 @@ static int bcm5421_init(struct mii_phy* phy)
 	if (phy->platform_data) {
 		struct device_node *np = of_get_parent(phy->platform_data);
 		int can_low_power = 1;
-		if (np == NULL || get_property(np, "no-autolowpower", NULL))
+		if (np == NULL || of_get_property(np, "no-autolowpower", NULL))
 			can_low_power = 0;
 		if (can_low_power) {
 			/* Enable automatic low-power */
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 16b9acd..d7aff81 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3787,7 +3787,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 
 	ugeth_vdbg("%s: IN", __FUNCTION__);
 
-	prop = get_property(np, "device-id", NULL);
+	prop = of_get_property(np, "device-id", NULL);
 	ucc_num = *prop - 1;
 	if ((ucc_num < 0) || (ucc_num > 7))
 		return -ENODEV;
@@ -3795,9 +3795,9 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	ug_info = &ugeth_info[ucc_num];
 	ug_info->uf_info.ucc_num = ucc_num;
 
-	prop = get_property(np, "rx-clock", NULL);
+	prop = of_get_property(np, "rx-clock", NULL);
 	ug_info->uf_info.rx_clock = *prop;
-	prop = get_property(np, "tx-clock", NULL);
+	prop = of_get_property(np, "tx-clock", NULL);
 	ug_info->uf_info.tx_clock = *prop;
 	err = of_address_to_resource(np, 0, &res);
 	if (err)
@@ -3806,23 +3806,23 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	ug_info->uf_info.regs = res.start;
 	ug_info->uf_info.irq = irq_of_parse_and_map(np, 0);
 
-	ph = get_property(np, "phy-handle", NULL);
+	ph = of_get_property(np, "phy-handle", NULL);
 	phy = of_find_node_by_phandle(*ph);
 
 	if (phy == NULL)
 		return -ENODEV;
 
 	/* set the PHY address */
-	prop = get_property(phy, "reg", NULL);
+	prop = of_get_property(phy, "reg", NULL);
 	if (prop == NULL)
 		return -1;
 	ug_info->phy_address = *prop;
 
 	/* get the phy interface type, or default to MII */
-	prop = get_property(np, "interface-type", NULL);
+	prop = of_get_property(np, "interface-type", NULL);
 	if (!prop) {
 		/* handle interface property present in old trees */
-		prop = get_property(phy, "interface", NULL);
+		prop = of_get_property(phy, "interface", NULL);
 		if (prop != NULL)
 			phy_interface = enet_to_phy_interface[*prop];
 		else
@@ -3832,10 +3832,10 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	}
 
 	/* get speed, or derive from interface */
-	prop = get_property(np, "max-speed", NULL);
+	prop = of_get_property(np, "max-speed", NULL);
 	if (!prop) {
 		/* handle interface property present in old trees */
-		prop = get_property(phy, "interface", NULL);
+		prop = of_get_property(phy, "interface", NULL);
 		if (prop != NULL)
 			max_speed = enet_to_speed[*prop];
 	} else {
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index 73b5a53..27a1ef3 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -172,7 +172,7 @@ static int uec_mdio_probe(struct of_device *ofdev, const struct of_device_id *ma
 	while ((child = of_get_next_child(np, child)) != NULL) {
 		int irq = irq_of_parse_and_map(child, 0);
 		if (irq != NO_IRQ) {
-			const u32 *id = get_property(child, "reg", NULL);
+			const u32 *id = of_get_property(child, "reg", NULL);
 			new_bus->irq[*id] = irq;
 		}
 	}
@@ -203,7 +203,7 @@ static int uec_mdio_probe(struct of_device *ofdev, const struct of_device_id *ma
 		if ((res.start >= tempres.start) &&
 		    (res.end <= tempres.end)) {
 			/* set this UCC to be the MII master */
-			const u32 *id = get_property(tempnp, "device-id", NULL);
+			const u32 *id = of_get_property(tempnp, "device-id", NULL);
 			if (id == NULL)
 				goto bus_register_fail;
 
diff --git a/drivers/pci/hotplug/rpaphp_core.c b/drivers/pci/hotplug/rpaphp_core.c
index 71a2cb8..353da5b 100644
--- a/drivers/pci/hotplug/rpaphp_core.c
+++ b/drivers/pci/hotplug/rpaphp_core.c
@@ -182,10 +182,10 @@ static int get_children_props(struct device_node *dn, const int **drc_indexes,
 {
 	const int *indexes, *names, *types, *domains;
 
-	indexes = get_property(dn, "ibm,drc-indexes", NULL);
-	names = get_property(dn, "ibm,drc-names", NULL);
-	types = get_property(dn, "ibm,drc-types", NULL);
-	domains = get_property(dn, "ibm,drc-power-domains", NULL);
+	indexes = of_get_property(dn, "ibm,drc-indexes", NULL);
+	names = of_get_property(dn, "ibm,drc-names", NULL);
+	types = of_get_property(dn, "ibm,drc-types", NULL);
+	domains = of_get_property(dn, "ibm,drc-power-domains", NULL);
 
 	if (!indexes || !names || !types || !domains) {
 		/* Slot does not have dynamically-removable children */
@@ -218,7 +218,7 @@ int rpaphp_get_drc_props(struct device_node *dn, int *drc_index,
 	char *name_tmp, *type_tmp;
 	int i, rc;
 
-	my_index = get_property(dn, "ibm,my-drc-index", NULL);
+	my_index = of_get_property(dn, "ibm,my-drc-index", NULL);
 	if (!my_index) {
 		/* Node isn't DLPAR/hotplug capable */
 		return -EINVAL;
diff --git a/drivers/scsi/ibmvscsi/ibmvstgt.c b/drivers/scsi/ibmvscsi/ibmvstgt.c
index a39a478..140dd97 100644
--- a/drivers/scsi/ibmvscsi/ibmvstgt.c
+++ b/drivers/scsi/ibmvscsi/ibmvstgt.c
@@ -903,16 +903,16 @@ static int get_system_info(void)
 	if (!rootdn)
 		return -ENOENT;
 
-	model = get_property(rootdn, "model", NULL);
-	id = get_property(rootdn, "system-id", NULL);
+	model = of_get_property(rootdn, "model", NULL);
+	id = of_get_property(rootdn, "system-id", NULL);
 	if (model && id)
 		snprintf(system_id, sizeof(system_id), "%s-%s", model, id);
 
-	name = get_property(rootdn, "ibm,partition-name", NULL);
+	name = of_get_property(rootdn, "ibm,partition-name", NULL);
 	if (name)
 		strncpy(partition_name, name, sizeof(partition_name));
 
-	num = get_property(rootdn, "ibm,partition-no", NULL);
+	num = of_get_property(rootdn, "ibm,partition-no", NULL);
 	if (num)
 		partition_number = *num;
 
diff --git a/drivers/scsi/ibmvscsi/rpa_vscsi.c b/drivers/scsi/ibmvscsi/rpa_vscsi.c
index 0a533f3..d8700aa 100644
--- a/drivers/scsi/ibmvscsi/rpa_vscsi.c
+++ b/drivers/scsi/ibmvscsi/rpa_vscsi.c
@@ -162,11 +162,11 @@ static void gather_partition_info(void)
 		return;
 	}
 
-	ppartition_name = get_property(rootdn, "ibm,partition-name", NULL);
+	ppartition_name = of_get_property(rootdn, "ibm,partition-name", NULL);
 	if (ppartition_name)
 		strncpy(partition_name, ppartition_name,
 				sizeof(partition_name));
-	p_number_ptr = get_property(rootdn, "ibm,partition-no", NULL);
+	p_number_ptr = of_get_property(rootdn, "ibm,partition-no", NULL);
 	if (p_number_ptr)
 		partition_number = *p_number_ptr;
 	of_node_put(rootdn);
diff --git a/drivers/scsi/mac53c94.c b/drivers/scsi/mac53c94.c
index 753d883..5806ede 100644
--- a/drivers/scsi/mac53c94.c
+++ b/drivers/scsi/mac53c94.c
@@ -471,7 +471,7 @@ static int mac53c94_probe(struct macio_dev *mdev, const struct of_device_id *mat
 		goto out_free;
 	}
 
-       	clkprop = get_property(node, "clock-frequency", &proplen);
+	clkprop = of_get_property(node, "clock-frequency", &proplen);
        	if (clkprop == NULL || proplen != sizeof(int)) {
        		printk(KERN_ERR "%s: can't get clock frequency, "
        		       "assuming 25MHz\n", node->full_name);
diff --git a/drivers/scsi/mesh.c b/drivers/scsi/mesh.c
index 1fd3c75..cf3666d 100644
--- a/drivers/scsi/mesh.c
+++ b/drivers/scsi/mesh.c
@@ -1947,7 +1947,7 @@ static int mesh_probe(struct macio_dev *mdev, const struct of_device_id *match)
 	       	ms->tgts[tgt].current_req = NULL;
        	}
 
-	if ((cfp = get_property(mesh, "clock-frequency", NULL)))
+	if ((cfp = of_get_property(mesh, "clock-frequency", NULL)))
        		ms->clk_freq = *cfp;
 	else {
        		printk(KERN_INFO "mesh: assuming 50MHz clock frequency\n");
diff --git a/drivers/serial/mpc52xx_uart.c b/drivers/serial/mpc52xx_uart.c
index 8d24cd5..f8c1761 100644
--- a/drivers/serial/mpc52xx_uart.c
+++ b/drivers/serial/mpc52xx_uart.c
@@ -1069,7 +1069,7 @@ mpc52xx_uart_of_enumerate(void)
 			continue;
 
 		/* Is a particular device number requested? */
-		devno = get_property(np, "port-number", NULL);
+		devno = of_get_property(np, "port-number", NULL);
 		mpc52xx_uart_of_assign(of_node_get(np), devno ? *devno : -1);
 	}
 
diff --git a/drivers/serial/of_serial.c b/drivers/serial/of_serial.c
index 09b0b73..e7928fe 100644
--- a/drivers/serial/of_serial.c
+++ b/drivers/serial/of_serial.c
@@ -29,8 +29,8 @@ static int __devinit of_platform_serial_setup(struct of_device *ofdev,
 	int ret;
 
 	memset(port, 0, sizeof *port);
-	spd = get_property(np, "current-speed", NULL);
-	clk = get_property(np, "clock-frequency", NULL);
+	spd = of_get_property(np, "current-speed", NULL);
+	clk = of_get_property(np, "clock-frequency", NULL);
 	if (!clk) {
 		dev_warn(&ofdev->dev, "no clock-frequency property set\n");
 		return -ENODEV;
diff --git a/drivers/serial/pmac_zilog.c b/drivers/serial/pmac_zilog.c
index be8d757..cd92a39 100644
--- a/drivers/serial/pmac_zilog.c
+++ b/drivers/serial/pmac_zilog.c
@@ -1452,12 +1452,12 @@ no_dma:
 	 */
 	if (device_is_compatible(np, "cobalt"))
 		uap->flags |= PMACZILOG_FLAG_IS_INTMODEM;
-	conn = get_property(np, "AAPL,connector", &len);
+	conn = of_get_property(np, "AAPL,connector", &len);
 	if (conn && (strcmp(conn, "infrared") == 0))
 		uap->flags |= PMACZILOG_FLAG_IS_IRDA;
 	uap->port_type = PMAC_SCC_ASYNC;
 	/* 1999 Powerbook G3 has slot-names property instead */
-	slots = get_property(np, "slot-names", &len);
+	slots = of_get_property(np, "slot-names", &len);
 	if (slots && slots->count > 0) {
 		if (strcmp(slots->name, "IrDA") == 0)
 			uap->flags |= PMACZILOG_FLAG_IS_IRDA;
@@ -1471,7 +1471,7 @@ no_dma:
 			of_find_node_by_name(NULL, "i2c-modem");
 		if (i2c_modem) {
 			const char* mid =
-				get_property(i2c_modem, "modem-id", NULL);
+				of_get_property(i2c_modem, "modem-id", NULL);
 			if (mid) switch(*mid) {
 			case 0x04 :
 			case 0x05 :
diff --git a/drivers/video/aty/radeon_base.c b/drivers/video/aty/radeon_base.c
index a4b3fd1..9d629fe 100644
--- a/drivers/video/aty/radeon_base.c
+++ b/drivers/video/aty/radeon_base.c
@@ -422,7 +422,7 @@ static int __devinit radeon_read_xtal_OF (struct radeonfb_info *rinfo)
 
 	if (dp == NULL)
 		return -ENODEV;
-	val = get_property(dp, "ATY,RefCLK", NULL);
+	val = of_get_property(dp, "ATY,RefCLK", NULL);
 	if (!val || !*val) {
 		printk(KERN_WARNING "radeonfb: No ATY,RefCLK property !\n");
 		return -EINVAL;
@@ -430,11 +430,11 @@ static int __devinit radeon_read_xtal_OF (struct radeonfb_info *rinfo)
 
 	rinfo->pll.ref_clk = (*val) / 10;
 
-	val = get_property(dp, "ATY,SCLK", NULL);
+	val = of_get_property(dp, "ATY,SCLK", NULL);
 	if (val && *val)
 		rinfo->pll.sclk = (*val) / 10;
 
-	val = get_property(dp, "ATY,MCLK", NULL);
+	val = of_get_property(dp, "ATY,MCLK", NULL);
 	if (val && *val)
 		rinfo->pll.mclk = (*val) / 10;
 
diff --git a/drivers/video/aty/radeon_monitor.c b/drivers/video/aty/radeon_monitor.c
index 737b5c0..2030ed8 100644
--- a/drivers/video/aty/radeon_monitor.c
+++ b/drivers/video/aty/radeon_monitor.c
@@ -70,7 +70,7 @@ static int __devinit radeon_parse_montype_prop(struct device_node *dp, u8 **out_
         int i, mt = MT_NONE;  
 	
 	RTRACE("analyzing OF properties...\n");
-	pmt = get_property(dp, "display-type", NULL);
+	pmt = of_get_property(dp, "display-type", NULL);
 	if (!pmt)
 		return MT_NONE;
 	RTRACE("display-type: %s\n", pmt);
@@ -89,7 +89,7 @@ static int __devinit radeon_parse_montype_prop(struct device_node *dp, u8 **out_
 	}
 
 	for (i = 0; propnames[i] != NULL; ++i) {
-		pedid = get_property(dp, propnames[i], NULL);
+		pedid = of_get_property(dp, propnames[i], NULL);
 		if (pedid != NULL)
 			break;
 	}
@@ -98,9 +98,10 @@ static int __devinit radeon_parse_montype_prop(struct device_node *dp, u8 **out_
 	 * single-head cards have hdno == -1 and skip this step
 	 */
 	if (pedid == NULL && dp->parent && (hdno != -1))
-		pedid = get_property(dp->parent, (hdno == 0) ? "EDID1" : "EDID2", NULL);
+		pedid = of_get_property(dp->parent,
+				(hdno == 0) ? "EDID1" : "EDID2", NULL);
 	if (pedid == NULL && dp->parent && (hdno == 0))
-		pedid = get_property(dp->parent, "EDID", NULL);
+		pedid = of_get_property(dp->parent, "EDID", NULL);
 	if (pedid == NULL)
 		return mt;
 
@@ -130,7 +131,7 @@ static int __devinit radeon_probe_OF_head(struct radeonfb_info *rinfo, int head_
 		do {
 			if (!dp)
 				return MT_NONE;
-			pname = get_property(dp, "name", NULL);
+			pname = of_get_property(dp, "name", NULL);
 			if (!pname)
 				return MT_NONE;
 			len = strlen(pname);
diff --git a/drivers/video/aty/radeon_pm.c b/drivers/video/aty/radeon_pm.c
index c411293..1786ae1 100644
--- a/drivers/video/aty/radeon_pm.c
+++ b/drivers/video/aty/radeon_pm.c
@@ -1290,7 +1290,7 @@ static void radeon_pm_full_reset_sdram(struct radeonfb_info *rinfo)
 		if (rinfo->of_node != NULL) {
 			int size;
 
-			mrtable = get_property(rinfo->of_node, "ATY,MRT", &size);
+			mrtable = of_get_property(rinfo->of_node, "ATY,MRT", &size);
 			if (mrtable)
 				mrtable_size = size >> 2;
 			else
diff --git a/drivers/video/nvidia/nv_of.c b/drivers/video/nvidia/nv_of.c
index 163a774..73afd7e 100644
--- a/drivers/video/nvidia/nv_of.c
+++ b/drivers/video/nvidia/nv_of.c
@@ -46,15 +46,15 @@ int nvidia_probe_of_connector(struct fb_info *info, int conn, u8 **out_edid)
 
 		for (dp = NULL;
 		     (dp = of_get_next_child(parent, dp)) != NULL;) {
-			pname = get_property(dp, "name", NULL);
+			pname = of_get_property(dp, "name", NULL);
 			if (!pname)
 				continue;
 			len = strlen(pname);
 			if ((pname[len-1] == 'A' && conn == 1) ||
 			    (pname[len-1] == 'B' && conn == 2)) {
 				for (i = 0; propnames[i] != NULL; ++i) {
-					pedid = get_property(dp, propnames[i],
-							     NULL);
+					pedid = of_get_property(dp,
+							propnames[i], NULL);
 					if (pedid != NULL)
 						break;
 				}
@@ -65,7 +65,7 @@ int nvidia_probe_of_connector(struct fb_info *info, int conn, u8 **out_edid)
 	}
 	if (pedid == NULL) {
 		for (i = 0; propnames[i] != NULL; ++i) {
-			pedid = get_property(parent, propnames[i], NULL);
+			pedid = of_get_property(parent, propnames[i], NULL);
 			if (pedid != NULL)
 				break;
 		}
diff --git a/drivers/video/offb.c b/drivers/video/offb.c
index 9576a55..3cf603c 100644
--- a/drivers/video/offb.c
+++ b/drivers/video/offb.c
@@ -425,27 +425,27 @@ static void __init offb_init_nodriver(struct device_node *dp, int no_real_node)
 	const u32 *pp, *addrp, *up;
 	u64 asize;
 
-	pp = get_property(dp, "linux,bootx-depth", &len);
+	pp = of_get_property(dp, "linux,bootx-depth", &len);
 	if (pp == NULL)
-		pp = get_property(dp, "depth", &len);
+		pp = of_get_property(dp, "depth", &len);
 	if (pp && len == sizeof(u32))
 		depth = *pp;
 
-	pp = get_property(dp, "linux,bootx-width", &len);
+	pp = of_get_property(dp, "linux,bootx-width", &len);
 	if (pp == NULL)
-		pp = get_property(dp, "width", &len);
+		pp = of_get_property(dp, "width", &len);
 	if (pp && len == sizeof(u32))
 		width = *pp;
 
-	pp = get_property(dp, "linux,bootx-height", &len);
+	pp = of_get_property(dp, "linux,bootx-height", &len);
 	if (pp == NULL)
-		pp = get_property(dp, "height", &len);
+		pp = of_get_property(dp, "height", &len);
 	if (pp && len == sizeof(u32))
 		height = *pp;
 
-	pp = get_property(dp, "linux,bootx-linebytes", &len);
+	pp = of_get_property(dp, "linux,bootx-linebytes", &len);
 	if (pp == NULL)
-		pp = get_property(dp, "linebytes", &len);
+		pp = of_get_property(dp, "linebytes", &len);
 	if (pp && len == sizeof(u32) && (*pp != 0xffffffffu))
 		pitch = *pp;
 	else
@@ -463,9 +463,9 @@ static void __init offb_init_nodriver(struct device_node *dp, int no_real_node)
 	 * ranges and pick one that is both big enough and if possible encloses
 	 * the "address" property. If none match, we pick the biggest
 	 */
-	up = get_property(dp, "linux,bootx-addr", &len);
+	up = of_get_property(dp, "linux,bootx-addr", &len);
 	if (up == NULL)
-		up = get_property(dp, "address", &len);
+		up = of_get_property(dp, "address", &len);
 	if (up && len == sizeof(u32))
 		addr_prop = *up;
 
@@ -521,7 +521,7 @@ static int __init offb_init(void)
 		return -ENODEV;
 
 	/* Check if we have a MacOS display without a node spec */
-	if (get_property(of_chosen, "linux,bootx-noscreen", NULL) != NULL) {
+	if (of_get_property(of_chosen, "linux,bootx-noscreen", NULL) != NULL) {
 		/* The old code tried to work out which node was the MacOS
 		 * display based on the address. I'm dropping that since the
 		 * lack of a node spec only happens with old BootX versions
@@ -532,14 +532,14 @@ static int __init offb_init(void)
 	}
 
 	for (dp = NULL; (dp = of_find_node_by_type(dp, "display"));) {
-		if (get_property(dp, "linux,opened", NULL) &&
-		    get_property(dp, "linux,boot-display", NULL)) {
+		if (of_get_property(dp, "linux,opened", NULL) &&
+		    of_get_property(dp, "linux,boot-display", NULL)) {
 			boot_disp = dp;
 			offb_init_nodriver(dp, 0);
 		}
 	}
 	for (dp = NULL; (dp = of_find_node_by_type(dp, "display"));) {
-		if (get_property(dp, "linux,opened", NULL) &&
+		if (of_get_property(dp, "linux,opened", NULL) &&
 		    dp != boot_disp)
 			offb_init_nodriver(dp, 0);
 	}
diff --git a/drivers/video/riva/fbdev.c b/drivers/video/riva/fbdev.c
index d7ece8d..9c6bd09 100644
--- a/drivers/video/riva/fbdev.c
+++ b/drivers/video/riva/fbdev.c
@@ -1760,13 +1760,13 @@ static int __devinit riva_get_EDID_OF(struct fb_info *info, struct pci_dev *pd)
 	NVTRACE_ENTER();
 	dp = pci_device_to_OF_node(pd);
 	for (; dp != NULL; dp = dp->child) {
-		disptype = get_property(dp, "display-type", NULL);
+		disptype = of_get_property(dp, "display-type", NULL);
 		if (disptype == NULL)
 			continue;
 		if (strncmp(disptype, "LCD", 3) != 0)
 			continue;
 		for (i = 0; propnames[i] != NULL; ++i) {
-			pedid = get_property(dp, propnames[i], NULL);
+			pedid = of_get_property(dp, propnames[i], NULL);
 			if (pedid != NULL) {
 				par->EDID = (unsigned char *)pedid;
 				NVTRACE("LCD found.\n");
-- 
1.5.1.2


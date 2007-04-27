From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH 2/2] Rename get_property to of_get_property: drivers/net
Date: Fri, 27 Apr 2007 14:55:08 +1000
Message-ID: <20070427145508.9c5641a2.sfr@canb.auug.org.au>
References: <20070427145107.4f73e436.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ppc-dev <linuxppc-dev@ozlabs.org>, akpm@linux-foundation.org,
	paulus@samba.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20070427145107.4f73e436.sfr@canb.auug.org.au>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

This is part of the consolidation of the OpenFirmware code ebtween
PowerPC and Sparc.

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/bmac.c           |    5 +++--
 drivers/net/ehea/ehea_main.c |    6 +++---
 drivers/net/mace.c           |    4 ++--
 drivers/net/pasemi_mac.c     |    2 +-
 drivers/net/spider_net.c     |    4 ++--
 drivers/net/sungem.c         |    2 +-
 drivers/net/sungem_phy.c     |    2 +-
 drivers/net/ucc_geth.c       |   18 +++++++++---------
 drivers/net/ucc_geth_mii.c   |    4 ++--
 9 files changed, 24 insertions(+), 23 deletions(-)

Jeff,

This patch is based on a merge between Paulus' for-2.6.22 tree and your
upstream tree.  As such it depends on changes in Paulus' tree to be
merged first.  This patch was originally in Paulus' tree but has been
reverted from there.

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --git a/drivers/net/bmac.c b/drivers/net/bmac.c
index c143304..aa01ba3 100644
--- a/drivers/net/bmac.c
+++ b/drivers/net/bmac.c
@@ -1261,9 +1261,10 @@ static int __devinit bmac_probe(struct macio_dev *mdev, const struct of_device_i
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
index ece9159..a091887 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -2526,7 +2526,7 @@ static int ehea_setup_ports(struct ehea_adapter *adapter)
 	lhea_dn = adapter->ebus_dev->ofdev.node;
 	while ((eth_dn = of_get_next_child(lhea_dn, eth_dn))) {
 
-		dn_log_port_id = get_property(eth_dn, "ibm,hea-port-no",
+		dn_log_port_id = of_get_property(eth_dn, "ibm,hea-port-no",
 						    NULL);
 		if (!dn_log_port_id) {
 			ehea_error("bad device node: eth_dn name=%s",
@@ -2565,7 +2565,7 @@ static struct device_node *ehea_get_eth_dn(struct ehea_adapter *adapter,
 	lhea_dn = adapter->ebus_dev->ofdev.node;
 	while ((eth_dn = of_get_next_child(lhea_dn, eth_dn))) {
 
-		dn_log_port_id = get_property(eth_dn, "ibm,hea-port-no",
+		dn_log_port_id = of_get_property(eth_dn, "ibm,hea-port-no",
 						    NULL);
 		if (dn_log_port_id)
 			if (*dn_log_port_id == logical_port_id)
@@ -2697,7 +2697,7 @@ static int __devinit ehea_probe_adapter(struct ibmebus_dev *dev,
 
 	adapter->ebus_dev = dev;
 
-	adapter_handle = get_property(dev->ofdev.node, "ibm,hea-handle",
+	adapter_handle = of_get_property(dev->ofdev.node, "ibm,hea-handle",
 					    NULL);
 	if (adapter_handle)
 		adapter->handle = *adapter_handle;
diff --git a/drivers/net/mace.c b/drivers/net/mace.c
index 9ec24f0..7018ba9 100644
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
index d670ac7..cb7a8e7 100644
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
index e3019d5..1c4a69e 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -1831,7 +1831,7 @@ try_host_fw:
 	if (!dn)
 		goto out_err;
 
-	fw_prop = get_property(dn, "firmware", &fw_size);
+	fw_prop = of_get_property(dn, "firmware", &fw_size);
 	if (!fw_prop)
 		goto out_err;
 
@@ -2237,7 +2237,7 @@ spider_net_setup_netdev(struct spider_net_card *card)
 	if (!dn)
 		return -EIO;
 
-	mac = get_property(dn, "local-mac-address", NULL);
+	mac = of_get_property(dn, "local-mac-address", NULL);
 	if (!mac)
 		return -EIO;
 	memcpy(addr.sa_data, mac, ETH_ALEN);
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 08ea61d..6b1cd74 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -2929,7 +2929,7 @@ static int __devinit gem_get_device_address(struct gem *gp)
 #elif defined(CONFIG_PPC_PMAC)
 	const unsigned char *addr;
 
-	addr = get_property(gp->of_node, "local-mac-address", NULL);
+	addr = of_get_property(gp->of_node, "local-mac-address", NULL);
 	if (addr == NULL) {
 		printk("\n");
 		printk(KERN_ERR "%s: can't get mac-address\n", dev->name);
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
 
-- 
1.5.1.2

From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 17/37] drivers/net: use .dev.of_node instead of .node in
	struct of_device
Date: Thu, 11 Mar 2010 11:05:22 -0700
Message-ID: <20100311180521.4824.98943.stgit__4845.25261349535$1268331353$gmane$org@angua>
References: <20100311174830.4824.19820.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:63703 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933669Ab0CKSF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:05:26 -0500
In-Reply-To: <20100311174830.4824.19820.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.node is being removed

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/net/can/sja1000/sja1000_of_platform.c |    4 ++--
 drivers/net/ehea/ehea_main.c                  |   14 ++++++-------
 drivers/net/greth.c                           |    3 ++-
 drivers/net/ibm_newemac/core.c                |   13 ++++++------
 drivers/net/ibm_newemac/debug.c               |    9 ++++----
 drivers/net/ibm_newemac/debug.h               |    4 ++--
 drivers/net/ibm_newemac/mal.c                 |   28 +++++++++++++------------
 drivers/net/ibm_newemac/rgmii.c               |   12 +++++------
 drivers/net/ibm_newemac/tah.c                 |    7 ++++--
 drivers/net/ibm_newemac/zmii.c                |    9 ++++----
 drivers/net/myri_sbus.c                       |    2 +-
 drivers/net/niu.c                             |   10 ++++-----
 drivers/net/phy/mdio-gpio.c                   |    6 +++--
 drivers/net/sunbmac.c                         |    6 +++--
 drivers/net/sunhme.c                          |    8 ++++---
 drivers/net/sunlance.c                        |    6 +++--
 drivers/net/sunqe.c                           |    6 +++--
 drivers/net/xilinx_emaclite.c                 |   10 ++++-----
 18 files changed, 81 insertions(+), 76 deletions(-)

diff --git a/drivers/net/can/sja1000/sja1000_of_platform.c b/drivers/net/can/sja1000/sja1000_of_platform.c
index 9dd076a..dc5f20c 100644
--- a/drivers/net/can/sja1000/sja1000_of_platform.c
+++ b/drivers/net/can/sja1000/sja1000_of_platform.c
@@ -72,7 +72,7 @@ static int __devexit sja1000_ofp_remove(struct of_device *ofdev)
 {
 	struct net_device *dev = dev_get_drvdata(&ofdev->dev);
 	struct sja1000_priv *priv = netdev_priv(dev);
-	struct device_node *np = ofdev->node;
+	struct device_node *np = ofdev->dev.of_node;
 	struct resource res;
 
 	dev_set_drvdata(&ofdev->dev, NULL);
@@ -91,7 +91,7 @@ static int __devexit sja1000_ofp_remove(struct of_device *ofdev)
 static int __devinit sja1000_ofp_probe(struct of_device *ofdev,
 				       const struct of_device_id *id)
 {
-	struct device_node *np = ofdev->node;
+	struct device_node *np = ofdev->dev.of_node;
 	struct net_device *dev;
 	struct sja1000_priv *priv;
 	struct resource res;
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index b004eab..3cdc938 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -3034,7 +3034,7 @@ static DEVICE_ATTR(log_port_id, S_IRUSR | S_IRGRP | S_IROTH, ehea_show_port_id,
 static void __devinit logical_port_release(struct device *dev)
 {
 	struct ehea_port *port = container_of(dev, struct ehea_port, ofdev.dev);
-	of_node_put(port->ofdev.node);
+	of_node_put(port->ofdev.dev.of_node);
 }
 
 static struct device *ehea_register_port(struct ehea_port *port,
@@ -3042,7 +3042,7 @@ static struct device *ehea_register_port(struct ehea_port *port,
 {
 	int ret;
 
-	port->ofdev.node = of_node_get(dn);
+	port->ofdev.dev.of_node = of_node_get(dn);
 	port->ofdev.dev.parent = &port->adapter->ofdev->dev;
 	port->ofdev.dev.bus = &ibmebus_bus_type;
 
@@ -3209,7 +3209,7 @@ static int ehea_setup_ports(struct ehea_adapter *adapter)
 	const u32 *dn_log_port_id;
 	int i = 0;
 
-	lhea_dn = adapter->ofdev->node;
+	lhea_dn = adapter->ofdev->dev.of_node;
 	while ((eth_dn = of_get_next_child(lhea_dn, eth_dn))) {
 
 		dn_log_port_id = of_get_property(eth_dn, "ibm,hea-port-no",
@@ -3248,7 +3248,7 @@ static struct device_node *ehea_get_eth_dn(struct ehea_adapter *adapter,
 	struct device_node *eth_dn = NULL;
 	const u32 *dn_log_port_id;
 
-	lhea_dn = adapter->ofdev->node;
+	lhea_dn = adapter->ofdev->dev.of_node;
 	while ((eth_dn = of_get_next_child(lhea_dn, eth_dn))) {
 
 		dn_log_port_id = of_get_property(eth_dn, "ibm,hea-port-no",
@@ -3378,7 +3378,7 @@ static int __devinit ehea_probe_adapter(struct of_device *dev,
 	const u64 *adapter_handle;
 	int ret;
 
-	if (!dev || !dev->node) {
+	if (!dev || !dev->dev.of_node) {
 		ehea_error("Invalid ibmebus device probed");
 		return -EINVAL;
 	}
@@ -3394,14 +3394,14 @@ static int __devinit ehea_probe_adapter(struct of_device *dev,
 
 	adapter->ofdev = dev;
 
-	adapter_handle = of_get_property(dev->node, "ibm,hea-handle",
+	adapter_handle = of_get_property(dev->dev.of_node, "ibm,hea-handle",
 					 NULL);
 	if (adapter_handle)
 		adapter->handle = *adapter_handle;
 
 	if (!adapter->handle) {
 		dev_err(&dev->dev, "failed getting handle for adapter"
-			" '%s'\n", dev->node->full_name);
+			" '%s'\n", dev->dev.of_node->full_name);
 		ret = -ENODEV;
 		goto out_free_ad;
 	}
diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index 2b9c1cb..04be634 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -1499,7 +1499,8 @@ static int __devinit greth_of_probe(struct of_device *ofdev, const struct of_dev
 	if (i == 6) {
 		const unsigned char *addr;
 		int len;
-		addr = of_get_property(ofdev->node, "local-mac-address", &len);
+		addr = of_get_property(ofdev->dev.of_node, "local-mac-address",
+					&len);
 		if (addr != NULL && len == 6) {
 			for (i = 0; i < 6; i++)
 				macaddr[i] = (unsigned int) addr[i];
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index fb0ac6d..bad72ba 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -135,7 +135,8 @@ static inline void emac_report_timeout_error(struct emac_instance *dev,
 				  EMAC_FTR_440EP_PHY_CLK_FIX))
 		DBG(dev, "%s" NL, error);
 	else if (net_ratelimit())
-		printk(KERN_ERR "%s: %s\n", dev->ofdev->node->full_name, error);
+		printk(KERN_ERR "%s: %s\n", dev->ofdev->dev.of_node->full_name,
+			error);
 }
 
 /* EMAC PHY clock workaround:
@@ -2184,7 +2185,7 @@ static void emac_ethtool_get_drvinfo(struct net_device *ndev,
 	strcpy(info->version, DRV_VERSION);
 	info->fw_version[0] = '\0';
 	sprintf(info->bus_info, "PPC 4xx EMAC-%d %s",
-		dev->cell_index, dev->ofdev->node->full_name);
+		dev->cell_index, dev->ofdev->dev.of_node->full_name);
 	info->regdump_len = emac_ethtool_get_regs_len(ndev);
 }
 
@@ -2378,7 +2379,7 @@ static int __devinit emac_read_uint_prop(struct device_node *np, const char *nam
 
 static int __devinit emac_init_phy(struct emac_instance *dev)
 {
-	struct device_node *np = dev->ofdev->node;
+	struct device_node *np = dev->ofdev->dev.of_node;
 	struct net_device *ndev = dev->ndev;
 	u32 phy_map, adv;
 	int i;
@@ -2513,7 +2514,7 @@ static int __devinit emac_init_phy(struct emac_instance *dev)
 
 static int __devinit emac_init_config(struct emac_instance *dev)
 {
-	struct device_node *np = dev->ofdev->node;
+	struct device_node *np = dev->ofdev->dev.of_node;
 	const void *p;
 	unsigned int plen;
 	const char *pm, *phy_modes[] = {
@@ -2722,7 +2723,7 @@ static int __devinit emac_probe(struct of_device *ofdev,
 {
 	struct net_device *ndev;
 	struct emac_instance *dev;
-	struct device_node *np = ofdev->node;
+	struct device_node *np = ofdev->dev.of_node;
 	struct device_node **blist = NULL;
 	int err, i;
 
@@ -2809,7 +2810,7 @@ static int __devinit emac_probe(struct of_device *ofdev,
 	err = mal_register_commac(dev->mal, &dev->commac);
 	if (err) {
 		printk(KERN_ERR "%s: failed to register with mal %s!\n",
-		       np->full_name, dev->mal_dev->node->full_name);
+		       np->full_name, dev->mal_dev->dev.of_node->full_name);
 		goto err_rel_deps;
 	}
 	dev->rx_skb_size = emac_rx_skb_size(ndev->mtu);
diff --git a/drivers/net/ibm_newemac/debug.c b/drivers/net/ibm_newemac/debug.c
index 775c850..3995faf 100644
--- a/drivers/net/ibm_newemac/debug.c
+++ b/drivers/net/ibm_newemac/debug.c
@@ -33,7 +33,7 @@ static void emac_desc_dump(struct emac_instance *p)
 	int i;
 	printk("** EMAC %s TX BDs **\n"
 	       " tx_cnt = %d tx_slot = %d ack_slot = %d\n",
-	       p->ofdev->node->full_name,
+	       p->ofdev->dev.of_node->full_name,
 	       p->tx_cnt, p->tx_slot, p->ack_slot);
 	for (i = 0; i < NUM_TX_BUFF / 2; ++i)
 		printk
@@ -49,7 +49,7 @@ static void emac_desc_dump(struct emac_instance *p)
 	printk("** EMAC %s RX BDs **\n"
 	       " rx_slot = %d flags = 0x%lx rx_skb_size = %d rx_sync_size = %d\n"
 	       " rx_sg_skb = 0x%p\n",
-	       p->ofdev->node->full_name,
+	       p->ofdev->dev.of_node->full_name,
 	       p->rx_slot, p->commac.flags, p->rx_skb_size,
 	       p->rx_sync_size, p->rx_sg_skb);
 	for (i = 0; i < NUM_RX_BUFF / 2; ++i)
@@ -77,7 +77,8 @@ static void emac_mac_dump(struct emac_instance *dev)
 	       "MR0 = 0x%08x MR1 = 0x%08x TMR0 = 0x%08x TMR1 = 0x%08x\n"
 	       "RMR = 0x%08x ISR = 0x%08x ISER = 0x%08x\n"
 	       "IAR = %04x%08x VTPID = 0x%04x VTCI = 0x%04x\n",
-	       dev->ofdev->node->full_name, in_be32(&p->mr0), in_be32(&p->mr1),
+	       dev->ofdev->dev.of_node->full_name,
+	       in_be32(&p->mr0), in_be32(&p->mr1),
 	       in_be32(&p->tmr0), in_be32(&p->tmr1),
 	       in_be32(&p->rmr), in_be32(&p->isr), in_be32(&p->iser),
 	       in_be32(&p->iahr), in_be32(&p->ialr), in_be32(&p->vtpid),
@@ -128,7 +129,7 @@ static void emac_mal_dump(struct mal_instance *mal)
 	       "CFG = 0x%08x ESR = 0x%08x IER = 0x%08x\n"
 	       "TX|CASR = 0x%08x CARR = 0x%08x EOBISR = 0x%08x DEIR = 0x%08x\n"
 	       "RX|CASR = 0x%08x CARR = 0x%08x EOBISR = 0x%08x DEIR = 0x%08x\n",
-	       mal->ofdev->node->full_name,
+	       mal->ofdev->dev.of_node->full_name,
 	       get_mal_dcrn(mal, MAL_CFG), get_mal_dcrn(mal, MAL_ESR),
 	       get_mal_dcrn(mal, MAL_IER),
 	       get_mal_dcrn(mal, MAL_TXCASR), get_mal_dcrn(mal, MAL_TXCARR),
diff --git a/drivers/net/ibm_newemac/debug.h b/drivers/net/ibm_newemac/debug.h
index b631842..e596c77 100644
--- a/drivers/net/ibm_newemac/debug.h
+++ b/drivers/net/ibm_newemac/debug.h
@@ -53,8 +53,8 @@ extern void emac_dbg_dump_all(void);
 
 #endif
 
-#define EMAC_DBG(dev, name, fmt, arg...) \
-	printk(KERN_DEBUG #name "%s: " fmt, dev->ofdev->node->full_name, ## arg)
+#define EMAC_DBG(d, name, fmt, arg...) \
+	printk(KERN_DEBUG #name "%s: " fmt, d->ofdev->dev.of_node->full_name, ## arg)
 
 #if DBG_LEVEL > 0
 #  define DBG(d,f,x...)		EMAC_DBG(d, emac, f, ##x)
diff --git a/drivers/net/ibm_newemac/mal.c b/drivers/net/ibm_newemac/mal.c
index 2a2fc17..29ed695 100644
--- a/drivers/net/ibm_newemac/mal.c
+++ b/drivers/net/ibm_newemac/mal.c
@@ -537,11 +537,11 @@ static int __devinit mal_probe(struct of_device *ofdev,
 	}
 	mal->index = index;
 	mal->ofdev = ofdev;
-	mal->version = of_device_is_compatible(ofdev->node, "ibm,mcmal2") ? 2 : 1;
+	mal->version = of_device_is_compatible(ofdev->dev.of_node, "ibm,mcmal2") ? 2 : 1;
 
 	MAL_DBG(mal, "probe" NL);
 
-	prop = of_get_property(ofdev->node, "num-tx-chans", NULL);
+	prop = of_get_property(ofdev->dev.of_node, "num-tx-chans", NULL);
 	if (prop == NULL) {
 		printk(KERN_ERR
 		       "mal%d: can't find MAL num-tx-chans property!\n",
@@ -551,7 +551,7 @@ static int __devinit mal_probe(struct of_device *ofdev,
 	}
 	mal->num_tx_chans = prop[0];
 
-	prop = of_get_property(ofdev->node, "num-rx-chans", NULL);
+	prop = of_get_property(ofdev->dev.of_node, "num-rx-chans", NULL);
 	if (prop == NULL) {
 		printk(KERN_ERR
 		       "mal%d: can't find MAL num-rx-chans property!\n",
@@ -561,14 +561,14 @@ static int __devinit mal_probe(struct of_device *ofdev,
 	}
 	mal->num_rx_chans = prop[0];
 
-	dcr_base = dcr_resource_start(ofdev->node, 0);
+	dcr_base = dcr_resource_start(ofdev->dev.of_node, 0);
 	if (dcr_base == 0) {
 		printk(KERN_ERR
 		       "mal%d: can't find DCR resource!\n", index);
 		err = -ENODEV;
 		goto fail;
 	}
-	mal->dcr_host = dcr_map(ofdev->node, dcr_base, 0x100);
+	mal->dcr_host = dcr_map(ofdev->dev.of_node, dcr_base, 0x100);
 	if (!DCR_MAP_OK(mal->dcr_host)) {
 		printk(KERN_ERR
 		       "mal%d: failed to map DCRs !\n", index);
@@ -576,28 +576,28 @@ static int __devinit mal_probe(struct of_device *ofdev,
 		goto fail;
 	}
 
-	if (of_device_is_compatible(ofdev->node, "ibm,mcmal-405ez")) {
+	if (of_device_is_compatible(ofdev->dev.of_node, "ibm,mcmal-405ez")) {
 #if defined(CONFIG_IBM_NEW_EMAC_MAL_CLR_ICINTSTAT) && \
 		defined(CONFIG_IBM_NEW_EMAC_MAL_COMMON_ERR)
 		mal->features |= (MAL_FTR_CLEAR_ICINTSTAT |
 				MAL_FTR_COMMON_ERR_INT);
 #else
 		printk(KERN_ERR "%s: Support for 405EZ not enabled!\n",
-				ofdev->node->full_name);
+				ofdev->dev.of_node->full_name);
 		err = -ENODEV;
 		goto fail;
 #endif
 	}
 
-	mal->txeob_irq = irq_of_parse_and_map(ofdev->node, 0);
-	mal->rxeob_irq = irq_of_parse_and_map(ofdev->node, 1);
-	mal->serr_irq = irq_of_parse_and_map(ofdev->node, 2);
+	mal->txeob_irq = irq_of_parse_and_map(ofdev->dev.of_node, 0);
+	mal->rxeob_irq = irq_of_parse_and_map(ofdev->dev.of_node, 1);
+	mal->serr_irq = irq_of_parse_and_map(ofdev->dev.of_node, 2);
 
 	if (mal_has_feature(mal, MAL_FTR_COMMON_ERR_INT)) {
 		mal->txde_irq = mal->rxde_irq = mal->serr_irq;
 	} else {
-		mal->txde_irq = irq_of_parse_and_map(ofdev->node, 3);
-		mal->rxde_irq = irq_of_parse_and_map(ofdev->node, 4);
+		mal->txde_irq = irq_of_parse_and_map(ofdev->dev.of_node, 3);
+		mal->rxde_irq = irq_of_parse_and_map(ofdev->dev.of_node, 4);
 	}
 
 	if (mal->txeob_irq == NO_IRQ || mal->rxeob_irq == NO_IRQ ||
@@ -628,7 +628,7 @@ static int __devinit mal_probe(struct of_device *ofdev,
 	/* Current Axon is not happy with priority being non-0, it can
 	 * deadlock, fix it up here
 	 */
-	if (of_device_is_compatible(ofdev->node, "ibm,mcmal-axon"))
+	if (of_device_is_compatible(ofdev->dev.of_node, "ibm,mcmal-axon"))
 		cfg &= ~(MAL2_CFG_RPP_10 | MAL2_CFG_WPP_10);
 
 	/* Apply configuration */
@@ -700,7 +700,7 @@ static int __devinit mal_probe(struct of_device *ofdev,
 
 	printk(KERN_INFO
 	       "MAL v%d %s, %d TX channels, %d RX channels\n",
-	       mal->version, ofdev->node->full_name,
+	       mal->version, ofdev->dev.of_node->full_name,
 	       mal->num_tx_chans, mal->num_rx_chans);
 
 	/* Advertise this instance to the rest of the world */
diff --git a/drivers/net/ibm_newemac/rgmii.c b/drivers/net/ibm_newemac/rgmii.c
index 8d76cb8..57fc784 100644
--- a/drivers/net/ibm_newemac/rgmii.c
+++ b/drivers/net/ibm_newemac/rgmii.c
@@ -102,7 +102,7 @@ int __devinit rgmii_attach(struct of_device *ofdev, int input, int mode)
 	/* Check if we need to attach to a RGMII */
 	if (input < 0 || !rgmii_valid_mode(mode)) {
 		printk(KERN_ERR "%s: unsupported settings !\n",
-		       ofdev->node->full_name);
+		       ofdev->dev.of_node->full_name);
 		return -ENODEV;
 	}
 
@@ -112,7 +112,7 @@ int __devinit rgmii_attach(struct of_device *ofdev, int input, int mode)
 	out_be32(&p->fer, in_be32(&p->fer) | rgmii_mode_mask(mode, input));
 
 	printk(KERN_NOTICE "%s: input %d in %s mode\n",
-	       ofdev->node->full_name, input, rgmii_mode_name(mode));
+	       ofdev->dev.of_node->full_name, input, rgmii_mode_name(mode));
 
 	++dev->users;
 
@@ -230,7 +230,7 @@ void *rgmii_dump_regs(struct of_device *ofdev, void *buf)
 static int __devinit rgmii_probe(struct of_device *ofdev,
 				 const struct of_device_id *match)
 {
-	struct device_node *np = ofdev->node;
+	struct device_node *np = ofdev->dev.of_node;
 	struct rgmii_instance *dev;
 	struct resource regs;
 	int rc;
@@ -263,11 +263,11 @@ static int __devinit rgmii_probe(struct of_device *ofdev,
 	}
 
 	/* Check for RGMII flags */
-	if (of_get_property(ofdev->node, "has-mdio", NULL))
+	if (of_get_property(ofdev->dev.of_node, "has-mdio", NULL))
 		dev->flags |= EMAC_RGMII_FLAG_HAS_MDIO;
 
 	/* CAB lacks the right properties, fix this up */
-	if (of_device_is_compatible(ofdev->node, "ibm,rgmii-axon"))
+	if (of_device_is_compatible(ofdev->dev.of_node, "ibm,rgmii-axon"))
 		dev->flags |= EMAC_RGMII_FLAG_HAS_MDIO;
 
 	DBG2(dev, " Boot FER = 0x%08x, SSR = 0x%08x\n",
@@ -278,7 +278,7 @@ static int __devinit rgmii_probe(struct of_device *ofdev,
 
 	printk(KERN_INFO
 	       "RGMII %s initialized with%s MDIO support\n",
-	       ofdev->node->full_name,
+	       ofdev->dev.of_node->full_name,
 	       (dev->flags & EMAC_RGMII_FLAG_HAS_MDIO) ? "" : "out");
 
 	wmb();
diff --git a/drivers/net/ibm_newemac/tah.c b/drivers/net/ibm_newemac/tah.c
index 30173a9..4f64b00 100644
--- a/drivers/net/ibm_newemac/tah.c
+++ b/drivers/net/ibm_newemac/tah.c
@@ -57,7 +57,8 @@ void tah_reset(struct of_device *ofdev)
 		--n;
 
 	if (unlikely(!n))
-		printk(KERN_ERR "%s: reset timeout\n", ofdev->node->full_name);
+		printk(KERN_ERR "%s: reset timeout\n",
+			ofdev->dev.of_node->full_name);
 
 	/* 10KB TAH TX FIFO accomodates the max MTU of 9000 */
 	out_be32(&p->mr,
@@ -89,7 +90,7 @@ void *tah_dump_regs(struct of_device *ofdev, void *buf)
 static int __devinit tah_probe(struct of_device *ofdev,
 			       const struct of_device_id *match)
 {
-	struct device_node *np = ofdev->node;
+	struct device_node *np = ofdev->dev.of_node;
 	struct tah_instance *dev;
 	struct resource regs;
 	int rc;
@@ -127,7 +128,7 @@ static int __devinit tah_probe(struct of_device *ofdev,
 	tah_reset(ofdev);
 
 	printk(KERN_INFO
-	       "TAH %s initialized\n", ofdev->node->full_name);
+	       "TAH %s initialized\n", ofdev->dev.of_node->full_name);
 	wmb();
 
 	return 0;
diff --git a/drivers/net/ibm_newemac/zmii.c b/drivers/net/ibm_newemac/zmii.c
index 17b1541..724e00e 100644
--- a/drivers/net/ibm_newemac/zmii.c
+++ b/drivers/net/ibm_newemac/zmii.c
@@ -120,13 +120,14 @@ int __devinit zmii_attach(struct of_device *ofdev, int input, int *mode)
 			dev->mode = *mode;
 
 		printk(KERN_NOTICE "%s: bridge in %s mode\n",
-		       ofdev->node->full_name, zmii_mode_name(dev->mode));
+		       ofdev->dev.of_node->full_name,
+		       zmii_mode_name(dev->mode));
 	} else {
 		/* All inputs must use the same mode */
 		if (*mode != PHY_MODE_NA && *mode != dev->mode) {
 			printk(KERN_ERR
 			       "%s: invalid mode %d specified for input %d\n",
-			       ofdev->node->full_name, *mode, input);
+			       ofdev->dev.of_node->full_name, *mode, input);
 			mutex_unlock(&dev->lock);
 			return -EINVAL;
 		}
@@ -232,7 +233,7 @@ void *zmii_dump_regs(struct of_device *ofdev, void *buf)
 static int __devinit zmii_probe(struct of_device *ofdev,
 				const struct of_device_id *match)
 {
-	struct device_node *np = ofdev->node;
+	struct device_node *np = ofdev->dev.of_node;
 	struct zmii_instance *dev;
 	struct resource regs;
 	int rc;
@@ -272,7 +273,7 @@ static int __devinit zmii_probe(struct of_device *ofdev,
 	out_be32(&dev->base->fer, 0);
 
 	printk(KERN_INFO
-	       "ZMII %s initialized\n", ofdev->node->full_name);
+	       "ZMII %s initialized\n", ofdev->dev.of_node->full_name);
 	wmb();
 	dev_set_drvdata(&ofdev->dev, dev);
 
diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index 8b43130..be4e6e4 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -928,7 +928,7 @@ static const struct net_device_ops myri_ops = {
 
 static int __devinit myri_sbus_probe(struct of_device *op, const struct of_device_id *match)
 {
-	struct device_node *dp = op->node;
+	struct device_node *dp = op->dev.of_node;
 	static unsigned version_printed;
 	struct net_device *dev;
 	struct myri_eth *mp;
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 0678f31..1fcf1ac 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -9093,7 +9093,7 @@ static int __devinit niu_n2_irq_init(struct niu *np, u8 *ldg_num_map)
 	const u32 *int_prop;
 	int i;
 
-	int_prop = of_get_property(op->node, "interrupts", NULL);
+	int_prop = of_get_property(op->dev.of_node, "interrupts", NULL);
 	if (!int_prop)
 		return -ENODEV;
 
@@ -9244,7 +9244,7 @@ static int __devinit niu_get_of_props(struct niu *np)
 	int prop_len;
 
 	if (np->parent->plat_type == PLAT_TYPE_NIU)
-		dp = np->op->node;
+		dp = np->op->dev.of_node;
 	else
 		dp = pci_device_to_OF_node(np->pdev);
 
@@ -10055,10 +10055,10 @@ static int __devinit niu_of_probe(struct of_device *op,
 
 	niu_driver_version();
 
-	reg = of_get_property(op->node, "reg", NULL);
+	reg = of_get_property(op->dev.of_node, "reg", NULL);
 	if (!reg) {
 		dev_err(&op->dev, "%s: No 'reg' property, aborting\n",
-			op->node->full_name);
+			op->dev.of_node->full_name);
 		return -ENODEV;
 	}
 
@@ -10071,7 +10071,7 @@ static int __devinit niu_of_probe(struct of_device *op,
 	np = netdev_priv(dev);
 
 	memset(&parent_id, 0, sizeof(parent_id));
-	parent_id.of = of_get_parent(op->node);
+	parent_id.of = of_get_parent(op->dev.of_node);
 
 	np->parent = niu_get_parent(np, &parent_id,
 				    PLAT_TYPE_NIU);
diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 3589713..641973c 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -199,12 +199,12 @@ static int __devinit mdio_ofgpio_probe(struct of_device *ofdev,
 	if (!pdata)
 		return -ENOMEM;
 
-	ret = of_get_gpio(ofdev->node, 0);
+	ret = of_get_gpio(ofdev->dev.of_node, 0);
 	if (ret < 0)
 		goto out_free;
 	pdata->mdc = ret;
 
-	ret = of_get_gpio(ofdev->node, 1);
+	ret = of_get_gpio(ofdev->dev.of_node, 1);
 	if (ret < 0)
 		goto out_free;
 	pdata->mdio = ret;
@@ -213,7 +213,7 @@ static int __devinit mdio_ofgpio_probe(struct of_device *ofdev,
 	if (!new_bus)
 		goto out_free;
 
-	ret = of_mdiobus_register(new_bus, ofdev->node);
+	ret = of_mdiobus_register(new_bus, ofdev->dev.of_node);
 	if (ret)
 		mdio_gpio_bus_deinit(&ofdev->dev);
 
diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index a0bd361..9b6aa7c 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -1133,8 +1133,8 @@ static int __devinit bigmac_ether_init(struct of_device *op,
 		goto fail_and_cleanup;
 
 	/* Get supported SBUS burst sizes. */
-	bsizes = of_getintprop_default(qec_op->node, "burst-sizes", 0xff);
-	bsizes_more = of_getintprop_default(qec_op->node, "burst-sizes", 0xff);
+	bsizes = of_getintprop_default(qec_op->dev.of_node, "burst-sizes", 0xff);
+	bsizes_more = of_getintprop_default(qec_op->dev.of_node, "burst-sizes", 0xff);
 
 	bsizes &= 0xff;
 	if (bsizes_more != 0xff)
@@ -1186,7 +1186,7 @@ static int __devinit bigmac_ether_init(struct of_device *op,
 	}
 
 	/* Get the board revision of this BigMAC. */
-	bp->board_rev = of_getintprop_default(bp->bigmac_op->node,
+	bp->board_rev = of_getintprop_default(bp->bigmac_op->dev.of_node,
 					      "board-version", 1);
 
 	/* Init auto-negotiation timer state. */
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index b17dbb1..c6463f7 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -2483,7 +2483,7 @@ static void hme_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info
 	else {
 		const struct linux_prom_registers *regs;
 		struct of_device *op = hp->happy_dev;
-		regs = of_get_property(op->node, "regs", NULL);
+		regs = of_get_property(op->dev.of_node, "regs", NULL);
 		if (regs)
 			sprintf(info->bus_info, "SBUS:%d",
 				regs->which_io);
@@ -2643,14 +2643,14 @@ static const struct net_device_ops hme_netdev_ops = {
 #ifdef CONFIG_SBUS
 static int __devinit happy_meal_sbus_probe_one(struct of_device *op, int is_qfe)
 {
-	struct device_node *dp = op->node, *sbus_dp;
+	struct device_node *dp = op->dev.of_node, *sbus_dp;
 	struct quattro *qp = NULL;
 	struct happy_meal *hp;
 	struct net_device *dev;
 	int i, qfe_slot = -1;
 	int err = -ENODEV;
 
-	sbus_dp = to_of_device(op->dev.parent)->node;
+	sbus_dp = to_of_device(op->dev.parent)->dev.of_node;
 
 	/* We can match PCI devices too, do not accept those here. */
 	if (strcmp(sbus_dp->name, "sbus"))
@@ -3241,7 +3241,7 @@ static void happy_meal_pci_exit(void)
 #ifdef CONFIG_SBUS
 static int __devinit hme_sbus_probe(struct of_device *op, const struct of_device_id *match)
 {
-	struct device_node *dp = op->node;
+	struct device_node *dp = op->dev.of_node;
 	const char *model = of_get_property(dp, "model", NULL);
 	int is_qfe = (match->data != NULL);
 
diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index d7c73f4..a139861 100644
--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -1324,7 +1324,7 @@ static int __devinit sparc_lance_probe_one(struct of_device *op,
 					   struct of_device *ledma,
 					   struct of_device *lebuffer)
 {
-	struct device_node *dp = op->node;
+	struct device_node *dp = op->dev.of_node;
 	static unsigned version_printed;
 	struct lance_private *lp;
 	struct net_device *dev;
@@ -1411,7 +1411,7 @@ static int __devinit sparc_lance_probe_one(struct of_device *op,
 
 	lp->burst_sizes = 0;
 	if (lp->ledma) {
-		struct device_node *ledma_dp = ledma->node;
+		struct device_node *ledma_dp = ledma->dev.of_node;
 		struct device_node *sbus_dp;
 		unsigned int sbmask;
 		const char *prop;
@@ -1507,7 +1507,7 @@ fail:
 static int __devinit sunlance_sbus_probe(struct of_device *op, const struct of_device_id *match)
 {
 	struct of_device *parent = to_of_device(op->dev.parent);
-	struct device_node *parent_dp = parent->node;
+	struct device_node *parent_dp = parent->dev.of_node;
 	int err;
 
 	if (!strcmp(parent_dp->name, "ledma")) {
diff --git a/drivers/net/sunqe.c b/drivers/net/sunqe.c
index be637dc..9864f4f 100644
--- a/drivers/net/sunqe.c
+++ b/drivers/net/sunqe.c
@@ -696,7 +696,7 @@ static void qe_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 	strcpy(info->version, "3.0");
 
 	op = qep->op;
-	regs = of_get_property(op->node, "reg", NULL);
+	regs = of_get_property(op->dev.of_node, "reg", NULL);
 	if (regs)
 		sprintf(info->bus_info, "SBUS:%d", regs->which_io);
 
@@ -800,7 +800,7 @@ static struct sunqec * __devinit get_qec(struct of_device *child)
 			if (qec_global_reset(qecp->gregs))
 				goto fail;
 
-			qecp->qec_bursts = qec_get_burst(op->node);
+			qecp->qec_bursts = qec_get_burst(op->dev.of_node);
 
 			qec_init_once(qecp, op);
 
@@ -858,7 +858,7 @@ static int __devinit qec_ether_init(struct of_device *op)
 
 	res = -ENODEV;
 
-	i = of_getintprop_default(op->node, "channel#", -1);
+	i = of_getintprop_default(op->dev.of_node, "channel#", -1);
 	if (i == -1)
 		goto fail;
 	qe->channel = i;
diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emaclite.c
index 1a74594..40b8fdc 100644
--- a/drivers/net/xilinx_emaclite.c
+++ b/drivers/net/xilinx_emaclite.c
@@ -1089,7 +1089,7 @@ static void xemaclite_remove_ndev(struct net_device *ndev)
  */
 static bool get_bool(struct of_device *ofdev, const char *s)
 {
-	u32 *p = (u32 *)of_get_property(ofdev->node, s, NULL);
+	u32 *p = (u32 *)of_get_property(ofdev->dev.of_node, s, NULL);
 
 	if (p) {
 		return (bool)*p;
@@ -1131,14 +1131,14 @@ static int __devinit xemaclite_of_probe(struct of_device *ofdev,
 	dev_info(dev, "Device Tree Probing\n");
 
 	/* Get iospace for the device */
-	rc = of_address_to_resource(ofdev->node, 0, &r_mem);
+	rc = of_address_to_resource(ofdev->dev.of_node, 0, &r_mem);
 	if (rc) {
 		dev_err(dev, "invalid address\n");
 		return rc;
 	}
 
 	/* Get IRQ for the device */
-	rc = of_irq_to_resource(ofdev->node, 0, &r_irq);
+	rc = of_irq_to_resource(ofdev->dev.of_node, 0, &r_irq);
 	if (rc == NO_IRQ) {
 		dev_err(dev, "no IRQ found\n");
 		return rc;
@@ -1183,7 +1183,7 @@ static int __devinit xemaclite_of_probe(struct of_device *ofdev,
 	lp->next_rx_buf_to_use = 0x0;
 	lp->tx_ping_pong = get_bool(ofdev, "xlnx,tx-ping-pong");
 	lp->rx_ping_pong = get_bool(ofdev, "xlnx,rx-ping-pong");
-	mac_address = of_get_mac_address(ofdev->node);
+	mac_address = of_get_mac_address(ofdev->dev.of_node);
 
 	if (mac_address)
 		/* Set the MAC address. */
@@ -1198,7 +1198,7 @@ static int __devinit xemaclite_of_probe(struct of_device *ofdev,
 	/* Set the MAC address in the EmacLite device */
 	xemaclite_update_address(lp, ndev->dev_addr);
 
-	lp->phy_node = of_parse_phandle(ofdev->node, "phy-handle", 0);
+	lp->phy_node = of_parse_phandle(ofdev->dev.of_node, "phy-handle", 0);
 	rc = xemaclite_mdio_setup(lp, &ofdev->dev);
 	if (rc)
 		dev_warn(&ofdev->dev, "error registering MDIO bus\n");


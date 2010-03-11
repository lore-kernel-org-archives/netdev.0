From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 04/37] arch/sparc: use .dev.of_node instead of .node in struct
	of_device
Date: Thu, 11 Mar 2010 11:04:09 -0700
Message-ID: <20100311180409.4824.64311.stgit__18579.1202159182$1268330793$gmane$org@angua>
References: <20100311174830.4824.19820.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:53396 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933551Ab0CKSEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:04:14 -0500
In-Reply-To: <20100311174830.4824.19820.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.node is being removed

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 arch/sparc/include/asm/floppy_64.h   |    4 ++--
 arch/sparc/include/asm/parport.h     |    2 +-
 arch/sparc/kernel/auxio_64.c         |    2 +-
 arch/sparc/kernel/central.c          |    4 ++--
 arch/sparc/kernel/chmc.c             |   10 +++++-----
 arch/sparc/kernel/ioport.c           |    2 +-
 arch/sparc/kernel/of_device_32.c     |   14 +++++++-------
 arch/sparc/kernel/of_device_64.c     |   26 +++++++++++++-------------
 arch/sparc/kernel/of_device_common.c |    4 ++--
 arch/sparc/kernel/pci.c              |    8 +++-----
 arch/sparc/kernel/pci_common.c       |    9 +++++----
 arch/sparc/kernel/pci_fire.c         |    4 ++--
 arch/sparc/kernel/pci_msi.c          |   18 +++++++++---------
 arch/sparc/kernel/pci_psycho.c       |    4 ++--
 arch/sparc/kernel/pci_sabre.c        |    4 ++--
 arch/sparc/kernel/pci_schizo.c       |   14 +++++++-------
 arch/sparc/kernel/pci_sun4v.c        |    8 ++++----
 arch/sparc/kernel/power.c            |    4 ++--
 arch/sparc/kernel/psycho_common.c    |    2 +-
 arch/sparc/kernel/sbus.c             |   16 ++++++++--------
 arch/sparc/kernel/time_32.c          |    2 +-
 arch/sparc/kernel/time_64.c          |    6 +++---
 22 files changed, 83 insertions(+), 84 deletions(-)

diff --git a/arch/sparc/include/asm/floppy_64.h b/arch/sparc/include/asm/floppy_64.h
index 36439d6..8fac3ab 100644
--- a/arch/sparc/include/asm/floppy_64.h
+++ b/arch/sparc/include/asm/floppy_64.h
@@ -589,7 +589,7 @@ static unsigned long __init sun_floppy_init(void)
 		if (!op)
 			return 0;
 
-		state_prop = of_get_property(op->node, "status", NULL);
+		state_prop = of_get_property(op->dev.of_node, "status", NULL);
 		if (state_prop && !strncmp(state_prop, "disabled", 8))
 			return 0;
 
@@ -716,7 +716,7 @@ static unsigned long __init sun_floppy_init(void)
 
 		return sun_floppy_types[0];
 	}
-	prop = of_get_property(op->node, "status", NULL);
+	prop = of_get_property(op->dev.of_node, "status", NULL);
 	if (prop && !strncmp(state, "disabled", 8))
 		return 0;
 
diff --git a/arch/sparc/include/asm/parport.h b/arch/sparc/include/asm/parport.h
index ff9ead6..1bb6a41 100644
--- a/arch/sparc/include/asm/parport.h
+++ b/arch/sparc/include/asm/parport.h
@@ -113,7 +113,7 @@ static int __devinit ecpp_probe(struct of_device *op, const struct of_device_id
 	struct parport *p;
 	int slot, err;
 
-	parent = op->node->parent;
+	parent = op->dev.of_node->parent;
 	if (!strcmp(parent->name, "dma")) {
 		p = parport_pc_probe_port(base, base + 0x400,
 					  op->irqs[0], PARPORT_DMA_NOFIFO,
diff --git a/arch/sparc/kernel/auxio_64.c b/arch/sparc/kernel/auxio_64.c
index 9f52db2..bd8421a 100644
--- a/arch/sparc/kernel/auxio_64.c
+++ b/arch/sparc/kernel/auxio_64.c
@@ -104,7 +104,7 @@ MODULE_DEVICE_TABLE(of, auxio_match);
 
 static int __devinit auxio_probe(struct of_device *dev, const struct of_device_id *match)
 {
-	struct device_node *dp = dev->node;
+	struct device_node *dp = dev->dev.of_node;
 	unsigned long size;
 
 	if (!strcmp(dp->parent->name, "ebus")) {
diff --git a/arch/sparc/kernel/central.c b/arch/sparc/kernel/central.c
index 4589ca3..dfc3698 100644
--- a/arch/sparc/kernel/central.c
+++ b/arch/sparc/kernel/central.c
@@ -167,7 +167,7 @@ static int __devinit fhc_probe(struct of_device *op,
 		goto out;
 	}
 
-	if (!strcmp(op->node->parent->name, "central"))
+	if (!strcmp(op->dev.of_node->parent->name, "central"))
 		p->central = true;
 
 	p->pregs = of_ioremap(&op->resource[0], 0,
@@ -182,7 +182,7 @@ static int __devinit fhc_probe(struct of_device *op,
 		reg = upa_readl(p->pregs + FHC_PREGS_BSR);
 		p->board_num = ((reg >> 16) & 1) | ((reg >> 12) & 0x0e);
 	} else {
-		p->board_num = of_getintprop_default(op->node, "board#", -1);
+		p->board_num = of_getintprop_default(op->dev.of_node, "board#", -1);
 		if (p->board_num == -1) {
 			printk(KERN_ERR "fhc: No board# property\n");
 			goto out_unmap_pregs;
diff --git a/arch/sparc/kernel/chmc.c b/arch/sparc/kernel/chmc.c
index e1a9598..9368796 100644
--- a/arch/sparc/kernel/chmc.c
+++ b/arch/sparc/kernel/chmc.c
@@ -425,7 +425,7 @@ static int __devinit jbusmc_probe(struct of_device *op,
 	INIT_LIST_HEAD(&p->list);
 
 	err = -ENODEV;
-	prop = of_get_property(op->node, "portid", &len);
+	prop = of_get_property(op->dev.of_node, "portid", &len);
 	if (!prop || len != 4) {
 		printk(KERN_ERR PFX "Cannot find portid.\n");
 		goto out_free;
@@ -433,7 +433,7 @@ static int __devinit jbusmc_probe(struct of_device *op,
 
 	p->portid = *prop;
 
-	prop = of_get_property(op->node, "memory-control-register-1", &len);
+	prop = of_get_property(op->dev.of_node, "memory-control-register-1", &len);
 	if (!prop || len != 8) {
 		printk(KERN_ERR PFX "Cannot get memory control register 1.\n");
 		goto out_free;
@@ -449,7 +449,7 @@ static int __devinit jbusmc_probe(struct of_device *op,
 	}
 
 	err = -ENODEV;
-	ml = of_get_property(op->node, "memory-layout", &p->layout_len);
+	ml = of_get_property(op->dev.of_node, "memory-layout", &p->layout_len);
 	if (!ml) {
 		printk(KERN_ERR PFX "Cannot get memory layout property.\n");
 		goto out_iounmap;
@@ -466,7 +466,7 @@ static int __devinit jbusmc_probe(struct of_device *op,
 	mc_list_add(&p->list);
 
 	printk(KERN_INFO PFX "UltraSPARC-IIIi memory controller at %s\n",
-	       op->node->full_name);
+	       op->dev.of_node->full_name);
 
 	dev_set_drvdata(&op->dev, p);
 
@@ -693,7 +693,7 @@ static void chmc_fetch_decode_regs(struct chmc *p)
 static int __devinit chmc_probe(struct of_device *op,
 				const struct of_device_id *match)
 {
-	struct device_node *dp = op->node;
+	struct device_node *dp = op->dev.of_node;
 	unsigned long ver;
 	const void *pval;
 	int len, portid;
diff --git a/arch/sparc/kernel/ioport.c b/arch/sparc/kernel/ioport.c
index 3c8c44f..6d93d2a 100644
--- a/arch/sparc/kernel/ioport.c
+++ b/arch/sparc/kernel/ioport.c
@@ -290,7 +290,7 @@ static void *sbus_alloc_coherent(struct device *dev, size_t len,
 	if (mmu_map_dma_area(dev, dma_addrp, va, res->start, len_total) != 0)
 		goto err_noiommu;
 
-	res->name = op->node->name;
+	res->name = op->dev.of_node->name;
 
 	return (void *)(unsigned long)res->start;
 
diff --git a/arch/sparc/kernel/of_device_32.c b/arch/sparc/kernel/of_device_32.c
index 5a5509c..909bee0 100644
--- a/arch/sparc/kernel/of_device_32.c
+++ b/arch/sparc/kernel/of_device_32.c
@@ -254,10 +254,10 @@ static void __init build_device_resources(struct of_device *op,
 		return;
 
 	p_op = to_of_device(parent);
-	bus = of_match_bus(p_op->node);
-	bus->count_cells(op->node, &na, &ns);
+	bus = of_match_bus(p_op->dev.of_node);
+	bus->count_cells(op->dev.of_node, &na, &ns);
 
-	preg = of_get_property(op->node, bus->addr_prop_name, &num_reg);
+	preg = of_get_property(op->dev.of_node, bus->addr_prop_name, &num_reg);
 	if (!preg || num_reg == 0)
 		return;
 
@@ -271,8 +271,8 @@ static void __init build_device_resources(struct of_device *op,
 		struct resource *r = &op->resource[index];
 		u32 addr[OF_MAX_ADDR_CELLS];
 		const u32 *reg = (preg + (index * ((na + ns) * 4)));
-		struct device_node *dp = op->node;
-		struct device_node *pp = p_op->node;
+		struct device_node *dp = op->dev.of_node;
+		struct device_node *pp = p_op->dev.of_node;
 		struct of_bus *pbus, *dbus;
 		u64 size, result = OF_BAD_ADDR;
 		unsigned long flags;
@@ -321,7 +321,7 @@ static void __init build_device_resources(struct of_device *op,
 
 		if (of_resource_verbose)
 			printk("%s reg[%d] -> %llx\n",
-			       op->node->full_name, index,
+			       op->dev.of_node->full_name, index,
 			       result);
 
 		if (result != OF_BAD_ADDR) {
@@ -329,7 +329,7 @@ static void __init build_device_resources(struct of_device *op,
 			r->end = result + size - 1;
 			r->flags = flags | ((result >> 32ULL) & 0xffUL);
 		}
-		r->name = op->node->name;
+		r->name = op->dev.of_node->name;
 	}
 }
 
diff --git a/arch/sparc/kernel/of_device_64.c b/arch/sparc/kernel/of_device_64.c
index 9d30b07..e436381 100644
--- a/arch/sparc/kernel/of_device_64.c
+++ b/arch/sparc/kernel/of_device_64.c
@@ -323,10 +323,10 @@ static void __init build_device_resources(struct of_device *op,
 		return;
 
 	p_op = to_of_device(parent);
-	bus = of_match_bus(p_op->node);
-	bus->count_cells(op->node, &na, &ns);
+	bus = of_match_bus(p_op->dev.of_node);
+	bus->count_cells(op->dev.of_node, &na, &ns);
 
-	preg = of_get_property(op->node, bus->addr_prop_name, &num_reg);
+	preg = of_get_property(op->dev.of_node, bus->addr_prop_name, &num_reg);
 	if (!preg || num_reg == 0)
 		return;
 
@@ -340,7 +340,7 @@ static void __init build_device_resources(struct of_device *op,
 	if (num_reg > PROMREG_MAX) {
 		printk(KERN_WARNING "%s: Too many regs (%d), "
 		       "limiting to %d.\n",
-		       op->node->full_name, num_reg, PROMREG_MAX);
+		       op->dev.of_node->full_name, num_reg, PROMREG_MAX);
 		num_reg = PROMREG_MAX;
 	}
 
@@ -348,8 +348,8 @@ static void __init build_device_resources(struct of_device *op,
 		struct resource *r = &op->resource[index];
 		u32 addr[OF_MAX_ADDR_CELLS];
 		const u32 *reg = (preg + (index * ((na + ns) * 4)));
-		struct device_node *dp = op->node;
-		struct device_node *pp = p_op->node;
+		struct device_node *dp = op->dev.of_node;
+		struct device_node *pp = p_op->dev.of_node;
 		struct of_bus *pbus, *dbus;
 		u64 size, result = OF_BAD_ADDR;
 		unsigned long flags;
@@ -397,7 +397,7 @@ static void __init build_device_resources(struct of_device *op,
 
 		if (of_resource_verbose)
 			printk("%s reg[%d] -> %llx\n",
-			       op->node->full_name, index,
+			       op->dev.of_node->full_name, index,
 			       result);
 
 		if (result != OF_BAD_ADDR) {
@@ -408,7 +408,7 @@ static void __init build_device_resources(struct of_device *op,
 			r->end = result + size - 1;
 			r->flags = flags;
 		}
-		r->name = op->node->name;
+		r->name = op->dev.of_node->name;
 	}
 }
 
@@ -530,7 +530,7 @@ static unsigned int __init build_one_device_irq(struct of_device *op,
 						struct device *parent,
 						unsigned int irq)
 {
-	struct device_node *dp = op->node;
+	struct device_node *dp = op->dev.of_node;
 	struct device_node *pp, *ip;
 	unsigned int orig_irq = irq;
 	int nid;
@@ -575,7 +575,7 @@ static unsigned int __init build_one_device_irq(struct of_device *op,
 
 			if (of_irq_verbose)
 				printk("%s: Apply [%s:%x] imap --> [%s:%x]\n",
-				       op->node->full_name,
+				       op->dev.of_node->full_name,
 				       pp->full_name, this_orig_irq,
 				       (iret ? iret->full_name : "NULL"), irq);
 
@@ -594,7 +594,7 @@ static unsigned int __init build_one_device_irq(struct of_device *op,
 				if (of_irq_verbose)
 					printk("%s: PCI swizzle [%s] "
 					       "%x --> %x\n",
-					       op->node->full_name,
+					       op->dev.of_node->full_name,
 					       pp->full_name, this_orig_irq,
 					       irq);
 
@@ -611,11 +611,11 @@ static unsigned int __init build_one_device_irq(struct of_device *op,
 	if (!ip)
 		return orig_irq;
 
-	irq = ip->irq_trans->irq_build(op->node, irq,
+	irq = ip->irq_trans->irq_build(op->dev.of_node, irq,
 				       ip->irq_trans->data);
 	if (of_irq_verbose)
 		printk("%s: Apply IRQ trans [%s] %x --> %x\n",
-		       op->node->full_name, ip->full_name, orig_irq, irq);
+		      op->dev.of_node->full_name, ip->full_name, orig_irq, irq);
 
 out:
 	nid = of_node_to_nid(dp);
diff --git a/arch/sparc/kernel/of_device_common.c b/arch/sparc/kernel/of_device_common.c
index cb8eb79..21b3923 100644
--- a/arch/sparc/kernel/of_device_common.c
+++ b/arch/sparc/kernel/of_device_common.c
@@ -17,7 +17,7 @@ static int node_match(struct device *dev, void *data)
 	struct of_device *op = to_of_device(dev);
 	struct device_node *dp = data;
 
-	return (op->node == dp);
+	return (op->dev.of_node == dp);
 }
 
 struct of_device *of_find_device_by_node(struct device_node *dp)
@@ -49,7 +49,7 @@ EXPORT_SYMBOL(irq_of_parse_and_map);
 void of_propagate_archdata(struct of_device *bus)
 {
 	struct dev_archdata *bus_sd = &bus->dev.archdata;
-	struct device_node *bus_dp = bus->node;
+	struct device_node *bus_dp = bus->dev.of_node;
 	struct device_node *dp;
 
 	for (dp = bus_dp->child; dp; dp = dp->sibling) {
diff --git a/arch/sparc/kernel/pci.c b/arch/sparc/kernel/pci.c
index 40861ed..89c17d0 100644
--- a/arch/sparc/kernel/pci.c
+++ b/arch/sparc/kernel/pci.c
@@ -684,7 +684,7 @@ static void __devinit pci_bus_register_of_sysfs(struct pci_bus *bus)
 struct pci_bus * __devinit pci_scan_one_pbm(struct pci_pbm_info *pbm,
 					    struct device *parent)
 {
-	struct device_node *node = pbm->op->node;
+	struct device_node *node = pbm->op->dev.of_node;
 	struct pci_bus *bus;
 
 	printk("PCI: Scanning PBM %s\n", node->full_name);
@@ -1152,15 +1152,13 @@ static int __init of_pci_slot_init(void)
 		struct device_node *node;
 
 		if (pbus->self) {
-			struct dev_archdata *sd = pbus->self->sysdata;
-
 			/* PCI->PCI bridge */
-			node = sd->prom_node;
+			node = pbus->self->dev.of_node;
 		} else {
 			struct pci_pbm_info *pbm = pbus->sysdata;
 
 			/* Host PCI controller */
-			node = pbm->op->node;
+			node = pbm->op->dev.of_node;
 		}
 
 		pci_bus_slot_names(node, pbus);
diff --git a/arch/sparc/kernel/pci_common.c b/arch/sparc/kernel/pci_common.c
index b775658..87614be 100644
--- a/arch/sparc/kernel/pci_common.c
+++ b/arch/sparc/kernel/pci_common.c
@@ -314,12 +314,12 @@ struct pci_ops sun4v_pci_ops = {
 
 void pci_get_pbm_props(struct pci_pbm_info *pbm)
 {
-	const u32 *val = of_get_property(pbm->op->node, "bus-range", NULL);
+	const u32 *val = of_get_property(pbm->op->dev.of_node, "bus-range", NULL);
 
 	pbm->pci_first_busno = val[0];
 	pbm->pci_last_busno = val[1];
 
-	val = of_get_property(pbm->op->node, "ino-bitmap", NULL);
+	val = of_get_property(pbm->op->dev.of_node, "ino-bitmap", NULL);
 	if (val) {
 		pbm->ino_bitmap = (((u64)val[1] << 32UL) |
 				   ((u64)val[0] <<  0UL));
@@ -365,7 +365,8 @@ static void pci_register_legacy_regions(struct resource *io_res,
 
 static void pci_register_iommu_region(struct pci_pbm_info *pbm)
 {
-	const u32 *vdma = of_get_property(pbm->op->node, "virtual-dma", NULL);
+	const u32 *vdma = of_get_property(pbm->op->dev.of_node, "virtual-dma",
+					  NULL);
 
 	if (vdma) {
 		struct resource *rp = kzalloc(sizeof(*rp), GFP_KERNEL);
@@ -389,7 +390,7 @@ void pci_determine_mem_io_space(struct pci_pbm_info *pbm)
 	int num_pbm_ranges;
 
 	saw_mem = saw_io = 0;
-	pbm_ranges = of_get_property(pbm->op->node, "ranges", &i);
+	pbm_ranges = of_get_property(pbm->op->dev.of_node, "ranges", &i);
 	if (!pbm_ranges) {
 		prom_printf("PCI: Fatal error, missing PBM ranges property "
 			    " for %s\n",
diff --git a/arch/sparc/kernel/pci_fire.c b/arch/sparc/kernel/pci_fire.c
index d53f45b..ff844ba 100644
--- a/arch/sparc/kernel/pci_fire.c
+++ b/arch/sparc/kernel/pci_fire.c
@@ -413,7 +413,7 @@ static int __devinit pci_fire_pbm_init(struct pci_pbm_info *pbm,
 				       struct of_device *op, u32 portid)
 {
 	const struct linux_prom64_registers *regs;
-	struct device_node *dp = op->node;
+	struct device_node *dp = op->dev.of_node;
 	int err;
 
 	pbm->numa_node = -1;
@@ -458,7 +458,7 @@ static int __devinit pci_fire_pbm_init(struct pci_pbm_info *pbm,
 static int __devinit fire_probe(struct of_device *op,
 				const struct of_device_id *match)
 {
-	struct device_node *dp = op->node;
+	struct device_node *dp = op->dev.of_node;
 	struct pci_pbm_info *pbm;
 	struct iommu *iommu;
 	u32 portid;
diff --git a/arch/sparc/kernel/pci_msi.c b/arch/sparc/kernel/pci_msi.c
index e1b0541..4cfe593 100644
--- a/arch/sparc/kernel/pci_msi.c
+++ b/arch/sparc/kernel/pci_msi.c
@@ -323,7 +323,7 @@ void sparc64_pbm_msi_init(struct pci_pbm_info *pbm,
 	const u32 *val;
 	int len;
 
-	val = of_get_property(pbm->op->node, "#msi-eqs", &len);
+	val = of_get_property(pbm->op->dev.of_node, "#msi-eqs", &len);
 	if (!val || len != 4)
 		goto no_msi;
 	pbm->msiq_num = *val;
@@ -346,16 +346,16 @@ void sparc64_pbm_msi_init(struct pci_pbm_info *pbm,
 			u32 msi64_len;
 		} *arng;
 
-		val = of_get_property(pbm->op->node, "msi-eq-size", &len);
+		val = of_get_property(pbm->op->dev.of_node, "msi-eq-size", &len);
 		if (!val || len != 4)
 			goto no_msi;
 
 		pbm->msiq_ent_count = *val;
 
-		mqp = of_get_property(pbm->op->node,
+		mqp = of_get_property(pbm->op->dev.of_node,
 				      "msi-eq-to-devino", &len);
 		if (!mqp)
-			mqp = of_get_property(pbm->op->node,
+			mqp = of_get_property(pbm->op->dev.of_node,
 					      "msi-eq-devino", &len);
 		if (!mqp || len != sizeof(struct msiq_prop))
 			goto no_msi;
@@ -363,27 +363,27 @@ void sparc64_pbm_msi_init(struct pci_pbm_info *pbm,
 		pbm->msiq_first = mqp->first_msiq;
 		pbm->msiq_first_devino = mqp->first_devino;
 
-		val = of_get_property(pbm->op->node, "#msi", &len);
+		val = of_get_property(pbm->op->dev.of_node, "#msi", &len);
 		if (!val || len != 4)
 			goto no_msi;
 		pbm->msi_num = *val;
 
-		mrng = of_get_property(pbm->op->node, "msi-ranges", &len);
+		mrng = of_get_property(pbm->op->dev.of_node, "msi-ranges", &len);
 		if (!mrng || len != sizeof(struct msi_range_prop))
 			goto no_msi;
 		pbm->msi_first = mrng->first_msi;
 
-		val = of_get_property(pbm->op->node, "msi-data-mask", &len);
+		val = of_get_property(pbm->op->dev.of_node, "msi-data-mask", &len);
 		if (!val || len != 4)
 			goto no_msi;
 		pbm->msi_data_mask = *val;
 
-		val = of_get_property(pbm->op->node, "msix-data-width", &len);
+		val = of_get_property(pbm->op->dev.of_node, "msix-data-width", &len);
 		if (!val || len != 4)
 			goto no_msi;
 		pbm->msix_data_width = *val;
 
-		arng = of_get_property(pbm->op->node, "msi-address-ranges",
+		arng = of_get_property(pbm->op->dev.of_node, "msi-address-ranges",
 				       &len);
 		if (!arng || len != sizeof(struct addr_range_prop))
 			goto no_msi;
diff --git a/arch/sparc/kernel/pci_psycho.c b/arch/sparc/kernel/pci_psycho.c
index 142b9d6..e675e21 100644
--- a/arch/sparc/kernel/pci_psycho.c
+++ b/arch/sparc/kernel/pci_psycho.c
@@ -285,7 +285,7 @@ static irqreturn_t psycho_ce_intr(int irq, void *dev_id)
 #define  PSYCHO_ECCCTRL_CE	 0x2000000000000000UL /* Enable CE INterrupts */
 static void psycho_register_error_handlers(struct pci_pbm_info *pbm)
 {
-	struct of_device *op = of_find_device_by_node(pbm->op->node);
+	struct of_device *op = of_find_device_by_node(pbm->op->dev.of_node);
 	unsigned long base = pbm->controller_regs;
 	u64 tmp;
 	int err;
@@ -507,7 +507,7 @@ static int __devinit psycho_probe(struct of_device *op,
 				  const struct of_device_id *match)
 {
 	const struct linux_prom64_registers *pr_regs;
-	struct device_node *dp = op->node;
+	struct device_node *dp = op->dev.of_node;
 	struct pci_pbm_info *pbm;
 	struct iommu *iommu;
 	int is_pbm_a, err;
diff --git a/arch/sparc/kernel/pci_sabre.c b/arch/sparc/kernel/pci_sabre.c
index ba6fbeb..5048498 100644
--- a/arch/sparc/kernel/pci_sabre.c
+++ b/arch/sparc/kernel/pci_sabre.c
@@ -310,7 +310,7 @@ static irqreturn_t sabre_ce_intr(int irq, void *dev_id)
 
 static void sabre_register_error_handlers(struct pci_pbm_info *pbm)
 {
-	struct device_node *dp = pbm->op->node;
+	struct device_node *dp = pbm->op->dev.of_node;
 	struct of_device *op;
 	unsigned long base = pbm->controller_regs;
 	u64 tmp;
@@ -456,7 +456,7 @@ static int __devinit sabre_probe(struct of_device *op,
 				 const struct of_device_id *match)
 {
 	const struct linux_prom64_registers *pr_regs;
-	struct device_node *dp = op->node;
+	struct device_node *dp = op->dev.of_node;
 	struct pci_pbm_info *pbm;
 	u32 upa_portid, dma_mask;
 	struct iommu *iommu;
diff --git a/arch/sparc/kernel/pci_schizo.c b/arch/sparc/kernel/pci_schizo.c
index 2b5cdde..2f3f921 100644
--- a/arch/sparc/kernel/pci_schizo.c
+++ b/arch/sparc/kernel/pci_schizo.c
@@ -844,7 +844,7 @@ static int pbm_routes_this_ino(struct pci_pbm_info *pbm, u32 ino)
  */
 static void tomatillo_register_error_handlers(struct pci_pbm_info *pbm)
 {
-	struct of_device *op = of_find_device_by_node(pbm->op->node);
+	struct of_device *op = of_find_device_by_node(pbm->op->dev.of_node);
 	u64 tmp, err_mask, err_no_mask;
 	int err;
 
@@ -939,7 +939,7 @@ static void tomatillo_register_error_handlers(struct pci_pbm_info *pbm)
 
 static void schizo_register_error_handlers(struct pci_pbm_info *pbm)
 {
-	struct of_device *op = of_find_device_by_node(pbm->op->node);
+	struct of_device *op = of_find_device_by_node(pbm->op->dev.of_node);
 	u64 tmp, err_mask, err_no_mask;
 	int err;
 
@@ -1068,7 +1068,7 @@ static void __devinit schizo_scan_bus(struct pci_pbm_info *pbm,
 {
 	pbm_config_busmastering(pbm);
 	pbm->is_66mhz_capable =
-		(of_find_property(pbm->op->node, "66mhz-capable", NULL)
+		(of_find_property(pbm->op->dev.of_node, "66mhz-capable", NULL)
 		 != NULL);
 
 	pbm->pci_bus = pci_scan_one_pbm(pbm, parent);
@@ -1138,7 +1138,7 @@ static int schizo_pbm_iommu_init(struct pci_pbm_info *pbm)
 	u32 dma_mask;
 	u64 control;
 
-	vdma = of_get_property(pbm->op->node, "virtual-dma", NULL);
+	vdma = of_get_property(pbm->op->dev.of_node, "virtual-dma", NULL);
 	if (!vdma)
 		vdma = vdma_default;
 
@@ -1268,7 +1268,7 @@ static void schizo_pbm_hw_init(struct pci_pbm_info *pbm)
 	    pbm->chip_version >= 0x2)
 		tmp |= 0x3UL << SCHIZO_PCICTRL_PTO_SHIFT;
 
-	if (!of_find_property(pbm->op->node, "no-bus-parking", NULL))
+	if (!of_find_property(pbm->op->dev.of_node, "no-bus-parking", NULL))
 		tmp |= SCHIZO_PCICTRL_PARK;
 	else
 		tmp &= ~SCHIZO_PCICTRL_PARK;
@@ -1311,7 +1311,7 @@ static int __devinit schizo_pbm_init(struct pci_pbm_info *pbm,
 				     int chip_type)
 {
 	const struct linux_prom64_registers *regs;
-	struct device_node *dp = op->node;
+	struct device_node *dp = op->dev.of_node;
 	const char *chipset_name;
 	int is_pbm_a, err;
 
@@ -1415,7 +1415,7 @@ static struct pci_pbm_info * __devinit schizo_find_sibling(u32 portid,
 
 static int __devinit __schizo_init(struct of_device *op, unsigned long chip_type)
 {
-	struct device_node *dp = op->node;
+	struct device_node *dp = op->dev.of_node;
 	struct pci_pbm_info *pbm;
 	struct iommu *iommu;
 	u32 portid;
diff --git a/arch/sparc/kernel/pci_sun4v.c b/arch/sparc/kernel/pci_sun4v.c
index 23c33ff..5c11f56 100644
--- a/arch/sparc/kernel/pci_sun4v.c
+++ b/arch/sparc/kernel/pci_sun4v.c
@@ -540,7 +540,7 @@ static void __devinit pci_sun4v_scan_bus(struct pci_pbm_info *pbm,
 	struct property *prop;
 	struct device_node *dp;
 
-	dp = pbm->op->node;
+	dp = pbm->op->dev.of_node;
 	prop = of_find_property(dp, "66mhz-capable", NULL);
 	pbm->is_66mhz_capable = (prop != NULL);
 	pbm->pci_bus = pci_scan_one_pbm(pbm, parent);
@@ -584,7 +584,7 @@ static int __devinit pci_sun4v_iommu_init(struct pci_pbm_info *pbm)
 	u32 dma_mask, dma_offset;
 	const u32 *vdma;
 
-	vdma = of_get_property(pbm->op->node, "virtual-dma", NULL);
+	vdma = of_get_property(pbm->op->dev.of_node, "virtual-dma", NULL);
 	if (!vdma)
 		vdma = vdma_default;
 
@@ -881,7 +881,7 @@ static void pci_sun4v_msi_init(struct pci_pbm_info *pbm)
 static int __devinit pci_sun4v_pbm_init(struct pci_pbm_info *pbm,
 					struct of_device *op, u32 devhandle)
 {
-	struct device_node *dp = op->node;
+	struct device_node *dp = op->dev.of_node;
 	int err;
 
 	pbm->numa_node = of_node_to_nid(dp);
@@ -929,7 +929,7 @@ static int __devinit pci_sun4v_probe(struct of_device *op,
 	u32 devhandle;
 	int i, err;
 
-	dp = op->node;
+	dp = op->dev.of_node;
 
 	if (!hvapi_negotiated++) {
 		err = sun4v_hvapi_register(HV_GRP_PCI,
diff --git a/arch/sparc/kernel/power.c b/arch/sparc/kernel/power.c
index e2a045c..e3f806a 100644
--- a/arch/sparc/kernel/power.c
+++ b/arch/sparc/kernel/power.c
@@ -41,9 +41,9 @@ static int __devinit power_probe(struct of_device *op, const struct of_device_id
 	power_reg = of_ioremap(res, 0, 0x4, "power");
 
 	printk(KERN_INFO "%s: Control reg at %llx\n",
-	       op->node->name, res->start);
+	       op->dev.of_node->name, res->start);
 
-	if (has_button_interrupt(irq, op->node)) {
+	if (has_button_interrupt(irq, op->dev.of_node)) {
 		if (request_irq(irq,
 				power_handler, 0, "power", NULL) < 0)
 			printk(KERN_ERR "power: Cannot setup IRQ handler.\n");
diff --git a/arch/sparc/kernel/psycho_common.c b/arch/sparc/kernel/psycho_common.c
index 8f14784..3f34ac8 100644
--- a/arch/sparc/kernel/psycho_common.c
+++ b/arch/sparc/kernel/psycho_common.c
@@ -450,7 +450,7 @@ int psycho_iommu_init(struct pci_pbm_info *pbm, int tsbsize,
 void psycho_pbm_init_common(struct pci_pbm_info *pbm, struct of_device *op,
 			    const char *chip_name, int chip_type)
 {
-	struct device_node *dp = op->node;
+	struct device_node *dp = op->dev.of_node;
 
 	pbm->name = dp->full_name;
 	pbm->numa_node = -1;
diff --git a/arch/sparc/kernel/sbus.c b/arch/sparc/kernel/sbus.c
index 406e087..cfeaf04 100644
--- a/arch/sparc/kernel/sbus.c
+++ b/arch/sparc/kernel/sbus.c
@@ -63,10 +63,10 @@ void sbus_set_sbus64(struct device *dev, int bursts)
 	int slot;
 	u64 val;
 
-	regs = of_get_property(op->node, "reg", NULL);
+	regs = of_get_property(op->dev.of_node, "reg", NULL);
 	if (!regs) {
 		printk(KERN_ERR "sbus_set_sbus64: Cannot find regs for %s\n",
-		       op->node->full_name);
+		       op->dev.of_node->full_name);
 		return;
 	}
 	slot = regs->which_io;
@@ -287,7 +287,7 @@ static irqreturn_t sysio_ue_handler(int irq, void *dev_id)
 		 SYSIO_UEAFSR_SPIO | SYSIO_UEAFSR_SDRD | SYSIO_UEAFSR_SDWR);
 	upa_writeq(error_bits, afsr_reg);
 
-	portid = of_getintprop_default(op->node, "portid", -1);
+	portid = of_getintprop_default(op->dev.of_node, "portid", -1);
 
 	/* Log the error. */
 	printk("SYSIO[%x]: Uncorrectable ECC Error, primary error type[%s]\n",
@@ -361,7 +361,7 @@ static irqreturn_t sysio_ce_handler(int irq, void *dev_id)
 		 SYSIO_CEAFSR_SPIO | SYSIO_CEAFSR_SDRD | SYSIO_CEAFSR_SDWR);
 	upa_writeq(error_bits, afsr_reg);
 
-	portid = of_getintprop_default(op->node, "portid", -1);
+	portid = of_getintprop_default(op->dev.of_node, "portid", -1);
 
 	printk("SYSIO[%x]: Correctable ECC Error, primary error type[%s]\n",
 	       portid,
@@ -439,7 +439,7 @@ static irqreturn_t sysio_sbus_error_handler(int irq, void *dev_id)
 		 SYSIO_SBAFSR_SLE | SYSIO_SBAFSR_STO | SYSIO_SBAFSR_SBERR);
 	upa_writeq(error_bits, afsr_reg);
 
-	portid = of_getintprop_default(op->node, "portid", -1);
+	portid = of_getintprop_default(op->dev.of_node, "portid", -1);
 
 	/* Log the error. */
 	printk("SYSIO[%x]: SBUS Error, primary error type[%s] read(%d)\n",
@@ -496,7 +496,7 @@ static void __init sysio_register_error_handlers(struct of_device *op)
 	u64 control;
 	int portid;
 
-	portid = of_getintprop_default(op->node, "portid", -1);
+	portid = of_getintprop_default(op->dev.of_node, "portid", -1);
 
 	irq = sbus_build_irq(op, SYSIO_UE_INO);
 	if (request_irq(irq, sysio_ue_handler, 0,
@@ -537,7 +537,7 @@ static void __init sysio_register_error_handlers(struct of_device *op)
 static void __init sbus_iommu_init(struct of_device *op)
 {
 	const struct linux_prom64_registers *pr;
-	struct device_node *dp = op->node;
+	struct device_node *dp = op->dev.of_node;
 	struct iommu *iommu;
 	struct strbuf *strbuf;
 	unsigned long regs, reg_base;
@@ -589,7 +589,7 @@ static void __init sbus_iommu_init(struct of_device *op)
 	 */
 	iommu->write_complete_reg = regs + 0x2000UL;
 
-	portid = of_getintprop_default(op->node, "portid", -1);
+	portid = of_getintprop_default(op->dev.of_node, "portid", -1);
 	printk(KERN_INFO "SYSIO: UPA portID %x, at %016lx\n",
 	       portid, regs);
 
diff --git a/arch/sparc/kernel/time_32.c b/arch/sparc/kernel/time_32.c
index 0d4c09b..e0dbed9 100644
--- a/arch/sparc/kernel/time_32.c
+++ b/arch/sparc/kernel/time_32.c
@@ -152,7 +152,7 @@ static struct platform_device m48t59_rtc = {
 
 static int __devinit clock_probe(struct of_device *op, const struct of_device_id *match)
 {
-	struct device_node *dp = op->node;
+	struct device_node *dp = op->dev.of_node;
 	const char *model = of_get_property(dp, "model", NULL);
 
 	if (!model)
diff --git a/arch/sparc/kernel/time_64.c b/arch/sparc/kernel/time_64.c
index 67e1651..ee3fe41 100644
--- a/arch/sparc/kernel/time_64.c
+++ b/arch/sparc/kernel/time_64.c
@@ -423,7 +423,7 @@ static int __devinit rtc_probe(struct of_device *op, const struct of_device_id *
 	struct resource *r;
 
 	printk(KERN_INFO "%s: RTC regs at 0x%llx\n",
-	       op->node->full_name, op->resource[0].start);
+	       op->dev.of_node->full_name, op->resource[0].start);
 
 	/* The CMOS RTC driver only accepts IORESOURCE_IO, so cons
 	 * up a fake resource so that the probe works for all cases.
@@ -479,7 +479,7 @@ static int __devinit bq4802_probe(struct of_device *op, const struct of_device_i
 {
 
 	printk(KERN_INFO "%s: BQ4802 regs at 0x%llx\n",
-	       op->node->full_name, op->resource[0].start);
+	       op->dev.of_node->full_name, op->resource[0].start);
 
 	rtc_bq4802_device.resource = &op->resource[0];
 	return platform_device_register(&rtc_bq4802_device);
@@ -533,7 +533,7 @@ static struct platform_device m48t59_rtc = {
 
 static int __devinit mostek_probe(struct of_device *op, const struct of_device_id *match)
 {
-	struct device_node *dp = op->node;
+	struct device_node *dp = op->dev.of_node;
 
 	/* On an Enterprise system there can be multiple mostek clocks.
 	 * We should only match the one that is on the central FHC bus.


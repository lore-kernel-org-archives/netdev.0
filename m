From: Roel Kluin <12o3l@tiscali.nl>
Subject: Re: [2.6 patch] atm/idt77105.c: fix section mismatch
Date: Mon, 21 Jan 2008 01:37:00 +0100
Message-ID: <4793E92C.5090309@tiscali.nl>
References: <20080119131849.GA8669@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757283AbYAUAha@vger.kernel.org>
In-Reply-To: <20080119131849.GA8669@does.not.exist>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> EXPORT_SYMBOL'ed code mustn't be __*init.
> 

Is it correct that the cases below are section mismatches as well?
If required I'll send separate patches to the respective maintainers
& lists.

__init
arch/arm/mach-imx/generic.c:330:EXPORT_SYMBOL(set_imx_fb_info);

__devinit
arch/parisc/kernel/pci.c:245:EXPORT_SYMBOL(pcibios_resource_to_bus);
arch/powerpc/kernel/pci_64.c:371:EXPORT_SYMBOL(of_scan_bus);
arch/powerpc/kernel/pci_64.c:460:EXPORT_SYMBOL(of_scan_pci_bridge);
arch/powerpc/kernel/pci_64.c:842:EXPORT_SYMBOL(pcibios_fixup_device_resources);
arch/powerpc/kernel/pci_64.c:862:EXPORT_SYMBOL(pcibios_setup_new_device);
arch/powerpc/kernel/pci_64.c:908:EXPORT_SYMBOL(pcibios_fixup_bus);
arch/ia64/pci/pci.c:477:EXPORT_SYMBOL_GPL(pcibios_fixup_device_resources);
arch/powerpc/kernel/vio.c:240:EXPORT_SYMBOL(vio_register_device_node);
arch/powerpc/kernel/vio.c:309:EXPORT_SYMBOL(vio_unregister_device);

__cpu_init
arch/x86/kernel/topology.c:60:EXPORT_SYMBOL(arch_register_cpu);
--
EXPORT_SYMBOL'ed code mustn't be __*init.

Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/arch/arm/mach-imx/generic.c b/arch/arm/mach-imx/generic.c
index 4cfc9d3..92e098a 100644
--- a/arch/arm/mach-imx/generic.c
+++ b/arch/arm/mach-imx/generic.c
@@ -323,7 +323,7 @@ void __init imx_set_mmc_info(struct imxmmc_platform_data *info)
 
 static struct imxfb_mach_info imx_fb_info;
 
-void __init set_imx_fb_info(struct imxfb_mach_info *hard_imx_fb_info)
+void set_imx_fb_info(struct imxfb_mach_info *hard_imx_fb_info)
 {
 	memcpy(&imx_fb_info,hard_imx_fb_info,sizeof(struct imxfb_mach_info));
 }
diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 488e48a..8c200a8 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -470,7 +470,7 @@ pcibios_fixup_resources(struct pci_dev *dev, int start, int limit)
 	}
 }
 
-void __devinit pcibios_fixup_device_resources(struct pci_dev *dev)
+void pcibios_fixup_device_resources(struct pci_dev *dev)
 {
 	pcibios_fixup_resources(dev, 0, PCI_BRIDGE_RESOURCES);
 }
diff --git a/arch/parisc/kernel/pci.c b/arch/parisc/kernel/pci.c
index 507d0ac..9cf3cfc 100644
--- a/arch/parisc/kernel/pci.c
+++ b/arch/parisc/kernel/pci.c
@@ -195,7 +195,7 @@ void __init pcibios_init_bus(struct pci_bus *bus)
 }
 
 /* called by drivers/pci/setup-bus.c:pci_setup_bridge().  */
-void __devinit pcibios_resource_to_bus(struct pci_dev *dev,
+void pcibios_resource_to_bus(struct pci_dev *dev,
 		struct pci_bus_region *region, struct resource *res)
 {
 #ifdef CONFIG_64BIT
diff --git a/arch/powerpc/kernel/pci_64.c b/arch/powerpc/kernel/pci_64.c
index 9f63bdc..5f1151a 100644
--- a/arch/powerpc/kernel/pci_64.c
+++ b/arch/powerpc/kernel/pci_64.c
@@ -338,7 +338,7 @@ struct pci_dev *of_create_pci_dev(struct device_node *node,
 }
 EXPORT_SYMBOL(of_create_pci_dev);
 
-void __devinit of_scan_bus(struct device_node *node,
+void of_scan_bus(struct device_node *node,
 				  struct pci_bus *bus)
 {
 	struct device_node *child = NULL;
@@ -370,7 +370,7 @@ void __devinit of_scan_bus(struct device_node *node,
 }
 EXPORT_SYMBOL(of_scan_bus);
 
-void __devinit of_scan_pci_bridge(struct device_node *node,
+void of_scan_pci_bridge(struct device_node *node,
 			 	struct pci_dev *dev)
 {
 	struct pci_bus *bus;
@@ -818,7 +818,7 @@ static void __devinit fixup_resource(struct resource *res, struct pci_dev *dev)
 	}
 }
 
-void __devinit pcibios_fixup_device_resources(struct pci_dev *dev,
+void pcibios_fixup_device_resources(struct pci_dev *dev,
 					      struct pci_bus *bus)
 {
 	/* Update device resources.  */
@@ -841,7 +841,7 @@ void __devinit pcibios_fixup_device_resources(struct pci_dev *dev,
 }
 EXPORT_SYMBOL(pcibios_fixup_device_resources);
 
-void __devinit pcibios_setup_new_device(struct pci_dev *dev)
+void pcibios_setup_new_device(struct pci_dev *dev)
 {
 	struct dev_archdata *sd = &dev->dev.archdata;
 
@@ -879,7 +879,7 @@ static void __devinit do_bus_setup(struct pci_bus *bus)
 	}
 }
 
-void __devinit pcibios_fixup_bus(struct pci_bus *bus)
+void pcibios_fixup_bus(struct pci_bus *bus)
 {
 	struct pci_dev *dev = bus->self;
 	struct device_node *np;
diff --git a/arch/powerpc/kernel/vio.c b/arch/powerpc/kernel/vio.c
index 19a5656..70a2ce4 100644
--- a/arch/powerpc/kernel/vio.c
+++ b/arch/powerpc/kernel/vio.c
@@ -178,7 +178,7 @@ static void __devinit vio_dev_release(struct device *dev)
  * Returns a pointer to the created vio_dev or NULL if node has
  * NULL device_type or compatible fields.
  */
-struct vio_dev * __devinit vio_register_device_node(struct device_node *of_node)
+struct vio_dev * vio_register_device_node(struct device_node *of_node)
 {
 	struct vio_dev *viodev;
 	const unsigned int *unit_address;
@@ -302,7 +302,7 @@ static struct device_attribute vio_dev_attrs[] = {
 	__ATTR_NULL
 };
 
-void __devinit vio_unregister_device(struct vio_dev *viodev)
+void vio_unregister_device(struct vio_dev *viodev)
 {
 	device_unregister(&viodev->dev);
 }
diff --git a/arch/x86/kernel/topology.c b/arch/x86/kernel/topology.c
index 7e16d67..561acc0 100644
--- a/arch/x86/kernel/topology.c
+++ b/arch/x86/kernel/topology.c
@@ -33,7 +33,7 @@
 
 static struct i386_cpu cpu_devices[NR_CPUS];
 
-int __cpuinit arch_register_cpu(int num)
+int arch_register_cpu(int num)
 {
 	/*
 	 * CPU0 cannot be offlined due to several

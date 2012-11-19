From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 189/493] ssb: remove use of __devinit
Date: Mon, 19 Nov 2012 13:22:18 -0500
Message-ID: <1353349642-3677-189-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Michael Buesch <m@bues.ch>, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41754 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754074Ab2KSSm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:42:59 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devinit is no longer
needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Michael Buesch <m@bues.ch> 
Cc: netdev@vger.kernel.org 
---
 drivers/ssb/driver_gige.c     |  6 +++---
 drivers/ssb/driver_pcicore.c  | 10 +++++-----
 drivers/ssb/main.c            | 12 ++++++------
 drivers/ssb/pcihost_wrapper.c |  4 ++--
 4 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/ssb/driver_gige.c b/drivers/ssb/driver_gige.c
index f30ea68..b0e995d 100644
--- a/drivers/ssb/driver_gige.c
+++ b/drivers/ssb/driver_gige.c
@@ -107,7 +107,7 @@ void gige_pcicfg_write32(struct ssb_gige *dev,
 	gige_write32(dev, SSB_GIGE_PCICFG + offset, value);
 }
 
-static int __devinit ssb_gige_pci_read_config(struct pci_bus *bus,
+static int ssb_gige_pci_read_config(struct pci_bus *bus,
 					      unsigned int devfn, int reg,
 					      int size, u32 *val)
 {
@@ -138,7 +138,7 @@ static int __devinit ssb_gige_pci_read_config(struct pci_bus *bus,
 	return PCIBIOS_SUCCESSFUL;
 }
 
-static int __devinit ssb_gige_pci_write_config(struct pci_bus *bus,
+static int ssb_gige_pci_write_config(struct pci_bus *bus,
 					       unsigned int devfn, int reg,
 					       int size, u32 val)
 {
@@ -169,7 +169,7 @@ static int __devinit ssb_gige_pci_write_config(struct pci_bus *bus,
 	return PCIBIOS_SUCCESSFUL;
 }
 
-static int __devinit ssb_gige_probe(struct ssb_device *sdev,
+static int ssb_gige_probe(struct ssb_device *sdev,
 				    const struct ssb_device_id *id)
 {
 	struct ssb_gige *dev;
diff --git a/drivers/ssb/driver_pcicore.c b/drivers/ssb/driver_pcicore.c
index 49d2091..59801d2 100644
--- a/drivers/ssb/driver_pcicore.c
+++ b/drivers/ssb/driver_pcicore.c
@@ -315,7 +315,7 @@ int ssb_pcicore_pcibios_map_irq(const struct pci_dev *dev, u8 slot, u8 pin)
 	return ssb_mips_irq(extpci_core->dev) + 2;
 }
 
-static void __devinit ssb_pcicore_init_hostmode(struct ssb_pcicore *pc)
+static void ssb_pcicore_init_hostmode(struct ssb_pcicore *pc)
 {
 	u32 val;
 
@@ -380,7 +380,7 @@ static void __devinit ssb_pcicore_init_hostmode(struct ssb_pcicore *pc)
 	register_pci_controller(&ssb_pcicore_controller);
 }
 
-static int __devinit pcicore_is_in_hostmode(struct ssb_pcicore *pc)
+static int pcicore_is_in_hostmode(struct ssb_pcicore *pc)
 {
 	struct ssb_bus *bus = pc->dev->bus;
 	u16 chipid_top;
@@ -413,7 +413,7 @@ static int __devinit pcicore_is_in_hostmode(struct ssb_pcicore *pc)
  * Workarounds.
  **************************************************/
 
-static void __devinit ssb_pcicore_fix_sprom_core_index(struct ssb_pcicore *pc)
+static void ssb_pcicore_fix_sprom_core_index(struct ssb_pcicore *pc)
 {
 	u16 tmp = pcicore_read16(pc, SSB_PCICORE_SPROM(0));
 	if (((tmp & 0xF000) >> 12) != pc->dev->core_index) {
@@ -515,7 +515,7 @@ static void ssb_pcicore_pcie_setup_workarounds(struct ssb_pcicore *pc)
  * Generic and Clientmode operation code.
  **************************************************/
 
-static void __devinit ssb_pcicore_init_clientmode(struct ssb_pcicore *pc)
+static void ssb_pcicore_init_clientmode(struct ssb_pcicore *pc)
 {
 	struct ssb_device *pdev = pc->dev;
 	struct ssb_bus *bus = pdev->bus;
@@ -534,7 +534,7 @@ static void __devinit ssb_pcicore_init_clientmode(struct ssb_pcicore *pc)
 	}
 }
 
-void __devinit ssb_pcicore_init(struct ssb_pcicore *pc)
+void ssb_pcicore_init(struct ssb_pcicore *pc)
 {
 	struct ssb_device *dev = pc->dev;
 
diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index df0f145..bfde3ee 100644
--- a/drivers/ssb/main.c
+++ b/drivers/ssb/main.c
@@ -542,7 +542,7 @@ error:
 }
 
 /* Needs ssb_buses_lock() */
-static int __devinit ssb_attach_queued_buses(void)
+static int ssb_attach_queued_buses(void)
 {
 	struct ssb_bus *bus, *n;
 	int err = 0;
@@ -753,7 +753,7 @@ out:
 	return err;
 }
 
-static int __devinit ssb_bus_register(struct ssb_bus *bus,
+static int ssb_bus_register(struct ssb_bus *bus,
 				      ssb_invariants_func_t get_invariants,
 				      unsigned long baseaddr)
 {
@@ -836,7 +836,7 @@ err_disable_xtal:
 }
 
 #ifdef CONFIG_SSB_PCIHOST
-int __devinit ssb_bus_pcibus_register(struct ssb_bus *bus,
+int ssb_bus_pcibus_register(struct ssb_bus *bus,
 				      struct pci_dev *host_pci)
 {
 	int err;
@@ -860,7 +860,7 @@ EXPORT_SYMBOL(ssb_bus_pcibus_register);
 #endif /* CONFIG_SSB_PCIHOST */
 
 #ifdef CONFIG_SSB_PCMCIAHOST
-int __devinit ssb_bus_pcmciabus_register(struct ssb_bus *bus,
+int ssb_bus_pcmciabus_register(struct ssb_bus *bus,
 					 struct pcmcia_device *pcmcia_dev,
 					 unsigned long baseaddr)
 {
@@ -882,7 +882,7 @@ EXPORT_SYMBOL(ssb_bus_pcmciabus_register);
 #endif /* CONFIG_SSB_PCMCIAHOST */
 
 #ifdef CONFIG_SSB_SDIOHOST
-int __devinit ssb_bus_sdiobus_register(struct ssb_bus *bus,
+int ssb_bus_sdiobus_register(struct ssb_bus *bus,
 				       struct sdio_func *func,
 				       unsigned int quirks)
 {
@@ -904,7 +904,7 @@ int __devinit ssb_bus_sdiobus_register(struct ssb_bus *bus,
 EXPORT_SYMBOL(ssb_bus_sdiobus_register);
 #endif /* CONFIG_SSB_PCMCIAHOST */
 
-int __devinit ssb_bus_ssbbus_register(struct ssb_bus *bus,
+int ssb_bus_ssbbus_register(struct ssb_bus *bus,
 				      unsigned long baseaddr,
 				      ssb_invariants_func_t get_invariants)
 {
diff --git a/drivers/ssb/pcihost_wrapper.c b/drivers/ssb/pcihost_wrapper.c
index af5448f..9fd81f0 100644
--- a/drivers/ssb/pcihost_wrapper.c
+++ b/drivers/ssb/pcihost_wrapper.c
@@ -54,7 +54,7 @@ static int ssb_pcihost_resume(struct pci_dev *dev)
 # define ssb_pcihost_resume	NULL
 #endif /* CONFIG_PM */
 
-static int __devinit ssb_pcihost_probe(struct pci_dev *dev,
+static int ssb_pcihost_probe(struct pci_dev *dev,
 				       const struct pci_device_id *id)
 {
 	struct ssb_bus *ssb;
@@ -111,7 +111,7 @@ static void ssb_pcihost_remove(struct pci_dev *dev)
 	pci_set_drvdata(dev, NULL);
 }
 
-int __devinit ssb_pcihost_register(struct pci_driver *driver)
+int ssb_pcihost_register(struct pci_driver *driver)
 {
 	driver->probe = ssb_pcihost_probe;
 	driver->remove = ssb_pcihost_remove;
-- 
1.8.0

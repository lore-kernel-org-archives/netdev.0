From: Matthew Whitehead <tedheadster@gmail.com>
Subject: [PATCH] eisa: standardize on eisa_register_driver like similar bus registrations
Date: Sat,  5 Oct 2013 22:35:58 -0400
Message-ID: <1381026958-4459-1-git-send-email-tedheadster@gmail.com>
Cc: linux-scsi@vger.kernel.org,
	Matthew Whitehead <tedheadster@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The other buses (isa, pci, pnp, parport, usb, tty, etc) all use the convention
of ${BUSNAME}_register_driver. Rewrite the little remaining code that uses EISA
to follow this convention for easier readability.

This affects the EISA bus, SCSI, and networking subsystems so only one should
ultimately merge the patch if it is accepted.

Signed-off-by: Matthew Whitehead <tedheadster@gmail.com>
---
 drivers/eisa/eisa-bus.c                |    8 ++++----
 drivers/net/ethernet/3com/3c509.c      |    4 ++--
 drivers/net/ethernet/3com/3c59x.c      |    6 +++---
 drivers/net/ethernet/dec/tulip/de4x5.c |    4 ++--
 drivers/net/ethernet/hp/hp100.c        |    6 +++---
 drivers/net/fddi/defxx.c               |    4 ++--
 drivers/scsi/advansys.c                |    6 +++---
 drivers/scsi/aha1740.c                 |    4 ++--
 drivers/scsi/aic7xxx/aic7770_osm.c     |    4 ++--
 drivers/scsi/sim710.c                  |    4 ++--
 include/linux/eisa.h                   |    8 ++++----
 11 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/drivers/eisa/eisa-bus.c b/drivers/eisa/eisa-bus.c
index 272a3ec..9fe589b 100644
--- a/drivers/eisa/eisa-bus.c
+++ b/drivers/eisa/eisa-bus.c
@@ -143,18 +143,18 @@ struct bus_type eisa_bus_type = {
 };
 EXPORT_SYMBOL(eisa_bus_type);
 
-int eisa_driver_register(struct eisa_driver *edrv)
+int eisa_register_driver(struct eisa_driver *edrv)
 {
 	edrv->driver.bus = &eisa_bus_type;
 	return driver_register(&edrv->driver);
 }
-EXPORT_SYMBOL(eisa_driver_register);
+EXPORT_SYMBOL(eisa_register_driver);
 
-void eisa_driver_unregister(struct eisa_driver *edrv)
+void eisa_unregister_driver(struct eisa_driver *edrv)
 {
 	driver_unregister(&edrv->driver);
 }
-EXPORT_SYMBOL(eisa_driver_unregister);
+EXPORT_SYMBOL(eisa_unregister_driver);
 
 static ssize_t eisa_show_sig(struct device *dev, struct device_attribute *attr,
 			     char *buf)
diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index ede8daa..ddfc2f0 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -1417,7 +1417,7 @@ static int __init el3_init_module(void)
 			isa_registered = 1;
 	}
 #ifdef CONFIG_EISA
-	ret = eisa_driver_register(&el3_eisa_driver);
+	ret = eisa_register_driver(&el3_eisa_driver);
 	if (!ret)
 		eisa_registered = 1;
 #endif
@@ -1447,7 +1447,7 @@ static void __exit el3_cleanup_module(void)
 		release_region(id_port, 1);
 #ifdef CONFIG_EISA
 	if (eisa_registered)
-		eisa_driver_unregister(&el3_eisa_driver);
+		eisa_unregister_driver(&el3_eisa_driver);
 #endif
 }
 
diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index ad5272b..df22872 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -976,12 +976,12 @@ static int __init vortex_eisa_init(void)
 #ifdef CONFIG_EISA
 	int err;
 
-	err = eisa_driver_register (&vortex_eisa_driver);
+	err = eisa_register_driver (&vortex_eisa_driver);
 	if (!err) {
 		/*
 		 * Because of the way EISA bus is probed, we cannot assume
 		 * any device have been found when we exit from
-		 * eisa_driver_register (the bus root driver may not be
+		 * eisa_register_driver (the bus root driver may not be
 		 * initialized yet). So we blindly assume something was
 		 * found, and let the sysfs magic happened...
 		 */
@@ -3295,7 +3295,7 @@ static void __exit vortex_eisa_cleanup(void)
 
 #ifdef CONFIG_EISA
 	/* Take care of the EISA devices */
-	eisa_driver_unregister(&vortex_eisa_driver);
+	eisa_unregister_driver(&vortex_eisa_driver);
 #endif
 
 	if (compaq_net_device) {
diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index 263b92c..1df85a1 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -5570,7 +5570,7 @@ static int __init de4x5_module_init (void)
 	err = pci_register_driver(&de4x5_pci_driver);
 #endif
 #ifdef CONFIG_EISA
-	err |= eisa_driver_register (&de4x5_eisa_driver);
+	err |= eisa_register_driver (&de4x5_eisa_driver);
 #endif
 
 	return err;
@@ -5582,7 +5582,7 @@ static void __exit de4x5_module_exit (void)
 	pci_unregister_driver (&de4x5_pci_driver);
 #endif
 #ifdef CONFIG_EISA
-	eisa_driver_unregister (&de4x5_eisa_driver);
+	eisa_unregister_driver (&de4x5_eisa_driver);
 #endif
 }
 
diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index 91227d0..bf817ff 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -3030,7 +3030,7 @@ static int __init hp100_module_init(void)
 	if (err && err != -ENODEV)
 		goto out;
 #ifdef CONFIG_EISA
-	err = eisa_driver_register(&hp100_eisa_driver);
+	err = eisa_register_driver(&hp100_eisa_driver);
 	if (err && err != -ENODEV)
 		goto out2;
 #endif
@@ -3043,7 +3043,7 @@ static int __init hp100_module_init(void)
 	return err;
  out3:
 #ifdef CONFIG_EISA
-	eisa_driver_unregister (&hp100_eisa_driver);
+	eisa_unregister_driver (&hp100_eisa_driver);
  out2:
 #endif
 	hp100_isa_cleanup();
@@ -3055,7 +3055,7 @@ static void __exit hp100_module_exit(void)
 {
 	hp100_isa_cleanup();
 #ifdef CONFIG_EISA
-	eisa_driver_unregister (&hp100_eisa_driver);
+	eisa_unregister_driver (&hp100_eisa_driver);
 #endif
 #ifdef CONFIG_PCI
 	pci_unregister_driver (&hp100_pci_driver);
diff --git a/drivers/net/fddi/defxx.c b/drivers/net/fddi/defxx.c
index 0b40e1c..01ce473 100644
--- a/drivers/net/fddi/defxx.c
+++ b/drivers/net/fddi/defxx.c
@@ -3713,7 +3713,7 @@ static int dfx_init(void)
 
 	status = pci_register_driver(&dfx_pci_driver);
 	if (!status)
-		status = eisa_driver_register(&dfx_eisa_driver);
+		status = eisa_register_driver(&dfx_eisa_driver);
 	if (!status)
 		status = tc_register_driver(&dfx_tc_driver);
 	return status;
@@ -3722,7 +3722,7 @@ static int dfx_init(void)
 static void dfx_cleanup(void)
 {
 	tc_unregister_driver(&dfx_tc_driver);
-	eisa_driver_unregister(&dfx_eisa_driver);
+	eisa_unregister_driver(&dfx_eisa_driver);
 	pci_unregister_driver(&dfx_pci_driver);
 }
 
diff --git a/drivers/scsi/advansys.c b/drivers/scsi/advansys.c
index c67e401..17451e8 100644
--- a/drivers/scsi/advansys.c
+++ b/drivers/scsi/advansys.c
@@ -12307,7 +12307,7 @@ static int __init advansys_init(void)
 	if (error)
 		goto unregister_isa;
 
-	error = eisa_driver_register(&advansys_eisa_driver);
+	error = eisa_register_driver(&advansys_eisa_driver);
 	if (error)
 		goto unregister_vlb;
 
@@ -12318,7 +12318,7 @@ static int __init advansys_init(void)
 	return 0;
 
  unregister_eisa:
-	eisa_driver_unregister(&advansys_eisa_driver);
+	eisa_unregister_driver(&advansys_eisa_driver);
  unregister_vlb:
 	isa_unregister_driver(&advansys_vlb_driver);
  unregister_isa:
@@ -12330,7 +12330,7 @@ static int __init advansys_init(void)
 static void __exit advansys_exit(void)
 {
 	pci_unregister_driver(&advansys_pci_driver);
-	eisa_driver_unregister(&advansys_eisa_driver);
+	eisa_unregister_driver(&advansys_eisa_driver);
 	isa_unregister_driver(&advansys_vlb_driver);
 	isa_unregister_driver(&advansys_isa_driver);
 }
diff --git a/drivers/scsi/aha1740.c b/drivers/scsi/aha1740.c
index 5f31017..5f6bfed 100644
--- a/drivers/scsi/aha1740.c
+++ b/drivers/scsi/aha1740.c
@@ -664,12 +664,12 @@ static struct eisa_driver aha1740_driver = {
 
 static __init int aha1740_init (void)
 {
-	return eisa_driver_register (&aha1740_driver);
+	return eisa_register_driver (&aha1740_driver);
 }
 
 static __exit void aha1740_exit (void)
 {
-	eisa_driver_unregister (&aha1740_driver);
+	eisa_unregister_driver (&aha1740_driver);
 }
 
 module_init (aha1740_init);
diff --git a/drivers/scsi/aic7xxx/aic7770_osm.c b/drivers/scsi/aic7xxx/aic7770_osm.c
index 0cb8ef6..cbe99e4 100644
--- a/drivers/scsi/aic7xxx/aic7770_osm.c
+++ b/drivers/scsi/aic7xxx/aic7770_osm.c
@@ -146,11 +146,11 @@ static struct eisa_driver aic7770_driver = {
 int
 ahc_linux_eisa_init(void)
 {
-	return eisa_driver_register(&aic7770_driver);
+	return eisa_register_driver(&aic7770_driver);
 }
   
 void
 ahc_linux_eisa_exit(void)
 {
-	eisa_driver_unregister(&aic7770_driver);
+	eisa_unregister_driver(&aic7770_driver);
 }
diff --git a/drivers/scsi/sim710.c b/drivers/scsi/sim710.c
index 3b3b56f..d5c20cf 100644
--- a/drivers/scsi/sim710.c
+++ b/drivers/scsi/sim710.c
@@ -235,7 +235,7 @@ static int __init sim710_init(void)
 #endif
 
 #ifdef CONFIG_EISA
-	err = eisa_driver_register(&sim710_eisa_driver);
+	err = eisa_register_driver(&sim710_eisa_driver);
 #endif
 	/* FIXME: what we'd really like to return here is -ENODEV if
 	 * no devices have actually been found.  Instead, the err
@@ -248,7 +248,7 @@ static int __init sim710_init(void)
 static void __exit sim710_exit(void)
 {
 #ifdef CONFIG_EISA
-	eisa_driver_unregister(&sim710_eisa_driver);
+	eisa_unregister_driver(&sim710_eisa_driver);
 #endif
 }
 
diff --git a/include/linux/eisa.h b/include/linux/eisa.h
index 6925249..ab8bdb8 100644
--- a/include/linux/eisa.h
+++ b/include/linux/eisa.h
@@ -65,13 +65,13 @@ struct eisa_driver {
 #ifdef CONFIG_EISA
 
 extern struct bus_type eisa_bus_type;
-int eisa_driver_register (struct eisa_driver *edrv);
-void eisa_driver_unregister (struct eisa_driver *edrv);
+int eisa_register_driver (struct eisa_driver *edrv);
+void eisa_unregister_driver (struct eisa_driver *edrv);
 
 #else /* !CONFIG_EISA */
 
-static inline int eisa_driver_register (struct eisa_driver *edrv) { return 0; }
-static inline void eisa_driver_unregister (struct eisa_driver *edrv) { }
+static inline int eisa_register_driver (struct eisa_driver *edrv) { return 0; }
+static inline void eisa_unregister_driver (struct eisa_driver *edrv) { }
 
 #endif /* !CONFIG_EISA */
 
-- 
1.7.2.5


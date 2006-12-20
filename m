From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 2.6.20-rc1 04/10] EISA registration with !CONFIG_EISA
Date: Wed, 20 Dec 2006 12:01:49 +0000 (GMT)
Message-ID: <Pine.LNX.4.64N.0612191816460.20895@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-mips@linux-mips.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
To: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

 This is a change for the EISA bus support to permit drivers to call 
un/registration functions even if EISA support has not been enabled.  This 
is similar to what PCI (and now TC) does and reduces the need for #ifdef 
clutter.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---

 This is required by the updated defxx driver.

 Please apply.

  Maciej

patch-mips-2.6.18-20060920-eisa-register-0
diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/include/linux/eisa.h linux-mips-2.6.18-20060920/include/linux/eisa.h
--- linux-mips-2.6.18-20060920.macro/include/linux/eisa.h	2003-10-10 04:00:31.000000000 +0000
+++ linux-mips-2.6.18-20060920/include/linux/eisa.h	2006-12-14 22:43:31.000000000 +0000
@@ -67,10 +67,20 @@ struct eisa_driver {
 
 #define to_eisa_driver(drv) container_of(drv,struct eisa_driver, driver)
 
+/* These external functions are only available when EISA support is enabled. */
+#ifdef CONFIG_EISA
+
 extern struct bus_type eisa_bus_type;
 int eisa_driver_register (struct eisa_driver *edrv);
 void eisa_driver_unregister (struct eisa_driver *edrv);
 
+#else /* !CONFIG_EISA */
+
+static inline int eisa_driver_register (struct eisa_driver *edrv) { return 0; }
+static inline void eisa_driver_unregister (struct eisa_driver *edrv) { }
+
+#endif /* !CONFIG_EISA */
+
 /* Mimics pci.h... */
 static inline void *eisa_get_drvdata (struct eisa_device *edev)
 {

From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] switch lanmedia driver to initcalls
Date: Mon, 26 May 2003 21:25:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030526192513.GA5995@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It's a PCI driver and has no business in setup.c :)


--- 1.13/drivers/net/setup.c	Fri May 23 09:50:54 2003
+++ edited/drivers/net/setup.c	Sun May 25 13:33:06 2003
@@ -15,7 +15,6 @@
 extern int fec_enet_init(void); 
 extern int sdla_setup(void); 
 extern int sdla_c_setup(void); 
-extern int lmc_setup(void);
 
 /*
  *	Devices in this list must do new style probing. That is they must
@@ -44,9 +43,6 @@
 #endif
 #if defined(CONFIG_FEC_ENET)
         {fec_enet_init, 0},
-#endif
-#if defined(CONFIG_LANMEDIA)
-	{lmc_setup, 0},
 #endif
 	{NULL, 0},
 };
--- 1.14/drivers/net/wan/lmc/lmc_main.c	Mon May 12 04:48:01 2003
+++ edited/drivers/net/wan/lmc/lmc_main.c	Sun May 25 13:29:37 2003
@@ -1965,9 +1965,7 @@
     return (struct net_device_stats *) &sc->stats;
 }
 
-#ifdef MODULE
-
-int init_module (void) /*fold00*/
+static int __init init_lmc(void)
 {
     printk ("lmc: module loaded\n");
 
@@ -1978,7 +1976,7 @@
     return 0;
 }
 
-void cleanup_module (void) /*fold00*/
+static void __exit exit_lmc(void)
 {
     struct net_device *dev, *next;
     lmc_softc_t *sc;
@@ -2020,7 +2018,9 @@
     Lmc_root_dev = NULL;
     printk ("lmc module unloaded\n");
 }
-#endif
+
+module_init(init_lmc);
+module_exit(exit_lmc);
 
 unsigned lmc_mii_readreg (lmc_softc_t * const sc, unsigned devaddr, unsigned regno) /*fold00*/
 {

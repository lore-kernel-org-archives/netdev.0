From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: 1/x: [NETDRV] Ifdef builtin-only probe in ISA/MCA drivers
Date: Thu, 20 May 2004 21:19:37 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040520111937.GA21804@gondor.apana.org.au>
References: <20040313025859.GA8186@gondor.apana.org.au> <405C294D.5040508@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="RnlQjJ0d97Da+TV1"
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <405C294D.5040508@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--RnlQjJ0d97Da+TV1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Mar 20, 2004 at 06:21:49AM -0500, Jeff Garzik wrote:
> 
> I like the patch, but it is awfully big and wants splitting up.
> 
> Some early pieces to send (each as a separate patch):
> 
> * add #ifndef MODULE where appropriate

Thanks for the comments.

I'll split it up.  Here is the bit which conditionalises the
builtin-only probe functions.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--RnlQjJ0d97Da+TV1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1807  -> 1.1808 
#	drivers/net/eexpress.c	1.17    -> 1.18   
#	drivers/net/hp-plus.c	1.14    -> 1.15   
#	    drivers/net/wd.c	1.17    -> 1.18   
#	 drivers/net/lance.c	1.21    -> 1.22   
#	drivers/net/smc-ultra.c	1.20    -> 1.21   
#	    drivers/net/hp.c	1.12    -> 1.13   
#	drivers/net/ne2k_cbus.c	1.5     -> 1.6    
#	drivers/net/ne-h8300.c	1.1     -> 1.2    
#	 drivers/net/hp100.c	1.27    -> 1.28   
#	    drivers/net/ne.c	1.20    -> 1.21   
#	 drivers/net/3c523.c	1.14    -> 1.15   
#	drivers/net/ac3200.c	1.17    -> 1.18   
#	 drivers/net/3c503.c	1.18    -> 1.19   
#	 drivers/net/eepro.c	1.23    -> 1.24   
#	drivers/net/es3210.c	1.12    -> 1.13   
#	drivers/net/cs89x0.c	1.22    -> 1.23   
#	drivers/net/eth16i.c	1.17    -> 1.18   
#	 drivers/net/e2100.c	1.16    -> 1.17   
#	drivers/net/lne390.c	1.12    -> 1.13   
#	drivers/net/isa-skeleton.c	1.12    -> 1.13   
#	 drivers/net/ewrk3.c	1.28    -> 1.29   
#	   drivers/net/ne2.c	1.14    -> 1.15   
#	 drivers/net/3c505.c	1.28    -> 1.29   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/05/20	herbert@gondor.apana.org.au	1.1808
# [NETDRV] Conditionalise builtin-only probe function in ISA/MCA drivers.
# --------------------------------------------
#
diff -Nru a/drivers/net/3c503.c b/drivers/net/3c503.c
--- a/drivers/net/3c503.c	Thu May 20 21:16:23 2004
+++ b/drivers/net/3c503.c	Thu May 20 21:16:23 2004
@@ -147,6 +147,7 @@
 	release_region(dev->base_addr, EL2_IO_EXTENT);
 }
 
+#ifndef MODULE
 struct net_device * __init el2_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -171,6 +172,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 /* Probe for the Etherlink II card at I/O port base IOADDR,
    returning non-zero on success.  If found, set the station
diff -Nru a/drivers/net/3c505.c b/drivers/net/3c505.c
--- a/drivers/net/3c505.c	Thu May 20 21:16:23 2004
+++ b/drivers/net/3c505.c	Thu May 20 21:16:23 2004
@@ -1614,6 +1614,7 @@
 	return err;
 }
 
+#ifndef MODULE
 struct net_device * __init elplus_probe(int unit)
 {
 	struct net_device *dev = alloc_etherdev(sizeof(elp_device));
@@ -1632,7 +1633,7 @@
 	return dev;
 }
 
-#ifdef MODULE
+#else
 static struct net_device *dev_3c505[ELP_MAX_CARDS];
 static int io[ELP_MAX_CARDS];
 static int irq[ELP_MAX_CARDS];
diff -Nru a/drivers/net/3c523.c b/drivers/net/3c523.c
--- a/drivers/net/3c523.c	Thu May 20 21:16:23 2004
+++ b/drivers/net/3c523.c	Thu May 20 21:16:23 2004
@@ -585,6 +585,7 @@
 	release_region(dev->base_addr, ELMC_IO_EXTENT);
 }
 
+#ifndef MODULE
 struct net_device * __init elmc_probe(int unit)
 {
 	struct net_device *dev = alloc_etherdev(sizeof(struct priv));
@@ -609,6 +610,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 /**********************************************
  * init the chip (elmc-interrupt should be disabled?!)
diff -Nru a/drivers/net/ac3200.c b/drivers/net/ac3200.c
--- a/drivers/net/ac3200.c	Thu May 20 21:16:23 2004
+++ b/drivers/net/ac3200.c	Thu May 20 21:16:23 2004
@@ -130,6 +130,7 @@
 		iounmap((void *)dev->mem_start);
 }
 
+#ifndef MODULE
 struct net_device * __init ac3200_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -154,6 +155,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int __init ac_probe1(int ioaddr, struct net_device *dev)
 {
diff -Nru a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
--- a/drivers/net/cs89x0.c	Thu May 20 21:16:23 2004
+++ b/drivers/net/cs89x0.c	Thu May 20 21:16:23 2004
@@ -261,7 +261,6 @@
 }
 
 __setup("cs89x0_media=", media_fn);
-#endif
 
 
 /* Check for a network adaptor of this type, and return '0' iff one exists.
@@ -318,6 +317,7 @@
 	printk(KERN_WARNING "cs89x0: no cs8900 or cs8920 detected.  Be sure to disable PnP with SETUP\n");
 	return ERR_PTR(err);
 }
+#endif
 
 static int
 readreg(struct net_device *dev, int portno)
diff -Nru a/drivers/net/e2100.c b/drivers/net/e2100.c
--- a/drivers/net/e2100.c	Thu May 20 21:16:23 2004
+++ b/drivers/net/e2100.c	Thu May 20 21:16:23 2004
@@ -144,6 +144,7 @@
 	release_region(dev->base_addr, E21_IO_EXTENT);
 }
 
+#ifndef MODULE
 struct net_device * __init e2100_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -168,6 +169,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int __init e21_probe1(struct net_device *dev, int ioaddr)
 {
diff -Nru a/drivers/net/eepro.c b/drivers/net/eepro.c
--- a/drivers/net/eepro.c	Thu May 20 21:16:23 2004
+++ b/drivers/net/eepro.c	Thu May 20 21:16:23 2004
@@ -577,6 +577,7 @@
 	return -ENODEV;
 }
 
+#ifndef MODULE
 struct net_device * __init eepro_probe(int unit)
 {
 	struct net_device *dev = alloc_etherdev(sizeof(struct eepro_local));
@@ -603,6 +604,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static void __init printEEPROMInfo(short ioaddr, struct net_device *dev)
 {
diff -Nru a/drivers/net/eexpress.c b/drivers/net/eexpress.c
--- a/drivers/net/eexpress.c	Thu May 20 21:16:23 2004
+++ b/drivers/net/eexpress.c	Thu May 20 21:16:23 2004
@@ -423,6 +423,7 @@
 	return -ENODEV;
 }
 
+#ifndef MODULE
 struct net_device * __init express_probe(int unit)
 {
 	struct net_device *dev = alloc_etherdev(sizeof(struct net_local));
@@ -443,6 +444,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 /*
  * open and initialize the adapter, ready for use
diff -Nru a/drivers/net/es3210.c b/drivers/net/es3210.c
--- a/drivers/net/es3210.c	Thu May 20 21:16:23 2004
+++ b/drivers/net/es3210.c	Thu May 20 21:16:23 2004
@@ -161,6 +161,7 @@
 	release_region(dev->base_addr, ES_IO_EXTENT);
 }
 
+#ifndef MODULE
 struct net_device * __init es_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -185,6 +186,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int __init es_probe1(struct net_device *dev, int ioaddr)
 {
diff -Nru a/drivers/net/eth16i.c b/drivers/net/eth16i.c
--- a/drivers/net/eth16i.c	Thu May 20 21:16:23 2004
+++ b/drivers/net/eth16i.c	Thu May 20 21:16:23 2004
@@ -458,6 +458,7 @@
 	return -ENODEV;
 }
 
+#ifndef MODULE
 struct net_device * __init eth16i_probe(int unit)
 {
 	struct net_device *dev = alloc_etherdev(sizeof(struct eth16i_local));
@@ -483,6 +484,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int __init eth16i_probe1(struct net_device *dev, int ioaddr)
 {
diff -Nru a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
--- a/drivers/net/ewrk3.c	Thu May 20 21:16:23 2004
+++ b/drivers/net/ewrk3.c	Thu May 20 21:16:23 2004
@@ -341,6 +341,7 @@
     mdelay(1);\
 }
 
+#ifndef MODULE
 struct net_device * __init ewrk3_probe(int unit)
 {
 	struct net_device *dev = alloc_etherdev(sizeof(struct ewrk3_private));
@@ -364,6 +365,7 @@
 	return ERR_PTR(err);
 	
 }
+#endif
 
 static int __init ewrk3_probe1(struct net_device *dev, u_long iobase, int irq)
 {
diff -Nru a/drivers/net/hp-plus.c b/drivers/net/hp-plus.c
--- a/drivers/net/hp-plus.c	Thu May 20 21:16:23 2004
+++ b/drivers/net/hp-plus.c	Thu May 20 21:16:23 2004
@@ -142,6 +142,7 @@
 	release_region(dev->base_addr - NIC_OFFSET, HP_IO_EXTENT);
 }
 
+#ifndef MODULE
 struct net_device * __init hp_plus_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -166,6 +167,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 /* Do the interesting part of the probe at a single address. */
 static int __init hpp_probe1(struct net_device *dev, int ioaddr)
diff -Nru a/drivers/net/hp.c b/drivers/net/hp.c
--- a/drivers/net/hp.c	Thu May 20 21:16:23 2004
+++ b/drivers/net/hp.c	Thu May 20 21:16:23 2004
@@ -106,6 +106,7 @@
 	release_region(dev->base_addr - NIC_OFFSET, HP_IO_EXTENT);
 }
 
+#ifndef MODULE
 struct net_device * __init hp_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -130,6 +131,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int __init hp_probe1(struct net_device *dev, int ioaddr)
 {
diff -Nru a/drivers/net/hp100.c b/drivers/net/hp100.c
--- a/drivers/net/hp100.c	Thu May 20 21:16:23 2004
+++ b/drivers/net/hp100.c	Thu May 20 21:16:23 2004
@@ -386,6 +386,7 @@
 }
 
 
+#ifndef MODULE
 struct net_device * __init hp100_probe(int unit)
 {
 	struct net_device *dev = alloc_etherdev(sizeof(struct hp100_private));
@@ -420,6 +421,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int __init hp100_probe1(struct net_device *dev, int ioaddr,
 			       u_char bus, struct pci_dev *pci_dev)
diff -Nru a/drivers/net/isa-skeleton.c b/drivers/net/isa-skeleton.c
--- a/drivers/net/isa-skeleton.c	Thu May 20 21:16:23 2004
+++ b/drivers/net/isa-skeleton.c	Thu May 20 21:16:23 2004
@@ -161,6 +161,7 @@
 	release_region(dev->base_addr, NETCARD_IO_EXTENT);
 }
 
+#ifndef MODULE
 struct net_device * __init netcard_probe(int unit)
 {
 	struct net_device *dev = alloc_etherdev(sizeof(struct net_local));
@@ -185,6 +186,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 /*
  * This is the real probe routine. Linux has a history of friendly device
diff -Nru a/drivers/net/lance.c b/drivers/net/lance.c
--- a/drivers/net/lance.c	Thu May 20 21:16:23 2004
+++ b/drivers/net/lance.c	Thu May 20 21:16:23 2004
@@ -432,6 +432,7 @@
 	return -ENODEV;
 }
 
+#ifndef MODULE
 struct net_device * __init lance_probe(int unit)
 {
 	struct net_device *dev = alloc_etherdev(0);
@@ -456,6 +457,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int __init lance_probe1(struct net_device *dev, int ioaddr, int irq, int options)
 {
diff -Nru a/drivers/net/lne390.c b/drivers/net/lne390.c
--- a/drivers/net/lne390.c	Thu May 20 21:16:23 2004
+++ b/drivers/net/lne390.c	Thu May 20 21:16:23 2004
@@ -151,6 +151,7 @@
 		iounmap((void *)dev->mem_start);
 }
 
+#ifndef MODULE
 struct net_device * __init lne390_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -175,6 +176,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int __init lne390_probe1(struct net_device *dev, int ioaddr)
 {
diff -Nru a/drivers/net/ne-h8300.c b/drivers/net/ne-h8300.c
--- a/drivers/net/ne-h8300.c	Thu May 20 21:16:23 2004
+++ b/drivers/net/ne-h8300.c	Thu May 20 21:16:23 2004
@@ -156,6 +156,7 @@
 	release_region(dev->base_addr, NE_IO_EXTENT);
 }
 
+#ifndef MODULE
 struct net_device * __init ne_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -187,6 +188,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int __init ne_probe1(struct net_device *dev, int ioaddr)
 {
diff -Nru a/drivers/net/ne.c b/drivers/net/ne.c
--- a/drivers/net/ne.c	Thu May 20 21:16:23 2004
+++ b/drivers/net/ne.c	Thu May 20 21:16:23 2004
@@ -203,6 +203,7 @@
 	release_region(dev->base_addr, NE_IO_EXTENT);
 }
 
+#ifndef MODULE
 struct net_device * __init ne_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -227,6 +228,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int __init ne_probe_isapnp(struct net_device *dev)
 {
diff -Nru a/drivers/net/ne2.c b/drivers/net/ne2.c
--- a/drivers/net/ne2.c	Thu May 20 21:16:23 2004
+++ b/drivers/net/ne2.c	Thu May 20 21:16:23 2004
@@ -284,6 +284,7 @@
 	release_region(dev->base_addr, NE_IO_EXTENT);
 }
 
+#ifndef MODULE
 struct net_device * __init ne2_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -308,6 +309,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int ne2_procinfo(char *buf, int slot, struct net_device *dev)
 {
diff -Nru a/drivers/net/ne2k_cbus.c b/drivers/net/ne2k_cbus.c
--- a/drivers/net/ne2k_cbus.c	Thu May 20 21:16:23 2004
+++ b/drivers/net/ne2k_cbus.c	Thu May 20 21:16:23 2004
@@ -187,6 +187,7 @@
 	ne2k_cbus_destroy(dev);
 }
 
+#ifndef MODULE
 struct net_device * __init ne_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -211,6 +212,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int __init ne_probe_cbus(struct net_device *dev, const struct ne2k_cbus_hwinfo *hw, int ioaddr, int irq)
 {
diff -Nru a/drivers/net/smc-ultra.c b/drivers/net/smc-ultra.c
--- a/drivers/net/smc-ultra.c	Thu May 20 21:16:23 2004
+++ b/drivers/net/smc-ultra.c	Thu May 20 21:16:23 2004
@@ -178,6 +178,7 @@
 	release_region(dev->base_addr - ULTRA_NIC_OFFSET, ULTRA_IO_EXTENT);
 }
 
+#ifndef MODULE
 struct net_device * __init ultra_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -202,6 +203,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int __init ultra_probe1(struct net_device *dev, int ioaddr)
 {
diff -Nru a/drivers/net/wd.c b/drivers/net/wd.c
--- a/drivers/net/wd.c	Thu May 20 21:16:23 2004
+++ b/drivers/net/wd.c	Thu May 20 21:16:23 2004
@@ -131,6 +131,7 @@
 	release_region(dev->base_addr - WD_NIC_OFFSET, WD_IO_EXTENT);
 }
 
+#ifndef MODULE
 struct net_device * __init wd_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -155,6 +156,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int __init wd_probe1(struct net_device *dev, int ioaddr)
 {

--RnlQjJ0d97Da+TV1--

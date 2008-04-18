From: akpm@linux-foundation.org
Subject: [patch 1/2] smsc-ircc2: wrap PNP probe code in #ifdef CONFIG_PNP
Date: Fri, 18 Apr 2008 13:47:33 -0700
Message-ID: <200804182047.m3IKlXQq014653@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	bjorn.helgaas@hp.com, kamalesh@linux.vnet.ibm.com,
	sfr@canb.auug.org.au
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46389 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753216AbYDRUuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 16:50:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bjorn Helgaas <bjorn.helgaas@hp.com>

Wrap PNP probe code in #ifdef CONFIG_PNP.

Without this change, we'll have unresolved references to pnp_get_resource()
function when CONFIG_PNP=n.  (This is a new interface that's not in mainline
yet.)

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Cc: Samuel Ortiz <samuel@sortiz.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/irda/smsc-ircc2.c |   14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff -puN drivers/net/irda/smsc-ircc2.c~smsc-ircc2-wrap-pnp-probe-code-in-ifdef-config_pnp drivers/net/irda/smsc-ircc2.c
--- a/drivers/net/irda/smsc-ircc2.c~smsc-ircc2-wrap-pnp-probe-code-in-ifdef-config_pnp
+++ a/drivers/net/irda/smsc-ircc2.c
@@ -79,9 +79,13 @@ MODULE_AUTHOR("Daniele Peri <peri@csai.u
 MODULE_DESCRIPTION("SMC IrCC SIR/FIR controller driver");
 MODULE_LICENSE("GPL");
 
+#ifdef CONFIG_PNP
 static int smsc_nopnp = 1;
 module_param_named(nopnp, smsc_nopnp, bool, 0);
 MODULE_PARM_DESC(nopnp, "Do not use PNP to detect controller settings, defaults to true");
+#else
+#define smsc_nopnp 1
+#endif
 
 #define DMA_INVAL 255
 static int ircc_dma = DMA_INVAL;
@@ -366,6 +370,10 @@ static inline void register_bank(int iob
                iobase + IRCC_MASTER);
 }
 
+static int pnp_driver_registered;
+
+#ifdef CONFIG_PNP
+
 /* PNP hotplug support */
 static const struct pnp_device_id smsc_ircc_pnp_table[] = {
 	{ .id = "SMCf010", .driver_data = 0 },
@@ -374,8 +382,6 @@ static const struct pnp_device_id smsc_i
 };
 MODULE_DEVICE_TABLE(pnp, smsc_ircc_pnp_table);
 
-static int pnp_driver_registered;
-
 static int __init smsc_ircc_pnp_probe(struct pnp_dev *dev,
 				      const struct pnp_device_id *dev_id)
 {
@@ -403,6 +409,10 @@ static struct pnp_driver smsc_ircc_pnp_d
 	.probe		= smsc_ircc_pnp_probe,
 };
 
+#else
+static struct pnp_driver smsc_ircc_pnp_driver;
+#endif
+
 
 /*******************************************************************************
  *
_

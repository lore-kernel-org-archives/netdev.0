From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 200/493] irda: remove use of __devinit
Date: Mon, 19 Nov 2012 13:22:29 -0500
Message-ID: <1353349642-3677-200-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41328 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455Ab2KSScu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:32:50 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devinit is no longer
needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Samuel Ortiz <samuel@sortiz.org> 
Cc: netdev@vger.kernel.org 
---
 drivers/net/irda/au1k_ir.c    | 4 ++--
 drivers/net/irda/bfin_sir.c   | 4 ++--
 drivers/net/irda/sh_irda.c    | 2 +-
 drivers/net/irda/sh_sir.c     | 2 +-
 drivers/net/irda/smsc-ircc2.c | 4 ++--
 drivers/net/irda/via-ircc.c   | 6 +++---
 drivers/net/irda/vlsi_ir.c    | 2 +-
 7 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index 51bbc14..7843f50 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -760,7 +760,7 @@ static const struct net_device_ops au1k_irda_netdev_ops = {
 	.ndo_do_ioctl		= au1k_irda_ioctl,
 };
 
-static int __devinit au1k_irda_net_init(struct net_device *dev)
+static int au1k_irda_net_init(struct net_device *dev)
 {
 	struct au1k_private *aup = netdev_priv(dev);
 	struct db_dest *pDB, *pDBfree;
@@ -849,7 +849,7 @@ out1:
 	return retval;
 }
 
-static int __devinit au1k_irda_probe(struct platform_device *pdev)
+static int au1k_irda_probe(struct platform_device *pdev)
 {
 	struct au1k_private *aup;
 	struct net_device *dev;
diff --git a/drivers/net/irda/bfin_sir.c b/drivers/net/irda/bfin_sir.c
index a4d0dda..98c903f 100644
--- a/drivers/net/irda/bfin_sir.c
+++ b/drivers/net/irda/bfin_sir.c
@@ -31,7 +31,7 @@ static void turnaround_delay(unsigned long last_jif, int mtt)
 	schedule_timeout_uninterruptible(ticks);
 }
 
-static void __devinit bfin_sir_init_ports(struct bfin_sir_port *sp, struct platform_device *pdev)
+static void bfin_sir_init_ports(struct bfin_sir_port *sp, struct platform_device *pdev)
 {
 	int i;
 	struct resource *res;
@@ -688,7 +688,7 @@ static const struct net_device_ops bfin_sir_ndo = {
 	.ndo_get_stats		= bfin_sir_stats,
 };
 
-static int __devinit bfin_sir_probe(struct platform_device *pdev)
+static int bfin_sir_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct bfin_sir_self *self;
diff --git a/drivers/net/irda/sh_irda.c b/drivers/net/irda/sh_irda.c
index a99127d..2d3f3e6 100644
--- a/drivers/net/irda/sh_irda.c
+++ b/drivers/net/irda/sh_irda.c
@@ -753,7 +753,7 @@ static const struct net_device_ops sh_irda_ndo = {
 
 
 ************************************************************************/
-static int __devinit sh_irda_probe(struct platform_device *pdev)
+static int sh_irda_probe(struct platform_device *pdev)
 {
 	struct net_device *ndev;
 	struct sh_irda_self *self;
diff --git a/drivers/net/irda/sh_sir.c b/drivers/net/irda/sh_sir.c
index 1b31f16..150b56c 100644
--- a/drivers/net/irda/sh_sir.c
+++ b/drivers/net/irda/sh_sir.c
@@ -705,7 +705,7 @@ static const struct net_device_ops sh_sir_ndo = {
 
 
 ************************************************************************/
-static int __devinit sh_sir_probe(struct platform_device *pdev)
+static int sh_sir_probe(struct platform_device *pdev)
 {
 	struct net_device *ndev;
 	struct sh_sir_self *self;
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index a926813..82c5f30a 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -376,7 +376,7 @@ MODULE_DEVICE_TABLE(pnp, smsc_ircc_pnp_table);
 static int pnp_driver_registered;
 
 #ifdef CONFIG_PNP
-static int __devinit smsc_ircc_pnp_probe(struct pnp_dev *dev,
+static int smsc_ircc_pnp_probe(struct pnp_dev *dev,
 				      const struct pnp_device_id *dev_id)
 {
 	unsigned int firbase, sirbase;
@@ -515,7 +515,7 @@ static const struct net_device_ops smsc_ircc_netdev_ops = {
  *    Try to open driver instance
  *
  */
-static int __devinit smsc_ircc_open(unsigned int fir_base, unsigned int sir_base, u8 dma, u8 irq)
+static int smsc_ircc_open(unsigned int fir_base, unsigned int sir_base, u8 dma, u8 irq)
 {
 	struct smsc_ircc_cb *self;
 	struct net_device *dev;
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 1b5e27a..d678f52 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -102,7 +102,7 @@ static int RxTimerHandler(struct via_ircc_cb *self, int iobase);
 static void hwreset(struct via_ircc_cb *self);
 static int via_ircc_dma_xmit(struct via_ircc_cb *self, u16 iobase);
 static int upload_rxdata(struct via_ircc_cb *self, int iobase);
-static int __devinit via_init_one (struct pci_dev *pcidev, const struct pci_device_id *id);
+static int via_init_one (struct pci_dev *pcidev, const struct pci_device_id *id);
 static void __devexit via_remove_one (struct pci_dev *pdev);
 
 /* FIXME : Should use udelay() instead, even if we are x86 only - Jean II */
@@ -156,7 +156,7 @@ static int __init via_ircc_init(void)
 	return 0;
 }
 
-static int __devinit via_init_one (struct pci_dev *pcidev, const struct pci_device_id *id)
+static int via_init_one (struct pci_dev *pcidev, const struct pci_device_id *id)
 {
 	int rc;
         u8 temp,oldPCI_40,oldPCI_44,bTmp,bTmp1;
@@ -286,7 +286,7 @@ static const struct net_device_ops via_ircc_fir_ops = {
  *    Open driver instance
  *
  */
-static __devinit int via_ircc_open(struct pci_dev *pdev, chipio_t * info,
+static int via_ircc_open(struct pci_dev *pdev, chipio_t * info,
 				   unsigned int id)
 {
 	struct net_device *dev;
diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index 931ef88..e255b65 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -1627,7 +1627,7 @@ static int vlsi_irda_init(struct net_device *ndev)
 
 /**************************************************************/
 
-static int __devinit
+static int
 vlsi_irda_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 {
 	struct net_device	*ndev;
-- 
1.8.0

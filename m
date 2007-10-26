From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] NETDRVR, USB: declance, lp486e, s3c2410_udc: minor irq handler cleanups
Date: Fri, 26 Oct 2007 05:40:32 -0400 (EDT)
Message-ID: <e4e05275a817f3d6dcafccfa24adf940cfde0a8a.1193390975.git.jeff@garzik.org>
References: <9799624f63e093aa915947aea8fb1b8a5df959a1.1193390973.git.jeff@garzik.org>
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	dbrownell@users.sourceforge.net
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:33767 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755899AbXJZJlR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 05:41:17 -0400
In-Reply-To: <9799624f63e093aa915947aea8fb1b8a5df959a1.1193390973.git.jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

declance:
	- irq handlers do not take 'const int' as first arg
	- add KERN_ prefix

lp486e:
	- neaten irq handler top of function formatting
	- remove pointless void* casts

s3c2410_udc:
	- 'irq' argument is merely used in place of a constant;
	  replace its usage with that constant.

Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
---
 drivers/net/declance.c           |    6 +++---
 drivers/net/lp486e.c             |    9 ++++-----
 drivers/usb/gadget/s3c2410_udc.c |    4 ++--
 3 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/net/declance.c b/drivers/net/declance.c
index 00e0194..6b1e77c 100644
--- a/drivers/net/declance.c
+++ b/drivers/net/declance.c
@@ -719,15 +719,15 @@ out:
 	spin_unlock(&lp->lock);
 }
 
-static irqreturn_t lance_dma_merr_int(const int irq, void *dev_id)
+static irqreturn_t lance_dma_merr_int(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 
-	printk("%s: DMA error\n", dev->name);
+	printk(KERN_ERR "%s: DMA error\n", dev->name);
 	return IRQ_HANDLED;
 }
 
-static irqreturn_t lance_interrupt(const int irq, void *dev_id)
+static irqreturn_t lance_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 	struct lance_private *lp = netdev_priv(dev);
diff --git a/drivers/net/lp486e.c b/drivers/net/lp486e.c
index c5095ec..0eff1a0 100644
--- a/drivers/net/lp486e.c
+++ b/drivers/net/lp486e.c
@@ -1144,14 +1144,13 @@ i596_handle_CU_completion(struct net_device *dev,
 }
 
 static irqreturn_t
-i596_interrupt (int irq, void *dev_instance) {
-	struct net_device *dev = (struct net_device *) dev_instance;
-	struct i596_private *lp;
+i596_interrupt (int irq, void *dev_instance)
+{
+	struct net_device *dev = dev_instance;
+	struct i596_private *lp = dev->priv;
 	unsigned short status, ack_cmd = 0;
 	int frames_in = 0;
 
-	lp = (struct i596_private *) dev->priv;
-
 	/*
 	 * The 82596 examines the command, performs the required action,
 	 * and then clears the SCB command word.
diff --git a/drivers/usb/gadget/s3c2410_udc.c b/drivers/usb/gadget/s3c2410_udc.c
index e3e90f8..1b07bc9 100644
--- a/drivers/usb/gadget/s3c2410_udc.c
+++ b/drivers/usb/gadget/s3c2410_udc.c
@@ -893,7 +893,7 @@ static void s3c2410_udc_handle_ep(struct s3c2410_ep *ep)
 /*
  *	s3c2410_udc_irq - interrupt handler
  */
-static irqreturn_t s3c2410_udc_irq(int irq, void *_dev)
+static irqreturn_t s3c2410_udc_irq(int dummy, void *_dev)
 {
 	struct s3c2410_udc *dev = _dev;
 	int usb_status;
@@ -1016,7 +1016,7 @@ static irqreturn_t s3c2410_udc_irq(int irq, void *_dev)
 		}
 	}
 
-	dprintk(DEBUG_VERBOSE, "irq: %d s3c2410_udc_done.\n", irq);
+	dprintk(DEBUG_VERBOSE, "irq: %d s3c2410_udc_done.\n", IRQ_USBD);
 
 	/* Restore old index */
 	udc_write(idx, S3C2410_UDC_INDEX_REG);
-- 
1.5.2.4


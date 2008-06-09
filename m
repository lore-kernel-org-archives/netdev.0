From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] drivers/net/: remove write-only "last_dev"
Date: Tue, 10 Jun 2008 01:23:25 +0300
Message-ID: <20080609222324.GN1987@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:53963 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759553AbYFIWYT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2008 18:24:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes write-only global "last_dev" variables from the 
following drivers:
- a2065.c
- declance.c
- sunlance.c

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 drivers/net/a2065.c    |    4 ----
 drivers/net/declance.c |    4 ----
 drivers/net/sunlance.c |    4 ----
 3 files changed, 12 deletions(-)

0214a4acf292e48df719498369573ac3d9bc7dd5 diff --git a/drivers/net/a2065.c b/drivers/net/a2065.c
index 6c5719a..9c08374 100644
--- a/drivers/net/a2065.c
+++ b/drivers/net/a2065.c
@@ -475,16 +475,12 @@ static irqreturn_t lance_interrupt (int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-struct net_device *last_dev;
-
 static int lance_open (struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
 	int ret;
 
-	last_dev = dev;
-
 	/* Stop the Lance */
 	ll->rap = LE_CSR0;
 	ll->rdp = LE_C0_STOP;
diff --git a/drivers/net/declance.c b/drivers/net/declance.c
index 6b1e77c..3e35064 100644
--- a/drivers/net/declance.c
+++ b/drivers/net/declance.c
@@ -773,8 +773,6 @@ static irqreturn_t lance_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-struct net_device *last_dev = 0;
-
 static int lance_open(struct net_device *dev)
 {
 	volatile u16 *ib = (volatile u16 *)dev->mem_start;
@@ -782,8 +780,6 @@ static int lance_open(struct net_device *dev)
 	volatile struct lance_regs *ll = lp->ll;
 	int status = 0;
 
-	last_dev = dev;
-
 	/* Stop the Lance */
 	writereg(&ll->rap, LE_CSR0);
 	writereg(&ll->rdp, LE_C0_STOP);
diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index 26ade68..4e994f8 100644
--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -915,15 +915,11 @@ static void build_fake_packet(struct lance_private *lp)
 	lp->tx_new = TX_NEXT(entry);
 }
 
-struct net_device *last_dev;
-
 static int lance_open(struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
 	int status = 0;
 
-	last_dev = dev;
-
 	STOP_LANCE(lp);
 
 	if (request_irq(dev->irq, &lance_interrupt, IRQF_SHARED,

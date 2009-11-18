From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 3/16] drivers/net: remove exceptional & on function name
Date: Wed, 18 Nov 2009 19:21:04 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0911181920450.20943@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, arnd@arndb.de, joe@perches.com,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:56220 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758195AbZKRSVA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2009 13:21:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

In this file, function names are otherwise used as pointers without &.

A simplified version of the semantic patch that makes this change is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@r@
identifier f;
@@

f(...) { ... }

@@
identifier r.f;
@@

- &f
+ f
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/ethoc.c             |    2 +-
 drivers/net/pcmcia/fmvj18x_cs.c |    2 +-
 drivers/net/pcmcia/nmclan_cs.c  |    2 +-
 drivers/net/tokenring/3c359.c   |    3 +--
 drivers/net/tokenring/olympic.c |    4 ++--
 5 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 50f1923..bd1db92 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -641,7 +641,7 @@ static int ethoc_mdio_probe(struct net_device *dev)
 		return -ENXIO;
 	}
 
-	phy = phy_connect(dev, dev_name(&phy->dev), &ethoc_mdio_poll, 0,
+	phy = phy_connect(dev, dev_name(&phy->dev), ethoc_mdio_poll, 0,
 			PHY_INTERFACE_MODE_GMII);
 	if (IS_ERR(phy)) {
 		dev_err(&dev->dev, "could not attach to PHY\n");
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index fdec5c3..d3a81ad 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -257,7 +257,7 @@ static int fmvj18x_probe(struct pcmcia_device *link)
     /* Interrupt setup */
     link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING|IRQ_HANDLE_PRESENT;
     link->irq.IRQInfo1 = IRQ_LEVEL_ID;
-    link->irq.Handler = &fjn_interrupt;
+    link->irq.Handler = fjn_interrupt;
     link->irq.Instance = dev;
 
     /* General socket configuration */
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index a536348..8fda8a4 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -465,7 +465,7 @@ static int nmclan_probe(struct pcmcia_device *link)
     link->io.IOAddrLines = 5;
     link->irq.Attributes = IRQ_TYPE_EXCLUSIVE | IRQ_HANDLE_PRESENT;
     link->irq.IRQInfo1 = IRQ_LEVEL_ID;
-    link->irq.Handler = &mace_interrupt;
+    link->irq.Handler = mace_interrupt;
     link->irq.Instance = dev;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index 7241589..cf552d1 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -610,9 +610,8 @@ static int xl_open(struct net_device *dev)
 
 	u16 switchsettings, switchsettings_eeprom  ;
  
-	if(request_irq(dev->irq, &xl_interrupt, IRQF_SHARED , "3c359", dev)) {
+	if (request_irq(dev->irq, xl_interrupt, IRQF_SHARED , "3c359", dev))
 		return -EAGAIN;
-	}
 
 	/* 
 	 * Read the information from the EEPROM that we need.
diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
index d9ec7f0..df32025 100644
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -445,9 +445,9 @@ static int olympic_open(struct net_device *dev)
 
 	olympic_init(dev);
 
-	if(request_irq(dev->irq, &olympic_interrupt, IRQF_SHARED , "olympic", dev)) {
+	if (request_irq(dev->irq, olympic_interrupt, IRQF_SHARED , "olympic",
+			dev))
 		return -EAGAIN;
-	}
 
 #if OLYMPIC_DEBUG
 	printk("BMCTL: %x\n",readl(olympic_mmio+BMCTL_SUM));

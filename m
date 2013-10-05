From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] irda: remove deprecated IRQF_DISABLED
Date: Sat,  5 Oct 2013 06:39:24 +0200
Message-ID: <1380947964-4206-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch proposes to remove the use of the IRQF_DISABLED flag

It's a NOOP since 2.6.35 and it will be removed one day.

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 drivers/net/irda/bfin_sir.c | 4 ++--
 drivers/net/irda/donauboe.c | 4 ++--
 drivers/net/irda/sh_irda.c  | 2 +-
 drivers/net/irda/sh_sir.c   | 2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/irda/bfin_sir.c b/drivers/net/irda/bfin_sir.c
index c74f384..303c4bd 100644
--- a/drivers/net/irda/bfin_sir.c
+++ b/drivers/net/irda/bfin_sir.c
@@ -411,12 +411,12 @@ static int bfin_sir_startup(struct bfin_sir_port *port, struct net_device *dev)
 
 #else
 
-	if (request_irq(port->irq, bfin_sir_rx_int, IRQF_DISABLED, "BFIN_SIR_RX", dev)) {
+	if (request_irq(port->irq, bfin_sir_rx_int, 0, "BFIN_SIR_RX", dev)) {
 		dev_warn(&dev->dev, "Unable to attach SIR RX interrupt\n");
 		return -EBUSY;
 	}
 
-	if (request_irq(port->irq+1, bfin_sir_tx_int, IRQF_DISABLED, "BFIN_SIR_TX", dev)) {
+	if (request_irq(port->irq+1, bfin_sir_tx_int, 0, "BFIN_SIR_TX", dev)) {
 		dev_warn(&dev->dev, "Unable to attach SIR TX interrupt\n");
 		free_irq(port->irq, dev);
 		return -EBUSY;
diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index 31bcb98..768dfe9 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -1352,7 +1352,7 @@ toshoboe_net_open (struct net_device *dev)
     return 0;
 
   rc = request_irq (self->io.irq, toshoboe_interrupt,
-                    IRQF_SHARED | IRQF_DISABLED, dev->name, self);
+                    IRQF_SHARED, dev->name, self);
   if (rc)
   	return rc;
 
@@ -1559,7 +1559,7 @@ toshoboe_open (struct pci_dev *pci_dev, const struct pci_device_id *pdid)
   self->io.fir_base = self->base;
   self->io.fir_ext = OBOE_IO_EXTENT;
   self->io.irq = pci_dev->irq;
-  self->io.irqflags = IRQF_SHARED | IRQF_DISABLED;
+  self->io.irqflags = IRQF_SHARED;
 
   self->speed = self->io.speed = 9600;
   self->async = 0;
diff --git a/drivers/net/irda/sh_irda.c b/drivers/net/irda/sh_irda.c
index 4455425..ff45cd0 100644
--- a/drivers/net/irda/sh_irda.c
+++ b/drivers/net/irda/sh_irda.c
@@ -804,7 +804,7 @@ static int sh_irda_probe(struct platform_device *pdev)
 		goto err_mem_4;
 
 	platform_set_drvdata(pdev, ndev);
-	err = request_irq(irq, sh_irda_irq, IRQF_DISABLED, "sh_irda", self);
+	err = request_irq(irq, sh_irda_irq, 0, "sh_irda", self);
 	if (err) {
 		dev_warn(&pdev->dev, "Unable to attach sh_irda interrupt\n");
 		goto err_mem_4;
diff --git a/drivers/net/irda/sh_sir.c b/drivers/net/irda/sh_sir.c
index 89682b4..8d9ae5a 100644
--- a/drivers/net/irda/sh_sir.c
+++ b/drivers/net/irda/sh_sir.c
@@ -761,7 +761,7 @@ static int sh_sir_probe(struct platform_device *pdev)
 		goto err_mem_4;
 
 	platform_set_drvdata(pdev, ndev);
-	err = request_irq(irq, sh_sir_irq, IRQF_DISABLED, "sh_sir", self);
+	err = request_irq(irq, sh_sir_irq, 0, "sh_sir", self);
 	if (err) {
 		dev_warn(&pdev->dev, "Unable to attach sh_sir interrupt\n");
 		goto err_mem_4;
-- 
1.8.1.2

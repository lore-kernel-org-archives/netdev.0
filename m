From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 3/7] drivers/net/irda/{ali-ircc,via-ircc,w83977af-ir}.c: ensure arguments to request_irq and free_irq are compatible
Date: Sun, 11 Mar 2012 20:36:23 +0100
Message-ID: <1331494587-12196-4-git-send-email-Julia.Lawall@lip6.fr>
References: <1331494587-12196-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1331494587-12196-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Convert calls to free_irq so that the second argument is the same as the
last argument of the corresponding call to request_irq.  Without this
property, free_irq does nothing.

In each case, there is one call to free_irq with self as the second
argument and one with dev as the second argument.  Even though dev was also
the last argument of request_irq, I have changed all of the calls to use
self, as it fits better with the first argument to each function.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
Not tested.  I don't know if I have made the right choice.

 drivers/net/irda/ali-ircc.c    |    4 ++--
 drivers/net/irda/via-ircc.c    |    4 ++--
 drivers/net/irda/w83977af_ir.c |    4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index 963067d..7e732d7 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -1352,7 +1352,7 @@ static int ali_ircc_net_open(struct net_device *dev)
 	iobase = self->io.fir_base;
 	
 	/* Request IRQ and install Interrupt Handler */
-	if (request_irq(self->io.irq, ali_ircc_interrupt, 0, dev->name, dev)) 
+	if (request_irq(self->io.irq, ali_ircc_interrupt, 0, dev->name, self))
 	{
 		IRDA_WARNING("%s, unable to allocate irq=%d\n",
 			     ALI_IRCC_DRIVER_NAME,
@@ -1424,7 +1424,7 @@ static int ali_ircc_net_close(struct net_device *dev)
 	/* Disable interrupts */
 	SetCOMInterrupts(self, FALSE);
 	       
-	free_irq(self->io.irq, dev);
+	free_irq(self->io.irq, self);
 	free_dma(self->io.dma);
 
 	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 2d456dd..c0678be 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -1483,7 +1483,7 @@ static int via_ircc_net_open(struct net_device *dev)
 	dev->stats.rx_packets = 0;
 	IRDA_ASSERT(self != NULL, return 0;);
 	iobase = self->io.fir_base;
-	if (request_irq(self->io.irq, via_ircc_interrupt, 0, dev->name, dev)) {
+	if (request_irq(self->io.irq, via_ircc_interrupt, 0, dev->name, self)) {
 		IRDA_WARNING("%s, unable to allocate irq=%d\n", driver_name,
 			     self->io.irq);
 		return -EAGAIN;
@@ -1562,7 +1562,7 @@ static int via_ircc_net_close(struct net_device *dev)
 
 	/* Disable interrupts */
 	EnAllInt(iobase, OFF);
-	free_irq(self->io.irq, dev);
+	free_irq(self->io.irq, self);
 	free_dma(self->io.dma);
 	if (self->io.dma2 != self->io.dma)
 		free_dma(self->io.dma2);
diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 7d43506..c0c430c 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -1164,7 +1164,7 @@ static int w83977af_net_open(struct net_device *dev)
 	iobase = self->io.fir_base;
 
 	if (request_irq(self->io.irq, w83977af_interrupt, 0, dev->name, 
-			(void *) dev)) {
+			self)) {
 		return -EAGAIN;
 	}
 	/*
@@ -1244,7 +1244,7 @@ static int w83977af_net_close(struct net_device *dev)
 	switch_bank(iobase, SET0);
 	outb(0, iobase+ICR); 
 
-	free_irq(self->io.irq, dev);
+	free_irq(self->io.irq, self);
 	free_dma(self->io.dma);
 
 	/* Restore bank register */

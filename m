From: Joe Perches <joe@perches.com>
Subject: [PATCH 5/8] irda: w83977af_ir: Use the common brace style
Date: Thu, 24 Nov 2016 11:10:32 -0800
Message-ID: <a6f62a9e467f1450e5e91c00bbafeca73d0bec24.1480014088.git.joe@perches.com>
References: <cover.1480014088.git.joe@perches.com>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1480014088.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add braces where appropriate and remove an unnecessary else.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/irda/w83977af_ir.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index ac481303e3ab..5d776fb716f4 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -462,8 +462,9 @@ static void w83977af_change_speed(struct w83977af_ir *self, __u32 speed)
 	if (speed > PIO_MAX_SPEED) {
 		outb(ICR_EFSFI, iobase + ICR);
 		w83977af_dma_receive(self);
-	} else
+	} else {
 		outb(ICR_ERBRI, iobase + ICR);
+	}
 
 	/* Restore SSR */
 	outb(set, iobase + SSR);
@@ -502,8 +503,8 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
 			w83977af_change_speed(self, speed);
 			dev_kfree_skb(skb);
 			return NETDEV_TX_OK;
-		} else
-			self->new_speed = speed;
+		}
+		self->new_speed = speed;
 	}
 
 	/* Save current set */
@@ -649,8 +650,9 @@ static void w83977af_dma_xmit_complete(struct w83977af_ir *self)
 
 		/* Clear bit, by writing 1 to it */
 		outb(AUDR_UNDR, iobase + AUDR);
-	} else
+	} else {
 		self->netdev->stats.tx_packets++;
+	}
 
 	if (self->new_speed) {
 		w83977af_change_speed(self, self->new_speed);
@@ -813,9 +815,8 @@ static int w83977af_dma_receive_complete(struct w83977af_ir *self)
 		} else {
 			/* Check if we have transferred all data to memory */
 			switch_bank(iobase, SET0);
-			if (inb(iobase + USR) & USR_RDR) {
+			if (inb(iobase + USR) & USR_RDR)
 				udelay(80); /* Should be enough!? */
-			}
 
 			skb = dev_alloc_skb(len + 1);
 			if (!skb)  {
@@ -969,7 +970,6 @@ static __u8 w83977af_fir_interrupt(struct w83977af_ir *self, int isr)
 	/* End of frame detected in FIFO */
 	if (isr & (ISR_FEND_I | ISR_FSF_I)) {
 		if (w83977af_dma_receive_complete(self)) {
-
 			/* Wait for next status FIFO interrupt */
 			new_icr |= ICR_EFSFI;
 		} else {
@@ -1094,8 +1094,9 @@ static int w83977af_is_receiving(struct w83977af_ir *self)
 			status =  TRUE;
 		}
 		outb(set, iobase + SSR);
-	} else
+	} else {
 		status = (self->rx_buff.state != OUTSIDE_FRAME);
+	}
 
 	return status;
 }
@@ -1141,8 +1142,9 @@ static int w83977af_net_open(struct net_device *dev)
 	if (self->io.speed > 115200) {
 		outb(ICR_EFSFI, iobase + ICR);
 		w83977af_dma_receive(self);
-	} else
+	} else {
 		outb(ICR_ERBRI, iobase + ICR);
+	}
 
 	/* Restore bank register */
 	outb(set, iobase + SSR);
-- 
2.10.0.rc2.1.g053435c

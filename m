From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/8] irda: w83977af_ir: Neaten pointer comparisons
Date: Thu, 24 Nov 2016 11:10:31 -0800
Message-ID: <d5ef4e23d9a46ef476d14b1228d0c2af53a11ec4.1480014088.git.joe@perches.com>
References: <cover.1480014088.git.joe@perches.com>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1480014088.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert pointer comparisons to NULL.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/irda/w83977af_ir.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 5aa61413aea8..ac481303e3ab 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -168,7 +168,7 @@ static int w83977af_open(int i, unsigned int iobase, unsigned int irq,
 	 *  Allocate new instance of the driver
 	 */
 	dev = alloc_irdadev(sizeof(struct w83977af_ir));
-	if (dev == NULL) {
+	if (!dev) {
 		printk(KERN_ERR "IrDA: Can't allocate memory for "
 			"IrDA control block!\n");
 		err = -ENOMEM;
@@ -206,7 +206,7 @@ static int w83977af_open(int i, unsigned int iobase, unsigned int irq,
 	self->rx_buff.head =
 		dma_zalloc_coherent(NULL, self->rx_buff.truesize,
 				    &self->rx_buff_dma, GFP_KERNEL);
-	if (self->rx_buff.head == NULL) {
+	if (!self->rx_buff.head) {
 		err = -ENOMEM;
 		goto err_out1;
 	}
@@ -214,7 +214,7 @@ static int w83977af_open(int i, unsigned int iobase, unsigned int irq,
 	self->tx_buff.head =
 		dma_zalloc_coherent(NULL, self->tx_buff.truesize,
 				    &self->tx_buff_dma, GFP_KERNEL);
-	if (self->tx_buff.head == NULL) {
+	if (!self->tx_buff.head) {
 		err = -ENOMEM;
 		goto err_out2;
 	}
@@ -629,7 +629,7 @@ static void w83977af_dma_xmit_complete(struct w83977af_ir *self)
 
 	pr_debug("%s(%ld)\n", __func__, jiffies);
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 
 	iobase = self->io.fir_base;
 
@@ -680,7 +680,7 @@ static int w83977af_dma_receive(struct w83977af_ir *self)
 	unsigned long flags;
 	__u8 hcr;
 #endif
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 
 	pr_debug("%s\n", __func__);
 
@@ -818,7 +818,7 @@ static int w83977af_dma_receive_complete(struct w83977af_ir *self)
 			}
 
 			skb = dev_alloc_skb(len + 1);
-			if (skb == NULL)  {
+			if (!skb)  {
 				printk(KERN_INFO
 				       "%s(), memory squeeze, dropping frame.\n", __func__);
 				/* Restore set register */
@@ -870,7 +870,7 @@ static void w83977af_pio_receive(struct w83977af_ir *self)
 	__u8 byte = 0x00;
 	int iobase;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 
 	iobase = self->io.fir_base;
 
@@ -1081,7 +1081,7 @@ static int w83977af_is_receiving(struct w83977af_ir *self)
 	int iobase;
 	__u8 set;
 
-	IRDA_ASSERT(self != NULL, return FALSE;);
+	IRDA_ASSERT(self, return FALSE;);
 
 	if (self->io.speed > 115200) {
 		iobase = self->io.fir_base;
@@ -1113,10 +1113,10 @@ static int w83977af_net_open(struct net_device *dev)
 	char hwname[32];
 	__u8 set;
 
-	IRDA_ASSERT(dev != NULL, return -1;);
+	IRDA_ASSERT(dev, return -1;);
 	self = netdev_priv(dev);
 
-	IRDA_ASSERT(self != NULL, return 0;);
+	IRDA_ASSERT(self, return 0;);
 
 	iobase = self->io.fir_base;
 
@@ -1174,11 +1174,11 @@ static int w83977af_net_close(struct net_device *dev)
 	int iobase;
 	__u8 set;
 
-	IRDA_ASSERT(dev != NULL, return -1;);
+	IRDA_ASSERT(dev, return -1;);
 
 	self = netdev_priv(dev);
 
-	IRDA_ASSERT(self != NULL, return 0;);
+	IRDA_ASSERT(self, return 0;);
 
 	iobase = self->io.fir_base;
 
@@ -1221,11 +1221,11 @@ static int w83977af_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	unsigned long flags;
 	int ret = 0;
 
-	IRDA_ASSERT(dev != NULL, return -1;);
+	IRDA_ASSERT(dev, return -1;);
 
 	self = netdev_priv(dev);
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 
 	pr_debug("%s(), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
 
-- 
2.10.0.rc2.1.g053435c

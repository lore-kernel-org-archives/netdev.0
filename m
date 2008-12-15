From: Samuel Ortiz <samuel@sortiz.org>
Subject: [RFC PATCH 6/9] irda: Drivers should use irda_dev_alloc_skb() on the RX path
Date: Mon, 15 Dec 2008 02:57:35 +0100
Message-ID: <20081215015901.398765090@sortiz.org>
References: <20081215015729.587697008@sortiz.org>
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 42.mail-out.ovh.net ([213.251.189.42]:50848 "HELO
	42.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751717AbYLOCDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2008 21:03:12 -0500
Content-Disposition: inline; filename=0006-irda-Drivers-should-use-irda_dev_alloc_skb-on-the.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 drivers/net/irda/ali-ircc.c     |    2 +-
 drivers/net/irda/donauboe.c     |    2 +-
 drivers/net/irda/irda-usb.c     |   12 ++++++------
 drivers/net/irda/kingsun-sir.c  |    2 +-
 drivers/net/irda/ks959-sir.c    |    2 +-
 drivers/net/irda/ksdazzle-sir.c |    2 +-
 drivers/net/irda/mcs7780.c      |    6 +++---
 drivers/net/irda/nsc-ircc.c     |    2 +-
 drivers/net/irda/sir_dev.c      |    4 +++-
 drivers/net/irda/smsc-ircc2.c   |    2 +-
 drivers/net/irda/stir4200.c     |    6 +++---
 drivers/net/irda/via-ircc.c     |    8 ++++----
 drivers/net/irda/vlsi_ir.c      |    2 +-
 drivers/net/irda/w83977af_ir.c  |    2 +-
 14 files changed, 28 insertions(+), 26 deletions(-)

diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index 2ff1818..517e6b2 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -1904,7 +1904,7 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 			 */
 			do_gettimeofday(&self->stamp);
 
-			skb = dev_alloc_skb(len+1);
+			skb = irda_dev_alloc_skb(len+1);
 			if (skb == NULL)  
 			{
 				IRDA_WARNING("%s(), memory squeeze, "
diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index 1f0f9ee..b4f954e 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -1265,7 +1265,7 @@ dumpbufs(self->rx_bufs[self->rxs],len,'<');
 
               if (len)
                 {
-                  skb = dev_alloc_skb (len + 1);
+		  skb = irda_dev_alloc_skb(len + 1);
                   if (skb)
                     {
                       skb_reserve (skb, 1);
diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index f5c13af..0bfdcdf 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -890,12 +890,12 @@ static void irda_usb_receive(struct urb *urb)
 
 	/* Allocate a new skb */
 	if (self->capability & IUC_STIR421X)
-		newskb = dev_alloc_skb(docopy ? urb->actual_length :
-				       IRDA_SKB_MAX_MTU +
-				       USB_IRDA_STIR421X_HEADER);
+		newskb = irda_dev_alloc_skb(docopy ? urb->actual_length :
+					    IRDA_SKB_MAX_MTU +
+					    USB_IRDA_STIR421X_HEADER);
 	else
-		newskb = dev_alloc_skb(docopy ? urb->actual_length :
-				       IRDA_SKB_MAX_MTU);
+		newskb = irda_dev_alloc_skb(docopy ? urb->actual_length :
+					    IRDA_SKB_MAX_MTU);
 
 	if (!newskb)  {
 		self->stats.rx_dropped++;
@@ -1235,7 +1235,7 @@ static int irda_usb_net_open(struct net_device *netdev)
 	/* Now that we can pass data to IrLAP, allow the USB layer
 	 * to send us some data... */
 	for (i = 0; i < IU_MAX_ACTIVE_RX_URBS; i++) {
-		struct sk_buff *skb = dev_alloc_skb(IRDA_SKB_MAX_MTU);
+		struct sk_buff *skb = irda_dev_alloc_skb(IRDA_SKB_MAX_MTU);
 		if (!skb) {
 			/* If this ever happen, we are in deep s***.
 			 * Basically, we can't start the Rx path... */
diff --git a/drivers/net/irda/kingsun-sir.c b/drivers/net/irda/kingsun-sir.c
index e1429fc..47ba0a9 100644
--- a/drivers/net/irda/kingsun-sir.c
+++ b/drivers/net/irda/kingsun-sir.c
@@ -267,7 +267,7 @@ static int kingsun_net_open(struct net_device *netdev)
 	kingsun->rx_buff.in_frame = FALSE;
 	kingsun->rx_buff.state = OUTSIDE_FRAME;
 	kingsun->rx_buff.truesize = IRDA_SKB_MAX_MTU;
-	kingsun->rx_buff.skb = dev_alloc_skb(IRDA_SKB_MAX_MTU);
+	kingsun->rx_buff.skb = irda_dev_alloc_skb(IRDA_SKB_MAX_MTU);
 	if (!kingsun->rx_buff.skb)
 		goto free_mem;
 
diff --git a/drivers/net/irda/ks959-sir.c b/drivers/net/irda/ks959-sir.c
index 2e67ae0..97f49ed 100644
--- a/drivers/net/irda/ks959-sir.c
+++ b/drivers/net/irda/ks959-sir.c
@@ -507,7 +507,7 @@ static int ks959_net_open(struct net_device *netdev)
 	kingsun->rx_unwrap_buff.in_frame = FALSE;
 	kingsun->rx_unwrap_buff.state = OUTSIDE_FRAME;
 	kingsun->rx_unwrap_buff.truesize = IRDA_SKB_MAX_MTU;
-	kingsun->rx_unwrap_buff.skb = dev_alloc_skb(IRDA_SKB_MAX_MTU);
+	kingsun->rx_unwrap_buff.skb = irda_dev_alloc_skb(IRDA_SKB_MAX_MTU);
 	if (!kingsun->rx_unwrap_buff.skb)
 		goto free_mem;
 
diff --git a/drivers/net/irda/ksdazzle-sir.c b/drivers/net/irda/ksdazzle-sir.c
index 3843b5f..e747c59 100644
--- a/drivers/net/irda/ksdazzle-sir.c
+++ b/drivers/net/irda/ksdazzle-sir.c
@@ -401,7 +401,7 @@ static int ksdazzle_net_open(struct net_device *netdev)
 	kingsun->rx_unwrap_buff.in_frame = FALSE;
 	kingsun->rx_unwrap_buff.state = OUTSIDE_FRAME;
 	kingsun->rx_unwrap_buff.truesize = IRDA_SKB_MAX_MTU;
-	kingsun->rx_unwrap_buff.skb = dev_alloc_skb(IRDA_SKB_MAX_MTU);
+	kingsun->rx_unwrap_buff.skb = irda_dev_alloc_skb(IRDA_SKB_MAX_MTU);
 	if (!kingsun->rx_unwrap_buff.skb)
 		goto free_mem;
 
diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index ad92d3f..9776f41 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -418,7 +418,7 @@ static void mcs_unwrap_mir(struct mcs_cb *mcs, __u8 *buf, int len)
 		return;
 	}
 
-	skb = dev_alloc_skb(new_len + 1);
+	skb = irda_dev_alloc_skb(new_len + 1);
 	if(unlikely(!skb)) {
 		++mcs->stats.rx_dropped;
 		return;
@@ -471,7 +471,7 @@ static void mcs_unwrap_fir(struct mcs_cb *mcs, __u8 *buf, int len)
 		return;
 	}
 
-	skb = dev_alloc_skb(new_len + 1);
+	skb = irda_dev_alloc_skb(new_len + 1);
 	if(unlikely(!skb)) {
 		++mcs->stats.rx_dropped;
 		return;
@@ -718,7 +718,7 @@ static int mcs_net_open(struct net_device *netdev)
 	/* Initialize for SIR/FIR to copy data directly into skb.  */
 	mcs->receiving = 0;
 	mcs->rx_buff.truesize = IRDA_SKB_MAX_MTU;
-	mcs->rx_buff.skb = dev_alloc_skb(IRDA_SKB_MAX_MTU);
+	mcs->rx_buff.skb = irda_dev_alloc_skb(IRDA_SKB_MAX_MTU);
 	if (!mcs->rx_buff.skb)
 		goto error1;
 
diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index 8583d95..05f53ca 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -1858,7 +1858,7 @@ static int nsc_ircc_dma_receive_complete(struct nsc_ircc_cb *self, int iobase)
 			 */
 			do_gettimeofday(&self->stamp);
 
-			skb = dev_alloc_skb(len+1);
+			skb = irda_dev_alloc_skb(len+1);
 			if (skb == NULL)  {
 				IRDA_WARNING("%s(), memory squeeze, "
 					     "dropping frame.\n",
diff --git a/drivers/net/irda/sir_dev.c b/drivers/net/irda/sir_dev.c
index 3f32909..3ca64e8 100644
--- a/drivers/net/irda/sir_dev.c
+++ b/drivers/net/irda/sir_dev.c
@@ -760,7 +760,9 @@ static int sirdev_alloc_buffers(struct sir_dev *dev)
 	dev->rx_buff.truesize = IRDA_SKB_MAX_MTU; 
 
 	/* Bootstrap ZeroCopy Rx */
-	dev->rx_buff.skb = __dev_alloc_skb(dev->rx_buff.truesize, GFP_KERNEL);
+	dev->rx_buff.skb = __dev_alloc_skb(dev->rx_buff.truesize +
+					   sizeof(struct irda_skb_cb),
+					   GFP_KERNEL);
 	if (dev->rx_buff.skb == NULL)
 		return -ENOMEM;
 	skb_reserve(dev->rx_buff.skb, 1);
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index b5360fe..f13c79e 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -1450,7 +1450,7 @@ static void smsc_ircc_dma_receive_complete(struct smsc_ircc_cb *self)
 	}
 	IRDA_DEBUG(2, "%s: msgcnt = %d, len=%d\n", __func__, msgcnt, len);
 
-	skb = dev_alloc_skb(len + 1);
+	skb = irda_dev_alloc_skb(len + 1);
 	if (!skb) {
 		IRDA_WARNING("%s(), memory squeeze, dropping frame.\n",
 			     __func__);
diff --git a/drivers/net/irda/stir4200.c b/drivers/net/irda/stir4200.c
index 3575804..f0edc00 100644
--- a/drivers/net/irda/stir4200.c
+++ b/drivers/net/irda/stir4200.c
@@ -338,7 +338,7 @@ static void fir_eof(struct stir_cb *stir)
 
 	/* if frame is short then just copy it */
 	if (len < IRDA_RX_COPY_THRESHOLD) {
-		nskb = dev_alloc_skb(len + 1);
+		nskb = irda_dev_alloc_skb(len + 1);
 		if (unlikely(!nskb)) {
 			++stir->stats.rx_dropped;
 			return;
@@ -347,7 +347,7 @@ static void fir_eof(struct stir_cb *stir)
 		skb = nskb;
 		skb_copy_to_linear_data(nskb, rx_buff->data, len);
 	} else {
-		nskb = dev_alloc_skb(rx_buff->truesize);
+		nskb = irda_dev_alloc_skb(rx_buff->truesize);
 		if (unlikely(!nskb)) {
 			++stir->stats.rx_dropped;
 			return;
@@ -871,7 +871,7 @@ static int stir_net_open(struct net_device *netdev)
 	/* Initialize for SIR/FIR to copy data directly into skb.  */
 	stir->receiving = 0;
 	stir->rx_buff.truesize = IRDA_SKB_MAX_MTU;
-	stir->rx_buff.skb = dev_alloc_skb(IRDA_SKB_MAX_MTU);
+	stir->rx_buff.skb = irda_dev_alloc_skb(IRDA_SKB_MAX_MTU);
 	if (!stir->rx_buff.skb) 
 		goto err_out1;
 
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 84e609e..8784215 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -1101,7 +1101,7 @@ static int via_ircc_dma_receive_complete(struct via_ircc_cb *self,
 
 	if (self->io.speed < 4000000) {	//Speed below FIR
 		len = GetRecvByte(iobase, self);
-		skb = dev_alloc_skb(len + 1);
+		skb = irda_dev_alloc_skb(len + 1);
 		if (skb == NULL)
 			return FALSE;
 		// Make sure IP header gets aligned 
@@ -1173,7 +1173,7 @@ F01_E */
 		st_fifo->head++;
 		st_fifo->len--;
 
-		skb = dev_alloc_skb(len + 1 - 4);
+		skb = irda_dev_alloc_skb(len + 1 - 4);
 		/*
 		 * if frame size,data ptr,or skb ptr are wrong ,the get next
 		 * entry.
@@ -1224,7 +1224,7 @@ static int upload_rxdata(struct via_ircc_cb *self, int iobase)
 		return FALSE;
 	}
 
-	skb = dev_alloc_skb(len + 1);
+	skb = irda_dev_alloc_skb(len + 1);
 	if (skb == NULL) {
 		self->stats.rx_dropped++;
 		return FALSE;
@@ -1288,7 +1288,7 @@ static int RxTimerHandler(struct via_ircc_cb *self, int iobase)
 			st_fifo->head++;
 			st_fifo->len--;
 
-			skb = dev_alloc_skb(len + 1 - 4);
+			skb = irda_dev_alloc_skb(len + 1 - 4);
 			/*
 			 * if frame size, data ptr, or skb ptr are wrong,
 			 * then get next entry.
diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index 9c926d2..162872e 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -622,7 +622,7 @@ static void vlsi_fill_rx(struct vlsi_ring *r)
 			break;
 		}
 		if (!rd->skb) {
-			rd->skb = dev_alloc_skb(IRLAP_SKB_ALLOCSIZE);
+			rd->skb = irda_dev_alloc_skb(IRLAP_SKB_ALLOCSIZE);
 			if (rd->skb) {
 				skb_reserve(rd->skb,1);
 				rd->skb->protocol = htons(ETH_P_IRDA);
diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 002a6d7..a3a44c7 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -889,7 +889,7 @@ int w83977af_dma_receive_complete(struct w83977af_ir *self)
 #endif
 			}
 						
-			skb = dev_alloc_skb(len+1);
+			skb = irda_dev_alloc_skb(len+1);
 			if (skb == NULL)  {
 				printk(KERN_INFO
 				       "%s(), memory squeeze, dropping frame.\n", __func__);
-- 
1.6.0.4.766.g6fc4a.dirty

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
